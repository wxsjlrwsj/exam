<template>
  <div class="paper-management-container">
    <div class="page-header">
      <h2 class="page-title">试卷管理</h2>
    </div>

    <el-row :gutter="20" class="main-content">
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
                  <el-tag type="info" size="small">{{ course.paperCount || 0 }} 套试卷</el-tag>
                </div>
              </div>
            </div>
            <el-empty v-if="filteredCourses.length === 0" description="暂无课程" />
          </div>
        </el-card>
      </el-col>

      <el-col :span="16">
        <el-card class="detail-card" v-if="currentCourse">
          <template #header>
            <div class="card-header">
              <div class="course-title">
                <span>{{ currentCourse.name }} - 试卷管理</span>
              </div>
              <div>
                <el-button type="primary" @click="handleCreatePaper('manual')">
                  <el-icon><Edit /></el-icon>手动组卷
                </el-button>
                <el-button type="success" @click="handleCreatePaper('auto')">
                  <el-icon><MagicStick /></el-icon>智能组卷
                </el-button>
              </div>
            </div>
          </template>

          <el-table v-loading="loading" :data="paperList" border style="width: 100%">
            <el-table-column prop="name" label="试卷名称" min-width="180" />
            <el-table-column prop="questionCount" label="题目数量" width="100" />
            <el-table-column prop="totalScore" label="总分" width="80" />
            <el-table-column prop="createTime" label="创建时间" width="180" />
            <el-table-column prop="creatorId" label="创建人" width="120" />
            <el-table-column prop="status" label="状态" width="100">
              <template #default="scope">
                <el-tag :type="getPaperStatusType(scope.row.status)">
                  {{ getPaperStatusText(scope.row.status) }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="260" fixed="right">
              <template #default="scope">
                <el-button link type="primary" @click="handlePreview(scope.row)">预览</el-button>
                <el-button link type="primary" @click="handleEdit(scope.row)" v-if="scope.row.status !== 'used'">编辑</el-button>
                <el-button link type="success" @click="handleCreateExam(scope.row)">发布考试</el-button>
                <el-button link type="danger" @click="handleDelete(scope.row)" v-if="scope.row.status !== 'used'">删除</el-button>
              </template>
            </el-table-column>
          </el-table>

          <div class="pagination-container">
            <el-pagination
              v-model:current-page="currentPage"
              v-model:page-size="pageSize"
              :page-sizes="[10, 20, 30, 50]"
              layout="total, sizes, prev, pager, next, jumper"
              :total="total"
              @size-change="handleSizeChange"
              @current-change="handleCurrentChange"
            />
          </div>
        </el-card>

        <el-card v-else class="detail-card">
          <el-empty description="请选择左侧课程查看试卷" />
        </el-card>
      </el-col>
    </el-row>

    <el-dialog v-model="previewVisible" title="试卷预览" width="80%" destroy-on-close>
      <div v-loading="previewLoading">
        <div v-if="previewData" class="preview-meta">
          <div><strong>试卷名称：</strong>{{ previewData.name }}</div>
          <div><strong>科目：</strong>{{ previewData.subject }}</div>
          <div><strong>题目数量：</strong>{{ previewData.questionCount }}</div>
          <div><strong>总分：</strong>{{ previewData.totalScore }}</div>
          <div><strong>及格分：</strong>{{ previewData.passScore }}</div>
        </div>
        <el-table
          v-if="previewData"
          :data="previewData.questions || []"
          border
          style="width: 100%; margin-top: 12px"
        >
          <el-table-column prop="sortOrder" label="序号" width="80" />
          <el-table-column label="题型" width="120">
            <template #default="scope">
              {{ getQuestionTypeLabel(scope.row.type_code || scope.row.typeId || scope.row.type_id) }}
            </template>
          </el-table-column>
          <el-table-column prop="content" label="题目内容" min-width="300" />
          <el-table-column prop="score" label="分数" width="100" />
          <el-table-column prop="difficulty" label="难度" width="120">
            <template #default="scope">
              <el-rate v-model="scope.row.difficulty" disabled text-color="#ff9900" />
            </template>
          </el-table-column>
        </el-table>
      </div>
    </el-dialog>

    <el-dialog v-model="publishVisible" title="发布考试" width="600px" destroy-on-close>
      <el-form
        ref="publishFormRef"
        :model="publishForm"
        :rules="publishRules"
        label-width="100px"
      >
        <el-form-item label="考试名称" prop="name">
          <el-input v-model="publishForm.name" placeholder="请输入考试名称" />
        </el-form-item>
        <el-form-item label="试卷" prop="paperId">
          <el-input v-model="publishForm.paperId" disabled />
        </el-form-item>
        <el-form-item label="开始时间" prop="startTime">
          <el-date-picker
            v-model="publishForm.startTime"
            type="datetime"
            placeholder="选择开始时间"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="考试时长" prop="duration">
          <el-input-number v-model="publishForm.duration" :min="10" :step="10" /> 分钟
        </el-form-item>
        <el-form-item label="参考班级" prop="classIds">
          <el-select
            v-model="publishForm.classIds"
            multiple
            placeholder="请选择班级"
            style="width: 100%"
          >
            <el-option
              v-for="cls in publishClasses"
              :key="cls.id"
              :label="cls.name || cls.className || cls.label"
              :value="cls.id"
            />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="publishVisible = false">取消</el-button>
        <el-button type="primary" :loading="publishLoading" @click="submitPublish">
          确定发布
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted, inject, computed } from 'vue'
import { useRouter } from 'vue-router'
import { Edit, MagicStick, Search, Reading } from '@element-plus/icons-vue'
import { getPapers, deletePaper, getPaperDetail, createExam } from '@/api/teacher'
import { getCourses, getTeachingClasses } from '@/api/course'

