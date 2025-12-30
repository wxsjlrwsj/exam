<template>
  <div class="question-bank-container">
    <div class="page-header">
      <h2 class="page-title">考题题库</h2>
      <div class="header-actions">
        <el-button type="success" @click="handleImport">
          <el-icon><Upload /></el-icon>批量导入
        </el-button>
        <el-button type="primary" @click="handleAddQuestion">
          <el-icon><Plus /></el-icon>添加题目
        </el-button>
        <input ref="importInput" class="import-input" type="file" accept=".xlsx,.xls" @change="handleImportFile" />
      </div>
    </div>

    <el-tabs v-model="activeTab" class="demo-tabs" @tab-change="handleTabChange">
      <el-tab-pane label="题目列表" name="list">
        <el-card class="filter-card" shadow="never">
          <div class="filter-row">
            <span class="filter-label">题目类型：</span>
            <el-radio-group v-model="filterForm.type" size="default" @change="handleSearch">
              <el-radio-button label="">全部</el-radio-button>
              <el-radio-button v-for="item in questionTypes" :key="item.value" :label="item.value">{{ item.label }}</el-radio-button>
            </el-radio-group>
          </div>
          <div class="filter-row" style="margin-top: 15px;">
            <span class="filter-label">难度筛选：</span>
            <el-rate v-model="filterForm.difficulty" @change="handleSearch" clearable />
            <span class="filter-label" style="margin-left: 30px;">学科搜索：</span>
            <el-input v-model="filterForm.subject" placeholder="例如: Java" clearable style="width: 200px" @keyup.enter="handleSearch" />
            <span class="filter-label" style="margin-left: 20px;">关键词：</span>
            <el-input v-model="filterForm.keyword" placeholder="题目内容关键词" clearable style="width: 250px" @keyup.enter="handleSearch" />
            <el-button type="primary" @click="handleSearch" style="margin-left: 20px;">查询</el-button>
            <el-button @click="resetFilter">重置</el-button>
          </div>
        </el-card>

        <el-table v-loading="loading" :data="questionList" border style="width: 100%">
          <el-table-column prop="id" label="ID" width="80" align="center" />
          <el-table-column prop="type" label="题型" width="120" align="center">
            <template #default="scope">
              <el-tag effect="light" type="info">{{ getQuestionTypeLabel(scope.row.type) }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="subject" label="学科" width="150" align="center" />
          <el-table-column prop="content" label="题目内容" show-overflow-tooltip />
          <el-table-column prop="difficulty" label="难度" width="150" align="center">
            <template #default="scope">
              <el-rate v-model="scope.row.difficulty" disabled text-color="#ff9900" />
            </template>
          </el-table-column>
          <el-table-column label="操作" width="200" fixed="right" align="center">
            <template #default="scope">
              <el-button link type="primary" @click="handleEdit(scope.row)">编辑</el-button>
              <el-button link type="primary" @click="handlePreview(scope.row)">预览</el-button>
              <el-button link type="danger" @click="handleDelete(scope.row)">删除</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>

      <el-tab-pane label="待审核题目" name="audit">
        <template #label>
          <span class="custom-tabs-label">
            <span>待审核题目</span>
            <el-badge :value="auditCount" class="item" v-if="auditCount > 0" type="danger" style="margin-left: 5px; vertical-align: super;" />
          </span>
        </template>
        <el-table v-loading="loading" :data="auditList" border style="width: 100%">
          <el-table-column prop="id" label="ID" width="80" />
          <el-table-column prop="typeCode" label="题型" width="120">
            <template #default="scope">
              {{ getQuestionTypeLabel(scope.row.typeCode || scope.row.type) }}
            </template>
          </el-table-column>
          <el-table-column prop="content" label="题目内容" show-overflow-tooltip />
          <el-table-column prop="submitterName" label="上传学生" width="120" />
          <el-table-column prop="submitTime" label="上传时间" width="180" />
          <el-table-column label="操作" width="200" fixed="right">
            <template #default="scope">
              <el-button link type="success" @click="handleApprove(scope.row)">通过</el-button>
              <el-button link type="warning" @click="handleReject(scope.row)">驳回</el-button>
              <el-button link type="primary" @click="handlePreview(scope.row)">查看详情</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>
    </el-tabs>

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

    <QuestionFormDialog
      v-model:visible="dialogVisible"
      :mode="dialogType"
      :initial-data="currentQuestionData"
      :submitting="submitting"
      :subjects="subjectList"
      @submit="handleQuestionSubmit"
    />

    <el-dialog v-model="previewVisible" title="题目预览" width="500px">
      <div v-if="currentQuestion" class="preview-content">
        <div class="preview-type">
          <el-tag>{{ getQuestionTypeLabel(currentQuestion.type) }}</el-tag>
          <el-rate v-model="currentQuestion.difficulty" disabled text-color="#ff9900" class="ml-2" />
        </div>
        <div class="preview-body mt-2">
          <strong>题目：</strong> {{ currentQuestion.content }}
        </div>
        <div v-if="getPreviewOptions(currentQuestion).length" class="preview-options mt-2">
          <div v-for="opt in getPreviewOptions(currentQuestion)" :key="opt.key" class="preview-option">
            {{ opt.key }}. {{ opt.value }}
          </div>
        </div>
        <el-divider />
        <div class="preview-answer">
          <strong>正确答案：</strong> {{ currentQuestion.answer }}
        </div>
        <div class="preview-analysis mt-1">
          <strong>解析：</strong> {{ currentQuestion.analysis || '暂无解析' }}
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, inject } from 'vue'
import { Plus, Upload } from '@element-plus/icons-vue'
import QuestionFormDialog from '@/components/QuestionFormDialog.vue'
import { getQuestions, createQuestion, updateQuestion, deleteQuestion, importQuestions, auditQuestion, getSubjects, getAuditQuestions } from '@/api/teacher'
import { filterValidQuestions } from '@/utils/dataValidator'

