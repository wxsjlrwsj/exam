<template>
  <div class="paper-compose">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>手动组卷</span>
          <div>
            <el-button @click="handleCancel">取消</el-button>
            <el-button type="primary" @click="handleSubmit" :loading="submitting">保存试卷</el-button>
          </div>
        </div>
      </template>
      
      <el-form :model="form" label-width="100px">
        <el-form-item label="试卷名称" required>
          <el-input v-model="form.name" placeholder="请输入试卷名称" />
        </el-form-item>
        
        <el-form-item label="科目" required>
          <el-select v-model="form.subject" placeholder="请选择科目">
            <el-option label="Java" value="Java" />
            <el-option label="数据结构" value="数据结构" />
            <el-option label="计算机网络" value="计算机网络" />
            <el-option label="操作系统" value="操作系统" />
            <el-option label="数据库原理" value="数据库原理" />
          </el-select>
        </el-form-item>
        
        <el-form-item label="及格分数">
          <el-input-number v-model="form.passScore" :min="0" :max="100" />
        </el-form-item>
        
        <el-divider>题目列表</el-divider>
        
        <el-button type="primary" @click="showQuestionDialog = true" style="margin-bottom: 20px">
          添加题目
        </el-button>
        
        <el-table :data="form.questions" border>
          <el-table-column type="index" label="序号" width="60" />
          <el-table-column prop="content" label="题目内容" min-width="300" />
          <el-table-column label="分数" width="150">
            <template #default="scope">
              <el-input-number v-model="scope.row.score" :min="1" :max="100" size="small" />
            </template>
          </el-table-column>
          <el-table-column label="操作" width="100">
            <template #default="scope">
              <el-button link type="danger" @click="removeQuestion(scope.$index)">删除</el-button>
            </template>
          </el-table-column>
        </el-table>
        
        <div v-if="form.questions.length === 0" style="text-align: center; padding: 40px; color: #999;">
          暂无题目，请点击"添加题目"按钮
        </div>
        
        <div style="margin-top: 20px; text-align: right;">
          <strong>总分：{{ totalScore }}</strong>
        </div>
      </el-form>
    </el-card>
    
    <el-dialog v-model="showQuestionDialog" title="选择题目" width="80%">
      <el-table :data="availableQuestions" @selection-change="handleSelectionChange" border>
        <el-table-column type="selection" width="55" />
        <el-table-column prop="content" label="题目内容" min-width="300" />
        <el-table-column prop="subject" label="科目" width="120" />
        <el-table-column prop="difficulty" label="难度" width="100">
          <template #default="scope">
            <el-rate v-model="scope.row.difficulty" disabled show-score text-color="#ff9900" />
          </template>
        </el-table-column>
      </el-table>
      
      <template #footer>
        <el-button @click="showQuestionDialog = false">取消</el-button>
        <el-button type="primary" @click="confirmAddQuestions">确定添加</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, inject, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import request from '@/utils/request'

const router = useRouter()
const showMessage = inject('showMessage')

const form = reactive({
  name: '',
  subject: '',
  passScore: 60,
  questions: []
})

const submitting = ref(false)
const showQuestionDialog = ref(false)
const availableQuestions = ref([])
const selectedQuestions = ref([])

const totalScore = computed(() => {
  return form.questions.reduce((sum, q) => sum + (q.score || 0), 0)
})

const loadQuestions = async () => {
  try {
    const res = await request.get('/questions', { params: { size: 100 } })
    availableQuestions.value = res.data.list || []
  } catch (error) {
    console.error('加载题目失败:', error)
  }
}

const handleSelectionChange = (val) => {
  selectedQuestions.value = val
}

const confirmAddQuestions = () => {
  selectedQuestions.value.forEach(q => {
    if (!form.questions.find(item => item.questionId === q.id)) {
      form.questions.push({
        questionId: q.id,
        content: q.content,
        score: 10
      })
    }
  })
  showQuestionDialog.value = false
  selectedQuestions.value = []
}

const removeQuestion = (index) => {
  form.questions.splice(index, 1)
}

const handleSubmit = async () => {
  if (!form.name) {
    showMessage('请输入试卷名称', 'warning')
    return
  }
  if (!form.subject) {
    showMessage('请选择科目', 'warning')
    return
  }
  if (form.questions.length === 0) {
    showMessage('请至少添加一道题目', 'warning')
    return
  }
  
  submitting.value = true
  try {
    const data = {
      name: form.name,
      subject: form.subject,
      passScore: form.passScore,
      questions: form.questions.map(q => ({
        questionId: q.questionId,
        score: q.score
      }))
    }
    
    console.log('发送数据:', data)
    
    await request.post('/papers/manual', data)
    showMessage('试卷创建成功', 'success')
    router.push('/dashboard/paper-management')
  } catch (error) {
    console.error('创建失败:', error)
    showMessage(error.response?.data?.message || '创建失败', 'error')
  } finally {
    submitting.value = false
  }
}

const handleCancel = () => {
  router.back()
}

onMounted(() => {
  loadQuestions()
})
</script>

<style scoped>
.paper-compose {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
