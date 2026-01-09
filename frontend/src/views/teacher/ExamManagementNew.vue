<template>
  <div class="exam-management-container">
    <div class="page-header">
      <h2 class="page-title">考试管理</h2>
    </div>

    <el-row :gutter="20" class="main-content">
      <!-- 左侧: 课程列表 -->
      <el-col :span="8">
        <el-card class="course-list-card">
          <template #header>
            <div class="card-header">
              <span>选择课程</span>
            </div>
          </template>

          <el-input
            v-model="courseFilter"
            placeholder="搜索课程..."
            prefix-icon="Search"
            clearable
            style="margin-bottom: 15px"
          />

          <div class="course-list" v-loading="loadingCourses">
            <div
              v-for="course in filteredCourses"
              :key="course.id"
              class="course-item"
              :class="{ active: currentCourse?.id === course.id }"
              @click="selectCourse(course)"
            >
              <div class="course-info">
                <div class="course-name">
                  <el-icon><Reading /></el-icon>
                  {{ course.name }}
                </div>
                <div class="course-meta">
                  <el-tag type="info" size="small">{{ course.examCount || 0 }} 场考试</el-tag>
                </div>
              </div>
            </div>
            <el-empty v-if="filteredCourses.length === 0" description="暂无课程" />
          </div>
        </el-card>
      </el-col>

      <!-- 右侧: 考试管理 -->
      <el-col :span="16">
        <el-card class="detail-card" v-if="currentCourse">
          <template #header>
            <div class="card-header">
              <div class="course-title">
                <span>{{ currentCourse.name }} - 考试管理</span>
              </div>
              <el-button @click="router.push('/dashboard/teacher/paper-management')">
                试卷管理
              </el-button>
              <el-button type="primary" :disabled="!canCreateExam" @click="handleCreateExam">
                <el-icon><Plus /></el-icon> 创建考试
              </el-button>
            </div>
          </template>

          <!-- 考试三阶段Tab -->
          <el-tabs v-model="examStatusTab" @tab-change="handleTabChange">
            <!-- 未开始 -->
            <el-tab-pane label="未开始" name="upcoming">
              <el-table :data="upcomingExams" border stripe v-loading="loadingExams">
                <el-table-column prop="name" label="考试名称" min-width="180" />
                <el-table-column prop="startTime" label="开始时间" width="160" />
                <el-table-column prop="duration" label="时长(分钟)" width="100" align="center" />
                <el-table-column label="状态" width="100" align="center">
                  <template #default>
                    <el-tag type="info">未开始</el-tag>
                  </template>
                </el-table-column>
                <el-table-column label="操作" width="200" fixed="right">
                  <template #default="{ row }">
                    <el-button link type="primary" size="small" @click="handleViewDetail(row)">详情</el-button>
                    <el-button link type="primary" size="small" @click="handleManageStudents(row)">考生</el-button>
                    <el-button link type="danger" size="small" @click="handleDeleteExam(row)">删除</el-button>
                  </template>
                </el-table-column>
              </el-table>
              <el-empty v-if="upcomingExams.length === 0 && !loadingExams" description="暂无未开始的考试" />
            </el-tab-pane>

            <!-- 进行中 -->
            <el-tab-pane label="进行中" name="ongoing">
              <el-table :data="ongoingExams" border stripe v-loading="loadingExams">
                <el-table-column prop="name" label="考试名称" min-width="180" />
                <el-table-column prop="startTime" label="开始时间" width="160" />
                <el-table-column prop="duration" label="时长(分钟)" width="100" align="center" />
                <el-table-column label="状态" width="100" align="center">
                  <template #default>
                    <el-tag type="success">进行中</el-tag>
                  </template>
                </el-table-column>
                <el-table-column label="操作" width="200" fixed="right">
                  <template #default="{ row }">
                    <el-button link type="primary" size="small" @click="handleViewDetail(row)">详情</el-button>
                    <el-button link type="success" size="small" @click="handleMonitor(row)">监考</el-button>
                  </template>
                </el-table-column>
              </el-table>
              <el-empty v-if="ongoingExams.length === 0 && !loadingExams" description="暂无进行中的考试" />
            </el-tab-pane>

            <!-- 已结束 -->
            <el-tab-pane label="已结束" name="finished">
              <el-alert 
                title="点击批阅按钮进入阅卷界面，点击成绩查看统计分析" 
                type="info" 
                :closable="false" 
                style="margin-bottom: 15px" 
              />
              <el-table :data="finishedExams" border stripe v-loading="loadingExams">
                <el-table-column prop="name" label="考试名称" min-width="180" />
                <el-table-column prop="startTime" label="开始时间" width="160" />
                <el-table-column prop="duration" label="时长(分钟)" width="100" align="center" />
                <el-table-column label="状态" width="100" align="center">
                  <template #default>
                    <el-tag type="warning">已结束</el-tag>
                  </template>
                </el-table-column>
                <el-table-column label="操作" width="220" fixed="right">
                  <template #default="{ row }">
                    <el-button link type="warning" size="small" @click="handleGrade(row)">批阅</el-button>
                    <el-button link type="info" size="small" @click="handleViewResults(row)">成绩</el-button>
                    <el-button link type="primary" size="small" @click="handleViewDetail(row)">详情</el-button>
                  </template>
                </el-table-column>
              </el-table>
              <el-empty v-if="finishedExams.length === 0 && !loadingExams" description="暂无已结束的考试" />
            </el-tab-pane>
          </el-tabs>
        </el-card>

        <el-card v-else class="detail-card">
          <el-empty description="请选择左侧课程查看考试" />
        </el-card>
      </el-col>
    </el-row>

    <!-- 创建考试对话框 -->
    <el-dialog
      v-model="createExamVisible"
      title="创建考试"
      width="600px"
      destroy-on-close
    >
      <el-form
        ref="examFormRef"
        :model="examForm"
        :rules="examRules"
        label-width="100px"
      >
        <el-form-item label="考试名称" prop="name">
          <el-input v-model="examForm.name" placeholder="请输入考试名称" />
        </el-form-item>
        <el-form-item label="选择试卷" prop="paperId">
          <el-select v-model="examForm.paperId" placeholder="请选择试卷" style="width: 100%">
            <el-option
              v-for="paper in paperList"
              :key="paper.id"
              :label="paper.name"
              :value="paper.id"
            />
          </el-select>
          <div class="form-tip">如无可用试卷，请先前往试卷管理创建</div>
        </el-form-item>
        <el-form-item label="开始时间" prop="startTime">
          <el-date-picker
            v-model="examForm.startTime"
            type="datetime"
            placeholder="选择开始时间"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="考试时长" prop="duration">
          <el-input-number v-model="examForm.duration" :min="10" :step="10" /> 分钟
        </el-form-item>
        <el-form-item label="参考教学班" prop="classIds">
          <el-select
            v-model="examForm.classIds"
            multiple
            placeholder="请选择教学班"
            style="width: 100%"
          >
            <el-option
              v-for="cls in courseClasses"
              :key="cls.id"
              :label="`${cls.name} (${cls.studentCount}人)`"
              :value="cls.id"
            />
          </el-select>
          <div class="form-tip">选择参加本次考试的教学班</div>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="createExamVisible = false">取消</el-button>
        <el-button type="primary" :loading="savingExam" @click="submitExam">
          确定
        </el-button>
      </template>
    </el-dialog>

    <!-- 考生管理对话框 -->
    <el-dialog
      v-model="studentManageVisible"
      title="考生管理"
      width="800px"
      destroy-on-close
    >
      <div v-if="currentExam" style="margin-bottom: 15px">
        <el-tag type="info">{{ currentExam.name }}</el-tag>
      </div>
      <el-table :data="examStudents" border v-loading="loadingStudents" max-height="400">
        <el-table-column prop="studentNo" label="学号" width="120" />
        <el-table-column prop="name" label="姓名" width="100" />
        <el-table-column prop="className" label="教学班" />
        <el-table-column prop="status" label="状态" width="100" align="center">
          <template #default="{ row }">
            <el-tag v-if="row.submitted" type="success" size="small">已交卷</el-tag>
            <el-tag v-else type="info" size="small">未参加</el-tag>
          </template>
        </el-table-column>
      </el-table>
    </el-dialog>
    
    <el-drawer v-model="monitorVisible" title="在线监考看板" size="100%" :with-header="false">
      <div v-if="currentMonitoredExam">
        <div class="monitor-header">
          <div class="exam-info" style="display:flex;align-items:center;">
            <el-button :icon="ArrowLeft" @click="monitorVisible = false" circle style="margin-right: 15px;" />
            <div>
               <h3 style="margin:0;">{{ currentMonitoredExam.name }} <el-tag type="success" effect="dark">进行中</el-tag></h3>
               <p style="margin:4px 0 0;">应考: {{ monitorStats.total }} | 考试中: {{ monitorStats.actual !== undefined ? monitorStats.actual : (monitorStats.online + monitorStats.submitted) }} | 已提交: {{ monitorStats.submitted }} | 异常: {{ monitorStats.abnormal }}</p>
            </div>
          </div>
          <div class="monitor-actions">
            <el-select v-model="monitorFilter" placeholder="状态筛选" style="width: 120px; margin-right: 10px;">
                <el-option label="全部" value="all" />
                <el-option label="异常" value="abnormal" />
                <el-option label="在线" value="online" />
                <el-option label="已交卷" value="submitted" />
            </el-select>
            <el-button type="primary" plain @click="handleBroadcast">发送广播</el-button>
            <el-button type="warning" plain @click="refreshMonitor">刷新数据</el-button>
            <el-button type="danger" plain @click="handleForceSubmitAll">一键收卷</el-button>
          </div>
        </div>

        <div class="monitor-body">
            <div class="monitor-main">
                <el-divider content-position="left">考生实时监控</el-divider>
                <el-row :gutter="20">
                <el-col :span="6" v-for="student in filteredMonitorStudents" :key="student.id" style="margin-bottom: 20px;">
                    <el-card :class="['student-card', { 'abnormal-card': (student.switchCount || 0) > 3, 'submitted-card': student.status === 'submitted' }]">
                    <div class="student-camera-placeholder">
                        <template v-if="student.cameraSnapshot">
                          <img :src="student.cameraSnapshot" style="width:100%;height:80px;object-fit:cover;border-radius:4px" />
                        </template>
                        <template v-else>
                          <el-icon v-if="student.status === 'online'" class="camera-icon"><VideoCamera /></el-icon>
                          <div v-else class="camera-offline">
                              {{ student.status === 'submitted' ? '已交卷' : '离线' }}
                          </div>
                        </template>
                    </div>
                    <div class="student-info">
                        <div class="student-detail">
                        <div class="name">{{ student.name }}</div>
                        </div>
                        <div class="status-tag">
                        <el-tag size="small" :type="getStudentStatusType(student.status)">{{ getStudentStatusText(student.status) }}</el-tag>
                        </div>
                    </div>
                    <div class="monitor-metrics">
                        <div class="metric-item">
                        <span class="label">切屏次数</span>
                        <span :class="['value', { 'danger-text': (student.switchCount || 0) > 3 }]">{{ student.switchCount }}</span>
                        </div>
                        <div class="metric-item">
                        <span class="label">答题进度</span>
                        <span class="value">{{ student.progress }}%</span>
                        </div>
                    </div>
                    <div class="card-actions" v-if="student.status === 'online'">
                        <el-button type="danger" link size="small" @click="handleWarning(student)">警告</el-button>
                        <el-button type="primary" link size="small" @click="handleForceSubmit(student)">强制收卷</el-button>
                    </div>
                    </el-card>
                </el-col>
                </el-row>
            </div>
            
            <div class="monitor-sidebar">
                <div class="sidebar-title">监考日志</div>
                <div class="log-list">
                    <div v-for="(log, index) in monitorLogs" :key="index" class="log-item">
                        <span class="log-time">{{ log.time }}</span>
                        <span :class="['log-content', log.type === 'danger' ? 'log-danger' : '']">{{ log.content }}</span>
                    </div>
                </div>
            </div>
        </div>
      </div>
    </el-drawer>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, onUnmounted, inject } from 'vue'
