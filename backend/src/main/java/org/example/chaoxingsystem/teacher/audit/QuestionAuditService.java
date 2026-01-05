package org.example.chaoxingsystem.teacher.audit;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.example.chaoxingsystem.teacher.bank.Question;
import org.example.chaoxingsystem.teacher.bank.QuestionMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 题目审核领域服务：列表统计/分页、详情查询、批量处理
 */
@Service
public class QuestionAuditService {
  private final QuestionAuditMapper mapper;
  private final QuestionMapper questionMapper;
  private final ObjectMapper objectMapper = new ObjectMapper();

  public QuestionAuditService(QuestionAuditMapper mapper, QuestionMapper questionMapper) {
    this.mapper = mapper;
    this.questionMapper = questionMapper;
  }

  public long count(Integer status, Long subjectId, String submitterName, String beginTime, String endTime) {
    return mapper.count(status, subjectId, submitterName, beginTime, endTime);
  }

  public List<QuestionAuditListRow> page(Integer status, Long subjectId, String submitterName, String beginTime, String endTime, int pageNum, int pageSize) {
    int offset = (Math.max(pageNum, 1) - 1) * Math.max(pageSize, 1);
    return mapper.selectPage(status, subjectId, submitterName, beginTime, endTime, offset, pageSize);
  }

  public QuestionAuditDetail detail(Long id) {
    return mapper.selectDetail(id);
  }

  @Transactional
  public int process(List<Long> ids, Integer status, String comment, Long auditorId) {
    if (ids == null || ids.isEmpty()) return 0;
    if (status == null || (status != 1 && status != 2)) return 0;
    List<QuestionAuditDetail> pending = null;
    if (status == 1) {
      pending = mapper.selectPendingDetailsForProcess(ids);
    }
    int affected = mapper.processBatch(ids, status, comment, auditorId);
    if (status == 1 && pending != null && !pending.isEmpty()) {
      for (QuestionAuditDetail d : pending) {
        Question q = toQuestion(d);
        questionMapper.insert(q);
        mapper.updateQuestionId(d.getId(), q.getId());
      }
    }
    return affected;
  }

  private Question toQuestion(QuestionAuditDetail d) {
    String stem = d.getContent();
    String optionsJson = null;
    String analysis = null;
    String subject = d.getSubjectName();
    if (stem != null && stem.trim().startsWith("{")) {
      try {
        JsonNode node = objectMapper.readTree(stem);
        if (node != null && node.isObject()) {
          if (node.hasNonNull("stem")) {
            stem = node.get("stem").asText();
          }
          if (node.hasNonNull("options")) {
            optionsJson = objectMapper.writeValueAsString(node.get("options"));
          }
          if (node.hasNonNull("analysis")) {
            analysis = node.get("analysis").asText();
          }
          if ((subject == null || subject.isBlank()) && node.hasNonNull("subject")) {
            subject = node.get("subject").asText();
          }
        }
      } catch (Exception ignored) {
      }
    }

    String answerJson = normalizeJson(d.getAnswer());
    Integer difficulty = d.getDifficulty() != null ? d.getDifficulty() : 1;
    String subjectValue = (subject == null || subject.isBlank()) ? "未分类" : subject;

    Question q = new Question();
    q.setTypeId(d.getTypeId());
    q.setContent(stem != null ? stem : "");
    q.setOptions(optionsJson);
    q.setAnswer(answerJson);
    q.setAnalysis(analysis);
    q.setDifficulty(difficulty);
    q.setSubject(subjectValue);
    q.setCreatorId(d.getSubmitterId());
    q.setStatus(1);
    return q;
  }

  private String normalizeJson(String raw) {
    if (raw == null) return "null";
    try {
      objectMapper.readTree(raw);
      return raw;
    } catch (Exception ignored) {
    }
    try {
      return objectMapper.writeValueAsString(raw);
    } catch (Exception ex) {
      return "\"" + raw.replace("\"", "\\\"") + "\"";
    }
  }
}
