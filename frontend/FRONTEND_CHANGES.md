# 前端修改说明

本文档记录本次为“学生端与教师端接入后端数据、修复中文显示问题”所做的前端代码改动。所有改动均已通过构建验证。

## 公共请求封装
- 统一使用 `src/api/http.js` 的 Axios 实例（携带 `Authorization: Bearer <token>`，基于 `VITE_API_BASE_URL`）。

## 学生端：考试列表接入后端
- 文件：`frontend/src/views/student/ExamList.vue`
- 主要改动：
  - 引入请求实例：在脚本中新增 `import http from '@/api/http'`（`frontend/src/views/student/ExamList.vue:103`）。
  - 接入后端分页接口，移除本地模拟数据：
    - 使用 `http.get('/api/student/exams', { params: { status, page, size } })` 获取数据（`frontend/src/views/student/ExamList.vue:171`）。
    - 标签页与接口状态参数映射：`all → null`，`not_started → upcoming`，`in_progress → ongoing`，`finished → finished`（`frontend/src/views/student/ExamList.vue:120-125`）。
    - 后端状态整数到前端文案映射：`0 → not_started`，`1 → in_progress`，`2 → finished`（`frontend/src/views/student/ExamList.vue:126-131`）。
  - 列展示优化：科目列为空时显示 `'-'`（`frontend/src/views/student/ExamList.vue:41-45`）。
  - 保留现有的筛选、分页、标签页切换逻辑，改为加载接口数据后在前端进行名称和状态过滤（`frontend/src/views/student/ExamList.vue:188-195`）。

## 教师端：题库列表接入后端
- 文件：`frontend/src/views/teacher/QuestionBank.vue`
- 主要改动：
  - 引入请求实例：在脚本中新增 `import http from '@/api/http'`（`frontend/src/views/teacher/QuestionBank.vue:71`）。
  - 接入后端分页接口：
    - 使用 `http.get('/api/questions', { params: { page, size, typeCode, keyword } })` 获取数据（`frontend/src/views/teacher/QuestionBank.vue:101-108`）。
    - 将题型筛选枚举值对齐后端 `biz_question_type.type_code`：`SINGLE/MULTI/TRUE_FALSE/FILL/SHORT`（`frontend/src/views/teacher/QuestionBank.vue:82-88`）。
  - 题型展示对齐后端返回：
    - 表格列使用后端字段 `typeId`（`frontend/src/views/teacher/QuestionBank.vue:29`）。
    - 使用字典映射显示中文标签：`{ 1:'单选题', 2:'多选题', 3:'判断题', 4:'填空题', 5:'简答题' }`（`frontend/src/views/teacher/QuestionBank.vue:95-97`）。
  - 新增重置筛选入口：`resetFilter` 置空筛选后重新加载（`frontend/src/views/teacher/QuestionBank.vue:120-133`）。

## 环境与构建
- `.env.development` 中 `VITE_API_BASE_URL` 指向本地后端；生产环境为空走 Nginx 代理（已存在，无改动）。
- 前端构建成功，产出包含更新后的页面脚本（如 `ExamList-*.js`、`QuestionBank-*.js`）。

## 影响范围
- 学生端“查看考试”页面（`/dashboard/student/exam-list`）现从后端实时获取并展示分页数据。
- 教师端“考题题库查看”页面（`/dashboard/teacher/question-bank`）现从后端实时获取并按题型/关键词过滤分页数据。

## 管理员端：侧边栏改为动态菜单
- 文件：`frontend/src/views/Dashboard.vue`
- 主要改动：
  - 管理员菜单改为按后端接口动态渲染：新增 `visibleAdminModules`，通过 `request.get('/system/modules/visible', { params: { role: 'admin' } })` 拉取包含 `enabled && showInMenu && allowedRoles` 命中的模块列表，并使用 `v-for` 渲染（`frontend/src/views/Dashboard.vue:24-34`、`frontend/src/views/Dashboard.vue:272-279`）。
  - 路由兜底归一：新增 `normalizeIndex`，当模块的 `routePath` 未以 `/dashboard/` 开头时，自动拼接为 `/dashboard/admin/...`，避免点击无法跳转（`frontend/src/views/Dashboard.vue:281-286`）。
  - 保留学生/教师菜单静态配置，但与禁用列表联动显隐：`isModuleDisabled(moduleCode)` 基于本地的禁用编码数组控制显隐（`frontend/src/views/Dashboard.vue:229-231`）。
  - 首次挂载同步后端禁用列表：调用 `request.get('/system/modules', { params: { status: 'disabled', page: 1, size: 100 } })`，将禁用的模块编码写入 `localStorage.disabledModules` 并更新内存（`frontend/src/views/Dashboard.vue:267-279`）。
  - 实时响应禁用切换：监听 `window.addEventListener('storage', ...)`，当功能模块页更新禁用列表并派发事件时，侧边栏无需刷新即可联动（`frontend/src/views/Dashboard.vue:263-265`）。

## 管理员端：角色成员管理弹窗部门筛选修复
- 文件：`frontend/src/views/admin/RoleUsers.vue`
- 主要改动：
  - 新增 `selectedOrgId` 状态记录当前选中的机构节点（`frontend/src/views/admin/RoleUsers.vue:120`）。
  - 未分配用户加载增加机构筛选参数：`loadUnassignedUsers` 在 `params` 中传递 `orgId: selectedOrgId.value`（`frontend/src/views/admin/RoleUsers.vue:203-216`）。
  - 机构树点击事件：`handleOrgNodeClick` 设置 `selectedOrgId` 并调用 `loadUnassignedUsers()` 触发筛选（`frontend/src/views/admin/RoleUsers.vue:251-254`）。
  - 效果：选择左侧部门/班级后，右侧候选用户列表按所选机构筛选，不再显示全部成员。

## 公共请求封装使用说明（补充）
- 本次改动涉及两个请求实例：
  - `src/api/http.js`：部分页面沿用此实例（如考试列表、题库列表），基于 `VITE_API_BASE_URL`。
  - `src/utils/request.js`：新增页面（如 `Dashboard.vue`、`RoleUsers.vue`）使用此实例，基于 `VITE_APP_BASE_API`，并内置错误提示与 401 跳转登录逻辑。
- 两者均在请求拦截器中自动附带 `Authorization: Bearer <token>`。后续如需统一，可将新旧页面逐步迁移为同一实例。

## 影响范围（补充）
- 管理员端侧边栏：启用/停用模块将立即增删菜单项；新增模块设置为 `enabled && showInMenu && allowedRoles` 命中后即可显示。
- 管理员端角色成员管理：左侧部门/班级点击后，右侧候选用户列表按机构筛选。