import { Plus, Search, Reading, VideoCamera, ArrowLeft } from '@element-plus/icons-vue'
import { ElMessageBox } from 'element-plus'
import { useRouter } from 'vue-router'
import { getCourses, getTeachingClasses } from '@/api/course'
import { getExams, createExam, deleteExam, getPapers, getExamDetail, getExamStudents, getMonitorData, sendWarning, forceSubmit } from '@/api/teacher'

const router = useRouter()
const showMessage = inject('showMessage')

// ==================== 课程相关 ====================
const courses = ref([])
const currentCourse = ref(null)
const loadingCourses = ref(false)
const courseFilter = ref('')

const isCreatorCourse = (course) => {
  const v = course?.isCreator
  if (typeof v === 'number') return v === 1
  if (typeof v === 'boolean') return v
  if (typeof v === 'string') return v === '1' || v.toLowerCase() === 'true'
  return false
}

const canCreateExam = computed(() => {
  return isCreatorCourse(currentCourse.value)
})

const filteredCourses = computed(() => {
  if (!courseFilter.value) return courses.value
  return courses.value.filter(c =>
    c.name.toLowerCase().includes(courseFilter.value.toLowerCase())
  )
})

const loadCourses = async () => {
  loadingCourses.value = true
  try {
    const res = await getCourses()
    courses.value = res || []
  } catch (e) {
    courses.value = []
  } finally {
    loadingCourses.value = false
  }
}

