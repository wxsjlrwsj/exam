package org.example.chaoxingsystem.teacher.paper;

import org.example.chaoxingsystem.teacher.bank.Question;
import org.example.chaoxingsystem.teacher.bank.ExamQuestionMapper;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;

/** 试卷服务：分页、组卷、智能组卷 */
@Service
public class PaperService {
  private final PaperMapper paperMapper;
  private final ExamQuestionMapper examQuestionMapper;

  public PaperService(PaperMapper paperMapper, ExamQuestionMapper examQuestionMapper) {
    this.paperMapper = paperMapper;
    this.examQuestionMapper = examQuestionMapper;
  }

  public long count(String subject) {
    return paperMapper.count(subject);
  }

  public List<Paper> page(String subject, int page, int size) {
    int offset = (Math.max(page, 1) - 1) * Math.max(size, 1);
    return paperMapper.selectPage(subject, offset, size);
  }

  public long countBySubjects(List<String> subjects) {
    return paperMapper.countBySubjects(subjects);
  }

  public List<Paper> pageBySubjects(List<String> subjects, int page, int size) {
    int offset = (Math.max(page, 1) - 1) * Math.max(size, 1);
    return paperMapper.selectPageBySubjects(subjects, offset, size);
  }

  public Paper getByIdOrThrow(Long id) {
    Paper paper = paperMapper.selectById(id);
    if (paper == null) {
      throw new ResponseStatusException(HttpStatus.NOT_FOUND, "试卷不存在");
    }
    return paper;
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
  public Long autoGenerate(
    Long creatorId,
    String subject,
    Integer difficulty,
    Integer totalScore,
    Map<String, Integer> typeDistribution,
    Map<String, Map<String, Integer>> difficultyDistribution
  ) {
    if (subject == null || subject.isEmpty()) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "subject is required");
    }
    if (totalScore == null || totalScore <= 0) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "totalScore must be greater than 0");
    }
    boolean hasDifficultyDistribution = difficultyDistribution != null && !difficultyDistribution.isEmpty();
    if (!hasDifficultyDistribution && (typeDistribution == null || typeDistribution.isEmpty())) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "typeDistribution is required");
    }

    if (hasDifficultyDistribution) {
      Map<Integer, Map<String, Integer>> normalizedByDifficulty = normalizeDifficultyDistribution(difficultyDistribution);
      int totalQuestions = normalizedByDifficulty.values().stream()
        .flatMap(m -> m.values().stream())
        .mapToInt(Integer::intValue)
        .sum();
      if (totalQuestions <= 0) {
        throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "question count must be greater than 0");
      }
      if (totalScore < totalQuestions) {
        throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "totalScore is too small for question count");
      }

      List<Question> selected = new ArrayList<>();
      for (Map.Entry<Integer, Map<String, Integer>> entry : normalizedByDifficulty.entrySet()) {
        int targetDifficulty = entry.getKey();
        Map<String, Integer> perType = normalizeTypeDistribution(entry.getValue());
        for (Map.Entry<String, Integer> typeEntry : perType.entrySet()) {
          String typeCode = typeEntry.getKey();
          int countNeed = typeEntry.getValue();
          if (countNeed <= 0) {
            continue;
          }
          List<Question> pool = examQuestionMapper.selectByTypeSubject(typeCode, subject);
          List<Question> filtered = pool.stream()
            .filter(q -> matchDifficulty(q.getDifficulty(), targetDifficulty))
            .toList();
          if (filtered.size() < countNeed) {
            throw new ResponseStatusException(
              HttpStatus.BAD_REQUEST,
              String.format("not enough questions for type %s difficulty %s: need %d, have %d",
                typeCode, difficultyLabel(targetDifficulty), countNeed, filtered.size())
            );
          }
          selected.addAll(pickQuestions(filtered, countNeed, targetDifficulty));
        }
      }

      if (selected.isEmpty()) {
        throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "not enough questions to generate a paper");
      }

      List<QuestionItem> items = assignScores(selected, totalScore);
      String name = subject + " Auto Paper";
      return create(creatorId, name, subject, items, null);
    }

    Map<String, Integer> normalized = normalizeTypeDistribution(typeDistribution);
    int totalQuestions = normalized.values().stream().mapToInt(Integer::intValue).sum();
    if (totalQuestions <= 0) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "question count must be greater than 0");
    }
    if (totalScore < totalQuestions) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "totalScore is too small for question count");
    }

    List<Question> selected = new ArrayList<>();
    for (Map.Entry<String, Integer> entry : normalized.entrySet()) {
      String typeCode = entry.getKey();
      int countNeed = entry.getValue();
      if (countNeed <= 0) {
        continue;
      }
      List<Question> pool = examQuestionMapper.selectByTypeSubject(typeCode, subject);
      if (pool.size() < countNeed) {
        throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          String.format("not enough questions for type %s: need %d, have %d", typeCode, countNeed, pool.size())
        );
      }
      selected.addAll(pickQuestions(pool, countNeed, difficulty));
    }

    if (selected.isEmpty()) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "not enough questions to generate a paper");
    }

    List<QuestionItem> items = assignScores(selected, totalScore);
    String name = subject + " Auto Paper";
    return create(creatorId, name, subject, items, null);
  }

  private Map<String, Integer> normalizeTypeDistribution(Map<String, Integer> typeDistribution) {
    Map<String, Integer> normalized = new LinkedHashMap<>();
    for (Map.Entry<String, Integer> entry : typeDistribution.entrySet()) {
      String typeCode = normalizeTypeCode(entry.getKey());
      if (typeCode == null || typeCode.isEmpty()) {
        continue;
      }
      int count = entry.getValue() == null ? 0 : entry.getValue();
      if (count <= 0) {
        continue;
      }
      normalized.merge(typeCode, count, Integer::sum);
    }
    return normalized;
  }

  private Map<Integer, Map<String, Integer>> normalizeDifficultyDistribution(
    Map<String, Map<String, Integer>> difficultyDistribution
  ) {
    Map<Integer, Map<String, Integer>> normalized = new LinkedHashMap<>();
    for (Map.Entry<String, Map<String, Integer>> entry : difficultyDistribution.entrySet()) {
      Integer difficulty = normalizeDifficultyKey(entry.getKey());
      if (difficulty == null) {
        continue;
      }
      Map<String, Integer> perType = entry.getValue();
      if (perType == null || perType.isEmpty()) {
        continue;
      }
      normalized.put(difficulty, perType);
    }
    return normalized;
  }

  private Integer normalizeDifficultyKey(String key) {
    if (key == null) return null;
    String raw = key.trim().toLowerCase();
    if (raw.isEmpty()) return null;
    try {
      int value = Integer.parseInt(raw);
      if (value <= 2) return 1;
      if (value == 3) return 3;
      return 5;
    } catch (NumberFormatException ignored) {
    }
    return switch (raw) {
      case "easy", "simple", "low", "easy_level", "simple_level", "简单" -> 1;
      case "medium", "mid", "normal", "中等" -> 3;
      case "hard", "difficult", "high", "困难" -> 5;
      default -> null;
    };
  }

  private String normalizeTypeCode(String typeCode) {
    if (typeCode == null) {
      return null;
    }
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

  private List<Question> pickQuestions(List<Question> pool, int countNeed, Integer targetDifficulty) {
    List<Question> ordered = new ArrayList<>(pool);
    Random random = new Random();
    if (targetDifficulty != null) {
      ordered.sort(Comparator.comparingInt(q -> difficultyDistance(q, targetDifficulty)));
      List<Question> shuffled = new ArrayList<>(ordered.size());
      int idx = 0;
      while (idx < ordered.size()) {
        int distance = difficultyDistance(ordered.get(idx), targetDifficulty);
        int end = idx + 1;
        while (end < ordered.size() && difficultyDistance(ordered.get(end), targetDifficulty) == distance) {
          end++;
        }
        List<Question> bucket = new ArrayList<>(ordered.subList(idx, end));
        Collections.shuffle(bucket, random);
        shuffled.addAll(bucket);
        idx = end;
      }
      ordered = shuffled;
    } else {
      Collections.shuffle(ordered, random);
    }
    return pickWithDiversity(ordered, countNeed);
  }

  private int difficultyDistance(Question question, int targetDifficulty) {
    int normalized = normalizeDifficulty(question.getDifficulty());
    int target = normalizeDifficulty(targetDifficulty);
    return Math.abs(normalized - target);
  }

  private int normalizeDifficulty(Integer difficulty) {
    if (difficulty == null) {
      return 3;
    }
    int value = difficulty;
    if (value < 1) {
      return 1;
    }
    if (value > 5) {
      return 5;
    }
    return value;
  }

  private boolean matchDifficulty(Integer difficulty, int targetDifficulty) {
    int value = normalizeDifficulty(difficulty);
    int target = normalizeDifficulty(targetDifficulty);
    if (target <= 1) {
      return value <= 2;
    }
    if (target == 3) {
      return value == 3;
    }
    return value >= 4;
  }

  private String difficultyLabel(int difficulty) {
    int target = normalizeDifficulty(difficulty);
    if (target <= 1) return "easy";
    if (target == 3) return "medium";
    return "hard";
  }

  private List<Question> pickWithDiversity(List<Question> ordered, int countNeed) {
    List<Question> picked = new ArrayList<>();
    Set<Long> pickedIds = new HashSet<>();
    Set<String> usedKnowledge = new HashSet<>();

    for (Question question : ordered) {
      if (picked.size() >= countNeed) {
        break;
      }
      if (question.getId() == null || pickedIds.contains(question.getId())) {
        continue;
      }
      String key = extractKnowledgeKey(question.getKnowledgePoints());
      if (!key.isEmpty() && usedKnowledge.contains(key)) {
        continue;
      }
      picked.add(question);
      pickedIds.add(question.getId());
      if (!key.isEmpty()) {
        usedKnowledge.add(key);
      }
    }

    if (picked.size() < countNeed) {
      for (Question question : ordered) {
        if (picked.size() >= countNeed) {
          break;
        }
        if (question.getId() == null || pickedIds.contains(question.getId())) {
          continue;
        }
        picked.add(question);
        pickedIds.add(question.getId());
      }
    }

    if (picked.size() < countNeed) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "not enough questions to satisfy selection");
    }

    return picked;
  }

  private String extractKnowledgeKey(String knowledgePoints) {
    if (knowledgePoints == null) {
      return "";
    }
    String normalized = knowledgePoints
      .replace('\uFF0C', ',')
      .replace('\uFF1B', ';')
      .replace('/', ',')
      .replace('|', ',');
    String[] parts = normalized.split("[,;\s]+");
    for (String part : parts) {
      String trimmed = part.trim();
      if (!trimmed.isEmpty()) {
        return trimmed;
      }
    }
    return "";
  }

  private List<QuestionItem> assignScores(List<Question> questions, int totalScore) {
    int questionCount = questions.size();
    if (questionCount == 0) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "no questions selected");
    }
    if (totalScore < questionCount) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "totalScore is too small for question count");
    }

    List<Integer> weights = new ArrayList<>();
    int weightSum = 0;
    for (Question question : questions) {
      int weight = normalizeDifficulty(question.getDifficulty());
      weights.add(weight);
      weightSum += weight;
    }
    if (weightSum <= 0) {
      weightSum = questionCount;
    }

    List<Integer> scores = new ArrayList<>();
    int accumulated = 0;
    for (int i = 0; i < questions.size(); i++) {
      int weight = weights.get(i);
      int score = (int) Math.floor(((double) totalScore * weight) / weightSum);
      if (score < 1) {
        score = 1;
      }
      scores.add(score);
      accumulated += score;
    }

    int diff = totalScore - accumulated;
    if (diff != 0) {
      adjustScores(scores, weights, diff);
    }

    List<QuestionItem> items = new ArrayList<>();
    for (int i = 0; i < questions.size(); i++) {
      items.add(new QuestionItem(questions.get(i).getId(), scores.get(i)));
    }
    return items;
  }

  private void adjustScores(List<Integer> scores, List<Integer> weights, int diff) {
    int count = scores.size();
    List<Integer> indices = new ArrayList<>();
    for (int i = 0; i < count; i++) {
      indices.add(i);
    }

    if (diff > 0) {
      indices.sort((a, b) -> Integer.compare(weights.get(b), weights.get(a)));
      for (int i = 0; i < diff; i++) {
        int idx = indices.get(i % indices.size());
        scores.set(idx, scores.get(idx) + 1);
      }
      return;
    }

    int remaining = -diff;
    indices.sort(Comparator.comparingInt(weights::get));
    int guard = 0;
    while (remaining > 0 && guard < count * 2) {
      boolean changed = false;
      for (int idx : indices) {
        if (remaining == 0) {
          break;
        }
        int score = scores.get(idx);
        if (score > 1) {
          scores.set(idx, score - 1);
          remaining--;
          changed = true;
        }
      }
      if (!changed) {
        break;
      }
      guard++;
    }

    if (remaining > 0) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "cannot allocate scores for totalScore");
    }
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
