package org.example.chaoxingsystem.admin.org;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class OrgService {
  private final OrganizationMapper mapper;

  public OrgService(OrganizationMapper mapper) {
    this.mapper = mapper;
  }

  /** 获取完整组织树 */
  public List<Map<String, Object>> getTree() {
    List<Organization> all = mapper.selectAll();
    Map<Long, List<Organization>> byParent = all.stream().collect(Collectors.groupingBy(o -> o.getParentId() == null ? 0L : o.getParentId()));
    return buildChildren(byParent, 0L);
  }

  private List<Map<String, Object>> buildChildren(Map<Long, List<Organization>> byParent, Long parentId) {
    List<Organization> children = byParent.getOrDefault(parentId, List.of());
    List<Map<String, Object>> result = new ArrayList<>();
    for (Organization o : children) {
      Map<String, Object> node = new LinkedHashMap<>();
      node.put("id", o.getId());
      node.put("name", o.getName());
      node.put("code", o.getCode());
      node.put("type", o.getType());
      node.put("parentId", o.getParentId());
      node.put("children", buildChildren(byParent, o.getId()));
      result.add(node);
    }
    return result;
  }

  /** 创建或更新组织 */
  @Transactional
  public void save(Organization org, boolean isUpdate) {
    if (!isUpdate && mapper.countByCode(org.getCode()) > 0) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "机构编码已存在");
    }
    if (org.getParentId() != null) {
      Organization parent = mapper.selectById(org.getParentId());
      if (parent == null) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "父节点不存在");
      org.setPath(parent.getPath());
    } else {
      org.setPath("/");
    }
    if (org.getSortOrder() == null || org.getSortOrder() < 1) org.setSortOrder(1);
    if (isUpdate) mapper.updateById(org); else mapper.insert(org);
    // 更新自身及子树路径
    rebuildPath(org.getId());
  }

  /** 删除前做级联检查 */
  @Transactional
  public void delete(Long id, long studentRefCount, long teacherRefCount) {
    Organization org = mapper.selectById(id);
    if (org == null) return;
    if (mapper.countChildren(id) > 0) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "存在子机构，禁止删除");
    }
    if (studentRefCount > 0 || teacherRefCount > 0) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "存在关联人员，禁止删除");
    }
    mapper.deleteById(id);
  }

  /** 拖拽移动节点 */
  @Transactional
  public void move(Long draggingId, Long dropId, String dropType) {
    Organization drag = mapper.selectById(draggingId);
    Organization drop = mapper.selectById(dropId);
    if (drag == null || drop == null) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "节点不存在");
    // 防环：目标不能在拖拽节点的子树中
    String dragPathPrefix = drag.getPath();
    if (drop.getPath() != null && drop.getPath().startsWith(dragPathPrefix)) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "非法移动：不能移动到自身子孙");
    }
    if ("inner".equalsIgnoreCase(dropType)) {
      drag.setParentId(drop.getId());
      drag.setSortOrder(nextSortOrder(drop.getId()));
    } else {
      Long newParent = drop.getParentId();
      drag.setParentId(newParent);
      int base = Objects.requireNonNullElse(drop.getSortOrder(), 1);
      drag.setSortOrder("before".equalsIgnoreCase(dropType) ? base : base + 1);
      normalizeSiblingsOrder(newParent, drag.getId(), drag.getSortOrder());
    }
    mapper.updateById(drag);
    rebuildPath(drag.getId());
  }

  private int nextSortOrder(Long parentId) {
    List<Organization> siblings = mapper.selectChildren(parentId);
    return siblings.isEmpty() ? 1 : siblings.get(siblings.size() - 1).getSortOrder() + 1;
  }

  /** 将同级排序重新归一化为 1..N，插入拖拽节点的期望位置 */
  private void normalizeSiblingsOrder(Long parentId, Long insertId, int insertOrder) {
    List<Organization> siblings = mapper.selectChildren(parentId);
    int idx = 1;
    for (Organization s : siblings) {
      if (idx == insertOrder) {
        idx++;
      }
      if (!s.getId().equals(insertId)) {
        s.setSortOrder(idx++);
        mapper.updateById(s);
      }
    }
  }

  /** 重建某节点及其子树路径 */
  private void rebuildPath(Long id) {
    Organization node = mapper.selectById(id);
    String base = node.getParentId() == null ? "/" : Objects.requireNonNullElse(mapper.selectById(node.getParentId()).getPath(), "/");
    node.setPath(normalizePath(base, node.getId()));
    mapper.updateById(node);
    Deque<Organization> stack = new ArrayDeque<>(mapper.selectChildren(node.getId()));
    while (!stack.isEmpty()) {
      Organization child = stack.pop();
      String parentPath = Objects.requireNonNullElse(mapper.selectById(child.getParentId()).getPath(), "/");
      child.setPath(normalizePath(parentPath, child.getId()));
      mapper.updateById(child);
      List<Organization> grandchildren = mapper.selectChildren(child.getId());
      if (grandchildren != null && !grandchildren.isEmpty()) {
        for (Organization g : grandchildren) stack.push(g);
      }
    }
  }

  private String normalizePath(String parentPath, Long id) {
    String base = (parentPath == null || parentPath.isEmpty()) ? "/" : parentPath;
    if (!base.endsWith("/")) base = base + "/";
    return base + (id == null ? "" : id) + "/";
  }

  /** 获取机构成员列表（上级包含下级）：
   *  - class: 返回班级学生与班级教师
   *  - 其他类型（包括 school、college、department/dept）：聚合子树中的班级学生、班级教师，以及学院教师
   */
  public List<Map<String, Object>> getMembers(Long orgId) {
    Organization org = mapper.selectById(orgId);
    if (org == null) return List.of();
    String type = org.getType() == null ? "" : org.getType().toLowerCase();
    if ("class".equals(type)) {
      List<Map<String, Object>> tmp = new ArrayList<>();
      tmp.addAll(mapper.listStudentMembersByClassIds(List.of(orgId)));
      tmp.addAll(mapper.listTeacherMembersByClassIds(List.of(orgId)));
      Map<String, Map<String, Object>> uniq = new LinkedHashMap<>();
      for (Map<String, Object> r : tmp) {
        Object uid = r.get("userId");
        Object ut = r.get("userType");
        String key = String.valueOf(uid) + "|" + String.valueOf(ut);
        if (!uniq.containsKey(key)) uniq.put(key, r);
      }
      return new ArrayList<>(uniq.values());
    }
    List<Organization> subtree = mapper.selectSubtree(org.getPath());
    List<Long> classIds = new ArrayList<>();
    List<Long> collegeIds = new ArrayList<>();
    for (Organization o : subtree) {
      String t = o.getType() == null ? "" : o.getType().toLowerCase();
      if ("class".equals(t)) classIds.add(o.getId());
      if ("college".equals(t)) collegeIds.add(o.getId());
    }
    List<Map<String, Object>> tmp = new ArrayList<>();
    if (!classIds.isEmpty()) tmp.addAll(mapper.listStudentMembersByClassIds(classIds));
    if (!classIds.isEmpty()) tmp.addAll(mapper.listTeacherMembersByClassIds(classIds));
    if (!collegeIds.isEmpty()) tmp.addAll(mapper.listTeacherMembersByCollegeIds(collegeIds));
    Map<String, Map<String, Object>> uniq = new LinkedHashMap<>();
    for (Map<String, Object> r : tmp) {
      Object uid = r.get("userId");
      Object ut = r.get("userType");
      String key = String.valueOf(uid) + "|" + String.valueOf(ut);
      if (!uniq.containsKey(key)) uniq.put(key, r);
    }
    return new ArrayList<>(uniq.values());
  }
}
