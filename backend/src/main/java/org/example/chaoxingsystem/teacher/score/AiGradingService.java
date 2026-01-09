package org.example.chaoxingsystem.teacher.score;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

@Service
public class AiGradingService {
  private static final Logger log = LoggerFactory.getLogger(AiGradingService.class);

  @Value("${ai.deepseek.api-key:}")
  private String apiKey;

  @Value("${ai.deepseek.api-url:https://api.deepseek.com/chat/completions}")
  private String apiUrl;

  @Value("${ai.deepseek.model:deepseek-chat}")
  private String model;

  private final ObjectMapper objectMapper = new ObjectMapper();

  public Map<String, Object> grade(String question, String studentAnswer, String correctAnswer, Integer fullScore, String questionType) {
    if (apiKey == null || apiKey.trim().isEmpty()) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "AI API key is not configured");
    }
    int maxScore = fullScore != null ? fullScore : 0;
    String systemPrompt = buildSystemPrompt(maxScore);
    String userPrompt = buildUserPrompt(question, studentAnswer, correctAnswer, maxScore, questionType);
    String response = callAi(systemPrompt, userPrompt);
    return parseAiResult(response, maxScore);
  }

  private String buildSystemPrompt(int maxScore) {
    return "你是严格的阅卷老师，根据题目、学生答案和参考答案给分。\n" +
      "评分要求：\n" +
      "1. 分数范围为 0-" + maxScore + "，允许小数。\n" +
      "2. 给出一句简短评语。\n" +
      "3. 只返回 JSON，格式：{\"score\": 分数, \"comment\": \"评语\"}\n";
  }

  private String buildUserPrompt(String question, String studentAnswer, String correctAnswer, int maxScore, String questionType) {
    String type = questionType == null ? "" : questionType;
    StringBuilder sb = new StringBuilder();
    sb.append("题型：").append(type).append("\n");
    sb.append("题目：\n").append(question == null ? "" : question).append("\n");
    if (correctAnswer != null && !correctAnswer.isBlank()) {
      sb.append("参考答案：\n").append(correctAnswer).append("\n");
    }
    sb.append("学生答案：\n").append(studentAnswer == null ? "" : studentAnswer).append("\n");
    sb.append("满分：").append(maxScore).append("\n");
    return sb.toString();
  }

  private String callAi(String systemPrompt, String userPrompt) {
    HttpURLConnection conn = null;
    try {
      URL url = new URL(apiUrl);
      conn = (HttpURLConnection) url.openConnection();
      conn.setRequestMethod("POST");
      conn.setRequestProperty("Content-Type", "application/json");
      conn.setRequestProperty("Authorization", "Bearer " + apiKey);
      conn.setDoOutput(true);
      conn.setConnectTimeout(30000);
      conn.setReadTimeout(120000);

      String requestBody = buildRequestBody(systemPrompt, userPrompt);
      try (OutputStream os = conn.getOutputStream()) {
        os.write(requestBody.getBytes(StandardCharsets.UTF_8));
      }

      int responseCode = conn.getResponseCode();
      if (responseCode != 200) {
        throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "AI service error: " + responseCode);
      }

      StringBuilder response = new StringBuilder();
      try (BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
        String line;
        while ((line = reader.readLine()) != null) {
          response.append(line);
        }
      }
      return extractMessageContent(response.toString());
    } catch (Exception e) {
      log.error("AI grading error", e);
      throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "AI service unavailable");
    } finally {
      if (conn != null) conn.disconnect();
    }
  }

  private String buildRequestBody(String systemPrompt, String userPrompt) {
    String messagesJson = "[" +
      "{\"role\":\"system\",\"content\":" + escapeJson(systemPrompt) + "}," +
      "{\"role\":\"user\",\"content\":" + escapeJson(userPrompt) + "}" +
      "]";
    return "{" +
      "\"model\":\"" + model + "\"," +
      "\"messages\":" + messagesJson + "," +
      "\"stream\":false," +
      "\"temperature\":0.2," +
      "\"max_tokens\":512" +
      "}";
  }

  private String escapeJson(String str) {
    if (str == null) return "\"\"";
    return "\"" + str
      .replace("\\", "\\\\")
      .replace("\"", "\\\"")
      .replace("\n", "\\n")
      .replace("\r", "\\r")
      .replace("\t", "\\t")
      + "\"";
  }

  private String extractMessageContent(String json) {
    int contentStart = json.indexOf("\"content\":\"");
    if (contentStart == -1) return "";
    contentStart += 11;
    int contentEnd = contentStart;
    while (contentEnd < json.length()) {
      char c = json.charAt(contentEnd);
      if (c == '\\') {
        contentEnd += 2;
      } else if (c == '"') {
        break;
      } else {
        contentEnd++;
      }
    }
    String content = json.substring(contentStart, contentEnd);
    return content
      .replace("\\n", "\n")
      .replace("\\r", "\r")
      .replace("\\t", "\t")
      .replace("\\\"", "\"")
      .replace("\\\\", "\\");
  }

  private Map<String, Object> parseAiResult(String raw, int maxScore) {
    Map<String, Object> fallback = new HashMap<>();
    fallback.put("score", 0);
    fallback.put("comment", "AI解析失败");
    if (raw == null || raw.isBlank()) {
      return fallback;
    }
    String trimmed = raw.trim();
    int start = trimmed.indexOf('{');
    int end = trimmed.lastIndexOf('}');
    if (start >= 0 && end > start) {
      trimmed = trimmed.substring(start, end + 1);
    }
    try {
      Map<String, Object> parsed = objectMapper.readValue(trimmed, new TypeReference<Map<String, Object>>() {});
      Object scoreObj = parsed.get("score");
      double score = 0;
      if (scoreObj instanceof Number) {
        score = ((Number) scoreObj).doubleValue();
      } else if (scoreObj != null) {
        try { score = Double.parseDouble(String.valueOf(scoreObj)); } catch (Exception ignored) {}
      }
      if (score < 0) score = 0;
      if (score > maxScore) score = maxScore;
      String comment = parsed.get("comment") != null ? String.valueOf(parsed.get("comment")) : "";
      Map<String, Object> out = new HashMap<>();
      out.put("score", Math.round(score * 2.0) / 2.0);
      out.put("comment", comment);
      out.put("raw", raw);
      return out;
    } catch (Exception e) {
      log.warn("AI grading parse failed: {}", e.getMessage());
      return fallback;
    }
  }
}
