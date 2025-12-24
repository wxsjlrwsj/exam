<template>
  <div class="personalized-bank-container">
    <div class="page-header">
      <h2 class="page-title">个性化题库</h2>
    </div>
    <el-row :gutter="20" class="full-height-content">
      <el-col :span="6" class="sidebar-col">
        <el-card class="box-card full-height-card" shadow="never">
          <template #header>
            <div class="card-header">
              <span>我的题集</span>
              <div class="header-actions">
                <el-button v-if="!isCollectionManageMode" type="primary" plain size="small" @click="isCollectionManageMode = true">管理</el-button>
                <el-button v-else type="success" size="small" @click="isCollectionManageMode = false">完成</el-button>
                <el-button link type="primary" @click="handleAddCollection">
                  <el-icon><Plus /></el-icon>
                </el-button>
              </div>
            </div>
          </template>
          <div class="collection-list">
            <div
              v-for="item in collectionList"
              :key="item.id"
              class="collection-item"
              :class="{ active: currentCollectionId === item.id }"
              @click="handleSelectCollection(item)"
            >
              <div class="collection-info">
                <span class="collection-name">{{ item.name }}</span>
                <span class="collection-count">{{ item.count }}题</span>
              </div>
              <div class="collection-actions" v-if="isCollectionManageMode">
                <el-button link type="danger" @click.stop="handleDeleteCollection(item)">
                  <el-icon><Delete /></el-icon>
                </el-button>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="18">
        <el-card class="box-card full-height-card" shadow="never">
          <template #header>
            <div class="card-header">
              <span>{{ currentCollectionName || '请选择题集' }}</span>
              <div class="header-actions">
                <el-button type="primary" :disabled="!currentCollectionId" @click="handleStartSelfTest">开始自测</el-button>
              </div>
            </div>
          </template>
          <div class="filter-row">
            <el-select v-model="filterForm.type" placeholder="题型" clearable style="width: 140px" @change="handleSearch">
              <el-option v-for="item in questionTypes" :key="item.value" :label="item.label" :value="item.value" />
            </el-select>
            <el-input v-model="filterForm.subject" placeholder="学科" clearable style="width: 200px; margin-left: 10px;" @keyup.enter="handleSearch" />
            <el-rate v-model="filterForm.difficulty" clearable style="margin-left: 10px;" @change="handleSearch" />
            <el-button style="margin-left: 10px;" type="primary" @click="handleSearch">查询</el-button>
            <el-button @click="resetFilter">重置</el-button>
            <el-button v-if="selectedRows.length" type="danger" plain style="margin-left: auto" @click="handleBatchDelete">批量移除</el-button>
          </div>
          <el-table
            v-loading="loading"
            :data="questionList"
            border
            style="width: 100%"
            @selection-change="handleSelectionChange"
          >
            <el-table-column type="selection" width="50" />
            <el-table-column prop="id" label="ID" width="80" align="center" />
            <el-table-column prop="type" label="题型" width="120" align="center">
              <template #default="scope">
                <el-tag>{{ getQuestionTypeLabel(scope.row.type) }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="content" label="题目预览" show-overflow-tooltip />
            <el-table-column prop="subject" label="学科" width="120" align="center" />
            <el-table-column prop="difficulty" label="难度" width="150" align="center">
              <template #default="scope">
                <el-rate v-model="scope.row.difficulty" disabled text-color="#ff9900" />
              </template>
            </el-table-column>
            <el-table-column label="操作" width="120" align="center" fixed="right">
              <template #default="scope">
                <el-button link type="primary" @click="handleViewDetail(scope.row)">查看</el-button>
                <el-button link type="danger" @click="handleRemoveQuestion(scope.row)">移除</el-button>
              </template>
            </el-table-column>
          </el-table>
          <div class="pagination-container">
            <el-pagination
              v-model:current-page="currentPage"
              v-model:page-size="pageSize"
              :total="total"
              layout="prev, pager, next"
              @current-change="loadQuestions"
            />
          </div>
        </el-card>
      </el-col>
    </el-row>
    <el-dialog v-model="detailDialogVisible" title="题目详情" width="600px" custom-class="detail-dialog">
      <div v-if="currentQuestion" class="detail-content">
        <div class="detail-header">
          <el-tag size="small">{{ getQuestionTypeLabel(currentQuestion.type) }}</el-tag>
          <span class="dh-subject">{{ currentQuestion.subject }}</span>
          <span class="dh-label">难度：</span>
          <el-rate v-model="currentQuestion.difficulty" disabled text-color="#ff9900" />
        </div>
        <div class="detail-body">
          <p class="q-text">{{ currentQuestion.content }}</p>
          <div v-if="['single_choice','multiple_choice'].includes(currentQuestion.type)" class="q-options">
            <div v-for="opt in parseOptions(currentQuestion.options)" :key="opt.key" class="option-item">
              <span class="opt-key">{{ opt.key }}.</span>
              <span class="opt-val">{{ opt.value }}</span>
            </div>
          </div>
          <el-divider />
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
      </template>
    </el-dialog>
    <el-dialog v-model="testSetupVisible" title="自测配置" width="420px">
      <el-form :model="testSetupForm" label-width="90px">
        <el-form-item label="出题范围">
          <el-radio-group v-model="testSetupForm.mode">
            <el-radio label="all">全部题目</el-radio>
            <el-radio label="count">指定数量</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="题目数量" v-if="testSetupForm.mode==='count'">
          <el-input-number v-model="testSetupForm.count" :min="1" :max="currentCollectionCount" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="testSetupVisible = false">取消</el-button>
        <el-button type="primary" @click="startQuiz">开始</el-button>
      </template>
    </el-dialog>
    <el-dialog
      v-model="quizVisible"
      fullscreen
      :show-close="false"
      :close-on-click-modal="false"
      :close-on-press-escape="false"
      class="quiz-dialog"
    >
      <div class="quiz-container">
        <div class="quiz-header">
          <div class="qh-left">
            <span class="qh-title">自测模式</span>
          </div>
          <div class="qh-right">
            <el-tag type="info">用时 {{ formatTime(timer) }}</el-tag>
            <el-button type="danger" @click="quitQuiz">退出</el-button>
            <el-button type="primary" @click="submitQuiz">提交</el-button>
          </div>
        </div>
        <div class="quiz-body">
          <div class="quiz-sidebar">
            <div class="qs-title">题目列表</div>
            <div class="qs-grid">
              <div
                v-for="(q, index) in quizQuestions"
                :key="q.id"
                class="qs-item"
                :class="{ active: currentQuizIndex===index, done: isAnsweredInQuiz(q.id) }"
                @click="scrollToQuestion(index)"
              >{{ index+1 }}</div>
            </div>
          </div>
          <div class="quiz-content">
            <div v-for="(q, index) in quizQuestions" :key="q.id" :id="'q-'+index" class="quiz-question">
              <div class="qq-header">
                <span class="qq-no">{{ index+1 }}.</span>
                <el-tag size="small">{{ getQuestionTypeLabel(q.type) }}</el-tag>
              </div>
              <div class="qq-content">{{ q.content }}</div>
              <div class="qq-input">
                <div v-if="q.type==='single_choice'" class="choice-group">
                  <div
                    v-for="opt in parseOptions(q.options)"
                    :key="opt.key"
                    class="choice-item"
                    :class="{selected: userAnswers[q.id]===opt.key}"
                    @click="userAnswers[q.id]=opt.key"
                  >
                    <span class="choice-key">{{ opt.key }}</span>
                    <span class="choice-val">{{ opt.value }}</span>
                  </div>
                </div>
                <div v-else-if="q.type==='multiple_choice'" class="choice-group">
                  <div
                    v-for="opt in parseOptions(q.options)"
                    :key="opt.key"
                    class="choice-item"
                    :class="{selected: (userAnswers[q.id]||[]).includes(opt.key)}"
                    @click="toggleMultipleChoice(q.id,opt.key)"
                  >
                    <span class="choice-key">{{ opt.key }}</span>
                    <span class="choice-val">{{ opt.value }}</span>
                  </div>
                </div>
                <div v-else-if="q.type==='true_false'" class="choice-group horizontal">
                  <div class="choice-item" :class="{selected: userAnswers[q.id]==='T'}" @click="userAnswers[q.id]='T'"><span class="choice-val">正确</span></div>
                  <div class="choice-item" :class="{selected: userAnswers[q.id]==='F'}" @click="userAnswers[q.id]='F'"><span class="choice-val">错误</span></div>
                </div>
                <div v-else>
                  <el-input type="textarea" :rows="4" v-model="userAnswers[q.id]" placeholder="请输入答案" />
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </el-dialog>
    <el-dialog v-model="resultVisible" title="自测结果" width="60%" custom-class="result-dialog">
      <div class="result-summary">
        <div class="score-circle">
          <span class="sc-val">{{ quizResult.score }}</span>
          <span class="sc-label">得分</span>
        </div>
        <div class="rs-meta">
          <div class="rs-item">
            <span class="label">总分</span>
            <span class="val">{{ quizResult.totalScore }}</span>
          </div>
          <div class="rs-item">
            <span class="label">正确率</span>
            <span class="val">{{ quizResult.accuracy }}%</span>
          </div>
          <div class="rs-item">
            <span class="label">用时</span>
            <span class="val">{{ formatTime(timer) }}</span>
          </div>
        </div>
      </div>
      <el-divider />
      <div class="result-detail-list">
        <div v-for="(q, index) in quizQuestions" :key="q.id" class="result-card">
          <div class="rc-header">
            <span class="rc-index">{{ index+1 }}.</span>
            <el-tag size="small" :type="quizResult.details[q.id]?.isCorrect?'success':'danger'">
              {{ quizResult.details[q.id]?.isCorrect?'正确':'错误' }}
            </el-tag>
            <span class="rc-type">{{ getQuestionTypeLabel(q.type) }}</span>
          </div>
          <div class="rc-content">{{ q.content }}</div>
          <div class="rc-comparison">
            <div class="rc-row">
              <span class="label">您的答案：</span>
              <span class="val" :class="quizResult.details[q.id]?.isCorrect?'text-success':'text-danger'">
                {{ formatAnswer(userAnswers[q.id]) }}
              </span>
            </div>
            <div class="rc-row">
              <span class="label">正确答案：</span>
              <span class="val text-success">{{ q.answer }}</span>
            </div>
          </div>
          <div class="rc-analysis"><strong>解析：</strong> {{ q.analysis || '暂无解析' }}</div>
        </div>
      </div>
      <template #footer>
        <el-button type="primary" @click="resultVisible=false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
  </template>
 
<script setup>
import { ref, reactive, computed, onMounted, onUnmounted, inject } from 'vue'
import { Plus, Delete } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import http from '@/api/http'
 
const showMessage = inject('showMessage') || ElMessage
 
const loading = ref(false)
const collectionList = ref([])
const isCollectionManageMode = ref(false)
const currentCollectionId = ref(null)
const currentCollectionName = ref('')
const currentCollectionCount = computed(() => {
  const c = collectionList.value.find(i => i.id === currentCollectionId.value)
  return c ? Number(c.count) || 0 : 0
})
 
const questionTypes = [
  { label: '单选题', value: 'single_choice' },
  { label: '多选题', value: 'multiple_choice' },
  { label: '判断题', value: 'true_false' },
  { label: '填空题', value: 'fill_blank' },
  { label: '简答题', value: 'short_answer' }
]
 
const filterForm = reactive({ type: '', subject: '', difficulty: 0 })
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const questionList = ref([])
const selectedRows = ref([])
 
const detailDialogVisible = ref(false)
const currentQuestion = ref(null)
 
const testSetupVisible = ref(false)
const testSetupForm = reactive({ mode: 'all', count: 10 })
const quizVisible = ref(false)
const quizQuestions = ref([])
const userAnswers = ref({})
const currentQuizIndex = ref(0)
const timer = ref(0)
let timerInterval = null
const resultVisible = ref(false)
const quizResult = reactive({ score: 0, totalScore: 0, accuracy: 0, details: {} })
 
const getQuestionTypeLabel = (type) => {
  const t = questionTypes.find(i => i.value === type)
  return t ? t.label : type
}
const parseOptions = (jsonStr) => {
  if (!jsonStr) return []
  try { return JSON.parse(jsonStr) } catch { return [] }
}
const formatAnswer = (ans) => Array.isArray(ans) ? ans.join(', ') : (ans || '未作答')
const formatTime = (seconds) => {
  const m = Math.floor(seconds / 60)
  const s = seconds % 60
  return `${String(m).padStart(2,'0')}:${String(s).padStart(2,'0')}`
}
const normArray = (v) => Array.isArray(v) ? v : Array.isArray(v?.data) ? v.data : Array.isArray(v?.list) ? v.list : []
const normTotal = (v, def) => (typeof v?.total === 'number' ? v.total : def)
const handleSelectionChange = (val) => { selectedRows.value = val }
 
const loadCollections = async () => {
  try {
    const resp = await http.get('/api/student/collections')
    const arr = normArray(resp)
    collectionList.value = arr.map(c => ({
      id: c.id,
      name: c.name,
      count: c.count ?? c.questionCount ?? 0,
      isDefault: !!c.isDefault
    }))
    if (collectionList.value.length && !currentCollectionId.value) {
      handleSelectCollection(collectionList.value[0])
    }
  } catch (e) {
    collectionList.value = []
  }
}
 
const handleSelectCollection = (item) => {
  if (!item) return
  currentCollectionId.value = item.id
  currentCollectionName.value = item.name
  currentPage.value = 1
  selectedRows.value = []
  loadQuestions()
}
 
const handleAddCollection = () => {
  ElMessageBox.prompt('请输入新题集名称', '创建题集', {
    confirmButtonText: '创建',
    cancelButtonText: '取消',
    inputPlaceholder: '例如：Java复习'
  }).then(async ({ value }) => {
    if (!value) return
    try {
      await http.post('/api/student/collections', { name: value })
      showMessage('创建成功', 'success')
      loadCollections()
    } catch {}
  }).catch(() => {})
}
 
const handleDeleteCollection = (item) => {
  ElMessageBox.confirm(`确定删除题集"${item.name}"吗？`, '提示', { type: 'warning' })
    .then(async () => {
      try {
        await http.delete(`/api/student/collections/${item.id}`)
      } catch {}
      await loadCollections()
      if (currentCollectionId.value === item.id) {
        currentCollectionId.value = null
        currentCollectionName.value = ''
        questionList.value = []
      }
      showMessage('删除成功', 'success')
    })
}
 
const loadQuestions = async () => {
  if (!currentCollectionId.value) return
  loading.value = true
  try {
    const resp = await http.get(`/api/student/collections/${currentCollectionId.value}/questions`, {
      params: {
        page: currentPage.value,
        pageSize: pageSize.value,
        type: filterForm.type || undefined,
        subject: filterForm.subject || undefined,
        difficulty: filterForm.difficulty || undefined
      }
    })
    const arr = normArray(resp)
    questionList.value = arr
    total.value = normTotal(resp, arr.length)
  } catch (e) {
    questionList.value = []
    total.value = 0
  } finally {
    loading.value = false
  }
}
 
const handleSearch = () => {
  currentPage.value = 1
  loadQuestions()
}
const resetFilter = () => {
  filterForm.type = ''
  filterForm.subject = ''
  filterForm.difficulty = 0
  handleSearch()
}
 
const handleViewDetail = (row) => {
  currentQuestion.value = row
  detailDialogVisible.value = true
}
 
const handleRemoveQuestion = (row) => {
  ElMessageBox.confirm('确定将该题移出此题集吗？', '确认移除', { type: 'warning' })
    .then(async () => {
      try {
        await http.delete(`/api/student/collections/${currentCollectionId.value}/questions/${row.id}`)
      } catch {}
      const c = collectionList.value.find(i => i.id === currentCollectionId.value)
      if (c) c.count = Math.max(0, Number(c.count || 0) - 1)
      questionList.value = questionList.value.filter(q => q.id !== row.id)
      showMessage('移除成功', 'success')
    })
}
 
const handleBatchDelete = () => {
  if (!selectedRows.value.length) return
  ElMessageBox.confirm(`确定将选中的 ${selectedRows.value.length} 道题目移出此题集吗？`, '批量移除', { type: 'warning' })
    .then(async () => {
      const ids = selectedRows.value.map(r => r.id)
      try {
        await http.delete(`/api/student/collections/${currentCollectionId.value}/questions/batch`, { data: { questionIds: ids } })
      } catch {}
      questionList.value = questionList.value.filter(q => !ids.includes(q.id))
      const c = collectionList.value.find(i => i.id === currentCollectionId.value)
      if (c) c.count = Math.max(0, Number(c.count || 0) - ids.length)
      selectedRows.value = []
      showMessage('批量移除成功', 'success')
    })
}
 
const handleStartSelfTest = () => {
  if (currentCollectionCount.value === 0) {
    showMessage('该题集暂无题目', 'warning')
    return
  }
  testSetupForm.mode = 'all'
  testSetupForm.count = Math.min(10, currentCollectionCount.value)
  testSetupVisible.value = true
}
 
const startQuiz = async () => {
  let questions = [...questionList.value]
  if (testSetupForm.mode === 'count') {
    questions = questions.slice(0, testSetupForm.count)
  }
  quizQuestions.value = questions.map(q => ({ ...q }))
  userAnswers.value = {}
  quizQuestions.value.forEach(q => { if (q.type === 'multiple_choice') userAnswers.value[q.id] = [] })
  testSetupVisible.value = false
  quizVisible.value = true
  timer.value = 0
  if (timerInterval) clearInterval(timerInterval)
  timerInterval = setInterval(() => { timer.value++ }, 1000)
}
 
const isAnsweredInQuiz = (qid) => {
  const ans = userAnswers.value[qid]
  return Array.isArray(ans) ? ans.length > 0 : !!ans
}
 
const toggleMultipleChoice = (qid, key) => {
  const arr = userAnswers.value[qid] || []
  if (arr.includes(key)) {
    userAnswers.value[qid] = arr.filter(k => k !== key)
  } else {
    userAnswers.value[qid] = [...arr, key]
  }
}
 
const scrollToQuestion = (index) => {
  currentQuizIndex.value = index
  const el = document.getElementById(`q-${index}`)
  if (el) el.scrollIntoView({ behavior: 'smooth', block: 'center' })
}
 
const quitQuiz = () => {
  ElMessageBox.confirm('退出后不保存当前进度，确定退出吗？', '提示', { type: 'warning' })
    .then(() => {
      quizVisible.value = false
      if (timerInterval) clearInterval(timerInterval)
    })
}
 
const submitQuiz = () => {
  ElMessageBox.confirm('确定提交试卷吗？', '提示', { type: 'info' })
    .then(() => {
      if (timerInterval) clearInterval(timerInterval)
      calculateResult()
      quizVisible.value = false
      resultVisible.value = true
    })
}
 
const calculateResult = () => {
  let score = 0
  let correctCount = 0
  const totalQ = quizQuestions.value.length
  const details = {}
  quizQuestions.value.forEach(q => {
    let isCorrect = false
    const userAns = userAnswers.value[q.id]
    if (q.type === 'single_choice' || q.type === 'true_false') {
      isCorrect = userAns === q.answer
    } else if (q.type === 'multiple_choice') {
      const sortedUser = [...(userAns || [])].sort().join(',')
      isCorrect = sortedUser === q.answer
    } else {
      isCorrect = !!userAns
    }
    if (isCorrect) {
      score += 10
      correctCount++
    }
    details[q.id] = { isCorrect }
  })
  quizResult.score = score
  quizResult.totalScore = totalQ * 10
  quizResult.accuracy = totalQ ? Math.round((correctCount / totalQ) * 100) : 0
  quizResult.details = details
}
 
onMounted(() => { loadCollections() })
onUnmounted(() => { if (timerInterval) clearInterval(timerInterval) })
</script>
 
<style scoped>
.personalized-bank-container {
  padding: 20px;
  height: calc(100vh - 84px);
  box-sizing: border-box;
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
.full-height-content {
  height: calc(100% - 50px);
}
.full-height-card {
  height: 100%;
  display: flex;
  flex-direction: column;
}
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.header-actions {
  display: flex;
  align-items: center;
  gap: 8px;
}
.collection-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.collection-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px;
  border: 1px solid #EBEEF5;
  border-radius: 6px;
  cursor: pointer;
}
.collection-item.active {
  border-color: #409EFF;
  background: #ecf5ff;
}
.collection-info {
  display: flex;
  align-items: center;
  gap: 10px;
}
.collection-name {
  font-weight: 500;
}
.collection-count {
  color: #909399;
  font-size: 12px;
}
.filter-row {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 10px;
  margin-bottom: 10px;
}
.pagination-container {
  margin-top: 10px;
  display: flex;
  justify-content: flex-end;
}
.detail-header {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 10px;
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
.quiz-dialog :deep(.el-dialog__body) {
  padding: 0 !important;
  height: 100%;
}
.quiz-container {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background: #f5f7fa;
}
.quiz-header {
  height: 60px;
  background: white;
  padding: 0 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 2px 4px rgba(0,0,0,0.05);
}
.qh-right {
  display: flex;
  align-items: center;
  gap: 10px;
}
.quiz-body {
  flex: 1;
  display: flex;
  overflow: hidden;
}
.quiz-sidebar {
  width: 240px;
  background: white;
  border-right: 1px solid #EBEEF5;
  padding: 20px;
}
.qs-title {
  font-weight: bold;
  margin-bottom: 10px;
}
.qs-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 8px;
}
.qs-item {
  height: 34px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 1px solid #EBEEF5;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
}
.qs-item.active {
  border-color: #E6A23C;
  color: #E6A23C;
  font-weight: 600;
}
.qs-item.done {
  background: #ecf5ff;
  border-color: #b3d8ff;
  color: #409EFF;
}
.quiz-content {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
}
.quiz-question {
  background: white;
  padding: 20px;
  border-radius: 8px;
  margin-bottom: 15px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.03);
}
.qq-header {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 10px;
}
.choice-group {
  display: flex;
  flex-direction: column;
  gap: 10px;
}
.choice-group.horizontal {
  flex-direction: row;
}
.choice-item {
  padding: 10px 12px;
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 10px;
}
.choice-item.selected {
  border-color: #409EFF;
  background: #ecf5ff;
  color: #409EFF;
}
.choice-key {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  background: #f0f2f5;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
}
.result-summary {
  display: flex;
  align-items: center;
  justify-content: space-around;
}
.score-circle {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  border: 4px solid #67C23A;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}
.sc-val {
  font-size: 24px;
  font-weight: bold;
  color: #67C23A;
}
.sc-label {
  font-size: 12px;
  color: #909399;
}
.rs-meta {
  display: flex;
  align-items: center;
  gap: 20px;
}
.rs-item {
  display: flex;
  flex-direction: column;
  align-items: center;
}
.result-detail-list {
  margin-top: 10px;
}
.result-card {
  background: white;
  padding: 15px;
  border-radius: 8px;
  margin-bottom: 10px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.03);
}
.rc-header {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 10px;
}
.rc-index {
  font-weight: 600;
}
.rc-type {
  margin-left: auto;
  color: #909399;
}
.rc-row {
  display: flex;
  align-items: center;
  gap: 10px;
  margin: 6px 0;
}
.text-success {
  color: #67C23A;
}
.text-danger {
  color: #F56C6C;
}
</style>
