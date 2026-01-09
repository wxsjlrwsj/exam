/*
  开发环境Axios Mock
  - 基于设置自定义 adapter 拦截指定接口，返回本地内存数据
  - 仅在 import.meta.env.DEV 时由 main.js 引入
*/
import service from '@/utils/request'

// ============== 内存数据 ==============
let teachers = [
  { id: 't1', name: '张老师', department: '数学学院' },
  { id: 't2', name: '李老师', department: '计算机学院' },
  { id: 't3', name: '王老师', department: '物理学院' }
]

let students = Array.from({ length: 35 }).map((_, i) => ({
  id: 's' + (1000 + i),
  studentNo: String(20230000 + i),
  name: ['小明', '小红', '小李', '小王', '小张'][i % 5] + (i + 1),
  adminClassName: ['计科2201', '计科2202', '数学2201'][i % 3]
}))

let orgTree = [
  {
    id: 'org_school_1', name: 'XX大学', type: 'school', children: [
      { id: 'org_college_cs', name: '计算机学院', type: 'college', children: [
        { id: 'org_cls_cs2201', name: '计科2201', type: 'class', memberCount: 18 },
        { id: 'org_cls_cs2202', name: '计科2202', type: 'class', memberCount: 17 }
      ]},
      { id: 'org_college_math', name: '数学学院', type: 'college', children: [
        { id: 'org_cls_math2201', name: '数学2201', type: 'class', memberCount: 30 }
      ]}
    ]
  }
]

let courses = [
  {
    id: 'c1',
    name: '高等数学A',
    description: '理工类通用高等数学课程',
    creatorId: 't1',
    creatorName: '张老师',
    isCreator: true,
    teachers: [ { id: 't1', name: '张老师', department: '数学学院' }, { id: 't2', name: '李老师', department: '计算机学院' } ],
    classCount: 2,
    examCount: 3
  },
  {
    id: 'c2',
    name: '数据结构',
    description: '线性表、树与图等数据结构基础',
    creatorId: 't2',
    creatorName: '李老师',
    isCreator: false,
    teachers: [ { id: 't2', name: '李老师', department: '计算机学院' } ],
    classCount: 1,
    examCount: 2
  }
]

let classes = [
  { id: 'cl1', courseId: 'c1', name: '高数A-1班', assignedTeacherId: 't1', assignedTeacherName: '张老师', studentCount: 18, createTime: '2025-09-01 09:00:00' },
  { id: 'cl2', courseId: 'c1', name: '高数A-2班', assignedTeacherId: 't2', assignedTeacherName: '李老师', studentCount: 17, createTime: '2025-09-01 09:30:00' },
  { id: 'cl3', courseId: 'c2', name: '数据结构-1班', assignedTeacherId: 't2', assignedTeacherName: '李老师', studentCount: 20, createTime: '2025-09-05 10:00:00' }
]

let classStudents = {
  cl1: students.slice(0, 18),
  cl2: students.slice(18),
  cl3: students.slice(0, 20)
}

// 考试数据
let exams = [
  { id: 'e1', courseId: 'c1', name: '高等数学A期中考试', paperId: 'p1', startTime: '2025-11-15 09:00:00', endTime: '2025-11-15 11:00:00', duration: 120, status: 'finished', classIds: ['cl1', 'cl2'], createTime: '2025-10-20 10:00:00', score: 88, recordStatus: 2 },
  { id: 'e2', courseId: 'c1', name: '高等数学A期末考试', paperId: 'p2', startTime: '2026-01-10 14:00:00', endTime: '2026-01-10 16:00:00', duration: 120, status: 'upcoming', classIds: ['cl1', 'cl2'], createTime: '2025-12-15 10:00:00', recordStatus: 0 },
  { id: 'e3', courseId: 'c1', name: '高等数学A随堂测验', paperId: 'p3', startTime: new Date(Date.now() - 1800000).toISOString().slice(0, 19).replace('T', ' '), endTime: new Date(Date.now() + 1800000).toISOString().slice(0, 19).replace('T', ' '), duration: 60, status: 'ongoing', classIds: ['cl1'], createTime: '2025-12-28 08:00:00', recordStatus: 0 },
  { id: 'e4', courseId: 'c2', name: '数据结构期中考试', paperId: 'p4', startTime: '2025-11-20 09:00:00', endTime: '2025-11-20 11:00:00', duration: 120, status: 'finished', classIds: ['cl3'], createTime: '2025-10-25 10:00:00', recordStatus: 1 },
  { id: 'e5', courseId: 'c2', name: '数据结构期末考试', paperId: 'p5', startTime: '2026-01-15 09:00:00', endTime: '2026-01-15 11:00:00', duration: 120, status: 'upcoming', classIds: ['cl3'], createTime: '2025-12-20 10:00:00', score: 92, recordStatus: 2 }
]

