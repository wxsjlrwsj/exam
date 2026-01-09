package org.example.chaoxingsystem.teacher.course;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class CourseService {
  private final CourseMapper courseMapper;
  private final TeachingClassMapper teachingClassMapper;

  public CourseService(CourseMapper courseMapper, TeachingClassMapper teachingClassMapper) {
    this.courseMapper = courseMapper;
    this.teachingClassMapper = teachingClassMapper;
  }

  public List<Map<String, Object>> listByTeacher(Long teacherUserId) {
    List<Map<String, Object>> rows = courseMapper.selectByTeacher(teacherUserId);
    for (Map<String, Object> row : rows) {
      if (!row.containsKey("examCount")) {
        row.put("examCount", 0);
      }
    }
    return rows;
  }

  public Course getByIdOrThrow(Long id) {
    Course c = courseMapper.selectById(id);
    if (c == null) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "课程不存在");
    return c;
  }

  public Course getByNameOrThrow(String name) {
    if (name == null || name.isBlank()) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "课程名称不能为空");
    Course c = courseMapper.selectByName(name);
    if (c == null) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "课程不存在");
    return c;
  }

  public boolean isCreator(Long courseId, Long teacherUserId) {
    if (courseId == null || teacherUserId == null) return false;
    Course c = getByIdOrThrow(courseId);
    return c.getCreatorId() != null && c.getCreatorId().longValue() == teacherUserId.longValue();
  }

  public boolean isCreatorByName(String courseName, Long teacherUserId) {
    if (courseName == null || courseName.isBlank() || teacherUserId == null) return false;
    Course c = getByNameOrThrow(courseName);
    return c.getCreatorId() != null && c.getCreatorId().longValue() == teacherUserId.longValue();
  }

  public Map<String, Object> getDetail(Long id) {
    Course c = courseMapper.selectById(id);
    if (c == null) return Map.of();
    Map<String, Object> map = new HashMap<>();
    map.put("id", c.getId());
    map.put("name", c.getName());
    map.put("description", c.getDescription());
    map.put("creatorId", c.getCreatorId());
    map.put("createTime", c.getCreateTime());
    List<Map<String, Object>> teachers = courseMapper.selectCourseTeachers(id);
    map.put("teachers", teachers);
    String creatorName = null;
    if (teachers != null && !teachers.isEmpty()) {
      if (c.getCreatorId() != null) {
        for (Map<String, Object> t : teachers) {
          Object idObj = t.get("id");
          if (idObj instanceof Number && ((Number) idObj).longValue() == c.getCreatorId()) {
            Object nameObj = t.get("name");
            creatorName = nameObj != null ? String.valueOf(nameObj) : null;
            break;
          }
        }
      }
      if (creatorName == null) {
        Object nameObj = teachers.get(0).get("name");
        creatorName = nameObj != null ? String.valueOf(nameObj) : null;
      }
    }
    map.put("creatorName", creatorName);
    return map;
  }

  @Transactional
  public Long create(Long creatorUserId, String name, String description) {
    Course c = new Course();
    c.setName(name);
    c.setDescription(description);
    c.setCreatorId(creatorUserId);
    courseMapper.insert(c);
    courseMapper.insertCourseTeacher(c.getId(), creatorUserId);
    return c.getId();
  }

  @Transactional
  public void update(Long id, String name, String description) {
    Course c = courseMapper.selectById(id);
    if (c == null) return;
    Course u = new Course();
    u.setId(id);
    u.setName(name != null ? name : c.getName());
    u.setDescription(description != null ? description : c.getDescription());
    u.setCreatorId(c.getCreatorId());
    courseMapper.updateById(u);
  }

  @Transactional
  public void delete(Long id) {
    teachingClassMapper.deleteClassStudentsByCourseId(id);
    teachingClassMapper.deleteByCourseId(id);
    courseMapper.deleteCourseTeachersByCourse(id);
    courseMapper.deleteById(id);
  }

  public List<Map<String, Object>> getCourseTeachers(Long courseId) {
    return courseMapper.selectCourseTeachers(courseId);
  }

  @Transactional
  public void addCourseTeacher(Long courseId, Long teacherUserId) {
    courseMapper.insertCourseTeacher(courseId, teacherUserId);
  }

  @Transactional
  public void removeCourseTeacher(Long courseId, Long teacherUserId) {
    courseMapper.deleteCourseTeacher(courseId, teacherUserId);
  }
}
