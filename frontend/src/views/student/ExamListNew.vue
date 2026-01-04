<template>
  <div class="exam-list-container">
    <div class="page-header">
      <h2 class="page-title">我的考试</h2>
    </div>

    <el-row :gutter="20" class="main-content">
      <!-- 左侧: 课程列表 -->
      <el-col :span="8">
        <el-card class="course-list-card">
          <template #header>
            <div class="card-header">
              <span>我的课程</span>
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
                  <span class="class-info">{{ course.className }}</span>
                  <el-tag type="info" size="small">{{ course.examCount || 0 }} 场考试</el-tag>
                </div>
              </div>
            </div>
            <el-empty v-if="filteredCourses.length === 0" description="暂无课程" />
          </div>
        </el-card>
      </el-col>

      <!-- 右侧: 考试列表 -->
      <el-col :span="16">
        <el-card class="detail-card" v-if="currentCourse">
          <template #header>
            <div class="card-header">
              <div class="course-title">
                <span>{{ currentCourse.name }}</span>
                <el-tag type="success" size="small">{{ currentCourse.className }}</el-tag>
              </div>
            </div>
          </template>

          <!-- 考试状态Tab -->
          <el-tabs v-model="statusFilter" @tab-change="handleTabChange" style="margin-bottom: 15px">
            <el-tab-pane label="全部" name="">
              <el-table :data="filteredExams" border stripe v-loading="loadingExams" @row-click="handleRowClick">
                <el-table-column prop="name" label="考试名称" min-width="200" show-overflow-tooltip />
                <el-table-column label="考试时间" width="280">
                  <template #default="{ row }">
                    {{ formatDate(row.startTime) }} 至 {{ formatDate(row.endTime) }}
                  </template>
                </el-table-column>
                <el-table-column prop="duration" label="时长(分钟)" width="100" align="center" />
                <el-table-column prop="status" label="状态" width="100" align="center">
                  <template #default="{ row }">
                    <el-tag :type="getStatusType(normalizeStatus(row))">
                      {{ getStatusText(normalizeStatus(row)) }}
                    </el-tag>
                  </template>
                </el-table-column>
                <el-table-column label="操作" fixed="right" width="120" align="center">
                  <template #default="{ row }">
                    <el-button
                      v-if="normalizeStatus(row) === 'in_progress'"
                      type="primary"
                      size="small"
                      @click.stop="handleTakeExam(row)"
                    >
                      参加考试
                    </el-button>
                    <el-button
                      v-else-if="normalizeStatus(row) === 'completed'"
                      link
                      type="primary"
                      size="small"
                      @click.stop="handleViewResult(row)"
                    >
                      查看成绩
                    </el-button>
                    <el-button
                      v-else
                      link
                      type="info"
                      size="small"
                      @click.stop="handleViewInfo(row)"
                    >
                      查看详情
                    </el-button>
                  </template>
                </el-table-column>
              </el-table>
              <el-empty v-if="filteredExams.length === 0 && !loadingExams" description="暂无考试" />
            </el-tab-pane>

            <el-tab-pane label="未开始" name="not_started">
              <el-table :data="filteredExams" border stripe v-loading="loadingExams" @row-click="handleRowClick">
                <el-table-column prop="name" label="考试名称" min-width="200" show-overflow-tooltip />
                <el-table-column label="考试时间" width="280">
                  <template #default="{ row }">
                    {{ formatDate(row.startTime) }} 至 {{ formatDate(row.endTime) }}
                  </template>
                </el-table-column>
                <el-table-column prop="duration" label="时长(分钟)" width="100" align="center" />
                <el-table-column label="操作" fixed="right" width="120" align="center">
                  <template #default="{ row }">
                    <el-button link type="info" size="small" @click.stop="handleViewInfo(row)">查看详情</el-button>
                  </template>
                </el-table-column>
              </el-table>
              <el-empty v-if="filteredExams.length === 0 && !loadingExams" description="暂无未开始的考试" />
            </el-tab-pane>

            <el-tab-pane label="进行中" name="in_progress">
              <el-table :data="filteredExams" border stripe v-loading="loadingExams" @row-click="handleRowClick">
                <el-table-column prop="name" label="考试名称" min-width="200" show-overflow-tooltip />
                <el-table-column label="考试时间" width="280">
                  <template #default="{ row }">
                    {{ formatDate(row.startTime) }} 至 {{ formatDate(row.endTime) }}
                  </template>
                </el-table-column>
                <el-table-column prop="duration" label="时长(分钟)" width="100" align="center" />
                <el-table-column label="操作" fixed="right" width="120" align="center">
                  <template #default="{ row }">
                    <el-button type="primary" size="small" @click.stop="handleTakeExam(row)">参加考试</el-button>
                  </template>
                </el-table-column>
              </el-table>
              <el-empty v-if="filteredExams.length === 0 && !loadingExams" description="暂无进行中的考试" />
            </el-tab-pane>

            <el-tab-pane label="待批阅" name="pending_grading">
              <el-table :data="filteredExams" border stripe v-loading="loadingExams" @row-click="handleRowClick">
                <el-table-column prop="name" label="考试名称" min-width="200" show-overflow-tooltip />
                <el-table-column label="考试时间" width="280">
                  <template #default="{ row }">
                    {{ formatDate(row.startTime) }} 至 {{ formatDate(row.endTime) }}
                  </template>
                </el-table-column>
                <el-table-column prop="duration" label="时长(分钟)" width="100" align="center" />
                <el-table-column label="操作" fixed="right" width="120" align="center">
                  <template #default="{ row }">
                    <el-button link type="info" size="small" @click.stop="handleViewInfo(row)">查看详情</el-button>
                  </template>
                </el-table-column>
              </el-table>
              <el-empty v-if="filteredExams.length === 0 && !loadingExams" description="暂无待批阅的考试" />
            </el-tab-pane>

            <el-tab-pane label="已完成" name="completed">
              <el-table :data="filteredExams" border stripe v-loading="loadingExams" @row-click="handleRowClick">
                <el-table-column prop="name" label="考试名称" min-width="200" show-overflow-tooltip />
                <el-table-column label="考试时间" width="280">
                  <template #default="{ row }">
                    {{ formatDate(row.startTime) }} 至 {{ formatDate(row.endTime) }}
                  </template>
                </el-table-column>
                <el-table-column prop="duration" label="时长(分钟)" width="100" align="center" />
                <el-table-column prop="score" label="成绩" width="100" align="center">
                  <template #default="{ row }">
                    <span style="color: #409eff; font-weight: bold">{{ row.score || '-' }}</span>
                  </template>
                </el-table-column>
                <el-table-column label="操作" fixed="right" width="120" align="center">
                  <template #default="{ row }">
                    <el-button link type="primary" size="small" @click.stop="handleViewResult(row)">查看成绩</el-button>
                  </template>
                </el-table-column>
              </el-table>
              <el-empty v-if="filteredExams.length === 0 && !loadingExams" description="暂无已完成的考试" />
            </el-tab-pane>
          </el-tabs>
        </el-card>

        <el-card v-else class="detail-card">
          <el-empty description="请选择左侧课程查看考试" />
        </el-card>
      </el-col>
    </el-row>

    <!-- 考试详情对话框 -->
    <el-dialog v-model="infoDialogVisible" title="考试详情" width="600px">
      <div v-if="currentExamInfo" class="exam-info-content">
        <h3 class="info-title">{{ currentExamInfo.name }}</h3>

        <el-descriptions :column="1" border size="large" class="info-desc">
          <el-descriptions-item label="课程">{{ currentCourse?.name }}</el-descriptions-item>
          <el-descriptions-item label="教学班">{{ currentCourse?.className }}</el-descriptions-item>
          <el-descriptions-item label="考试时间">
            {{ formatDate(currentExamInfo.startTime) }} <br/>至<br/> {{ formatDate(currentExamInfo.endTime) }}
          </el-descriptions-item>
          <el-descriptions-item label="考试时长">{{ currentExamInfo.duration }} 分钟</el-descriptions-item>
          <el-descriptions-item label="当前状态">
            <el-tag :type="getStatusType(normalizeStatus(currentExamInfo))" size="small">
              {{ getStatusText(normalizeStatus(currentExamInfo)) }}
            </el-tag>
          </el-descriptions-item>
        </el-descriptions>

        <div v-if="currentExamInfo.status === 'completed'" class="result-box">
          <div class="score-display">
            <span class="score-value">{{ currentExamInfo.score || 0 }}</span>
            <span class="score-label">最终得分</span>
          </div>
          <div class="result-meta">
            <div class="meta-item">
              <span class="meta-label">实际用时</span>
              <span class="meta-value">{{ formatDuration(currentExamInfo.timeTaken) }}</span>
            </div>
          </div>
        </div>

        <div v-if="currentExamInfo.status === 'pending_grading'" class="pending-box">
          <el-result icon="info" title="正在批阅中" sub-title="请耐心等待老师批改试卷">
            <template #extra>
              <p>实际用时：{{ formatDuration(currentExamInfo.timeTaken) }}</p>
            </template>
          </el-result>
        </div>
      </div>
      <template #footer>
        <el-button @click="infoDialogVisible = false">关闭</el-button>
        <el-button
          v-if="normalizeStatus(currentExamInfo) === 'in_progress'"
          type="primary"
          @click="startExamAction(currentExamInfo)"
        >
          进入考试
        </el-button>
      </template>
    </el-dialog>
    <FaceVerification v-model="faceDialogVisible" @verified="onFaceVerified" />
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, inject } from 'vue'
import { Search, Reading } from '@element-plus/icons-vue'
import { useRouter } from 'vue-router'
import request from '@/utils/request'
import FaceVerification from '@/components/FaceVerification.vue'

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
    const res = await request.get('/student/courses')
    courses.value = Array.isArray(res?.list) ? res.list : (res || [])
  } catch (e) {
    courses.value = []
  } finally {
    loadingCourses.value = false
  }
}