const router = useRouter()
const showMessage = inject('showMessage')
const showConfirm = inject('showConfirm')

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

const creatorCourses = computed(() => {
  return courses.value.filter(isCreatorCourse)
})

const filteredCourses = computed(() => {
  const base = creatorCourses.value
  if (!courseFilter.value) return base
  return base.filter(c =>
    String(c.name || '').toLowerCase().includes(courseFilter.value.toLowerCase())
  )
})

const loading = ref(false)
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const paperList = ref([])
const previewVisible = ref(false)
const previewLoading = ref(false)
const previewData = ref(null)
const publishVisible = ref(false)
const publishLoading = ref(false)
const publishFormRef = ref(null)
const publishClasses = ref([])
const publishPaper = ref(null)

const publishForm = ref({
  name: '',
  paperId: null,
  startTime: null,
  duration: 120,
  classIds: []
})

const publishRules = {
  name: [{ required: true, message: '请输入考试名称', trigger: 'blur' }],
  paperId: [{ required: true, message: '请选择试卷', trigger: 'change' }],
  startTime: [{ required: true, message: '请选择开始时间', trigger: 'change' }],
  duration: [{ required: true, message: '请输入考试时长', trigger: 'blur' }],
  classIds: [{ required: true, message: '请选择班级', trigger: 'change' }]
}

const questionTypeMap = {
  1: '单选题',
  2: '多选题',
  3: '判断题',
  4: '填空题',
  5: '简答题',
  6: '编程题',
  SINGLE: '单选题',
  MULTI: '多选题',
  TRUE_FALSE: '判断题',
  FILL: '填空题',
  SHORT: '简答题',
  PROGRAM: '编程题'
}

const getQuestionTypeLabel = (typeId) => {
  return questionTypeMap[typeId] || '未知'
}

const getPaperStatusType = (status) => {
  switch (status) {
    case 'unused':
    case 'draft':
      return 'info'
    case 'used':
      return 'success'
    case 'published':
      return 'warning'
    default:
      return ''
  }
}

const getPaperStatusText = (status) => {
  switch (status) {
    case 'unused':
    case 'draft':
      return '未使用'
    case 'used':
      return '已使用'
    case 'published':
      return '已发布'
    default:
      return '未知'
  }
}

