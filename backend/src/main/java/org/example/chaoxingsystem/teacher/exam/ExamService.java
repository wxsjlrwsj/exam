package org.example.chaoxingsystem.teacher.exam;

import org.example.chaoxingsystem.teacher.paper.Paper;
import org.example.chaoxingsystem.teacher.paper.PaperMapper;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** Exam service: pagination, creation, monitor data. */
@Service
public class ExamService {
  private final ExamMapper mapper;
  private final PaperMapper paperMapper;
  private final ExamStudentService examStudentService;

  public ExamService(ExamMapper mapper, PaperMapper paperMapper, ExamStudentService examStudentService) {
    this.mapper = mapper;
    this.paperMapper = paperMapper;
    this.examStudentService = examStudentService;
  }

  public long count(Integer status) { return mapper.count(status); }

  public List<Exam> page(Integer status, int page, int size) {
    int offset = (Math.max(page, 1) - 1) * Math.max(size, 1);
    return mapper.selectPage(status, offset, size);
  }

  public long countByPaperSubject(String subject) {
    return mapper.countByPaperSubject(subject);
  }

  public List<Exam> pageByPaperSubject(String subject, int page, int size) {
    int offset = (Math.max(page, 1) - 1) * Math.max(size, 1);
    return mapper.selectPageByPaperSubject(subject, offset, size);
  }

  public long countByStudent(Long studentId, Integer status) { return mapper.countByStudent(studentId, status); }

  public List<Exam> pageByStudent(Long studentId, Integer status, int page, int size) {
    int offset = (Math.max(page, 1) - 1) * Math.max(size, 1);
    return mapper.selectPageByStudent(studentId, status, offset, size);
  }

  public List<Map<String, Object>> pageByStudentWithSubject(Long studentId, Integer status, String subject, String semester, int page, int size) {
    int offset = (Math.max(page, 1) - 1) * Math.max(size, 1);
    return mapper.selectPageByStudentWithSubject(studentId, status, subject, semester, offset, size);
  }

  public long countByStudentWithFilters(Long studentId, Integer status, String subject, String semester) {
    return mapper.countByStudentWithFilters(studentId, status, subject, semester);
  }

