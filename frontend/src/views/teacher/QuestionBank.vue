<template>
  <div class="question-bank-container">
    <div class="page-header">
      <h2 class="page-title">考题管理</h2>
      <div class="header-actions">
        <input ref="fileInputRef" type="file" @change="onImportFileChange" style="display:none" />
        <el-button type="success" @click="handleImport">
          <el-icon><Upload /></el-icon>批量导入
        </el-button>
        <el-button type="info" @click="handleDownloadTemplate">
          <el-icon><Download /></el-icon>下载模板
        </el-button>
        <el-button type="primary" @click="handleAddQuestion">
          <el-icon><Plus /></el-icon>添加题目
        </el-button>
      </div>
    </div>
    
    <div class="layout-container" style="display: flex; gap: 20px;">
      <div class="sidebar" style="width: 240px; flex-shrink: 0;">
        <el-card class="box-card" shadow="never" :body-style="{ padding: '0' }">
            <template #header>
              <div class="card-header">
                <span>所授课程</span>
              </div>
            </template>
            <el-menu
              :default-active="activeSubject"
              class="subject-menu"
              @select="handleSubjectSelect"
              style="border-right: none;"
            >
              <el-menu-item v-for="item in subjectList" :key="item.name" :index="item.name">
                <el-icon><Document /></el-icon>
                <span>{{ item.name }}</span>
              </el-menu-item>
            </el-menu>
          </el-card>
      </div>
      
      <div class="main-content" style="flex: 1; min-width: 0;">
        <el-card class="filter-card">
      <el-form :inline="true" :model="filterForm" class="filter-form">
        <el-form-item label="题目类型">
          <el-select v-model="filterForm.type" placeholder="全部题型" clearable style="width: 150px">
            <el-option v-for="item in questionTypes" :key="item.value" :label="item.label" :value="item.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="难度">
          <el-select v-model="filterForm.difficulty" placeholder="全部难度" clearable style="width: 150px">
            <el-option label="简单 (1-2星)" :value="1" />
            <el-option label="中等 (3星)" :value="3" />
            <el-option label="困难 (4-5星)" :value="5" />
          </el-select>
        </el-form-item>
        <el-form-item label="关键词">
          <el-input v-model="filterForm.keyword" placeholder="题目内容/知识点" clearable style="width: 200px" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="resetFilter">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-table v-loading="loading" :data="questionList" border style="width: 100%">
      <el-table-column prop="id" label="ID" width="80" align="center" />
      <el-table-column prop="type" label="题型" width="100" align="center">
        <template #default="scope">
          <el-tag :type="getQuestionTypeTag(scope.row.type)">{{ getQuestionTypeLabel(scope.row.type) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="content" label="题目内容" min-width="300" show-overflow-tooltip />
      <el-table-column prop="knowledgePoints" label="知识点" width="150">
          <template #default="scope">
          <el-tag v-for="tag in scope.row.knowledgePoints" :key="tag" size="small" class="mr-1">{{ tag }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="subject" label="学科" width="120" align="center" />
      <el-table-column prop="difficulty" label="难度" width="120" align="center">
        <template #default="scope">
          <el-rate
            v-model="scope.row.difficulty"
            disabled
            text-color="#ff9900"
          />
        </template>
      </el-table-column>
      <el-table-column prop="creatorId" label="创建人ID" width="120" align="center" />
      <el-table-column prop="fileId" label="文件ID" width="160" align="center" />
      <el-table-column prop="status" label="状态" width="120" align="center">
        <template #default="scope">
          <el-tag v-if="scope.row.status === 1" type="success">启用</el-tag>
          <el-tag v-else type="info">禁用</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="createTime" label="创建时间" width="160" align="center" />
      <el-table-column label="操作" width="200" fixed="right" align="center">
        <template #default="scope">
          <el-button link type="primary" @click="handleEdit(scope.row)">编辑</el-button>
          <el-button link type="primary" @click="handlePreview(scope.row)">预览</el-button>
          <el-button link type="warning" @click="handleToggleStatus(scope.row)">{{ scope.row.status === 1 ? '停用' : '启用' }}</el-button>
          <el-button link type="danger" @click="handleDelete(scope.row)">删除</el-button>
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
    </div>
    </div>

    <!-- Add/Edit Dialog using shared component -->
    <QuestionFormDialog
      v-model:visible="dialogVisible"
      :mode="dialogType"
      :initial-data="currentQuestionData"
      :submitting="submitting"
      :subjects="subjectList"
      @submit="handleQuestionSubmit"
    />

    <!-- Preview Dialog -->
    <el-dialog v-model="previewVisible" title="题目预览" width="500px">
      <div v-if="currentQuestion" class="preview-content">
        <div class="preview-type">
          <el-tag>{{ getQuestionTypeLabel(currentQuestion.type) }}</el-tag>
          <el-rate v-model="currentQuestion.difficulty" disabled text-color="#ff9900" class="ml-2" />
        </div>
        <div class="preview-body mt-2">
          <strong>题目：</strong> {{ currentQuestion.content }}
        </div>
        <div v-if="currentQuestion.options && currentQuestion.options.length" class="preview-options mt-2">
          <div v-for="opt in currentQuestion.options" :key="opt.key" class="preview-option">
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
import { Plus, Upload, Delete, Document, Collection, Menu, Download } from '@element-plus/icons-vue'
import QuestionFormDialog from '@/components/QuestionFormDialog.vue'
import { getExamQuestions, createExamQuestion, updateExamQuestion, deleteExamQuestion, getSubjects, importExamQuestions } from '@/api/teacher'
import { filterValidQuestions } from '@/utils/dataValidator'
import http from '@/utils/request'

const showMessage = inject('showMessage')
const showConfirm = inject('showConfirm')

const loading = ref(false)
const submitting = ref(false)
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const questionList = ref([])
const subjectList = ref([])
const activeSubject = ref('')

const dialogVisible = ref(false)
const previewVisible = ref(false)
const dialogType = ref('add')
const currentQuestion = ref(null) // For preview
const currentQuestionData = ref({}) // For edit form

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
  difficulty: '',
  keyword: '',
  subject: ''
})

const loadSubjects = async () => {
  try {
    const res = await getSubjects()
    if (res && Array.isArray(res)) {
      subjectList.value = res
      // Default select first subject
      if (res.length > 0 && !activeSubject.value) {
        activeSubject.value = res[0].name
        filterForm.subject = res[0].name
        loadData()
      }
    } else {
      subjectList.value = []
    }
  } catch (error) {
    console.error('Failed to load subjects', error)
  }
}

const handleSubjectSelect = (index) => {
  activeSubject.value = index
  filterForm.subject = index
  currentPage.value = 1 // Reset to first page
  loadData()
}

const getQuestionTypeLabel = (type) => {
  const found = questionTypes.find(item => item.value === type)
  return found ? found.label : '未知'
}

const getQuestionTypeTag = (type) => {
  const map = {
    'single_choice': '',
    'multiple_choice': 'success',
    'true_false': 'warning',
    'fill_blank': 'info',
    'short_answer': 'danger',
    'programming': ''
  }
  return map[type] || ''
}

const loadData = async () => {
  loading.value = true
  try {
    const params = {
      page: currentPage.value,
      size: pageSize.value,
      ...filterForm
    }
    const res = await getExamQuestions(params)
    // Adapt response if needed, assuming API returns { list: [], total: 0 } or { data: { list: [], total: 0 } }
    // Based on request.js interceptor, it returns res.data directly if code===200
    if (res && res.list) {
        // 过滤掉无效数据，只显示数据库中真实存在的题目
        const validQuestions = filterValidQuestions(res.list).map(adaptExamQuestion)
        questionList.value = validQuestions
        total.value = res.total
        
        // 如果过滤后数据减少，提示用户
        if (validQuestions.length < res.list.length) {
          console.warn(`过滤掉 ${res.list.length - validQuestions.length} 条无效题目数据`)
        }
    } else {
        questionList.value = []
        total.value = 0
    }
  } catch (error) {
    console.error('Load data failed:', error)
    questionList.value = []
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  currentPage.value = 1
  loadData()
}

const resetFilter = () => {
  filterForm.type = ''
  filterForm.difficulty = ''
  filterForm.keyword = ''
  handleSearch()
}

const handleAddQuestion = () => {
  dialogType.value = 'add'
  currentQuestionData.value = { subject: activeSubject.value }
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
      await createExamQuestion(formData)
      showMessage('添加成功', 'success')
    } else {
      await updateExamQuestion(currentQuestionData.value.id, formData)
      showMessage('修改成功', 'success')
    }
    dialogVisible.value = false
    loadData()
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

const adaptExamQuestion = (q) => {
  const r = { ...q }
  try {
    if (typeof r.options === 'string' && r.options.trim().length) {
      const parsed = JSON.parse(r.options)
      r.options = Array.isArray(parsed) ? parsed : []
    } else if (!Array.isArray(r.options)) {
      r.options = []
    }
  } catch {
    r.options = []
  }
  if (typeof r.knowledgePoints === 'string') {
    const normalized = r.knowledgePoints
      .replace(/\uFF0C/g, ',')
      .replace(/\uFF1B/g, ';')
      .replace(/[|/]/g, ',')
    r.knowledgePoints = normalized.split(/[,\s;]+/).map(s => s.trim()).filter(Boolean)
  } else if (!Array.isArray(r.knowledgePoints)) {
    r.knowledgePoints = []
  }
  return r
}

const handleDelete = (row) => {
  showConfirm('确定要删除该题目吗？', '提示', 'warning')
    .then(async () => {
      try {
        await deleteExamQuestion(row.id)
        showMessage('删除成功', 'success')
        loadData()
      } catch (error) {
        console.error(error)
        showMessage('删除失败', 'error')
      }
    })
    .catch(() => {})
}

const handleToggleStatus = async (row) => {
  try {
    const next = row.status === 1 ? 0 : 1
    await updateExamQuestion(row.id, { status: next })
    showMessage(next === 1 ? '已启用' : '已停用', 'success')
    loadData()
  } catch (e) {
    showMessage('状态更新失败', 'error')
  }
}

const handleImport = () => {
  if (fileInputRef.value) fileInputRef.value.click()
}

const fileInputRef = ref(null)
const handleDownloadTemplate = async () => {
  try {
    const blob = await http.get('/exam-questions/import/template', { responseType: 'blob' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = '题库导入模板.xlsx'
    document.body.appendChild(a)
    a.click()
    a.remove()
    URL.revokeObjectURL(url)
  } catch (e) {
    showMessage('下载失败', 'error')
  }
}
const onImportFileChange = async (e) => {
  const file = e.target.files?.[0]
  if (!file) return
  const form = new FormData()
  form.append('file', file)
  try {
    const res = await importExamQuestions(form)
    const imported = res?.imported ?? 0
    showMessage(`导入成功：${imported} 条`, 'success')
    loadData()
  } catch (error) {
    showMessage('导入失败', 'error')
  } finally {
    e.target.value = ''
  }
}

const handleSizeChange = (val) => {
  pageSize.value = val
  loadData()
}

const handleCurrentChange = (val) => {
  currentPage.value = val
  loadData()
}

onMounted(() => {
  loadSubjects()
  loadData()
})
</script>

<style scoped>
.question-bank-container {
  padding: 20px;
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

.filter-card {
  margin-bottom: 20px;
}

.mr-1 {
  margin-right: 5px;
}

.ml-2 {
  margin-left: 10px;
}

.mt-2 {
  margin-top: 10px;
}

.mt-1 {
  margin-top: 5px;
}

.preview-content {
  padding: 10px;
}

.preview-option {
  padding: 5px 0;
}
</style>
