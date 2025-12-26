package org.example.chaoxingsystem.teacher.paper;

import org.example.chaoxingsystem.teacher.bank.Question;
import org.example.chaoxingsystem.teacher.bank.QuestionMapper;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** 试卷服务：分页、组卷、智能组卷 */
@Service
public class PaperService {
  private final PaperMapper paperMapper;
  private final QuestionMapper questionMapper;

  public PaperService(PaperMapper paperMapper, QuestionMapper questionMapper) {
    this.paperMapper = paperMapper;
    this.questionMapper = questionMapper;
  }

  public long count(String subject) {
    return paperMapper.count(subject);
  }

  public List<Paper> page(String subject, int page, int size) {
    int offset = (Math.max(page, 1) - 1) * Math.max(size, 1);
    return paperMapper.selectPage(subject, offset, size);
  }

  @Transactional
  public Long create(Long creatorId, String name, String subject, List<QuestionItem> items, Integer passScore) {
    if (items == null || items.isEmpty()) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "试题不能为空");
    int totalScore = items.stream().mapToInt(i -> i.score).sum();
    Paper p = new Paper();
    p.setName(name);
    p.setSubject(subject);
    p.setTotalScore(totalScore);
    p.setPassScore(passScore != null ? passScore : Math.max(60, (int)Math.round(totalScore * 0.6)));
    p.setQuestionCount(items.size());
    p.setStatus(0);
    p.setCreatorId(creatorId);
    paperMapper.insert(p);
    List<PaperQuestion> rels = new ArrayList<>();
    int order = 1;
    for (QuestionItem i : items) {
      PaperQuestion r = new PaperQuestion();
      r.setQuestionId(i.id);
      r.setScore(i.score);
      r.setSortOrder(order++);
      rels.add(r);
    }
    paperMapper.deletePaperQuestions(p.getId());
    paperMapper.insertPaperQuestions(p.getId(), rels);
    return p.getId();
  }

  @Transactional
  public Long autoGenerate(Long creatorId, String subject, Integer difficulty, Integer totalScore, Map<String, Integer> typeDistribution) {
    if (subject == null || subject.isEmpty()) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "科目必填");
    if (totalScore == null || totalScore <= 0) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "总分无效");
    List<QuestionItem> items = new ArrayList<>();
    int accumulated = 0;
    for (Map.Entry<String, Integer> e : typeDistribution.entrySet()) {
      String typeCode = e.getKey();
      int countNeed = e.getValue();
      List<Question> qs = questionMapper.selectByTypeSubjectDifficultyLimit(typeCode, subject, difficulty, countNeed);
      for (Question q : qs) {
        int scoreEach = Math.max(1, totalScore / Math.max(1, typeDistribution.values().stream().mapToInt(Integer::intValue).sum()));
        items.add(new QuestionItem(q.getId(), scoreEach));
        accumulated += scoreEach;
      }
    }
    if (items.isEmpty()) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "题库不足，无法组卷");
    // 调整最后一题以满足总分
    if (accumulated != totalScore) {
      int diff = totalScore - accumulated;
      QuestionItem last = items.get(items.size() - 1);
      last.score += diff;
    }
    String name = subject + "智能组卷";
    return create(creatorId, name, subject, items, null);
  }

  public Map<String, Object> getDetail(Long id) {
    Paper paper = paperMapper.selectById(id);
    if (paper == null) {
      throw new ResponseStatusException(HttpStatus.NOT_FOUND, "试卷不存在");
    }
    
    // 获取试卷题目列表
    List<Map<String, Object>> questions = paperMapper.selectPaperQuestionViews(id);
    
    Map<String, Object> data = new HashMap<>();
    data.put("id", paper.getId());
    data.put("name", paper.getName());
    data.put("subject", paper.getSubject());
    data.put("totalScore", paper.getTotalScore());
    data.put("passScore", paper.getPassScore());
    data.put("questionCount", paper.getQuestionCount());
    data.put("status", getStatusText(paper.getStatus()));
    data.put("creatorId", paper.getCreatorId());
    data.put("createTime", paper.getCreateTime());
    data.put("questions", questions);
    
    return data;
  }

  @Transactional
  public void delete(Long id) {
    Paper paper = paperMapper.selectById(id);
    if (paper == null) {
      throw new ResponseStatusException(HttpStatus.NOT_FOUND, "试卷不存在");
    }
    
    // 只能删除未被使用的试卷
    if (paper.getStatus() != 0) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "已被使用的试卷不能删除");
    }
    
    // 检查是否有考试使用该试卷
    long examCount = paperMapper.countExamsByPaperId(id);
    if (examCount > 0) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "已被考试使用的试卷不能删除");
    }
    
    // 删除试卷题目关联
    paperMapper.deletePaperQuestions(id);
    // 删除试卷
    paperMapper.deleteById(id);
  }

  @Transactional
  public void update(Long id, String name, String subject, List<QuestionItem> items, Integer passScore) {
    Paper paper = paperMapper.selectById(id);
    if (paper == null) {
      throw new ResponseStatusException(HttpStatus.NOT_FOUND, "试卷不存在");
    }
    
    // 只能更新未被使用的试卷
    if (paper.getStatus() != 0) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "已被使用的试卷不能修改");
    }
    
    if (items != null && !items.isEmpty()) {
      int totalScore = items.stream().mapToInt(i -> i.score).sum();
      paper.setTotalScore(totalScore);
      paper.setQuestionCount(items.size());
      
      // 更新试卷题目
      paperMapper.deletePaperQuestions(id);
      List<PaperQuestion> rels = new ArrayList<>();
      int order = 1;
      for (QuestionItem i : items) {
        PaperQuestion r = new PaperQuestion();
        r.setQuestionId(i.id);
        r.setScore(i.score);
        r.setSortOrder(order++);
        rels.add(r);
      }
      paperMapper.insertPaperQuestions(id, rels);
    }
    
    if (name != null) paper.setName(name);
    if (subject != null) paper.setSubject(subject);
    if (passScore != null) paper.setPassScore(passScore);
    
    paperMapper.updateById(paper);
  }

  @Transactional
  public void publish(Long id) {
    Paper paper = paperMapper.selectById(id);
    if (paper == null) {
      throw new ResponseStatusException(HttpStatus.NOT_FOUND, "试卷不存在");
    }
    
    // 验证试卷是否有题目
    List<Map<String, Object>> questions = paperMapper.selectPaperQuestionViews(id);
    if (questions.isEmpty()) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "试卷没有题目，无法发布");
    }
    
    // 更新状态为已发布(2)
    paper.setStatus(2);
    paperMapper.updateById(paper);
  }

  @Transactional
  public void unpublish(Long id) {
    Paper paper = paperMapper.selectById(id);
    if (paper == null) {
      throw new ResponseStatusException(HttpStatus.NOT_FOUND, "试卷不存在");
    }
    
    // 检查是否有正在进行的考试使用该试卷
    long examCount = paperMapper.countExamsByPaperId(id);
    if (examCount > 0) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "试卷正在被考试使用，无法取消发布");
    }
    
    // 更新状态为草稿(0)
    paper.setStatus(0);
    paperMapper.updateById(paper);
  }

  private String getStatusText(Integer status) {
    if (status == null) return "draft";
    return switch (status) {
      case 0 -> "draft";
      case 1 -> "used";
      case 2 -> "published";
      default -> "draft";
    };
  }

  /** 组卷题目项 */
  public static class QuestionItem {
    public Long id;
    public Integer score;
    public QuestionItem(Long id, Integer score) { this.id = id; this.score = score; }
  }
}