const selectCourse = async (course) => {
  currentCourse.value = course
  await Promise.all([
    loadExams(course.id),
    loadCourseClasses(course.id)
  ])
}

// ==================== 考试相关 ====================
const examList = ref([])
const loadingExams = ref(false)
const examStatusTab = ref('upcoming')

const upcomingExams = computed(() => examList.value.filter(e => e.status === 'upcoming'))
const ongoingExams = computed(() => examList.value.filter(e => e.status === 'ongoing'))
const finishedExams = computed(() => examList.value.filter(e => e.status === 'finished'))

const loadExams = async (courseId) => {
  loadingExams.value = true
  try {
    const res = await getExams({ courseId })
    examList.value = Array.isArray(res?.list) ? res.list : (res || [])
  } catch (e) {
    examList.value = []
  } finally {
    loadingExams.value = false
  }
}

const handleTabChange = () => {
  // Tab切换时可以做额外处理
}

// ==================== 创建考试 ====================
const createExamVisible = ref(false)
const examFormRef = ref(null)
const savingExam = ref(false)
const paperList = ref([])
const courseClasses = ref([])

const examForm = reactive({
  name: '',
  paperId: null,
  startTime: null,
  duration: 120,
  classIds: []
})

const examRules = {
  name: [{ required: true, message: '请输入考试名称', trigger: 'blur' }],
  paperId: [{ required: true, message: '请选择试卷', trigger: 'change' }],
  startTime: [{ required: true, message: '请选择开始时间', trigger: 'change' }],
  duration: [{ required: true, message: '请输入考试时长', trigger: 'blur' }],
  classIds: [{ required: true, message: '请选择教学班', trigger: 'change' }]
}

