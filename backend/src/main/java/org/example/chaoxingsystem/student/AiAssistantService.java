package org.example.chaoxingsystem.student;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * AI辅助解题服务
 * 调用DeepSeek API实现智能解题辅助
 */
@Service
public class AiAssistantService {

    private static final Logger log = LoggerFactory.getLogger(AiAssistantService.class);

    @Value("${ai.deepseek.api-key:sk-b78603dc052244768e98c5ccd8be7ebb}")
    private String apiKey;

    @Value("${ai.deepseek.api-url:https://api.deepseek.com/chat/completions}")
    private String apiUrl;

    @Value("${ai.deepseek.model:deepseek-chat}")
    private String model;

    private final ExecutorService executor = Executors.newCachedThreadPool();

    /**
     * 构建系统提示词
     */
    private String buildSystemPrompt(String question) {
        return "你是一个专业的学习辅导助手，专门帮助学生理解和解答题目。\n\n" +
               "当前学生正在做的题目是：\n" +
               "---\n" +
               question +
               "\n---\n\n" +
               "请根据学生的问题，提供详细、清晰的解答和指导。\n" +
               "注意事项：\n" +
               "1. 不要直接给出答案，而是引导学生思考\n" +
               "2. 解释相关的知识点和概念\n" +
               "3. 提供解题思路和方法\n" +
               "4. 如果学生明确要求答案，可以给出并详细解释\n" +
               "5. 使用简洁明了的语言，适合学生理解\n" +
               "6. 可以使用Markdown格式来组织回答";
    }

    /**
     * 流式聊天
     */
    public SseEmitter chatStream(String question, String message, String history) {
        SseEmitter emitter = new SseEmitter(120000L); // 2分钟超时

        executor.execute(() -> {
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

                // 构建请求体
                String systemPrompt = buildSystemPrompt(question);
                String requestBody = buildRequestBody(systemPrompt, message, history, true);

                try (OutputStream os = conn.getOutputStream()) {
                    os.write(requestBody.getBytes(StandardCharsets.UTF_8));
                }

                int responseCode = conn.getResponseCode();
                if (responseCode == 200) {
                    try (BufferedReader reader = new BufferedReader(
                            new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
                        String line;
                        while ((line = reader.readLine()) != null) {
                            if (line.startsWith("data: ")) {
                                String data = line.substring(6).trim();
                                if ("[DONE]".equals(data)) {
                                    emitter.send(SseEmitter.event().data("[DONE]"));
                                    break;
                                }
                                // 解析JSON获取content
                                String content = extractContent(data);
                                if (content != null && !content.isEmpty()) {
                                    // 直接发送内容块，让前端处理打字机效果
                                    emitter.send(SseEmitter.event().data(content));
                                }
                            }
                        }
                    }
                } else {
                    String errorMsg = "API调用失败: " + responseCode;
                    log.error(errorMsg);
                    try (BufferedReader errorReader = new BufferedReader(
                            new InputStreamReader(conn.getErrorStream(), StandardCharsets.UTF_8))) {
                        StringBuilder errorResponse = new StringBuilder();
                        String line;
                        while ((line = errorReader.readLine()) != null) {
                            errorResponse.append(line);
                        }
                        log.error("API错误响应: {}", errorResponse);
                    } catch (Exception e) {
                        log.error("读取错误响应失败", e);
                    }
                    emitter.send(SseEmitter.event().data("抱歉，AI服务暂时不可用，请稍后重试。"));
                }
                emitter.complete();
            } catch (Exception e) {
                log.error("AI流式聊天异常", e);
                try {
                    emitter.send(SseEmitter.event().data("抱歉，发生了错误：" + e.getMessage()));
                    emitter.complete();
                } catch (Exception ex) {
                    emitter.completeWithError(ex);
                }
            } finally {
                if (conn != null) {
                    conn.disconnect();
                }
            }
        });

        emitter.onTimeout(() -> {
            log.warn("SSE连接超时");
            emitter.complete();
        });

        emitter.onError(e -> {
            log.error("SSE连接错误", e);
        });

        return emitter;
    }