// 试卷数据
let papers = [
  { id: 'p1', courseId: 'c1', name: '高数A期中试卷', questionCount: 20, totalScore: 100, status: 'used', createTime: '2025-10-15 10:00:00' },
  { id: 'p2', courseId: 'c1', name: '高数A期末试卷', questionCount: 25, totalScore: 100, status: 'unused', createTime: '2025-12-10 10:00:00' },
  { id: 'p3', courseId: 'c1', name: '高数A测验卷', questionCount: 10, totalScore: 50, status: 'used', createTime: '2025-12-27 10:00:00' },
  { id: 'p4', courseId: 'c2', name: '数据结构期中试卷', questionCount: 20, totalScore: 100, status: 'used', createTime: '2025-10-18 10:00:00' },
  { id: 'p5', courseId: 'c2', name: '数据结构期末试卷', questionCount: 25, totalScore: 100, status: 'unused', createTime: '2025-12-18 10:00:00' }
]

// 学生课程数据（用于学生端）
let studentCourses = [
  { id: 'c1', name: '高等数学A', className: '高数A-1班', classId: 'cl1', examCount: 3 },
  { id: 'c2', name: '数据结构', className: '数据结构-1班', classId: 'cl3', examCount: 2 }
]

// ============== 工具函数 ==============
const sleep = (ms) => new Promise(r => setTimeout(r, ms))
const okPayload = (payload) => ({ code: 200, data: { data: payload } }) // 兼容现有前端写法 res.data
const emptyOk = () => okPayload(true)

function parseUrl(url) {
  // 去掉查询串
  const [path] = url.split('?')
  return path
}

function match(re, path) {
  const m = path.match(re)
  return m ? m.slice(1) : null
}

