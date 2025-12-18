<template>
  <div class="question-bank-container">
    <div class="page-header">
      <h2 class="page-title">考题题库查看</h2>
      <el-button type="primary" @click="openAddDialog">
        <el-icon><Plus /></el-icon>添加题目
      </el-button>
    </div>
    
    <el-card class="filter-card">
      <el-form :inline="true" :model="filterForm" class="filter-form">
        <el-form-item label="题目类型">
          <el-select v-model="filterForm.type" placeholder="请选择题型" clearable>
            <el-option v-for="item in questionTypes" :key="item.value" :label="item.label" :value="item.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="关键词">
          <el-input v-model="filterForm.keyword" placeholder="请输入关键词" clearable />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="resetFilter">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>
    
    <el-table v-loading="loading" :data="questionList" border style="width: 100%">
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="typeId" label="题型" width="120">
        <template #default="scope">
          {{ getQuestionTypeLabel(scope.row.typeId) }}
        </template>
      </el-table-column>
      <el-table-column prop="content" label="题目内容" show-overflow-tooltip />
      <el-table-column prop="difficulty" label="难度" width="100">
        <template #default="scope">
          <el-rate
            v-model="scope.row.difficulty"
            disabled
            text-color="#ff9900"
          />
        </template>
      </el-table-column>
      <el-table-column prop="createTime" label="创建时间" width="180" />
      <el-table-column label="操作" width="200" fixed="right">
        <template #default="scope">
          <el-button link type="primary" @click="handleEdit(scope.row)">编辑</el-button>
          <el-button link type="primary" @click="handlePreview(scope.row)">预览</el-button>
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

    <el-dialog v-model="addDialogVisible" title="添加题目" width="720px">
      <el-form :model="addForm" label-width="100px">
        <el-form-item label="题型">
          <el-select v-model="addForm.typeCode" placeholder="请选择题型">
            <el-option v-for="item in questionTypes" :key="item.value" :label="item.label" :value="item.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="题干">
          <el-input v-model="addForm.content" type="textarea" :rows="3" placeholder="请输入题目内容" />
        </el-form-item>
        <el-form-item label="科目">
          <el-input v-model="addForm.subject" placeholder="如：Java" />
        </el-form-item>
        <el-form-item label="难度">
          <el-rate v-model="addForm.difficulty" :max="5" />
        </el-form-item>
        <el-form-item v-if="isObjective(addForm.typeCode) && addForm.typeCode !== 'TRUE_FALSE'" label="选项">
          <div style="width:100%">
            <el-table :data="addForm.options" size="small" style="width: 100%" border>
              <el-table-column label="键" width="80">
                <template #default="scope">{{ scope.row.key }}</template>
              </el-table-column>
              <el-table-column label="内容">
                <template #default="scope">
                  <el-input v-model="scope.row.value" placeholder="请输入选项内容" />
                </template>
              </el-table-column>
              <el-table-column label="操作" width="100">
                <template #default="scope">
                  <el-button link type="danger" @click="removeOption(scope.$index)">删除</el-button>
                </template>
              </el-table-column>
            </el-table>
            <div style="margin-top:8px">
              <el-button @click="addOption">添加选项</el-button>
            </div>
          </div>
        </el-form-item>
        <el-form-item label="答案">
          <template v-if="addForm.typeCode==='SINGLE'">
            <el-radio-group v-model="addForm.answerSingle">
              <el-radio v-for="opt in addForm.options" :key="opt.key" :label="opt.key">{{ opt.key }}</el-radio>
            </el-radio-group>
          </template>
          <template v-else-if="addForm.typeCode==='MULTI'">
            <el-checkbox-group v-model="addForm.answerMulti">
              <el-checkbox v-for="opt in addForm.options" :key="opt.key" :label="opt.key">{{ opt.key }}</el-checkbox>
            </el-checkbox-group>
          </template>
          <template v-else-if="addForm.typeCode==='TRUE_FALSE'">
            <el-radio-group v-model="addForm.answerTrueFalse">
              <el-radio :label="true">正确</el-radio>
              <el-radio :label="false">错误</el-radio>
            </el-radio-group>
          </template>
          <template v-else-if="addForm.typeCode==='FILL'">
            <div style="width:100%">
              <div v-for="(f,i) in addForm.answerFill" :key="i" style="display:flex;gap:8px;margin-bottom:8px">
                <el-input v-model="addForm.answerFill[i]" placeholder="填写空" />
                <el-button link type="danger" @click="removeFill(i)">删除</el-button>
              </div>
              <el-button @click="addFill">添加空</el-button>
            </div>
          </template>
          <template v-else-if="addForm.typeCode==='SHORT'">
            <el-input v-model="addForm.answerShort" type="textarea" :rows="3" placeholder="请输入参考答案" />
          </template>
        </el-form-item>
        <el-form-item label="知识点">
          <el-input v-model="addForm.knowledgePoints" placeholder="如：JVM,集合" />
        </el-form-item>
        <el-form-item label="使用附件">
          <el-switch v-model="addForm.useFile" />
        </el-form-item>
        <el-form-item v-if="addForm.useFile" label="文件ID">
          <el-input v-model="addForm.fileId" placeholder="文件ID" />
        </el-form-item>
      </el-form>
      <template #footer>
        <div style="display:flex;justify-content:flex-end;gap:8px">
          <el-button @click="closeAddDialog">取消</el-button>
          <el-button type="primary" @click="submitAddQuestion">提交</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, inject } from 'vue'