const handleCreateExam = async () => {
  if (!currentCourse.value) return
  if (!canCreateExam.value) return
  
  // 加载试卷列表
  try {
    const res = await getPapers({ courseId: currentCourse.value.id })
    paperList.value = Array.isArray(res?.list) ? res.list : (res || [])
  } catch (e) {
    paperList.value = []
  }
  
  examForm.name = ''
  examForm.paperId = null
  examForm.startTime = null
  examForm.duration = 120
  examForm.classIds = []
  createExamVisible.value = true
}

const loadCourseClasses = async (courseId) => {
  try {
    const res = await getTeachingClasses(courseId)
    courseClasses.value = res || []
  } catch (e) {
    courseClasses.value = []
  }
}

const submitExam = async () => {
  if (!examFormRef.value || !currentCourse.value) return
  await examFormRef.value.validate(async (valid) => {
    if (!valid) return
    savingExam.value = true
    try {
      const formatDateTime = (date) => {
        if (!date) return ''
        const d = new Date(date)
        return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')} ${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}:00`
      }
      
      await createExam({
        ...examForm,
        courseId: currentCourse.value.id,
        startTime: formatDateTime(examForm.startTime)
      })
      showMessage('考试创建成功', 'success')
      createExamVisible.value = false
      loadExams(currentCourse.value.id)
      loadCourses() // 刷新考试数量
    } catch (e) {
      console.error(e)
    } finally {
      savingExam.value = false
    }
  })
}

// ==================== 考试操作 ====================
const handleViewDetail = async (row) => {
  try {
    const detail = await getExamDetail(row.id)
    if (detail) {
      router.push({
        name: 'TeacherScoreManagement',
        query: {
          activeTab: 'score',
          examId: row.id
        }
      })
    } else {
      showMessage('未获取到考试详情', 'warning')
    }
  } catch (e) {
    showMessage('查看考试详情失败', 'error')
  }
}

