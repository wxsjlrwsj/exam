package org.example.chaoxingsystem.admin.org;

import jakarta.validation.Valid;
import org.example.chaoxingsystem.admin.org.dto.MoveRequest;
import org.example.chaoxingsystem.admin.org.dto.SaveOrgRequest;
import org.example.chaoxingsystem.config.ModuleCheck;
import org.example.chaoxingsystem.user.dto.ApiResponse;
import org.example.chaoxingsystem.user.User;
import org.example.chaoxingsystem.user.UserMapper;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.List;
import java.util.Objects;

/** 组织机构管理接口 */
@RestController
@RequestMapping("/api/org")
@ModuleCheck(moduleCode = "sys_org")
public class OrgController {
  private final OrgService service;
  private final OrganizationMapper mapper;
  private final StudentProfileMapper studentMapper;
  private final TeacherProfileMapper teacherMapper;
  private final ClassTeacherMapper classTeacherMapper;
  private final UserMapper userMapper;

  public OrgController(OrgService service, OrganizationMapper mapper, StudentProfileMapper studentMapper, TeacherProfileMapper teacherMapper, ClassTeacherMapper classTeacherMapper, UserMapper userMapper) {
    this.service = service;
    this.mapper = mapper;
    this.studentMapper = studentMapper;
    this.teacherMapper = teacherMapper;
    this.classTeacherMapper = classTeacherMapper;
    this.userMapper = userMapper;
  }

  /** 获取组织机构树 */
  @GetMapping("/tree")
  @PreAuthorize("hasRole('ADMIN')")
  public ResponseEntity<ApiResponse<List<?>>> tree() {
    var data = service.getTree();
    return ResponseEntity.ok(ApiResponse.success("success", data));
  }

  /** 拖拽移动/排序机构 */
  @PostMapping("/move")
  @PreAuthorize("hasRole('ADMIN')")
  public ResponseEntity<ApiResponse<Void>> move(@Valid @RequestBody MoveRequest req) {
    service.move(req.getDraggingNodeId(), req.getDropNodeId(), req.getDropType());
    return ResponseEntity.ok(ApiResponse.success("移动成功", null));
  }

  /** 创建/更新机构 */
  @PostMapping("/save")
  @PreAuthorize("hasRole('ADMIN')")
  public ResponseEntity<ApiResponse<Void>> save(@Valid @RequestBody SaveOrgRequest req) {
    Organization org = new Organization();
    org.setId(req.getId());
    org.setName(req.getName());
    org.setCode(req.getCode());
    org.setParentId(req.getParentId());
    org.setType(req.getType());
    org.setSortOrder(req.getSortOrder());
    org.setLeader(req.getLeader());
    org.setPhone(req.getPhone());
    org.setStatus("1".equals(req.getStatus()) ? 1 : 0);
    org.setDescription(req.getDescription());
    service.save(org, req.getId() != null);
    return ResponseEntity.ok(ApiResponse.success("保存成功", null));
  }

  /** 删除机构（含关联检查） */
  @DeleteMapping("/{id}")
  @PreAuthorize("hasRole('ADMIN')")
  public ResponseEntity<ApiResponse<Void>> delete(@PathVariable("id") Long id) {
    // 统计关联人员：班级关联学生、部门关联教师
    Organization org = mapper.selectById(id);
    long studentRef = 0;
    long teacherRef = 0;
    if (org != null) {
      if ("class".equalsIgnoreCase(org.getType())) studentRef = studentMapper.countByClassId(id);
      if ("college".equalsIgnoreCase(org.getType())) teacherRef = teacherMapper.countByCollegeId(id);
    }
    service.delete(id, studentRef, teacherRef);
    return ResponseEntity.ok(ApiResponse.success("删除成功", null));
  }

  /** 获取某机构下的成员列表（按类型聚合：班级->学生，部门->教师；上级节点聚合子树） */
  @GetMapping("/{id}/members")
  @PreAuthorize("hasRole('ADMIN')")
  public ResponseEntity<ApiResponse<List<Map<String, Object>>>> members(@PathVariable("id") Long id) {
    try {
      var list = service.getMembers(id);
      return ResponseEntity.ok(ApiResponse.success("success", list));
    } catch (Exception ex) {
      return ResponseEntity.ok(ApiResponse.success("success", List.of()));
    }
  }