import { Plus } from '@element-plus/icons-vue'
import http from '@/api/http'

const showMessage = inject('showMessage')
const showConfirm = inject('showConfirm')

const loading = ref(false)
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const questionList = ref([])

const questionTypes = [
  { label: '单选题', value: 'SINGLE' },
  { label: '多选题', value: 'MULTI' },
  { label: '判断题', value: 'TRUE_FALSE' },
  { label: '填空题', value: 'FILL' },
  { label: '简答题', value: 'SHORT' }
]

const filterForm = reactive({
  type: '',
  keyword: ''
})

const typeIdLabelMap = { 1: '单选题', 2: '多选题', 3: '判断题', 4: '填空题', 5: '简答题' }
const getQuestionTypeLabel = (typeId) => typeIdLabelMap[typeId] || '未知'

const loadQuestionList = async () => {
  loading.value = true
  try {
    const resp = await http.get('/api/questions', {
      params: {
        page: currentPage.value,
        size: pageSize.value,
        typeCode: filterForm.type || undefined,
        keyword: filterForm.keyword || undefined
      }
    })
    const data = resp?.data || {}
    const list = Array.isArray(data.list) ? data.list : []
    questionList.value = list
    total.value = Number(data.total) || list.length
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
  filterForm.keyword = ''
  handleSearch()
}

const handleCurrentChange = () => {
  loadQuestionList()
}

// 处理每页数量变化
const handleSizeChange = () => {
  currentPage.value = 1
  loadQuestionList()
}

onMounted(() => {
  loadQuestionList()
})

const addDialogVisible = ref(false)
const addForm = reactive({
  typeCode: 'SINGLE',
  content: '',
  subject: 'Java',
  difficulty: 1,
  options: [
    { key: 'A', value: '' },
    { key: 'B', value: '' }
  ],
  answerSingle: 'A',
  answerMulti: [],
  answerTrueFalse: true,
  answerFill: [''],
  answerShort: '',
  knowledgePoints: '',
  useFile: false,
  fileId: ''
})

const isObjective = (t) => t === 'SINGLE' || t === 'MULTI' || t === 'TRUE_FALSE'
const nextOptionKey = () => {
  const base = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  const used = addForm.options.map(o => o.key)
  for (let i = 0; i < base.length; i++) {
    const k = base[i]
    if (!used.includes(k)) return k
  }
  return String(addForm.options.length + 1)
}
const addOption = () => {
  addForm.options.push({ key: nextOptionKey(), value: '' })
}
const removeOption = (idx) => {
  addForm.options.splice(idx, 1)
  if (!addForm.options.find(o => o.key === addForm.answerSingle)) {
    addForm.answerSingle = addForm.options.length ? addForm.options[0].key : ''
  }
  addForm.answerMulti = addForm.answerMulti.filter(k => addForm.options.find(o => o.key === k))
}
const addFill = () => { addForm.answerFill.push('') }
const removeFill = (idx) => { addForm.answerFill.splice(idx, 1) }

const resetAddForm = () => {
  addForm.typeCode = 'SINGLE'
  addForm.content = ''
  addForm.subject = 'Java'
  addForm.difficulty = 1
  addForm.options = [
    { key: 'A', value: '' },
    { key: 'B', value: '' }
  ]
  addForm.answerSingle = 'A'
  addForm.answerMulti = []
  addForm.answerTrueFalse = true
  addForm.answerFill = ['']
  addForm.answerShort = ''
  addForm.knowledgePoints = ''
  addForm.useFile = false
  addForm.fileId = ''
}
const openAddDialog = () => { resetAddForm(); addDialogVisible.value = true }
const closeAddDialog = () => { addDialogVisible.value = false }

const validateAddForm = () => {
  if (!addForm.typeCode) return '请选择题型'
  if (!addForm.content || !addForm.content.trim()) return '请输入题干'
  if (!addForm.subject || !addForm.subject.trim()) return '请输入科目'
  if (isObjective(addForm.typeCode) && addForm.typeCode !== 'TRUE_FALSE') {
    if (!Array.isArray(addForm.options) || addForm.options.length < 2) return '请至少填写两个选项'
    for (const o of addForm.options) {
      if (!o.value || !o.value.trim()) return '选项内容不能为空'
    }
    if (addForm.typeCode === 'SINGLE') {
      const keys = addForm.options.map(o => o.key)
      if (!keys.includes(addForm.answerSingle)) return '请选择单选答案'
    }
    if (addForm.typeCode === 'MULTI') {
      if (!addForm.answerMulti || addForm.answerMulti.length === 0) return '请至少选择一个多选答案'
      const keys = addForm.options.map(o => o.key)
      for (const k of addForm.answerMulti) { if (!keys.includes(k)) return '选择了不存在的选项键' }
    }
  }
  if (addForm.typeCode === 'TRUE_FALSE') {
    if (addForm.answerTrueFalse !== true && addForm.answerTrueFalse !== false) return '请选择判断题答案'
  }
  if (addForm.typeCode === 'FILL') {
    if (!addForm.answerFill || addForm.answerFill.length === 0) return '请至少填写一个填空答案'
    for (const s of addForm.answerFill) { if (!s || !s.trim()) return '填空答案不能为空' }
  }
  if (addForm.typeCode === 'SHORT') {
    if (!addForm.answerShort || !addForm.answerShort.trim()) return '请输入参考答案'
  }
  if (addForm.useFile && (!addForm.fileId || !addForm.fileId.trim())) return '启用附件时必须填写文件ID'
  return null
}

const submitAddQuestion = async () => {
  const err = validateAddForm()
  if (err) { showMessage(err, 'warning'); return }
  const payload = {
    typeCode: addForm.typeCode,
    content: addForm.content,
    options: isObjective(addForm.typeCode) && addForm.typeCode !== 'TRUE_FALSE' ? addForm.options.map(o => ({ key: o.key, value: o.value })) : null,
    answer:
      addForm.typeCode === 'SINGLE' ? [addForm.answerSingle] :
      addForm.typeCode === 'MULTI' ? addForm.answerMulti :
      addForm.typeCode === 'TRUE_FALSE' ? addForm.answerTrueFalse :
      addForm.typeCode === 'FILL' ? addForm.answerFill :
      addForm.answerShort,
    difficulty: addForm.difficulty,
    subject: addForm.subject,
    knowledgePoints: addForm.knowledgePoints,
    fileId: addForm.useFile ? addForm.fileId || null : null,
    useFile: addForm.useFile
  }
  try {
    const resp = await http.post('/api/questions', payload)
    if (resp && resp.code === 200) {
      showMessage('创建成功', 'success')
      addDialogVisible.value = false
      resetAddForm()
      loadQuestionList()
    } else {
      showMessage('创建失败', 'error')
    }
  } catch (e) {
    showMessage('创建失败', 'error')
  }
}

// 处理编辑题目
const handleEdit = (row) => {
  // 实际项目中应该跳转到编辑题目页面或打开编辑题目对话框
  showMessage(`编辑题目ID: ${row.id}`, 'info')
}

// 处理预览题目
const handlePreview = (row) => {
  // 实际项目中应该打开预览对话框
  showMessage(`预览题目ID: ${row.id}`, 'info')
}

// 处理删除题目
const handleDelete = (row) => {
  showConfirm(`确定要删除题目"${row.content.substring(0, 20)}..."吗？`, '删除确认', 'warning')
    .then(() => {
      // 模拟删除请求
      setTimeout(() => {
        const index = questionList.value.findIndex(item => item.id === row.id)
        if (index !== -1) {
          questionList.value.splice(index, 1)
        }
        showMessage('删除成功', 'success')
      }, 500)
    })
    .catch(() => {
      // 取消删除
    })
}

 
</script>

<style scoped>
.question-bank-container {
  padding: 20px;
}

.filter-card {
  margin-bottom: 20px;
}

.filter-form {
  display: flex;
  flex-wrap: wrap;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

@media (max-width: 768px) {
  .filter-form {
    flex-direction: column;
  }
  
  .filter-form .el-form-item {
    margin-right: 0;
  }
}
</style>
