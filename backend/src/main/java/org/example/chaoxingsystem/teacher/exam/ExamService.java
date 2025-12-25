package org.example.chaoxingsystem.teacher.exam;

import org.example.chaoxingsystem.teacher.paper.PaperMapper;
import org.example.chaoxingsystem.teacher.paper.Paper;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

/** 考试服务：分页、创建/发布、看板数据、监考功能 */
@Service
public class ExamService {
  private final ExamMapper mapper;
  private final PaperMapper paperMapper;

  public ExamService(ExamMapper mapper, PaperMapper paperMapper) {
    this.mapper = mapper;
    this.paperMapper = paperMapper;
  }

  public long count(Integer status) { return mapper.count(status); }

  public List<Exam> page(Integer status, int page, int size) {
    int offset = (Math.max(page, 1) - 1) * Math.max(size, 1);
    return mapper.selectPage(status, offset, size);
  }

  @Transactional
  public Long create(Long creatorId, String name, Long paperId, String startTime, Integer duration) {
    DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    LocalDateTime st = LocalDateTime.parse(startTime, fmt);
    LocalDateTime et = st.plusMinutes(duration != null ? duration : 60);
    Exam e = new Exam();
    e.setName(name);
    e.setPaperId(paperId);
    e.setStartTime(startTime);
    e.setEndTime(et.format(fmt));
    e.setDuration(duration != null ? duration : 60);
    e.setStatus(0);
    e.setCreatorId(creatorId);
    mapper.insert(e);
    
    // 更新试卷状态为已使用（1）
    if (paperId != null) {
      Paper paper = paperMapper.selectById(paperId);
      if (paper != null) {
        paper.setStatus(1); // 1 = 已使用
        paperMapper.updateById(paper);
      }
    }
    
    return e.getId();
  }

  public Map<String, Object> getDetail(Long id) {
    Exam exam = mapper.selectById(id);
    if (exam == null) {
      throw new ResponseStatusException(HttpStatus.NOT_FOUND, "考试不存在");
    }
    
    Map<String, Object> data = new HashMap<>();
    data.put("id", exam.getId());
    data.put("name", exam.getName());
    data.put("paperId", exam.getPaperId());
    data.put("startTime", exam.getStartTime());
    data.put("endTime", exam.getEndTime());
    data.put("duration", exam.getDuration());
    // 使用动态计算的状态，而不是数据库中的静态状态
    data.put("status", calculateStatus(exam));
    data.put("creatorId", exam.getCreatorId());
    data.put("createTime", exam.getCreateTime());
    
    // 获取试卷信息
    if (exam.getPaperId() != null) {
      Paper paper = paperMapper.selectById(exam.getPaperId());
      if (paper != null) {
        data.put("paperName", paper.getName());
        data.put("subject", paper.getSubject());
        data.put("totalScore", paper.getTotalScore());
      }
    }
    
    // 获取考试统计
    long studentCount = mapper.countExamStudents(id);
    long submittedCount = mapper.countSubmittedStudents(id);
    long gradedCount = mapper.countGradedStudents(id);
    
    data.put("studentCount", studentCount);
    data.put("submittedCount", submittedCount);
    data.put("gradedCount", gradedCount);
    
    return data;
  }

  @Transactional
  public void delete(Long id) {
    Exam exam = mapper.selectById(id);
    if (exam == null) {
      throw new ResponseStatusException(HttpStatus.NOT_FOUND, "考试不存在");
    }
    
    // 只能删除未开始的考试
    if (exam.getStatus() != 0) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "只能删除未开始的考试");
    }
    
    // 检查是否有学生参加
    long studentCount = mapper.countExamStudents(id);
    if (studentCount > 0) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "已有学生参加的考试不能删除");
    }
    
    mapper.deleteById(id);
  }

  @Transactional
  public void update(Long id, String name, String startTime, Integer duration, String description) {
    Exam exam = mapper.selectById(id);
    if (exam == null) {
      throw new ResponseStatusException(HttpStatus.NOT_FOUND, "考试不存在");
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
    Exam exam = mapper.selectById(examId);
    if (exam == null) {
      throw new ResponseStatusException(HttpStatus.NOT_FOUND, "考试不存在");
    }
    
    // 获取监考数据
    List<Map<String, Object>> students = mapper.selectMonitorStudents(examId);
    
    long total = students.size();
    long online = students.stream().filter(s -> "online".equals(s.get("status"))).count();
    long submitted = students.stream().filter(s -> "submitted".equals(s.get("status"))).count();
    long abnormal = students.stream().filter(s -> {
      Object switchCount = s.get("switchCount");
      return switchCount instanceof Number && ((Number) switchCount).intValue() > 3;
    }).count();
    
    Map<String, Object> data = new HashMap<>();
    data.put("examId", examId);
    data.put("examName", exam.getName());
    data.put("total", total);
    data.put("online", online);
    data.put("submitted", submitted);
    data.put("abnormal", abnormal);
    data.put("students", students);
    
    return data;
  }

  @Transactional
  public Map<String, Object> sendWarning(Long examId, Long studentId, String message, String type, Long teacherId) {
    // 插入警告记录
    mapper.insertWarning(examId, studentId, message, type, teacherId);
    
    Map<String, Object> data = new HashMap<>();
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
        // 更新考试记录状态为已提交
        int affected = mapper.forceSubmitExamRecord(examId, studentId);
        
        Map<String, Object> detail = new HashMap<>();
        detail.put("studentId", studentId);
        detail.put("success", affected > 0);
        details.add(detail);
        
        if (affected > 0) {
          successCount++;
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
   * 根据当前时间和考试的起止时间动态计算考试状态
   * @param exam 考试对象
   * @return 状态字符串：upcoming（未开始）、ongoing（进行中）、finished（已结束）
   */
  public String calculateStatus(Exam exam) {
    if (exam == null || exam.getStartTime() == null) {
      return "unknown";
    }
    
    DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    LocalDateTime now = LocalDateTime.now();
    
    try {
      LocalDateTime startTime = LocalDateTime.parse(exam.getStartTime(), fmt);
      
      // 如果当前时间早于开始时间，考试未开始
      if (now.isBefore(startTime)) {
        return "upcoming";
      }
      
      // 如果有结束时间，检查是否已结束
      if (exam.getEndTime() != null && !exam.getEndTime().isEmpty()) {
        LocalDateTime endTime = LocalDateTime.parse(exam.getEndTime(), fmt);
        // 如果当前时间晚于结束时间，考试已结束
        if (now.isAfter(endTime)) {
          return "finished";
        }
        // 如果当前时间在开始和结束时间之间，考试进行中
        if (!now.isBefore(startTime) && !now.isAfter(endTime)) {
          return "ongoing";
        }
      } else {
        // 如果没有结束时间，根据开始时间和时长计算
        if (exam.getDuration() != null && exam.getDuration() > 0) {
          LocalDateTime endTime = startTime.plusMinutes(exam.getDuration());
          if (now.isAfter(endTime)) {
            return "finished";
          }
          return "ongoing";
        }
        // 如果当前时间已过开始时间但没有结束时间信息，默认为进行中
        return "ongoing";
      }
    } catch (Exception e) {
      // 解析时间失败，返回unknown
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

