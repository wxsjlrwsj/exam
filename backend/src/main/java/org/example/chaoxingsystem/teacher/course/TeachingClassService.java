package org.example.chaoxingsystem.teacher.course;

import org.example.chaoxingsystem.common.ClassService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class TeachingClassService {
  private final TeachingClassMapper mapper;
  private final ClassService classService;

  public TeachingClassService(TeachingClassMapper mapper, ClassService classService) {
    this.mapper = mapper;
    this.classService = classService;
  }

  public List<Map<String, Object>> listByCourse(Long courseId) {
    return mapper.selectByCourse(courseId);
  }

  public Map<String, Object> getDetail(Long id) {
    TeachingClass c = mapper.selectById(id);
    if (c == null) return Map.of();
    Map<String, Object> map = new HashMap<>();
    map.put("id", c.getId());
    map.put("courseId", c.getCourseId());
    map.put("name", c.getName());
    map.put("assignedTeacherId", c.getAssignedTeacherId());
    map.put("createTime", c.getCreateTime());
    map.put("academicYear", c.getAcademicYear());
    map.put("semester", c.getSemester());
    return map;
  }

  @Transactional
  public Long create(Long courseId, String name, Long assignedTeacherId, String academicYear, String semester) {
    TeachingClass tc = new TeachingClass();
    tc.setCourseId(courseId);
    tc.setName(name);
    tc.setAssignedTeacherId(assignedTeacherId);
    tc.setAcademicYear(academicYear);
    tc.setSemester(semester);
    mapper.insert(tc);
    return tc.getId();
  }

  @Transactional
  public void update(Long id, String name, Long assignedTeacherId, String academicYear, String semester) {
    TeachingClass exist = mapper.selectById(id);
    if (exist == null) return;
    TeachingClass tc = new TeachingClass();
    tc.setId(id);
    tc.setCourseId(exist.getCourseId());
    tc.setName(name != null ? name : exist.getName());
    tc.setAssignedTeacherId(assignedTeacherId != null ? assignedTeacherId : exist.getAssignedTeacherId());
    tc.setAcademicYear(academicYear != null ? academicYear : exist.getAcademicYear());
    tc.setSemester(semester != null ? semester : exist.getSemester());
    mapper.updateById(tc);
  }

  @Transactional
  public void delete(Long id) {
    mapper.deleteById(id);
  }

  public List<Map<String, Object>> listClassStudents(Long classId) {
    return mapper.selectClassStudents(classId);
  }

  @Transactional
  public void addStudent(Long classId, Long userId) {
    mapper.insertClassStudent(classId, userId);
  }

  @Transactional
  public void removeStudent(Long classId, Long userId) {
    mapper.deleteClassStudent(classId, userId);
  }

  @Transactional
  public void assignTeacher(Long classId, Long teacherUserId) {
    TeachingClass tc = mapper.selectById(classId);
    if (tc == null) return;
    TeachingClass u = new TeachingClass();
    u.setId(classId);
    u.setCourseId(tc.getCourseId());
    u.setName(tc.getName());
    u.setAssignedTeacherId(teacherUserId);
    u.setAcademicYear(tc.getAcademicYear());
    u.setSemester(tc.getSemester());
    mapper.updateById(u);
  }

  @Transactional
  public int addStudentsFromAdminClass(Long classId, List<Long> adminClassIds) {
    if (adminClassIds == null || adminClassIds.isEmpty()) return 0;
    int added = 0;
    for (Long adminClassId : adminClassIds) {
      if (adminClassId == null) continue;
      List<Map<String, Object>> students = classService.getClassStudents(adminClassId);
      if (students == null || students.isEmpty()) continue;
      for (Map<String, Object> s : students) {
        Object userIdObj = s.get("userId");
        Long userId = null;
        if (userIdObj instanceof Number) {
          userId = ((Number) userIdObj).longValue();
        } else if (userIdObj instanceof String) {
          try {
            userId = Long.parseLong((String) userIdObj);
          } catch (NumberFormatException ignore) {}
        }
        if (userId != null) {
          added += mapper.insertClassStudent(classId, userId);
        }
      }
    }
    return added;
  }
}
