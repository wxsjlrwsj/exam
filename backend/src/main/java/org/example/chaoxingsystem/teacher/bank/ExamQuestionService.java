package org.example.chaoxingsystem.teacher.bank;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
public class ExamQuestionService {
  private final ExamQuestionMapper examQuestionMapper;
  private final QuestionTypeMapper typeMapper;
  private final ObjectMapper objectMapper = new ObjectMapper();

  public ExamQuestionService(ExamQuestionMapper examQuestionMapper, QuestionTypeMapper typeMapper) {
    this.examQuestionMapper = examQuestionMapper;
    this.typeMapper = typeMapper;
  }

  public long count(String typeCode, String keyword, Integer difficulty, String subject) {
    return examQuestionMapper.count(typeCode, keyword, difficulty, subject);
  }

  public List<Question> page(String typeCode, String keyword, Integer difficulty, String subject, int page, int size) {
    int offset = (Math.max(page, 1) - 1) * Math.max(size, 1);
    return examQuestionMapper.selectPage(typeCode, keyword, difficulty, subject, offset, size);
  }

  @Transactional
  public Long create(Long creatorId, String typeCode, String content, String optionsJson, String answerJson, Integer difficulty, String subject, String knowledgePoints, String fileId) {
    String normalizedCode = normalizeTypeCode(typeCode);
    QuestionType type = typeMapper.selectByCode(normalizedCode);
    if (type == null || type.getIsActive() == null || type.getIsActive() == 0) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "题型无效或未启用");
    }
    validateAnswer(answerJson);
    Question q = new Question();
    q.setTypeId(type.getTypeId());
    q.setContent(content);
    q.setOptions(optionsJson);
    q.setAnswer(answerJson);
    q.setDifficulty(difficulty);
    q.setSubject(subject);
    q.setKnowledgePoints(knowledgePoints);
    q.setFileId(fileId);
    q.setCreatorId(creatorId);
    q.setStatus(1);
    examQuestionMapper.insert(q);
    return q.getId();
  }

  @Transactional
  public void update(UpdateCommand cmd) {
    Question exist = examQuestionMapper.selectById(cmd.id);
    if (exist == null) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "题目不存在");
    Integer typeId = exist.getTypeId();
    if (cmd.typeCode != null && !cmd.typeCode.isEmpty()) {
      String normalizedCode = normalizeTypeCode(cmd.typeCode);
      QuestionType type = typeMapper.selectByCode(normalizedCode);
      if (type == null || type.getIsActive() == null || type.getIsActive() == 0) {
        throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "题型无效或未启用");
      }
      typeId = type.getTypeId();
    }
    if (cmd.answerJson != null) {
      validateAnswer(cmd.answerJson);
    }
    Question q = new Question();
    q.setId(cmd.id);
    q.setTypeId(typeId);
    q.setContent(cmd.content != null ? cmd.content : exist.getContent());
    q.setOptions(cmd.optionsJson != null ? cmd.optionsJson : exist.getOptions());
    q.setAnswer(cmd.answerJson != null ? cmd.answerJson : exist.getAnswer());
    q.setAnalysis(cmd.analysis != null ? cmd.analysis : exist.getAnalysis());
    q.setDifficulty(cmd.difficulty != null ? cmd.difficulty : exist.getDifficulty());
    q.setSubject(cmd.subject != null ? cmd.subject : exist.getSubject());
    q.setKnowledgePoints(cmd.knowledgePoints != null ? cmd.knowledgePoints : exist.getKnowledgePoints());
    if (cmd.useFile != null && !cmd.useFile) {
      q.setFileId(null);
    } else {
      q.setFileId(cmd.fileId != null ? cmd.fileId : exist.getFileId());
    }
    q.setStatus(cmd.status != null ? cmd.status : exist.getStatus());
    examQuestionMapper.updateById(q);
  }

  @Transactional
  public void delete(Long id) {
    examQuestionMapper.deleteById(id);
  }

  private void validateAnswer(String answerJson) {
    if (answerJson == null || answerJson.isEmpty()) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "答案不能为空");
    }
    try {
      objectMapper.readTree(answerJson);
    } catch (Exception ex) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "答案结构不合法");
    }
  }

  private String normalizeTypeCode(String typeCode) {
    if (typeCode == null) return null;
    String code = typeCode.trim();
    return switch (code) {
      case "single_choice" -> "SINGLE";
      case "multiple_choice" -> "MULTI";
      case "true_false" -> "TRUE_FALSE";
      case "fill_blank" -> "FILL";
      case "short_answer" -> "SHORT";
      case "programming" -> "PROGRAM";
      default -> code;
    };
  }

  public static class UpdateCommand {
    public Long id;
    public String typeCode;
    public String content;
    public String optionsJson;
    public String answerJson;
    public String analysis;
    public Integer difficulty;
    public String subject;
    public String knowledgePoints;
    public String fileId;
    public Integer status;
    public Boolean useFile;
  }
}