  /** 为机构分配成员（班级->学生，部门->教师）。支持按用户名分配，自动创建档案或更新归属 */
  @PostMapping("/{id}/members/assign")
  @PreAuthorize("hasRole('ADMIN')")
  public ResponseEntity<ApiResponse<Void>> assignMember(@PathVariable("id") Long id, @RequestBody Map<String, Object> req) {
    Organization org = mapper.selectById(id);
    if (org == null) {
      return ResponseEntity.badRequest().body(ApiResponse.error(400, "机构不存在"));
    }
    String type = org.getType() == null ? "" : org.getType().toLowerCase();
    if (!"class".equals(type) && !"college".equals(type)) {
      return ResponseEntity.badRequest().body(ApiResponse.error(400, "仅支持班级或学院类型分配成员"));
    }
    Object userIdObj = req.get("userId");
    Object usernameObj = req.get("username");
    User user = null;
    if (userIdObj instanceof Number) {
      Long uid = ((Number) userIdObj).longValue();
      user = userMapper.selectById(uid);
    } else if (usernameObj instanceof String) {
      user = userMapper.selectByUsername(((String) usernameObj).trim());
    }
    if (user == null) {
      return ResponseEntity.badRequest().body(ApiResponse.error(400, "用户不存在"));
    }
    String userType = user.getUserType() == null ? "" : user.getUserType().toLowerCase();
    // 班级支持分配学生与教师
    if ("class".equals(type) && !"student".equals(userType) && !"teacher".equals(userType)) {
      return ResponseEntity.badRequest().body(ApiResponse.error(400, "仅能为班级分配学生或教师"));
    }
    if ("college".equals(type) && !"teacher".equals(userType)) {
      return ResponseEntity.badRequest().body(ApiResponse.error(400, "仅能为学院分配教师"));
    }
    int year = java.time.LocalDate.now().getYear();
    if ("student".equals(userType)) {
      var s = studentMapper.selectByUserId(user.getId());
      if (s != null && s.get("class_id") != null) {
        Long curClassId = ((Number) s.get("class_id")).longValue();
        if (Objects.equals(curClassId, id)) {
          return ResponseEntity.badRequest().body(ApiResponse.error(400, "该学生已在当前班级，无需重复分配"));
        }
      }
      Long exist = studentMapper.countByUserId(user.getId());
      if (exist != null && exist > 0) {
        studentMapper.updateClassIdByUserId(user.getId(), id);
      } else {
        String sno = "S" + year + String.format("%04d", user.getId());
        String major = "UNASSIGNED";
        studentMapper.insertStudentProfile(user.getId(), sno, user.getRealName(), 0, id, major, year, null);
      }
    } else if ("teacher".equals(userType)) {
      if ("college".equals(type)) {
        Long existInCollege = teacherMapper.countByUserIdAndCollegeId(user.getId(), id);
        if (existInCollege != null && existInCollege > 0) {
          return ResponseEntity.badRequest().body(ApiResponse.error(400, "该教师已属于当前学院，无需重复分配"));
        }
        Long exist = teacherMapper.countByUserId(user.getId());
        if (exist != null && exist > 0) {
          teacherMapper.updateCollegeIdByUserId(user.getId(), id);
        } else {
          String tno = "T" + year + String.format("%04d", user.getId());
          teacherMapper.insertTeacherProfile(user.getId(), tno, user.getRealName(), 0, id, null, year);
        }
      } else if ("class".equals(type)) {
        Long exist = teacherMapper.countByUserId(user.getId());
        Long teacherId = null;
        if (exist != null && exist > 0) {
          teacherId = teacherMapper.selectIdByUserId(user.getId());
        } else {
          String tno = "T" + year + String.format("%04d", user.getId());
          teacherMapper.insertTeacherProfile(user.getId(), tno, user.getRealName(), 0, null, null, year);
          teacherId = teacherMapper.selectIdByUserId(user.getId());
        }
        if (teacherId == null) {
          return ResponseEntity.badRequest().body(ApiResponse.error(500, "教师档案创建失败"));
        }
        Long mappingExist = classTeacherMapper.countByClassAndTeacher(id, teacherId);
        if (mappingExist != null && mappingExist > 0) {
          return ResponseEntity.badRequest().body(ApiResponse.error(400, "该教师已在当前班级，无需重复分配"));
        }
        classTeacherMapper.insertMapping(id, teacherId);
      }
    }
    return ResponseEntity.ok(ApiResponse.success("分配成功", null));
  }