const showMessage = inject('showMessage')
const showConfirm = inject('showConfirm')

const loading = ref(false)
const submitting = ref(false)
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const questionList = ref([])
const auditList = ref([])
const activeTab = ref('list')
const auditCount = ref(0)
const subjectList = ref([])

const dialogVisible = ref(false)
const previewVisible = ref(false)
const dialogType = ref('add')
const currentQuestionData = ref({})
const currentQuestion = ref(null)
const importInput = ref(null)
const importing = ref(false)

const questionTypes = [
  { label: '单选题', value: 'single_choice' },
  { label: '多选题', value: 'multiple_choice' },
  { label: '判断题', value: 'true_false' },
  { label: '填空题', value: 'fill_blank' },
  { label: '简答题', value: 'short_answer' },
  { label: '编程题', value: 'programming' }
]

const filterForm = reactive({
  type: '',
  difficulty: 0,
  subject: '',
  keyword: ''
})

const loadSubjects = async () => {
  try {
    const res = await getSubjects()
    if (res && Array.isArray(res)) {
      subjectList.value = res
    }
  } catch (error) {
    console.error('Failed to load subjects', error)
  }
}

const resolveSubjectId = () => {
  const name = (filterForm.subject || '').trim()
  if (!name) return null
  const match = subjectList.value.find(item => item.name === name)
  return match ? match.id : null
}

const getQuestionTypeLabel = (type) => {
  const found = questionTypes.find(item => item.value === type)
  return found ? found.label : '未知'
}

const parseOptions = (value) => {
  if (!value) return []
  if (Array.isArray(value)) return value
  if (typeof value === 'string') {
    try {
      return JSON.parse(value)
    } catch (error) {
      return []
    }
  }
  return []
}

const getPreviewOptions = (question) => {
  if (!question) return []
  return parseOptions(question.options)
}

const loadQuestionList = async () => {
  loading.value = true
  try {
    if (activeTab.value === 'list') {
      const params = {
        page: currentPage.value,
        size: pageSize.value,
        ...filterForm,
        status: 'approved'
      }
      if (!params.difficulty || params.difficulty <= 0) {
        delete params.difficulty
      }
      const res = await getQuestions(params)
      const validQuestions = filterValidQuestions(res.list || [])
      questionList.value = validQuestions
      total.value = res.total || 0

      if (res.list && validQuestions.length < res.list.length) {
        console.warn(`过滤掉${res.list.length - validQuestions.length}条无效题目数据`)
      }
    } else {
      const params = {
        pageNum: currentPage.value,
        pageSize: pageSize.value,
        status: 0
      }
      const subjectId = resolveSubjectId()
      if (subjectId) {
        params.subjectId = subjectId
      }
      const res = await getAuditQuestions(params)
      auditList.value = res.list || []
      total.value = res.total || 0
      auditCount.value = res.total || 0
    }
  } catch (error) {
    console.error(error)
    questionList.value = []
    auditList.value = []
  } finally {
    loading.value = false
  }
}