// ============== Adapter ==============
service.interceptors.request.use(async (config) => {
  if (!import.meta.env.DEV) return config

  const method = (config.method || 'get').toLowerCase()
  const path = parseUrl(config.url || '')

  // 处理匹配的接口，设置自定义 adapter，阻断真实请求
  const handle = async () => {
    await sleep(200)

    // 登录
    if (method === 'post' && path === '/auth/login') {
      const body = config.data || {}
      let userType = 'student'
      const u = String(body.username || '').toLowerCase()
      if (u.includes('admin')) userType = 'admin'
      else if (u.includes('teacher')) userType = 'teacher'
      const token = 'mock-token-' + Date.now()
      const userInfo = {
        id: Date.now(),
        name: body.username || '用户',
        username: body.username || 'user',
        role: userType,
        userType
      }
      return okPayload({ token, userInfo })
    }

    // 刷新登录（记住我）
    if (method === 'post' && path === '/auth/refresh') {
      const hasRemember = localStorage.getItem('rememberMe') === 'true'
      const userInfoStr = localStorage.getItem('userInfo')
      let userInfo = null
      try { userInfo = JSON.parse(userInfoStr || 'null') } catch {}
      if (hasRemember && userInfo) {
        const token = 'mock-token-' + Date.now()
        return okPayload({ token, userInfo })
      }
      return { code: 401, data: { data: null }, message: 'Unauthorized' }
    }

    // 退出
    if (method === 'post' && path === '/logout') {
      return emptyOk()
    }

    // 课程列表
    if (method === 'get' && path === '/courses') {
      return okPayload(courses)
    }

    // 课程详情
    let m
    if ((m = match(/^\/courses\/([^/]+)$/i, path)) && method === 'get') {
      const id = m[0]
      const c = courses.find(x => x.id === id)
      return okPayload(c || null)
    }

    // 新建课程
    if (method === 'post' && path === '/courses') {
      const body = config.data || {}
      const id = 'c' + (courses.length + 1)
      const creator = teachers.find(t => t.id === (body.creatorId || 't1')) || teachers[0]
      const item = {
        id,
        name: body.name,
        description: body.description,
        creatorId: creator.id,
        creatorName: creator.name,
        isCreator: true,
        teachers: (body.teacherIds || []).map(tid => teachers.find(t => t.id === tid)).filter(Boolean),
        classCount: 0
      }
      courses.unshift(item)
      return okPayload(true)
    }

    // 更新课程
    if ((m = match(/^\/courses\/([^/]+)$/i, path)) && method === 'put') {
      const id = m[0]
      const body = config.data || {}
      const idx = courses.findIndex(x => x.id === id)
      if (idx > -1) {
        courses[idx].name = body.name ?? courses[idx].name
        courses[idx].description = body.description ?? courses[idx].description
        if (Array.isArray(body.teacherIds)) {
          courses[idx].teachers = body.teacherIds.map(tid => teachers.find(t => t.id === tid)).filter(Boolean)
        }
      }
      return okPayload(true)
    }

    // 删除课程
    if ((m = match(/^\/courses\/([^/]+)$/i, path)) && method === 'delete') {
      const id = m[0]
      courses = courses.filter(c => c.id !== id)
      classes = classes.filter(cl => cl.courseId !== id)
      Object.keys(classStudents).forEach(k => { if (!classes.find(c => c.id === k)) delete classStudents[k] })
      return okPayload(true)
    }

    // 课程教学组老师
    if ((m = match(/^\/courses\/([^/]+)\/teachers$/i, path)) && method === 'get') {
      const id = m[0]
      const c = courses.find(x => x.id === id)
      return okPayload(c ? c.teachers : [])
    }
    if ((m = match(/^\/courses\/([^/]+)\/teachers$/i, path)) && method === 'post') {
      const id = m[0]
      const body = config.data || {}
      const t = teachers.find(x => x.id === body.teacherId)
      const c = courses.find(x => x.id === id)
      if (t && c && !c.teachers.find(x => x.id === t.id)) c.teachers.push(t)
      return okPayload(true)
    }
    if ((m = match(/^\/courses\/([^/]+)\/teachers\/([^/]+)$/i, path)) && method === 'delete') {
      const courseId = m[0]
      const teacherId = m[1]
      const c = courses.find(x => x.id === courseId)
      if (c) c.teachers = c.teachers.filter(t => t.id !== teacherId)
      return okPayload(true)
    }

    // 课程下教学班列表
    if ((m = match(/^\/courses\/([^/]+)\/classes$/i, path)) && method === 'get') {
      const courseId = m[0]
      const list = classes.filter(cl => cl.courseId === courseId)
      return okPayload(list)
    }

    // 创建教学班
    if ((m = match(/^\/courses\/([^/]+)\/classes$/i, path)) && method === 'post') {
      const courseId = m[0]
      const body = config.data || {}
      const id = 'cl' + (classes.length + 1)
      const t = teachers.find(x => x.id === body.assignedTeacherId)
      const item = {
        id,
        courseId,
        name: body.name || '新建教学班',
        assignedTeacherId: t?.id || teachers[0].id,
        assignedTeacherName: t?.name || teachers[0].name,
        studentCount: 0,
        createTime: new Date().toISOString().slice(0, 19).replace('T', ' ')
      }
      classes.unshift(item)
      courses.forEach(c => { if (c.id === courseId) c.classCount = classes.filter(x => x.courseId === courseId).length })
      classStudents[id] = []
      return okPayload(true)
    }

    // 更新教学班
    if ((m = match(/^\/teaching-classes\/([^/]+)$/i, path)) && method === 'put') {
      const classId = m[0]
      const body = config.data || {}
      const idx = classes.findIndex(cl => cl.id === classId)
      if (idx > -1) {
        if (body.name) classes[idx].name = body.name
        if (body.assignedTeacherId) {
          const t = teachers.find(x => x.id === body.assignedTeacherId)
          classes[idx].assignedTeacherId = t?.id || body.assignedTeacherId
          classes[idx].assignedTeacherName = t?.name || classes[idx].assignedTeacherName
        }
      }
      return okPayload(true)
    }

    // 删除教学班
    if ((m = match(/^\/teaching-classes\/([^/]+)$/i, path)) && method === 'delete') {
      const classId = m[0]
      const courseId = classes.find(c => c.id === classId)?.courseId
      classes = classes.filter(cl => cl.id !== classId)
      delete classStudents[classId]
      if (courseId) courses.forEach(c => { if (c.id === courseId) c.classCount = classes.filter(x => x.courseId === courseId).length })
      return okPayload(true)
    }

    // 教学班详情
    if ((m = match(/^\/teaching-classes\/([^/]+)$/i, path)) && method === 'get') {
      const classId = m[0]
      return okPayload(classes.find(c => c.id === classId) || null)
    }

    // 教学班学生列表
    if ((m = match(/^\/teaching-classes\/([^/]+)\/students$/i, path)) && method === 'get') {
      const classId = m[0]
      return okPayload(classStudents[classId] || [])
    }

    // 从行政班批量添加
    if ((m = match(/^\/teaching-classes\/([^/]+)\/students\/batch$/i, path)) && method === 'post') {
      const classId = m[0]
      const body = config.data || {}
      const ids = body.adminClassIds || []
      // 简化：按行政班名称包含关键字筛选学生
      const addList = students.filter(s => ids.some(id => s.adminClassName.includes(id.split('_').pop()?.replace('cls_', '') || '')))
      const set = new Map((classStudents[classId] || []).map(s => [s.id, s]))
      addList.forEach(s => set.set(s.id, s))
      classStudents[classId] = Array.from(set.values())
      // 更新人数
      const idx = classes.findIndex(c => c.id === classId)
      if (idx > -1) classes[idx].studentCount = classStudents[classId].length
      return okPayload(true)
    }

    // 单独添加学生
    if ((m = match(/^\/teaching-classes\/([^/]+)\/students$/i, path)) && method === 'post') {
      const classId = m[0]
      const body = config.data || {}
      const stu = students.find(s => s.id === body.studentId)
      if (stu) {
        const list = classStudents[classId] || []
        if (!list.find(s => s.id === stu.id)) list.push(stu)
        classStudents[classId] = list
        const idx = classes.findIndex(c => c.id === classId)
        if (idx > -1) classes[idx].studentCount = classStudents[classId].length
      }
      return okPayload(true)
    }

    // 从教学班移除学生
    if ((m = match(/^\/teaching-classes\/([^/]+)\/students\/([^/]+)$/i, path)) && method === 'delete') {
      const classId = m[0]
      const studentId = m[1]
      classStudents[classId] = (classStudents[classId] || []).filter(s => s.id !== studentId)
      const idx = classes.findIndex(c => c.id === classId)
      if (idx > -1) classes[idx].studentCount = classStudents[classId].length
      return okPayload(true)
    }

    // 组织机构树
    if (method === 'get' && path === '/org/tree') {
      return okPayload(orgTree)
    }

    // 模块禁用配置（返回空表示全部启用）
    if (method === 'get' && path === '/system/module-config') {
      return okPayload([])
    }

    // 老师搜索
    if (method === 'get' && path === '/users/teachers') {
      const keyword = (config.params?.keyword || '').toLowerCase()
      const filtered = keyword
        ? teachers.filter(t => t.name.toLowerCase().includes(keyword) || t.department.toLowerCase().includes(keyword))
        : teachers
      return okPayload(filtered)
    }

    // 学生搜索
    if (method === 'get' && path === '/users/students') {
      const keyword = (config.params?.keyword || '').toLowerCase()
      const filtered = keyword
        ? students.filter(s => s.name.toLowerCase().includes(keyword) || s.studentNo.toLowerCase().includes(keyword))
        : students.slice(0, 20)
      return okPayload(filtered)
    }

    // 学生个人资料
    if (method === 'get' && path === '/student/profile') {
      const infoStr = localStorage.getItem('userInfo')
      let info = null
      try { info = JSON.parse(infoStr || 'null') } catch {}
      const profile = {
        name: info?.name || info?.username || '学生',
        avatar: ''
      }
      return okPayload(profile)
    }

    // ==================== 考试管理 ====================
    // 获取考试列表（支持按课程筛选）
    if (method === 'get' && path === '/exams') {
      const courseId = config.params?.courseId
      const filtered = courseId ? exams.filter(e => e.courseId === courseId) : exams
      return okPayload(filtered)
    }

    // 创建考试
    if (method === 'post' && path === '/exams') {
      const body = config.data || {}
      const id = 'e' + (exams.length + 1)
      const item = {
        id,
        courseId: body.courseId,
        name: body.name,
        paperId: body.paperId,
        startTime: body.startTime,
        endTime: body.endTime || body.startTime,
        duration: body.duration || 120,
        status: 'upcoming',
        classIds: body.classIds || [],
        createTime: new Date().toISOString().slice(0, 19).replace('T', ' ')
      }
      exams.push(item)
      // 更新课程考试数量
      courses.forEach(c => {
        if (c.id === body.courseId) c.examCount = exams.filter(e => e.courseId === c.id).length
      })
      return okPayload(true)
    }

    // 删除考试
    if ((m = match(/^\/exams\/([^/]+)$/i, path)) && method === 'delete') {
      const examId = m[0]
      const exam = exams.find(e => e.id === examId)
      exams = exams.filter(e => e.id !== examId)
      // 更新课程考试数量
      if (exam) {
        courses.forEach(c => {
          if (c.id === exam.courseId) c.examCount = exams.filter(e => e.courseId === c.id).length
        })
      }
      return okPayload(true)
    }

    // ==================== 试卷管理 ====================
    // 获取试卷列表（支持按课程筛选）
    if (method === 'get' && path === '/papers') {
      const courseId = config.params?.courseId
      const filtered = courseId ? papers.filter(p => p.courseId === courseId) : papers
      return okPayload(filtered)
    }

    // ==================== 学生端 ====================
    // 获取学生课程列表
    if (method === 'get' && path === '/student/courses') {
      return okPayload(studentCourses)
    }

    // 获取学生考试列表（支持按课程筛选）
    if (method === 'get' && path === '/student/exams') {
      const courseId = config.params?.courseId
      // 学生只能看到自己教学班的考试
      const studentClassIds = studentCourses.map(sc => sc.classId)
      const filtered = exams.filter(e => {
        const hasClass = e.classIds?.some(cid => studentClassIds.includes(cid))
        const matchCourse = courseId ? e.courseId === courseId : true
        return hasClass && matchCourse
      })
      return okPayload(filtered)
    }

    // 未匹配，返回404结构（也让前端看到提示）
    return { code: 404, data: { data: null }, message: 'Not mocked' }
  }

  // 若命中我们的mock范围，则设置自定义adapter
  const isMockTarget = path?.startsWith('/courses') ||
    path?.startsWith('/teaching-classes') ||
    path?.startsWith('/exams') ||
    path?.startsWith('/papers') ||
    path?.startsWith('/student/') ||
    path?.startsWith('/auth/') ||
    path === '/org/tree' ||
    path === '/system/module-config' ||
    path === '/users/teachers' ||
    path === '/users/students' ||
    path === '/logout'

  if (isMockTarget) {
    config.adapter = async () => {
      const payload = await handle()
      return {
        data: payload,
        status: 200,
        statusText: 'OK',
        headers: {},
        config
      }
    }
  }
  return config
})
