import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '@/stores/user'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      redirect: '/login'
    },
    {
      path: '/take-exam/:examId',
      name: 'TakeExam',
      component: () => import('../views/exam/TakeExam.vue'),
      meta: { title: '参加考试', roles: ['student'] }
    },
    {
      path: '/login',
      name: 'Login',
      component: () => import('../views/Login.vue'),
      meta: { title: '登录' }
    },
    {
      path: '/register',
      name: 'Register',
      component: () => import('../views/Register.vue'),
      meta: { title: '注册' }
    },
    {
      path: '/forgot-password',
      name: 'ForgotPassword',
      component: () => import('../views/ForgotPassword.vue'),
      meta: { title: '忘记密码' }
    },
    {
      path: '/dashboard',
      name: 'Dashboard',
      redirect: '/dashboard/home',
      component: () => import('../views/Dashboard.vue'),
      meta: { requiresAuth: true },
      children: [
        {
            path: 'home',
            name: 'DashboardHome',
            component: () => import('../views/common/Home.vue'),
            meta: { title: '首页', requiresAuth: true }
        },
        // Admin Routes
        {
          path: 'admin/function-module',
          name: 'AdminFunctionModule',
          component: () => import('../views/admin/FunctionModule.vue'),
          meta: { title: '功能模块管理', roles: ['admin'], moduleCode: 'sys_module' }
        },
        {
          path: 'admin/org-management',
          name: 'AdminOrgManagement',
          component: () => import('../views/admin/OrgManagement.vue'),
          meta: { title: '组织机构管理', roles: ['admin'], moduleCode: 'sys_org' }
        },
        {
          path: 'admin/permission',
          name: 'AdminPermission',
          component: () => import('../views/admin/Permission.vue'),
          meta: { title: '权限管理', roles: ['admin'], moduleCode: 'sys_perm' }
        },
        {
          path: 'admin/role/:roleId/users',
          name: 'AdminRoleUsers',
          component: () => import('../views/admin/RoleUsers.vue'),
          meta: { title: '角色成员管理', roles: ['admin'], hidden: true, activeMenu: '/dashboard/admin/permission' }
        },
        {
          path: 'admin/audit-log',
          name: 'AdminAuditLog',
          component: () => import('../views/admin/AuditLog.vue'),
          meta: { title: '操作日志', roles: ['admin'], moduleCode: 'sys_log' }
        },
        // Student Routes
        {
          path: 'student/exam-list',
          name: 'StudentExamList',
          component: () => import('../views/student/ExamList.vue'),
          meta: { title: '查看考试', roles: ['student'], moduleCode: 'stu_exam' }
        },
        {
          path: 'student/practice',
          name: 'StudentPractice',
          component: () => import('../views/student/PracticeBank.vue'),
          meta: { title: '练题题库查看', roles: ['student'], moduleCode: 'stu_practice' }
        },
        {
          path: 'student/personalized',
          name: 'StudentPersonalized',
          component: () => import('../views/student/PersonalizedBank.vue'),
          meta: { title: '个性化题库', roles: ['student'], moduleCode: 'stu_personalized' }
        },
        {
          path: 'student/profile',
          name: 'StudentProfile',
          component: () => import('../views/student/UserProfile.vue'),
          meta: { title: '个人空间', roles: ['student'], moduleCode: 'stu_profile' }
        },
        // Teacher Routes
        {
          path: 'teacher/practice',
          name: 'TeacherPractice',
          component: () => import('../views/teacher/PracticeBank.vue'),
          meta: { title: '练题题库查看', roles: ['teacher'], moduleCode: 'tch_practice' }
        },
        {
          path: 'teacher/question-bank',
          name: 'TeacherQuestionBank',
          component: () => import('../views/teacher/QuestionBank.vue'),
          meta: { title: '考题题库查看', roles: ['teacher'], moduleCode: 'tch_bank' }
        },
        {
          path: 'teacher/course-management',
          name: 'TeacherCourseManagement',
          component: () => import('../views/teacher/CourseManagement.vue'),
          meta: { title: '课程管理', roles: ['teacher'], moduleCode: 'tch_course' }
        },
        {
          path: 'teacher/paper-management',
          name: 'TeacherPaperManagement',
          component: () => import('../views/paper/PaperManagement.vue'),
          meta: { title: '试卷管理', roles: ['teacher'], moduleCode: 'tch_paper' }
        },
        {
          path: 'teacher/paper-compose',
          name: 'TeacherPaperCompose',
          component: () => import('../views/paper/PaperCompose.vue'),
          meta: { title: '手动组卷', roles: ['teacher'], moduleCode: 'tch_paper' }
        },
        {
          path: 'teacher/paper-auto',
          name: 'TeacherPaperAuto',
          component: () => import('../views/paper/PaperAutoGenerate.vue'),
          meta: { title: '智能组卷', roles: ['teacher'], moduleCode: 'tch_paper' }
        },
        {
          path: 'teacher/exam-management',
          name: 'TeacherExamManagement',
          component: () => import('../views/teacher/ExamManagementNew.vue'),
          meta: { title: '考试管理', roles: ['teacher'], moduleCode: 'tch_exam' }
        },
        {
          path: 'teacher/score-management',
          name: 'TeacherScoreManagement',
          component: () => import('../views/teacher/ScoreManagement.vue'),
          meta: { title: '成绩管理', roles: ['teacher'], moduleCode: 'tch_score' }
        },
        // Common Routes
        {
            path: 'common/profile',
            name: 'UserProfile',
            component: () => import('../views/common/UserProfile.vue'),
            meta: { title: '个人信息', requiresAuth: true }
        },
        {
            path: 'common/settings',
            name: 'AccountSettings',
            component: () => import('../views/common/AccountSettings.vue'),
            meta: { title: '账号设置', requiresAuth: true }
        }
      ]
    }
  ]
})

router.beforeEach(async (to, from, next) => {
  const userStore = useUserStore()
  
  // 检查Token是否过期
  if (userStore.token) {
    userStore.checkTokenExpire()
  }
  
  let isAuthenticated = userStore.isLoggedIn
  const userType = userStore.userRole || localStorage.getItem('userType')
  
  // 模拟从本地存储获取禁用的模块列表 (实际应从后端API获取配置)
  // 格式: "sys_org,stu_practice"
  const disabledModules = (localStorage.getItem('disabledModules') || '')
    .split(',')
    .map(s => s.trim())
    .filter(s => s)

  // Set document title
  document.title = to.meta.title ? `${to.meta.title} - 在线考试系统` : '在线考试系统'

  if (to.meta.requiresAuth && !isAuthenticated) {
    try {
      const request = (await import('@/utils/request')).default
      const resp = await request.post('/auth/refresh')
      if (resp && resp.token && resp.userInfo) {
        userStore.login({
          token: resp.token,
          userInfo: resp.userInfo,
          rememberMe: localStorage.getItem('rememberMe') === 'true'
        })
        isAuthenticated = true
      }
    } catch (e) {
      // ignore
    }
    if (!isAuthenticated) {
      next({ name: 'Login', query: { redirect: to.fullPath, noAutoLogin: '1' } })
    } else {
      next()
    }
  } else if (to.meta.moduleCode && disabledModules.includes(to.meta.moduleCode)) {
    next({ name: 'DashboardHome' })
  } else if (to.meta.roles && (!userType || !to.meta.roles.includes(userType))) {
    // Redirect to default page based on role if permission denied or mismatch
    next({ name: 'DashboardHome' })
  } else {
    next()
  }
})

export default router