  @PostMapping("/{id}/members/assign-batch")
  @PreAuthorize("hasRole('ADMIN')")
  public ResponseEntity<ApiResponse<Void>> assignBatch(@PathVariable("id") Long id, @RequestBody Map<String, Object> req) {
    Organization org = mapper.selectById(id);
    if (org == null) {
      return ResponseEntity.badRequest().body(ApiResponse.error(400, "机构不存在"));
    }
    String type = org.getType() == null ? "" : org.getType().toLowerCase();
    if (!"class".equals(type) && !"college".equals(type)) {
      return ResponseEntity.badRequest().body(ApiResponse.error(400, "仅支持班级或学院类型分配成员"));
    }
    Object idsObj = req.get("userIds");
    if (!(idsObj instanceof List<?> ids) || ids.isEmpty()) {
      return ResponseEntity.badRequest().body(ApiResponse.error(400, "用户ID列表为空"));
    }
    for (Object o : ids) {
      if (o instanceof Number) {
        Long uid = ((Number) o).longValue();
        User user = userMapper.selectById(uid);
        if (user == null) continue;
        String ut = user.getUserType() == null ? "" : user.getUserType().toLowerCase();
        int year = java.time.LocalDate.now().getYear();
        if ("student".equals(ut) && "class".equals(type)) {
          Long exist = studentMapper.countByUserId(user.getId());
          if (exist != null && exist > 0) {
            studentMapper.updateClassIdByUserId(user.getId(), id);
          } else {
            String sno = "S" + year + String.format("%04d", user.getId());
            String major = "UNASSIGNED";
            studentMapper.insertStudentProfile(user.getId(), sno, user.getRealName(), 0, id, major, year, null);
          }
        } else if ("teacher".equals(ut)) {
          if ("college".equals(type)) {
            Long exist = teacherMapper.countByUserId(user.getId());
            if (exist != null && exist > 0) {
              teacherMapper.updateCollegeIdByUserId(user.getId(), id);
            } else {
              String tno = "T" + year + String.format("%04d", user.getId());
              teacherMapper.insertTeacherProfile(user.getId(), tno, user.getRealName(), 0, id, null, year);
            }
          } else if ("class".equals(type)) {
            Long exist = teacherMapper.countByUserId(user.getId());
            Long teacherId = null;
            if (exist != null && exist > 0) {
              teacherId = teacherMapper.selectIdByUserId(user.getId());
            } else {
              String tno = "T" + year + String.format("%04d", user.getId());
              teacherMapper.insertTeacherProfile(user.getId(), tno, user.getRealName(), 0, null, null, year);
              teacherId = teacherMapper.selectIdByUserId(user.getId());
            }
            if (teacherId != null) {
              classTeacherMapper.insertMapping(id, teacherId);
            }
          }
        }
      }
    }
    return ResponseEntity.ok(ApiResponse.success("分配成功", null));
  }

  @PostMapping("/{id}/members/remove")
  @PreAuthorize("hasRole('ADMIN')")
  public ResponseEntity<ApiResponse<Void>> removeMember(@PathVariable("id") Long id, @RequestBody Map<String, Object> req) {
    Organization org = mapper.selectById(id);
    if (org == null) {
      return ResponseEntity.badRequest().body(ApiResponse.error(400, "机构不存在"));
    }
    String type = org.getType() == null ? "" : org.getType().toLowerCase();
    Object userIdObj = req.get("userId");
    if (!(userIdObj instanceof Number)) {
      return ResponseEntity.badRequest().body(ApiResponse.error(400, "参数错误"));
    }
    Long uid = ((Number) userIdObj).longValue();
    User user = userMapper.selectById(uid);
    if (user == null) {
      return ResponseEntity.badRequest().body(ApiResponse.error(400, "用户不存在"));
    }
    String userType = user.getUserType() == null ? "" : user.getUserType().toLowerCase();
    if ("class".equals(type)) {
      if ("student".equals(userType)) {
        studentMapper.updateClassIdByUserId(user.getId(), null);
      } else if ("teacher".equals(userType)) {
        Long teacherId = teacherMapper.selectIdByUserId(user.getId());
        if (teacherId != null) classTeacherMapper.deleteMapping(id, teacherId);
      }
    } else if ("college".equals(type)) {
      if ("teacher".equals(userType)) {
        teacherMapper.updateCollegeIdByUserId(user.getId(), null);
      }
    }
    return ResponseEntity.ok(ApiResponse.success("移除成功", null));
  }