    /**
     * 非流式聊天
     */
    public String chat(String question, String message, String history) {
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

            String systemPrompt = buildSystemPrompt(question);
            String requestBody = buildRequestBody(systemPrompt, message, history, false);

            try (OutputStream os = conn.getOutputStream()) {
                os.write(requestBody.getBytes(StandardCharsets.UTF_8));
            }

            int responseCode = conn.getResponseCode();
            if (responseCode == 200) {
                try (BufferedReader reader = new BufferedReader(
                        new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
                    StringBuilder response = new StringBuilder();
                    String line;
                    while ((line = reader.readLine()) != null) {
                        response.append(line);
                    }
                    return extractMessageContent(response.toString());
                }
            } else {
                log.error("API调用失败: {}", responseCode);
                return "抱歉，AI服务暂时不可用，请稍后重试。";
            }
        } catch (Exception e) {
            log.error("AI聊天异常", e);
            return "抱歉，发生了错误：" + e.getMessage();
        } finally {
            if (conn != null) {
                conn.disconnect();
            }
        }
    }

    /**
     * 构建请求体
     */
    private String buildRequestBody(String systemPrompt, String message, String history, boolean stream) {
        StringBuilder messagesJson = new StringBuilder();
        messagesJson.append("[");
        messagesJson.append("{\"role\":\"system\",\"content\":").append(escapeJson(systemPrompt)).append("}");
        
        // 添加历史消息
        if (history != null && !history.isEmpty()) {
            messagesJson.append(",").append(history);
        }
        
        // 添加当前用户消息
        messagesJson.append(",{\"role\":\"user\",\"content\":").append(escapeJson(message)).append("}");
        messagesJson.append("]");

        return "{" +
               "\"model\":\"" + model + "\"," +
               "\"messages\":" + messagesJson + "," +
               "\"stream\":" + stream + "," +
               "\"temperature\":0.7," +
               "\"max_tokens\":2048" +
               "}";
    }

    /**
     * JSON字符串转义
     */
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

    /**
     * 从流式响应中提取content
     * 优化：更精确的JSON解析，支持更复杂的转义字符
     */
    private String extractContent(String json) {
        try {
            // 简单解析: {"choices":[{"delta":{"content":"xxx"}}]}
            int contentStart = json.indexOf("\"content\":\"");
            if (contentStart == -1) return null;
            contentStart += 11;
            
            // 找到对应的结束引号（考虑转义）
            StringBuilder content = new StringBuilder();
            boolean escaped = false;
            for (int i = contentStart; i < json.length(); i++) {
                char c = json.charAt(i);
                if (escaped) {
                    // 处理转义字符
                    switch (c) {
                        case 'n': content.append('\n'); break;
                        case 'r': content.append('\r'); break;
                        case 't': content.append('\t'); break;
                        case '"': content.append('"'); break;
                        case '\\': content.append('\\'); break;
                        default: content.append(c);
                    }
                    escaped = false;
                } else if (c == '\\') {
                    escaped = true;
                } else if (c == '"') {
                    break;
                } else {
                    content.append(c);
                }
            }
            return content.toString();
        } catch (Exception e) {
            log.error("解析流式响应失败", e);
            return null;
        }
    }

    /**
     * 从非流式响应中提取message content
     */
    private String extractMessageContent(String json) {
        try {
            // 简单解析: {"choices":[{"message":{"content":"xxx"}}]}
            int contentStart = json.indexOf("\"content\":\"");
            if (contentStart == -1) return "解析响应失败";
            contentStart += 11;
            
            // 找到对应的结束引号（考虑转义）
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
        } catch (Exception e) {
            log.error("解析响应失败", e);
            return "解析响应失败";
        }
    }
}
