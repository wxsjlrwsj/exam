<template>
  <div class="paper-auto-generate-container">
    <div class="page-header">
      <h2 class="page-title">智能组卷</h2>
      <div>
        <el-button @click="handleCancel">取消</el-button>
        <el-button type="primary" @click="handleGenerate" :loading="generating">生成试卷</el-button>
      </div>
    </div>

    <el-card>
      <el-form :model="form" label-width="120px" style="max-width: 600px">
        <el-form-item label="试卷名称" required>
          <el-input v-model="form.name" placeholder="请输入试卷名称" />
        </el-form-item>
        
        <el-form-item label="科目" required>
          <el-input v-model="form.subject" placeholder="请输入科目，如：Java程序设计" />
        </el-form-item>

        <el-form-item label="难度">
          <el-select v-model="form.difficulty" placeholder="请选择难度">
            <el-option label="简单 (1-2星)" :value="1" />
            <el-option label="中等 (3星)" :value="3" />
            <el-option label="困难 (4-5星)" :value="5" />
          </el-select>
        </el-form-item>

        <el-form-item label="总分" required>
          <el-input-number v-model="form.totalScore" :min="1" :max="200" />
        </el-form-item>

        <el-divider content-position="left">题型分布</el-divider>

        <el-form-item label="单选题数量">
          <el-input-number v-model="form.typeDistribution.single_choice" :min="0" :max="50" />
        </el-form-item>

        <el-form-item label="多选题数量">
          <el-input-number v-model="form.typeDistribution.multiple_choice" :min="0" :max="50" />
        </el-form-item>

        <el-form-item label="判断题数量">
          <el-input-number v-model="form.typeDistribution.true_false" :min="0" :max="50" />
        </el-form-item>

        <el-form-item label="填空题数量">
          <el-input-number v-model="form.typeDistribution.fill_blank" :min="0" :max="50" />
        </el-form-item>

        <el-form-item label="简答题数量">
          <el-input-number v-model="form.typeDistribution.short_answer" :min="0" :max="50" />
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, inject } from 'vue'
import { useRouter } from 'vue-router'
import { autoGeneratePaper } from '@/api/teacher'

const router = useRouter()
const showMessage = inject('showMessage')

const generating = ref(false)

const form = reactive({
  name: '',
  subject: '',
  difficulty: null,
  totalScore: 100,
  typeDistribution: {
    single_choice: 10,
    multiple_choice: 5,
    true_false: 5,
    fill_blank: 3,
    short_answer: 2
  }
})

const handleGenerate = async () => {
  if (!form.name) {
    showMessage('请输入试卷名称', 'warning')
    return
  }
  if (!form.subject) {
    showMessage('请输入科目', 'warning')
    return
  }

  const totalQuestions = Object.values(form.typeDistribution).reduce((sum, count) => sum + count, 0)
  if (totalQuestions === 0) {
    showMessage('请至少选择一种题型', 'warning')
    return
  }

  generating.value = true
  try {
    const data = {
      subject: form.subject,
      difficulty: form.difficulty,
      totalScore: form.totalScore,
      typeDistribution: form.typeDistribution
    }
    
    const result = await autoGeneratePaper(data)
    
    showMessage(`智能组卷成功！试卷名称：${form.subject}智能组卷`, 'success')
    router.push('/dashboard/paper-management')
  } catch (error) {
    console.error('智能组卷失败:', error)
    const errorMsg = error.response?.data?.message || error.message || '智能组卷失败，可能题库中题目不足'
    showMessage(errorMsg, 'error')
  } finally {
    generating.value = false
  }
}

const handleCancel = () => {
  router.back()
}
</script>

<style scoped>
.paper-auto-generate-container {
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
</style>
