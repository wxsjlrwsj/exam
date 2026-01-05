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
              <el-button type="primary" @click="handleCreateExam">
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
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, inject } from 'vue'
import { Plus, Search, Reading } from '@element-plus/icons-vue'
import { ElMessageBox } from 'element-plus'
import { useRouter } from 'vue-router'
import { getCourses, getTeachingClasses } from '@/api/course'
import { getExams, createExam, deleteExam, getPapers } from '@/api/teacher'

const router = useRouter()
const showMessage = inject('showMessage')

// ==================== 课程相关 ====================
const courses = ref([])
const currentCourse = ref(null)
const loadingCourses = ref(false)
const courseFilter = ref('')

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
  
  // 加载试卷列表
  try {
    const res = await getPapers({ courseId: currentCourse.value.id })
    paperList.value = res.data || []
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
const handleViewDetail = (row) => {
  showMessage(`查看考试详情: ${row.name}`, 'info')
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

const handleMonitor = (row) => {
  showMessage('监考功能开发中...', 'info')
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
  
  // 模拟加载考生数据
  try {
    // TODO: 调用API获取考生列表
    examStudents.value = []
    showMessage('考生数据加载中...', 'info')
  } catch (e) {
    examStudents.value = []
  } finally {
    loadingStudents.value = false
  }
}

// ==================== 生命周期 ====================
onMounted(() => {
  loadCourses()
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
</style>