  @PostMapping("/{id}/members/remove-batch")
  @PreAuthorize("hasRole('ADMIN')")
  public ResponseEntity<ApiResponse<Void>> removeBatch(@PathVariable("id") Long id, @RequestBody Map<String, Object> req) {
    Organization org = mapper.selectById(id);
    if (org == null) {
      return ResponseEntity.badRequest().body(ApiResponse.error(400, "机构不存在"));
    }
    String type = org.getType() == null ? "" : org.getType().toLowerCase();
    Object idsObj = req.get("userIds");
    if (!(idsObj instanceof List<?> ids) || ids.isEmpty()) {
      return ResponseEntity.badRequest().body(ApiResponse.error(400, "用户ID列表为空"));
    }
    if ("class".equals(type)) {
      java.util.List<Long> teacherIds = new java.util.ArrayList<>();
      for (Object o : ids) {
        if (o instanceof Number) {
          Long uid = ((Number) o).longValue();
          User user = userMapper.selectById(uid);
          if (user == null) continue;
          String ut = user.getUserType() == null ? "" : user.getUserType().toLowerCase();
          if ("student".equals(ut)) {
            studentMapper.updateClassIdByUserId(uid, null);
          } else if ("teacher".equals(ut)) {
            Long tid = teacherMapper.selectIdByUserId(uid);
            if (tid != null) teacherIds.add(tid);
          }
        }
      }
      if (!teacherIds.isEmpty()) {
        classTeacherMapper.deleteByClassIdAndTeacherIds(id, teacherIds);
      }
    } else if ("college".equals(type)) {
      for (Object o : ids) {
        if (o instanceof Number) {
          Long uid = ((Number) o).longValue();
          User user = userMapper.selectById(uid);
          if (user == null) continue;
          String ut = user.getUserType() == null ? "" : user.getUserType().toLowerCase();
          if ("teacher".equals(ut)) {
            teacherMapper.updateCollegeIdByUserId(uid, null);
          }
        }
      }
    }
    return ResponseEntity.ok(ApiResponse.success("移除成功", null));
  }
  /** 候选成员搜索（根据机构类型：班级->student，部门->teacher） */
  @GetMapping("/{id}/members/candidates")
  @PreAuthorize("hasRole('ADMIN')")
  public ResponseEntity<ApiResponse<Map<String, Object>>> candidates(@PathVariable("id") Long id,
                                                                     @RequestParam(value = "keyword", required = false) String keyword,
                                                                     @RequestParam(value = "pageNum", defaultValue = "1") int pageNum,
                                                                     @RequestParam(value = "pageSize", defaultValue = "10") int pageSize,
                                                                     @RequestParam(value = "userType", required = false) String userTypeOverride) {
    Organization org = mapper.selectById(id);
    if (org == null) {
      return ResponseEntity.badRequest().body(ApiResponse.error(400, "机构不存在"));
    }
    String type = org.getType() == null ? "" : org.getType().toLowerCase();
    String userType;
    if (userTypeOverride != null && !userTypeOverride.isEmpty()) {
      userType = userTypeOverride.toLowerCase();
      // 校验与机构类型的合法性
      if ("college".equals(type) && !"teacher".equals(userType)) {
        Map<String, Object> data = new HashMap<>();
        data.put("list", List.of());
        data.put("total", 0L);
        return ResponseEntity.ok(ApiResponse.success("获取成功", data));
      }
    } else {
      if ("class".equals(type)) userType = "student"; else if ("college".equals(type)) userType = "teacher"; else userType = "";
    }
    if (userType.isEmpty()) {
      Map<String, Object> data = new HashMap<>();
      data.put("list", List.of());
      data.put("total", 0L);
      return ResponseEntity.ok(ApiResponse.success("获取成功", data));
    }
    int offset = (Math.max(pageNum, 1) - 1) * Math.max(pageSize, 1);
    var list = userMapper.searchCandidatesExcludingOrgMembers(userType, keyword, id, type, offset, pageSize);
    Long total = userMapper.countCandidatesExcludingOrgMembers(userType, keyword, id, type);
    Map<String, Object> data = new HashMap<>();
    data.put("list", list);
    data.put("total", total);
    return ResponseEntity.ok(ApiResponse.success("获取成功", data));
  }
}