const selectCourse = async (course) => {
  currentCourse.value = course
  await loadExams(course.id)
}

// ==================== 考试相关 ====================
const examList = ref([])
const loadingExams = ref(false)
const statusFilter = ref('')

const filteredExams = computed(() => {
  if (!statusFilter.value) return examList.value
  return examList.value.filter(e => normalizeStatus(e) === statusFilter.value)
})

const loadExams = async (courseId) => {
  loadingExams.value = true
  try {
    const res = await request.get('/student/exams', { params: { courseId } })
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

// ==================== 工具函数 ====================
const formatDate = (ts) => {
  if (!ts) return ''
  const d = new Date(ts)
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')} ${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`
}

const formatDuration = (seconds) => {
  if (!seconds) return '0分钟'
  const h = Math.floor(seconds / 3600)
  const m = Math.floor((seconds % 3600) / 60)
  return h > 0 ? `${h}小时${m}分钟` : `${m}分钟`
}

const getStatusType = (s) => {
  const map = { 'not_started': 'info', 'in_progress': 'success', 'pending_grading': 'warning', 'completed': '' }
  return map[s]
}

const getStatusText = (s) => {
  const map = { 'not_started': '未开始', 'in_progress': '进行中', 'pending_grading': '待批阅', 'completed': '已完成' }
  return map[s]
}

const normalizeStatus = (row) => {
  const rs = row?.recordStatus
  if (typeof rs === 'number') {
    if (rs >= 2) return 'completed'
    if (rs >= 1) return 'pending_grading'
  }
  const s = row?.status
  if (typeof s === 'number') {
    if (s === 0) return 'not_started'
    if (s === 1) return 'in_progress'
    if (s === 2) return 'completed'
  }
  if (typeof s === 'string' && ['not_started', 'in_progress', 'pending_grading', 'completed'].includes(s)) {
    return s
  }
  return 'not_started'
}

// ==================== 考试操作 ====================
const infoDialogVisible = ref(false)
const currentExamInfo = ref(null)
const faceDialogVisible = ref(false)
const selectedExam = ref(null)

const handleRowClick = (row) => {
  if (normalizeStatus(row) === 'in_progress') handleTakeExam(row)
  else handleViewInfo(row)
}

const handleViewInfo = (row) => {
  currentExamInfo.value = row
  infoDialogVisible.value = true
}

const handleViewResult = (row) => {
  currentExamInfo.value = row
  infoDialogVisible.value = true
}

const handleTakeExam = (row) => {
  selectedExam.value = row
  faceDialogVisible.value = true
}

const startExamAction = (exam) => {
  infoDialogVisible.value = false
  handleTakeExam(exam)
}

const onFaceVerified = (result) => {
  if (result?.verified && selectedExam.value?.id) {
    router.push({
      name: 'TakeExam',
      params: { examId: selectedExam.value.id }
    })
  } else {
    if (showMessage) showMessage('人脸验证未通过，无法进入考试', 'error')
  }
}

// ==================== 生命周期 ====================
onMounted(() => {
  loadCourses()
})
</script>

<style scoped>
.exam-list-container {
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
  display: flex;
  align-items: center;
  gap: 10px;
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
}

.class-info {
  color: #909399;
}

.info-title {
  margin: 0 0 20px 0;
  font-size: 18px;
  text-align: center;
}

.info-desc {
  margin-bottom: 20px;
}

.result-box {
  padding: 20px;
  background: #f5f7fa;
  border-radius: 8px;
  text-align: center;
}

.score-display {
  margin-bottom: 15px;
}

.score-value {
  display: block;
  font-size: 48px;
  font-weight: bold;
  color: #409eff;
}

.score-label {
  display: block;
  font-size: 14px;
  color: #909399;
  margin-top: 5px;
}

.result-meta {
  display: flex;
  justify-content: center;
  gap: 30px;
}

.meta-item {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.meta-label {
  font-size: 12px;
  color: #909399;
}

.meta-value {
  font-size: 16px;
  font-weight: 500;
  color: #606266;
  margin-top: 5px;
}

.pending-box {
  padding: 20px;
}
</style>