const handleDeleteExam = (row) => {
  ElMessageBox.confirm(
    `确定要删除考试 "${row.name}" 吗？`,
    '警告',
    { confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning' }
  ).then(async () => {
    try {
      await deleteExam(row.id)
      showMessage('删除成功', 'success')
      if (currentCourse.value) {
        loadExams(currentCourse.value.id)
        loadCourses()
      }
    } catch (e) {
      console.error(e)
    }
  })
}

const handleGrade = (row) => {
  router.push({
    name: 'TeacherScoreManagement',
    query: {
      activeTab: 'grading',
      examId: row.id,
      from: 'finished'
    }
  })
}

const handleViewResults = (row) => {
  router.push({
    name: 'TeacherScoreManagement',
    query: {
      activeTab: 'analysis',
      examId: row.id,
      from: 'finished'
    }
  })
}

const monitorVisible = ref(false)
const currentMonitoredExam = ref(null)
const monitorStudents = ref([])
const monitorStats = reactive({ total: 0, online: 0, submitted: 0, abnormal: 0, actual: 0 })
const monitorFilter = ref('all')
const monitorLogs = ref([])
let monitorTimer = null

const filteredMonitorStudents = computed(() => {
  if (monitorFilter.value === 'all') return monitorStudents.value
  if (monitorFilter.value === 'abnormal') return monitorStudents.value.filter(s => (s.switchCount || 0) > 3)
  return monitorStudents.value.filter(s => s.status === monitorFilter.value)
})

const addMonitorLog = (content, type = 'info') => {
  monitorLogs.value.unshift({
    time: new Date().toLocaleTimeString(),
    content,
    type
  })
}

const getStudentStatusType = (status) => {
  const map = { online: 'success', offline: 'info', submitted: 'warning' }
  return map[status] || ''
}
const getStudentStatusText = (status) => {
  const map = { online: '考试中', offline: '离线', submitted: '已交卷' }
  return map[status] || ''
}

const initMonitorData = async () => {
  try {
    const res = await getMonitorData(currentMonitoredExam.value.id)
    monitorStudents.value = res.students || []
    monitorStats.total = res.total || 0
    monitorStats.online = res.online || 0
    monitorStats.submitted = res.submitted || 0
    monitorStats.abnormal = res.abnormal || 0
    monitorStats.actual = (res.actual !== undefined ? res.actual : ((res.online || 0) + (res.submitted || 0)))
  } catch (e) {
    monitorStudents.value = []
  }
}

const refreshMonitor = () => {
  initMonitorData()
  showMessage('数据已刷新', 'success')
}

const handleBroadcast = () => {
  ElMessageBox.prompt('请输入广播内容', '发送广播', {
    confirmButtonText: '发送',
    cancelButtonText: '取消',
  })
    .then(({ value }) => {
      addMonitorLog(`老师发送广播: ${value}`, 'info')
      showMessage('广播发送成功', 'success')
    })
    .catch(() => {})
}

const handleWarning = (student) => {
  sendWarning(currentMonitoredExam.value.id, { studentId: student.id, message: '警告' })
    .then(() => {
      addMonitorLog(`发送警告给 ${student.name}`, 'warning')
      showMessage(`已向学生 ${student.name} 发送警告`, 'warning')
    })
}

const handleForceSubmit = (student) => {
  ElMessageBox.confirm(
    `确定要强制收取 ${student.name} 的试卷吗？`,
    '警告',
    { confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning' }
  ).then(async () => {
    try {
      await forceSubmit(currentMonitoredExam.value.id, { studentIds: [student.id] })
      addMonitorLog(`强制收卷: ${student.name}`, 'danger')
      initMonitorData()
      showMessage('强制收卷成功', 'success')
    } catch (error) {
      showMessage('操作失败', 'error')
    }
  }).catch(() => {})
}

const handleForceSubmitAll = () => {
  ElMessageBox.confirm(
    '确定要收取所有考生的试卷吗？',
    '严重警告',
    { confirmButtonText: '确定', cancelButtonText: '取消', type: 'error' }
  ).then(async () => {
    try {
      const onlineIds = monitorStudents.value.filter(s => s.status === 'online').map(s => s.id)
      if (onlineIds.length > 0) {
        await forceSubmit(currentMonitoredExam.value.id, { studentIds: onlineIds })
        addMonitorLog(`批量强制收卷: ${onlineIds.length}人`, 'danger')
        initMonitorData()
        showMessage('一键收卷成功', 'success')
      } else {
        showMessage('当前无在线考生需要收卷', 'info')
      }
    } catch (error) {
      showMessage('操作失败', 'error')
    }
  }).catch(() => {})
}

const startMonitorPolling = () => {
  if (monitorTimer) clearInterval(monitorTimer)
  monitorTimer = setInterval(() => {
    initMonitorData()
  }, 5000)
}

const handleMonitor = (row) => {
  currentMonitoredExam.value = row
  monitorVisible.value = true
  monitorLogs.value = []
  addMonitorLog('监考系统启动', 'info')
  initMonitorData()
  startMonitorPolling()
}

// ==================== 考生管理 ====================
const studentManageVisible = ref(false)
const currentExam = ref(null)
const examStudents = ref([])
const loadingStudents = ref(false)

const handleManageStudents = async (row) => {
  currentExam.value = row
  studentManageVisible.value = true
  loadingStudents.value = true
  
  try {
    const res = await getExamStudents(row.id, { size: 1000 })
    const list = Array.isArray(res?.list) ? res.list : (res || [])
    examStudents.value = list.map(item => ({
      studentNo: item.studentNo,
      name: item.name,
      className: item.className,
      submitted: !!item.submitTime
    }))
  } catch (e) {
    examStudents.value = []
    showMessage('加载考生失败', 'error')
  } finally {
    loadingStudents.value = false
  }
}

// ==================== 生命周期 ====================
onMounted(() => {
  loadCourses()
})

onUnmounted(() => {
  if (monitorTimer) clearInterval(monitorTimer)
})
</script>

<style scoped>
.exam-management-container {
  height: 100%;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding-bottom: 15px;
  border-bottom: 2px solid #E4E7ED;
}

.page-title {
  margin: 0;
  font-size: 24px;
  color: #303133;
  font-family: 'PingFang SC', 'Microsoft YaHei', sans-serif;
  letter-spacing: 1px;
}

.main-content {
  height: calc(100vh - 160px);
}

.course-list-card,
.detail-card {
  height: 100%;
  overflow-y: auto;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.course-title {
  font-size: 16px;
  font-weight: 500;
}

.course-list {
  max-height: calc(100vh - 320px);
  overflow-y: auto;
}

.course-item {
  padding: 12px;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s;
  border: 1px solid #ebeef5;
  margin-bottom: 10px;
}

.course-item:hover {
  background-color: #f5f7fa;
}

.course-item.active {
  background-color: #ecf5ff;
  border-color: #409eff;
}

.course-info {
  flex: 1;
}

.course-name {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 14px;
  font-weight: 500;
  margin-bottom: 6px;
}

.course-meta {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
  color: #909399;
}

.form-tip {
  font-size: 12px;
  color: #909399;
  margin-top: 5px;
}
.monitor-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}
.monitor-body {
  display: flex;
  height: calc(100vh - 100px);
  overflow: hidden;
}
.monitor-main {
  flex: 1;
  padding-right: 20px;
  overflow-y: auto;
}
.monitor-sidebar {
  width: 300px;
  border-left: 1px solid #dcdfe6;
  padding-left: 20px;
  display: flex;
  flex-direction: column;
}
.sidebar-title {
  font-weight: bold;
  margin-bottom: 10px;
  font-size: 16px;
}
.log-list {
  flex: 1;
  overflow-y: auto;
}
.log-item {
  margin-bottom: 8px;
  font-size: 13px;
  line-height: 1.4;
}
.log-time {
  color: #909399;
  margin-right: 5px;
}
.student-card {
  height: 140px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  position: relative;
}
.abnormal-card {
  border-color: #F56C6C;
  background-color: #fef0f0;
}
.submitted-card {
  background-color: #f0f9eb;
}
.student-info {
  display: flex;
  align-items: center;
  margin-bottom: 10px;
}
.student-detail .name {
  font-weight: bold;
}
.student-detail .id {
  font-size: 12px;
  color: #909399;
}
.status-tag {
  margin-left: auto;
}
.monitor-metrics {
  display: flex;
  justify-content: space-between;
  font-size: 13px;
  color: #606266;
}
.metric-item {
  display: flex;
  flex-direction: column;
  align-items: center;
}
.metric-item .value {
  font-weight: bold;
  margin-top: 4px;
}
.danger-text {
  color: #F56C6C;
}
.card-actions {
  text-align: right;
  margin-top: 5px;
}
.student-camera-placeholder {
  height: 80px;
  background-color: #000;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 10px;
  border-radius: 4px;
  color: #fff;
}
.camera-icon {
  font-size: 24px;
}
.camera-offline {
  font-size: 12px;
  color: #909399;
}
</style>
