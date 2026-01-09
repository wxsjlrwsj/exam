package org.example.chaoxingsystem.admin.module;

import jakarta.annotation.PostConstruct;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@Component
public class SystemModuleInitializer {
  private final SystemModuleMapper mapper;

  public SystemModuleInitializer(SystemModuleMapper mapper) {
    this.mapper = mapper;
  }

  @PostConstruct
  public void init() {
    List<SystemModule> modules = new ArrayList<>();
    modules.add(build("功能模块管理", "sys_module", "system", "1.0", true, true, "/dashboard/admin/function-module", "admin", "", "系统功能模块配置"));
    modules.add(build("组织机构管理", "sys_org", "system", "1.0", true, true, "/dashboard/admin/org-management", "admin", "", "组织机构维护"));
    modules.add(build("权限管理", "sys_perm", "system", "1.0", true, true, "/dashboard/admin/permission", "admin", "", "角色与权限设置"));
    modules.add(build("操作日志", "sys_log", "monitor", "1.0", true, true, "/dashboard/admin/audit-log", "admin", "", "系统操作日志"));
    modules.add(build("查看考试", "stu_exam", "exam", "1.0", true, true, "/dashboard/student/exam-list", "student", "", "学生查看考试列表"));
    modules.add(build("自由练题", "stu_practice", "question", "1.0", true, true, "/dashboard/student/practice", "student", "", "学生练题题库"));
    modules.add(build("个性化题库", "stu_personalized", "analytics", "1.0", true, true, "/dashboard/student/personalized", "student", "", "学生个性化题库"));
    modules.add(build("个人空间", "stu_profile", "system", "1.0", true, true, "/dashboard/student/profile", "student", "", "学生个人空间"));
    modules.add(build("练题题库", "tch_practice", "question", "1.0", true, true, "/dashboard/teacher/practice", "teacher,admin", "", "教师练题题库"));
    modules.add(build("考题题库", "tch_bank", "question", "1.0", true, true, "/dashboard/teacher/question-bank", "teacher,admin", "", "教师考题题库"));
    modules.add(build("考试管理", "tch_exam", "exam", "1.0", true, true, "/dashboard/teacher/exam-management", "teacher,admin", "", "发布考试与监考"));
    modules.add(build("成绩管理", "tch_score", "score", "1.0", true, true, "/dashboard/teacher/score-management", "teacher,admin", "", "阅卷与统计"));
    modules.add(build("题目审核", "tch_audit", "question", "1.0", true, false, "", "teacher", "", "题目上传申请审核"));
    modules.add(build("试卷管理", "tch_paper", "exam", "1.0", true, true, "/dashboard/admin/paper-management", "teacher,admin", "", "试卷管理"));
    for (SystemModule m : modules) {
      if (mapper.countByCode(m.getCode()) == 0) {
        mapper.insert(m);
      }
    }
    var all = mapper.selectPage(null, null, null, 0, Integer.MAX_VALUE);
    for (SystemModule m : all) {
      String roles = m.getAllowedRoles();
      if (roles != null && !roles.isEmpty()) {
        String normalized = Arrays.stream(roles.split(","))
          .map(s -> s.trim().toLowerCase())
          .filter(s -> !s.isEmpty())
          .collect(Collectors.joining(","));
        if (!normalized.equals(roles)) {
          m.setAllowedRoles(normalized);
          mapper.updateById(m);
        }
      }
    }
  }

  private SystemModule build(String name, String code, String category, String version, boolean enabled, boolean showInMenu, String routePath, String allowedRoles, String dependencies, String description) {
    SystemModule m = new SystemModule();
    m.setName(name);
    m.setCode(code);
    m.setCategory(category);
    m.setVersion(version);
    m.setEnabled(enabled);
    m.setShowInMenu(showInMenu);
    m.setRoutePath(routePath);
    m.setAllowedRoles(allowedRoles);
    m.setDependencies(dependencies);
    m.setDescription(description);
    return m;
  }
}
