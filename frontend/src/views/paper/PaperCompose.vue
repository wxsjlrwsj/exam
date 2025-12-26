<template>
  <div class="paper-compose-container">
    <div class="page-header">
      <h2 class="page-title">手动组卷</h2>
      <div>
        <el-button @click="handleCancel">取消</el-button>
        <el-button type="primary" @click="handleSave" :loading="saving">保存试卷</el-button>
      </div>
    </div>

    <el-card class="paper-info-card">
      <el-form :model="paperForm" label-width="100px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="试卷名称" required>
              <el-input v-model="paperForm.name" placeholder="请输入试卷名称" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="科目" required>
              <el-input v-model="paperForm.subject" placeholder="请输入科目" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="及格分数">
              <el-input-number v-model="paperForm.passScore" :min="0" :max="100" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="总分">
              <el-input-number v-model="totalScore" disabled />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
    </el-card>

    <el-card class="question-selection-card">
      <div class="card-header">
        <h3>选择题目</h3>
        <el-button type="primary" @click="showQuestionSelector = true">
          <el-icon><Plus /></el-icon>添加题目
        </el-button>
      </div>

      <el-table :data="selectedQuestions" border style="width: 100%; margin-top: 20px">
        <el-table-column type="index" label="序号" width="60" align="center" />
        <el-table-column prop="content" label="题目内容" min-width="300" show-overflow-tooltip />
        <el-table-column prop="subject" label="科目" width="120" />
        <el-table-column label="题型" width="100" align="center">
          <template #default="scope">
            <el-tag>{{ getQuestionTypeLabel(scope.row.typeId) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="分数" width="150" align="center">
          <template #default="scope">
            <el-input-number 
              v-model="scope.row.score" 
              :min="1" 
              :max="100" 
              size="small"
              @change="calculateTotalScore"
            />
          </template>
        </el-table-column>
        <el-table-column label="操作" width="100" align="center">
          <template #default="scope">
            <el-button link type="danger" @click="removeQuestion(scope.$index)">移除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div v-if="selectedQuestions.length === 0" class="empty-hint">
        <el-empty description="暂无题目，请点击上方按钮添加题目" />
      </div>
    </el-card>

    <!-- Question Selector Dialog -->
    <el-dialog v-model="showQuestionSelector" title="选择题目" width="80%" :close-on-click-modal="false">
      <el-form :inline="true" :model="filterForm" class="filter-form">
        <el-form-item label="题型">
          <el-select v-model="filterForm.typeCode" placeholder="全部" clearable style="width: 150px">
            <el-option label="单选题" value="single_choice" />
            <el-option label="多选题" value="multiple_choice" />
            <el-option label="判断题" value="true_false" />
            <el-option label="填空题" value="fill_blank" />
            <el-option label="简答题" value="short_answer" />
          </el-select>
        </el-form-item>
        <el-form-item label="科目">
          <el-input v-model="filterForm.subject" placeholder="科目" clearable style="width: 150px" />
        </el-form-item>
        <el-form-item label="关键词">
          <el-input v-model="filterForm.keyword" placeholder="题目内容" clearable style="width: 200px" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="loadQuestions">查询</el-button>
          <el-button @click="resetFilter">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table 
        ref="questionTable"
        v-loading="questionLoading"
        :data="questionList" 
        border 
        style="width: 100%"
        @selection-change="handleSelectionChange"
      >
        <el-table-column type="selection" width="55" />
        <el-table-column prop="id" label="ID" width="80" align="center" />
        <el-table-column label="题型" width="100" align="center">
          <template #default="scope">
            <el-tag>{{ getQuestionTypeLabel(scope.row.typeId) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="content" label="题目内容" min-width="300" show-overflow-tooltip />
        <el-table-column prop="subject" label="科目" width="120" />
        <el-table-column prop="difficulty" label="难度" width="120" align="center">
          <template #default="scope">
            <el-rate v-model="scope.row.difficulty" disabled text-color="#ff9900" />
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-container">
        <el-pagination
          v-model:current-page="questionPage"
          v-model:page-size="questionPageSize"
          :page-sizes="[10, 20, 30, 50]"
          layout="total, sizes, prev, pager, next"
          :total="questionTotal"
          @size-change="loadQuestions"
          @current-change="loadQuestions"
        />
      </div>

      <template #footer>
        <el-button @click="showQuestionSelector = false">取消</el-button>
        <el-button type="primary" @click="confirmAddQuestions">确定添加</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, inject } from 'vue'
import { useRouter } from 'vue-router'
import { Plus } from '@element-plus/icons-vue'
import { getQuestions, createPaper } from '@/api/teacher'

const router = useRouter()
const showMessage = inject('showMessage')

const saving = ref(false)
const showQuestionSelector = ref(false)
const questionLoading = ref(false)
const questionList = ref([])
const questionPage = ref(1)
const questionPageSize = ref(10)
const questionTotal = ref(0)
const selectedQuestions = ref([])
const tempSelectedQuestions = ref([])

const paperForm = reactive({
  name: '',
  subject: '',
  passScore: 60
})

const filterForm = reactive({
  typeCode: '',
  subject: '',
  keyword: ''
})

const questionTypeMap = {
  1: '单选题',
  2: '多选题',
  3: '判断题',
  4: '填空题',
  5: '简答题'
}

const getQuestionTypeLabel = (typeId) => {
  return questionTypeMap[typeId] || '未知'
}

const totalScore = computed(() => {
  return selectedQuestions.value.reduce((sum, q) => sum + (q.score || 0), 0)
})

const calculateTotalScore = () => {
  // Trigger computed property update
}

const loadQuestions = async () => {
  questionLoading.value = true
  try {
    const params = {
      page: questionPage.value,
      size: questionPageSize.value,
      ...filterForm
    }
    const res = await getQuestions(params)
    if (res && res.list) {
      questionList.value = res.list
      questionTotal.value = res.total || 0
    }
  } catch (error) {
    console.error('加载题目失败:', error)
    showMessage('加载题目失败', 'error')
  } finally {
    questionLoading.value = false
  }
}

const resetFilter = () => {
  filterForm.typeCode = ''
  filterForm.subject = ''
  filterForm.keyword = ''
  loadQuestions()
}

const handleSelectionChange = (selection) => {
  tempSelectedQuestions.value = selection
}

const confirmAddQuestions = () => {
  const newQuestions = tempSelectedQuestions.value.filter(q => {
    return !selectedQuestions.value.some(sq => sq.id === q.id)
  })
  
  newQuestions.forEach(q => {
    selectedQuestions.value.push({
      ...q,
      score: 5
    })
  })
  
  showQuestionSelector.value = false
  showMessage(`成功添加 ${newQuestions.length} 道题目`, 'success')
}

const removeQuestion = (index) => {
  selectedQuestions.value.splice(index, 1)
}

const handleSave = async () => {
  if (!paperForm.name) {
    showMessage('请输入试卷名称', 'warning')
    return
  }
  if (!paperForm.subject) {
    showMessage('请输入科目', 'warning')
    return
  }
  if (selectedQuestions.value.length === 0) {
    showMessage('请至少添加一道题目', 'warning')
    return
  }

  saving.value = true
  try {
    const data = {
      name: paperForm.name,
      subject: paperForm.subject,
      passScore: paperForm.passScore,
      questions: selectedQuestions.value.map(q => ({
        id: q.id,
        score: q.score
      }))
    }
    await createPaper(data)
    showMessage('试卷创建成功', 'success')
    router.push('/dashboard/paper-management')
  } catch (error) {
    console.error('保存失败:', error)
    showMessage(error.response?.data?.message || '保存失败', 'error')
  } finally {
    saving.value = false
  }
}

const handleCancel = () => {
  router.back()
}
</script>

<style scoped>
.paper-compose-container {
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

.paper-info-card {
  margin-bottom: 20px;
}

.question-selection-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.empty-hint {
  padding: 40px 0;
  text-align: center;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

.filter-form {
  margin-bottom: 20px;
}
</style>