  @Transactional
  public Long create(Long creatorId, String name, Long paperId, String startTime, Integer duration, List<Long> classIds, List<Long> studentIds) {
    if (name == null || name.isBlank()) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Exam name is required");
    }
    if (paperId == null) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Paper is required");
    }
    if (startTime == null || startTime.isBlank()) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Start time is required");
    }
    Paper paper = paperMapper.selectById(paperId);
    if (paper == null) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Paper not found");
    }
    DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    LocalDateTime st = LocalDateTime.parse(startTime, fmt);
    LocalDateTime et = st.plusMinutes(duration != null ? duration : 60);
    Exam e = new Exam();
    e.setName(name);
    e.setPaperId(paperId);
    e.setStartTime(startTime);
    e.setEndTime(et.format(fmt));
    e.setDuration(duration != null ? duration : 60);
    Integer totalScore = paper.getTotalScore();
    if (totalScore == null || totalScore <= 0) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Paper total score is invalid");
    }
    e.setTotalScore(totalScore);
    Integer passScore = paper.getPassScore();
    e.setPassScore(passScore != null ? passScore : Math.max(60, (int) Math.round(totalScore * 0.6)));
    e.setStatus(0);
    e.setCreatorId(creatorId);
    mapper.insert(e);

    paper.setStatus(1);
    paperMapper.updateById(paper);

    if ((classIds != null && !classIds.isEmpty()) || (studentIds != null && !studentIds.isEmpty())) {
      examStudentService.addStudents(e.getId(), studentIds, classIds);
    }

    return e.getId();
  }

  public Map<String, Object> getDetail(Long id) {
    Exam exam = mapper.selectById(id);
    if (exam == null) {
      throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Exam not found");
    }

    Map<String, Object> data = new HashMap<>();
    data.put("id", exam.getId());
    data.put("name", exam.getName());
    data.put("paperId", exam.getPaperId());
    data.put("startTime", exam.getStartTime());
    data.put("endTime", exam.getEndTime());
    data.put("duration", exam.getDuration());
    data.put("status", calculateStatus(exam));
    data.put("allowReview", exam.getAllowReview());
    data.put("creatorId", exam.getCreatorId());
    data.put("createTime", exam.getCreateTime());

    if (exam.getPaperId() != null) {
      Paper paper = paperMapper.selectById(exam.getPaperId());
      if (paper != null) {
        data.put("paperName", paper.getName());
        data.put("subject", paper.getSubject());
        data.put("totalScore", paper.getTotalScore());
      }
    }

    long studentCount = mapper.countExamStudents(id);
    long submittedCount = mapper.countSubmittedStudents(id);
    long gradedCount = mapper.countGradedStudents(id);

    data.put("studentCount", studentCount);
    data.put("submittedCount", submittedCount);
    data.put("gradedCount", gradedCount);

    return data;
  }

  @Transactional
  public void setAllowReview(Long id, Integer allowReview) {
    Exam exam = mapper.selectById(id);
    if (exam == null) {
      throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Exam not found");
    }
    int val = (allowReview != null && allowReview != 0) ? 1 : 0;
    mapper.updateAllowReviewById(id, val);
  }

  @Transactional
  public void delete(Long id) {
    Exam exam = mapper.selectById(id);
    if (exam == null) {
      throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Exam not found");
    }

    if (exam.getStatus() != 0) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Only upcoming exams can be deleted");
    }

    long studentCount = mapper.countExamStudents(id);
    if (studentCount > 0) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Exam has assigned students");
    }

    Long paperId = exam.getPaperId();
    mapper.deleteById(id);
    if (paperId != null) {
      long remain = paperMapper.countExamsByPaperId(paperId);
      if (remain == 0) {
        Paper paper = paperMapper.selectById(paperId);
        if (paper != null) {
          paper.setStatus(0);
          paperMapper.updateById(paper);
        }
      }
    }
  }

  @Transactional
  public void update(Long id, String name, String startTime, Integer duration, String description) {
    Exam exam = mapper.selectById(id);
    if (exam == null) {
      throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Exam not found");
    }

    if (name != null) exam.setName(name);
    if (startTime != null) {
      DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
      LocalDateTime st = LocalDateTime.parse(startTime, fmt);
      exam.setStartTime(startTime);

      int dur = duration != null ? duration : exam.getDuration();
      LocalDateTime et = st.plusMinutes(dur);
      exam.setEndTime(et.format(fmt));
    }
    if (duration != null) exam.setDuration(duration);

    mapper.updateById(exam);
  }

  public Map<String, Object> getMonitorData(Long examId) {
    try {
      mapper.createCameraSnapshotTableIfNotExists();
    } catch (Exception ignore) {}
    Exam exam = mapper.selectById(examId);
    if (exam == null) {
      throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Exam not found");
    }

    List<Map<String, Object>> students = mapper.selectMonitorStudents(examId);

    for (Map<String, Object> s : students) {
      Object studentNoObj = s.get("studentNo");
      if (s.get("name") != null) {
        String baseName = String.valueOf(s.get("name"));
        String no = studentNoObj != null ? String.valueOf(studentNoObj) : null;
        if (no != null && !no.isBlank()) {
          s.put("name", baseName + "(" + no + ")");
        }
      }
      Object blob = s.get("lastSnapshotData");
      String ct = s.get("lastSnapshotContentType") != null ? String.valueOf(s.get("lastSnapshotContentType")) : "image/jpeg";
      if (blob instanceof byte[] b && b.length > 0) {
        String b64 = java.util.Base64.getEncoder().encodeToString(b);
        s.put("cameraSnapshot", "data:" + ct + ";base64," + b64);
      } else {
        s.put("cameraSnapshot", null);
      }
    }

    long total = students.size();
    long online = students.stream().filter(s -> "online".equals(s.get("status"))).count();
    long submitted = students.stream().filter(s -> "submitted".equals(s.get("status"))).count();
    long abnormal = students.stream().filter(s -> {
      Object switchCount = s.get("switchCount");
      return switchCount instanceof Number && ((Number) switchCount).intValue() > 3;
    }).count();
    long actual = online + submitted;

    Map<String, Object> data = new HashMap<>();
    data.put("examId", examId);
    data.put("examName", exam.getName());
    data.put("total", total);
    data.put("online", online);
    data.put("submitted", submitted);
    data.put("abnormal", abnormal);
    data.put("actual", actual);
    data.put("students", students);

    return data;
  }

  @Transactional
  public Map<String, Object> sendWarning(Long examId, Long studentId, String message, String type, Long teacherId) {
    mapper.insertWarning(examId, studentId, message, type, teacherId);

    Map<String, Object> data = new HashMap<>();
    data.put("sentTime", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));

    return data;
  }

  @Transactional
  public Map<String, Object> broadcast(Long examId, Long teacherId, String message, String type) {
    Exam exam = mapper.selectById(examId);
    if (exam == null) {
      throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Exam not found");
    }
    List<Map<String, Object>> students = mapper.selectMonitorStudents(examId);
    int count = 0;
    for (Map<String, Object> s : students) {
      Object idObj = s.get("id");
      if (idObj instanceof Number) {
        Long sid = ((Number) idObj).longValue();
        try { mapper.insertWarning(examId, sid, message, type, teacherId); count++; } catch (Exception ignored) {}
      }
    }
    Map<String, Object> data = new HashMap<>();
    data.put("sentCount", count);
    data.put("sentTime", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
    return data;
  }

  @Transactional
  public Map<String, Object> forceSubmit(Long examId, List<Number> studentIds, String reason) {
    int successCount = 0;
    int failedCount = 0;
    List<Map<String, Object>> details = new ArrayList<>();

    for (Number sid : studentIds) {
      Long studentId = sid.longValue();
      try {
        int affected = mapper.forceSubmitExamRecord(examId, studentId);

        Map<String, Object> detail = new HashMap<>();
        detail.put("studentId", studentId);
        detail.put("success", affected > 0);
        details.add(detail);

        if (affected > 0) {
          successCount++;
          try { mapper.insertWarning(examId, studentId, "已被教师强制收卷", "force_submit", null); } catch (Exception ignored) {}
        } else {
          failedCount++;
        }
      } catch (Exception e) {
        failedCount++;
        Map<String, Object> detail = new HashMap<>();
        detail.put("studentId", studentId);
        detail.put("success", false);
        details.add(detail);
      }
    }

    Map<String, Object> data = new HashMap<>();
    data.put("successCount", successCount);
    data.put("failedCount", failedCount);
    data.put("details", details);

    return data;
  }

  /**
   * Calculate status based on time window.
   */
  public String calculateStatus(Exam exam) {
    if (exam == null || exam.getStartTime() == null) {
      return "unknown";
    }

    DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    LocalDateTime now = LocalDateTime.now();

    try {
      LocalDateTime startTime = LocalDateTime.parse(exam.getStartTime(), fmt);

      if (now.isBefore(startTime)) {
        return "upcoming";
      }

      if (exam.getEndTime() != null && !exam.getEndTime().isEmpty()) {
        LocalDateTime endTime = LocalDateTime.parse(exam.getEndTime(), fmt);
        if (now.isAfter(endTime)) {
          return "finished";
        }
        if (!now.isBefore(startTime) && !now.isAfter(endTime)) {
          return "ongoing";
        }
      } else {
        if (exam.getDuration() != null && exam.getDuration() > 0) {
          LocalDateTime endTime = startTime.plusMinutes(exam.getDuration());
          if (now.isAfter(endTime)) {
            return "finished";
          }
          return "ongoing";
        }
        return "ongoing";
      }
    } catch (Exception e) {
      return "unknown";
    }

    return "unknown";
  }

  private String getStatusText(Integer status) {
    if (status == null) return "unknown";
    return switch (status) {
      case 0 -> "upcoming";
      case 1 -> "ongoing";
      case 2 -> "finished";
      default -> "unknown";
    };
  }
}
