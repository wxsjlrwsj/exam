<template>
  <div class="practice-bank-container">
    <div class="page-header">
      <h2 class="page-title">练题题库</h2>
      <el-button type="primary" @click="handleUpload">
        <el-icon><Upload /></el-icon> 上传题目
      </el-button>
    </div>
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
    <el-row :gutter="20" style="margin-top: 20px;">
      <el-col :span="24">
        <el-table v-loading="loading" :data="questionList" border style="width: 100%">
          <el-table-column prop="id" label="ID" width="80" align="center" />
          <el-table-column prop="type" label="题型" width="120" align="center">
            <template #default="scope">
              <el-tag>{{ getQuestionTypeLabel(scope.row.type) }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="subject" label="学科" width="150" align="center" />
          <el-table-column prop="content" label="题目内容" show-overflow-tooltip />
          <el-table-column prop="difficulty" label="难度" width="150" align="center">
            <template #default="scope">
              <el-rate v-model="scope.row.difficulty" disabled text-color="#ff9900" />
            </template>
          </el-table-column>
          <el-table-column label="操作" width="180" align="center" fixed="right">
            <template #default="scope">
              <el-button link type="primary" @click="handleViewDetail(scope.row)">
                <el-icon><View /></el-icon> 查看
              </el-button>
              <el-button link type="warning" @click="handleAddToCollection(scope.row)">
                <el-icon><Plus /></el-icon> 添加
              </el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-col>
    </el-row>
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
    <el-dialog v-model="detailDialogVisible" title="题目详情" width="50%" custom-class="detail-dialog">
      <div v-if="currentQuestion" class="detail-content">
        <div class="detail-header-refined">
          <div class="dh-left">
            <span class="dh-type">{{ getQuestionTypeLabel(currentQuestion.type) }}</span>
            <span class="dh-subject">{{ currentQuestion.subject }}</span>
          </div>
          <div class="dh-right">
            <span class="dh-label">难度：</span>
            <el-rate v-model="currentQuestion.difficulty" disabled text-color="#ff9900" />
          </div>
        </div>
        <div class="detail-body">
          <p class="q-text">{{ currentQuestion.content }}</p>
          <div v-if="['single_choice', 'multiple_choice'].includes(currentQuestion.type)" class="q-options">
            <div v-for="opt in parseOptions(currentQuestion.options)" :key="opt.key" class="option-item">
              <span class="opt-key">{{ opt.key }}.</span>
              <span class="opt-val">{{ opt.value }}</span>
            </div>
          </div>
          <el-divider border-style="dashed" />
          <div class="q-answer-section">
            <p><strong>参考答案：</strong><span class="text-success">{{ currentQuestion.answer }}</span></p>
            <div class="analysis-box">
              <strong>解析：</strong>
              <p>{{ currentQuestion.analysis || '暂无解析' }}</p>
            </div>
          </div>
        </div>
      </div>
      <template #footer>
        <el-button @click="detailDialogVisible = false">关闭</el-button>
        <el-button type="primary" @click="handleAddToCollection(currentQuestion)">
          <el-icon><Plus /></el-icon> 添加到题集
        </el-button>
      </template>
    </el-dialog>
    <el-dialog v-model="collectionDialogVisible" title="添加到题集" width="400px">
      <div class="collection-select-list">
        <div
          v-for="c in userCollections"
          :key="c.id"
          class="collection-select-item"
          :class="{ added: c.hasQuestion }"
          @click="toggleCollection(c)"
        >
          <div class="csl-name">
            <span class="name">{{ c.name }}</span>
            <el-tag size="small" type="info">{{ c.count }}题</el-tag>
          </div>
          <div class="csl-state">
            <el-tag v-if="c.hasQuestion" type="success" size="small">已添加</el-tag>
            <el-tag v-else type="warning" size="small">未添加</el-tag>
          </div>
        </div>
      </div>
      <template #footer>
        <el-button @click="collectionDialogVisible = false">关闭</el-button>
      </template>
    </el-dialog>
    <el-dialog v-model="uploadDialogVisible" title="上传题目" width="600px">
      <el-form ref="uploadFormRef" :model="uploadForm" :rules="uploadRules" label-width="80px">
        <el-form-item label="学科" prop="subject">
          <el-input v-model="uploadForm.subject" />
        </el-form-item>
        <el-form-item label="题型">
          <el-select v-model="uploadForm.type" @change="handleTypeChange">
            <el-option v-for="item in questionTypes" :key="item.value" :label="item.label" :value="item.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="难度">
          <el-rate v-model="uploadForm.difficulty" />
        </el-form-item>
        <el-form-item label="题目" prop="content">
          <el-input v-model="uploadForm.content" type="textarea" :rows="3" />
        </el-form-item>
        <el-form-item label="选项" v-if="['single_choice','multiple_choice'].includes(uploadForm.type)">
          <div class="option-edit-list">
            <div v-for="(opt, idx) in uploadForm.options" :key="idx" class="option-edit-item">
              <span class="opt-key">{{ opt.key }}</span>
              <el-input v-model="opt.value" style="flex:1" />
              <el-button link type="danger" @click="removeOption(idx)"><el-icon><Delete /></el-icon></el-button>
            </div>
            <el-button link type="primary" @click="addOption"><el-icon><Plus /></el-icon> 添加选项</el-button>
          </div>
        </el-form-item>
        <el-form-item label="答案" prop="answer">
          <el-input v-if="uploadForm.type==='short_answer' || uploadForm.type==='fill_blank'" v-model="uploadForm.answer" />
          <el-select v-else-if="uploadForm.type==='single_choice'" v-model="uploadForm.answer">
            <el-option v-for="opt in uploadForm.options" :key="opt.key" :label="opt.key" :value="opt.key" />
          </el-select>
          <el-select v-else-if="uploadForm.type==='multiple_choice'" v-model="uploadForm.answerArr" multiple>
            <el-option v-for="opt in uploadForm.options" :key="opt.key" :label="opt.key" :value="opt.key" />
          </el-select>
          <el-radio-group v-else-if="uploadForm.type==='true_false'" v-model="uploadForm.answer">
            <el-radio label="T">正确</el-radio>
            <el-radio label="F">错误</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="解析" prop="analysis">
          <el-input v-model="uploadForm.analysis" type="textarea" :rows="2" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="uploadDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitUpload">提交审核</el-button>
      </template>
    </el-dialog>
  </div>
</template>
 
<script setup>
import { ref, reactive, onMounted, inject } from 'vue'
import { Upload, Plus, View, Delete } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import http from '@/api/http'
 
const showMessage = inject('showMessage') || ElMessage
 
const loading = ref(false)
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const questionList = ref([])
const detailDialogVisible = ref(false)
const currentQuestion = ref(null)
 
const uploadDialogVisible = ref(false)
const uploadFormRef = ref(null)
const uploadForm = reactive({
  subject: '',
  type: 'single_choice',
  difficulty: 3,
  content: '',
  options: [{key: 'A', value: ''}, {key: 'B', value: ''}, {key: 'C', value: ''}, {key: 'D', value: ''}],
  answer: '',
  answerArr: [],
  analysis: ''
})
 
const collectionDialogVisible = ref(false)
const userCollections = ref([])
const targetQuestionId = ref(null)
 
const questionTypes = [
  { label: '单选题', value: 'single_choice' },
  { label: '多选题', value: 'multiple_choice' },
  { label: '判断题', value: 'true_false' },
  { label: '填空题', value: 'fill_blank' },
  { label: '简答题', value: 'short_answer' }
]
 
const filterForm = reactive({
  type: '',
  difficulty: 0,
  subject: '',
  keyword: ''
})
 
const uploadRules = {
  subject: [{ required: true, message: '请输入学科', trigger: 'blur' }],
  content: [{ required: true, message: '请输入题目内容', trigger: 'blur' }],
  answer: [{ required: true, message: '请输入或选择答案', trigger: 'change' }]
}
 
const getQuestionTypeLabel = (type) => {
  const t = questionTypes.find(i => i.value === type)
  return t ? t.label : type
}
 
const parseOptions = (jsonStr) => {
  if (!jsonStr) return []
  try { return JSON.parse(jsonStr) } catch { return [] }
}
 
const normArray = (v) => Array.isArray(v) ? v : Array.isArray(v?.data) ? v.data : Array.isArray(v?.list) ? v.list : []
const normTotal = (v, def) => (typeof v?.total === 'number' ? v.total : def)
 
const loadQuestionList = async () => {
  loading.value = true
  try {
    const resp = await http.get('/api/student/questions', {
      params: {
        page: currentPage.value,
        pageSize: pageSize.value,
        type: filterForm.type || undefined,
        difficulty: filterForm.difficulty || undefined,
        subject: filterForm.subject || undefined,
        keyword: filterForm.keyword || undefined
      }
    })
    const list = normArray(resp)
    questionList.value = list
    total.value = normTotal(resp, list.length)
  } catch (e) {
    questionList.value = []
    total.value = 0
  } finally {
    loading.value = false
  }
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
 
const handleSizeChange = () => {
  currentPage.value = 1
  loadQuestionList()
}
const handleCurrentChange = () => {
  loadQuestionList()
}
 
const handleViewDetail = (row) => {
  currentQuestion.value = row
  detailDialogVisible.value = true
}
 
const handleUpload = () => {
  uploadDialogVisible.value = true
}
 
const handleTypeChange = () => {
  uploadForm.answer = ''
  uploadForm.answerArr = []
}
 
const addOption = () => {
  const nextKey = String.fromCharCode(65 + uploadForm.options.length)
  uploadForm.options.push({ key: nextKey, value: '' })
}
const removeOption = (index) => {
  uploadForm.options.splice(index, 1)
  uploadForm.options.forEach((opt, idx) => {
    opt.key = String.fromCharCode(65 + idx)
  })
}
 
const submitUpload = () => {
  uploadFormRef.value.validate(async (valid) => {
    if (valid) {
      if (uploadForm.type === 'multiple_choice') {
        uploadForm.answer = uploadForm.answerArr.sort().join(',')
      }
      const payload = {
        subject: uploadForm.subject,
        type: uploadForm.type,
        difficulty: uploadForm.difficulty,
        content: uploadForm.content,
        options: uploadForm.options?.length ? JSON.stringify(uploadForm.options) : null,
        answer: uploadForm.answer,
        analysis: uploadForm.analysis
      }
      try {
        await http.post('/api/student/questions/upload', payload)
        showMessage('提交成功，等待老师审核', 'success')
      } catch {}
      uploadDialogVisible.value = false
      uploadForm.content = ''
      uploadForm.analysis = ''
      uploadForm.answer = ''
      uploadForm.answerArr = []
    }
  })
}
 
const handleAddToCollection = async (row) => {
  targetQuestionId.value = row.id
  try {
    const resp = await http.get('/api/student/collections')
    const arr = normArray(resp)
    userCollections.value = arr.map(c => ({
      id: c.id,
      name: c.name,
      count: c.count ?? c.questionCount ?? 0,
      hasQuestion: false
    }))
  } catch {
    userCollections.value = []
  }
  collectionDialogVisible.value = true
}
 
const toggleCollection = async (collection) => {
  if (collection.hasQuestion) return
  try {
    await http.post(`/api/student/collections/${collection.id}/questions`, { questionId: targetQuestionId.value })
    collection.hasQuestion = true
    collection.count++
    showMessage(`已添加到 "${collection.name}"`, 'success')
  } catch {}
}
 
onMounted(() => {
  loadQuestionList()
})
</script>
 
<style scoped>
.practice-bank-container {
  padding: 20px;
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
  font-size: 24px;
  color: #303133;
  margin: 0;
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
.detail-header-refined {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}
.dh-left {
  display: flex;
  gap: 10px;
  align-items: center;
}
.q-text {
  font-size: 16px;
  line-height: 1.6;
}
.q-options .option-item {
  padding: 8px 12px;
  border: 1px solid #EBEEF5;
  border-radius: 4px;
  margin-bottom: 6px;
}
.opt-key {
  font-weight: bold;
  margin-right: 8px;
}
.collection-select-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.collection-select-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px;
  border: 1px solid #EBEEF5;
  border-radius: 6px;
  cursor: pointer;
}
.collection-select-item.added {
  border-color: #67C23A;
  background: #f0f9eb;
}
.csl-name {
  display: flex;
  align-items: center;
  gap: 10px;
}
.option-edit-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.option-edit-item {
  display: flex;
  align-items: center;
  gap: 8px;
}
@media (max-width: 768px) {
  .filter-row {
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }
}
</style>