const loadPaperList = async () => {
  loading.value = true
  try {
    const params = { page: currentPage.value, size: pageSize.value }
    if (currentCourse.value?.id) {
      params.courseId = currentCourse.value.id
    }
    const res = await getPapers(params)
    paperList.value = res?.list || []
    total.value = res?.total || 0
  } catch (error) {
    if (error?.response?.status === 403) {
      showMessage(error.response?.data?.message || '无权限查看该课程试卷', 'error')
    }
    paperList.value = []
    total.value = 0
  } finally {
    loading.value = false
  }
}

const handleCurrentChange = () => {
  loadPaperList()
}

const handleSizeChange = () => {
  currentPage.value = 1
  loadPaperList()
}

const handleCreatePaper = (type) => {
  if (type === 'manual') {
    const query = currentCourse.value?.name ? { subject: currentCourse.value.name } : {}
    router.push({ path: '/dashboard/teacher/paper-compose', query })
    return
  }
  const query = currentCourse.value?.name ? { subject: currentCourse.value.name } : {}
  router.push({ path: '/dashboard/teacher/paper-auto', query })
}

const handlePreview = (row) => {
  previewVisible.value = true
  previewLoading.value = true
  previewData.value = null
  getPaperDetail(row.id)
    .then((res) => {
      previewData.value = res
    })
    .finally(() => {
      previewLoading.value = false
    })
}

const handleEdit = (row) => {
  router.push({
    path: '/dashboard/teacher/paper-compose',
    query: { paperId: row.id }
  })
}

const handleCreateExam = (row) => {
  publishPaper.value = row
  publishForm.value = {
    name: `${row.name}（考试）`,
    paperId: row.id,
    startTime: null,
    duration: 120,
    classIds: []
  }
  publishVisible.value = true
  loadPublishClasses()
}

const handleDelete = (row) => {
  showConfirm(`确定要删除试卷"${row.name}"吗？`, '删除确认', 'warning')
    .then(async () => {
      await deletePaper(row.id)
      showMessage('删除成功', 'success')
      loadPaperList()
    })
    .catch(() => {})
}

const loadCourses = async () => {
  loadingCourses.value = true
  try {
    const res = await getCourses()
    courses.value = res || []
    if (currentCourse.value && !courses.value.some(c => c.id === currentCourse.value.id && isCreatorCourse(c))) {
      currentCourse.value = null
      paperList.value = []
      total.value = 0
    }
  } catch (e) {
    courses.value = []
  } finally {
    loadingCourses.value = false
  }
}

const selectCourse = async (course) => {
  currentCourse.value = course
  currentPage.value = 1
  await Promise.all([loadPaperList(), loadCourseClasses(course.id)])
}

onMounted(() => {
  loadCourses()
})

const loadPublishClasses = async () => {
  try {
    if (!currentCourse.value?.id) {
      publishClasses.value = []
      return
    }
    const res = await getTeachingClasses(currentCourse.value.id)
    publishClasses.value = Array.isArray(res) ? res : (res?.list || [])
  } catch (error) {
    publishClasses.value = []
  }
}

const submitPublish = async () => {
  if (!publishFormRef.value) return
  await publishFormRef.value.validate(async (valid) => {
    if (!valid) return
    publishLoading.value = true
    try {
      const formatDateTime = (date) => {
        if (!date) return ''
        const d = new Date(date)
        return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')} ${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}:00`
      }

      await createExam({
        name: publishForm.value.name,
        paperId: publishForm.value.paperId,
        startTime: formatDateTime(publishForm.value.startTime),
        duration: publishForm.value.duration,
        classIds: publishForm.value.classIds,
        courseId: currentCourse.value?.id
      })
      showMessage('考试发布成功', 'success')
      publishVisible.value = false
    } catch (error) {
      showMessage(error.response?.data?.message || '发布失败', 'error')
    } finally {
      publishLoading.value = false
    }
  })
}
</script>

<style scoped>
.paper-management-container { height: 100%; }

.main-content {
  height: calc(100vh - 160px);
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

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

.preview-meta {
  display: grid;
  gap: 6px;
}

.paper-management-container :deep(.el-table__cell) {
  overflow: visible;
}

.paper-management-container :deep(.el-rate) {
  display: inline-flex;
  align-items: center;
}

.paper-management-container :deep(.el-rate__icon) {
  font-size: 14px;
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
</style>