const handleTabChange = () => {
  currentPage.value = 1
  loadQuestionList()
}

const handleSearch = () => {
  currentPage.value = 1
  loadQuestionList()
}

const resetFilter = () => {
  filterForm.type = ''
  filterForm.difficulty = 0
  filterForm.subject = ''
  filterForm.keyword = ''
  handleSearch()
}

const handleCurrentChange = () => {
  loadQuestionList()
}

const handleSizeChange = () => {
  currentPage.value = 1
  loadQuestionList()
}

const handleAddQuestion = () => {
  dialogType.value = 'add'
  const defaultSubject = filterForm.subject || (subjectList.value[0] ? subjectList.value[0].name : '')
  currentQuestionData.value = { subject: defaultSubject }
  dialogVisible.value = true
}

const handleEdit = (row) => {
  dialogType.value = 'edit'
  currentQuestionData.value = { ...row }
  dialogVisible.value = true
}

const handleQuestionSubmit = async (formData) => {
  submitting.value = true
  try {
    if (dialogType.value === 'add') {
      await createQuestion(formData)
      showMessage('添加成功', 'success')
    } else {
      await updateQuestion(currentQuestionData.value.id, formData)
      showMessage('修改成功', 'success')
    }
    dialogVisible.value = false
    loadQuestionList()
  } catch (error) {
    console.error(error)
    showMessage('操作失败', 'error')
  } finally {
    submitting.value = false
  }
}

const handlePreview = (row) => {
  currentQuestion.value = row
  previewVisible.value = true
}

const handleDelete = (row) => {
  showConfirm('确定要删除该题目吗？', '提示', 'warning')
    .then(async () => {
      try {
        await deleteQuestion(row.id)
        showMessage('删除成功', 'success')
        loadQuestionList()
      } catch (error) {
        console.error(error)
        showMessage('删除失败', 'error')
      }
    })
    .catch(() => {})
}


const handleImport = () => {
  if (importing.value) return
  if (importInput.value) {
    importInput.value.value = ''
    importInput.value.click()
  }
}

const handleImportFile = async (event) => {
  const file = event?.target?.files?.[0]
  if (!file) return
  importing.value = true
  try {
    const formData = new FormData()
    formData.append('file', file)
    const res = await importQuestions(formData)
    const imported = res?.imported ?? 0
    const failed = res?.failed ?? 0
    showMessage(`Import completed: ${imported} success, ${failed} failed`, 'success')
    if (res?.errors?.length) {
      console.warn('Import errors:', res.errors)
    }
    loadQuestionList()
  } catch (error) {
    console.error(error)
    showMessage('Import failed', 'error')
  } finally {
    importing.value = false
  }
}

const handleApprove = (row) => {
  showConfirm('确定通过该题目吗？', '审核', 'success')
    .then(async () => {
      try {
        await auditQuestion(row.id, { status: 'approved' })
        showMessage('审核通过', 'success')
        loadQuestionList()
      } catch (error) {
        console.error(error)
        showMessage('操作失败', 'error')
      }
    })
    .catch(() => {})
}

const handleReject = (row) => {
  showConfirm('确定驳回该题目吗？', '审核', 'warning')
    .then(async () => {
      try {
        await auditQuestion(row.id, { status: 'rejected' })
        showMessage('已驳回', 'success')
        loadQuestionList()
      } catch (error) {
        console.error(error)
        showMessage('操作失败', 'error')
      }
    })
    .catch(() => {})
}

onMounted(() => {
  loadSubjects()
  loadQuestionList()
})
</script>

<style scoped>
.question-bank-container {
  padding: 20px;
}

.filter-card {
  margin-bottom: 20px;
}

.filter-row {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
}

.filter-label {
  font-weight: bold;
  color: #606266;
  margin-right: 10px;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.page-title {
  font-size: 20px;
  font-weight: bold;
}

.header-actions {
  display: flex;
  gap: 12px;
}

.import-input {
  display: none;
}
</style>
