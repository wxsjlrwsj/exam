<template>
  <div class="paper-auto">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>智能组卷</span>
          <div>
            <el-button @click="handleCancel">取消</el-button>
            <el-button type="primary" @click="handleSubmit" :loading="submitting">生成试卷</el-button>
          </div>
        </div>
      </template>
      
      <el-form :model="form" label-width="120px">
        <el-form-item label="科目" required>
          <el-select v-model="form.subject" placeholder="请选择科目">
            <el-option label="Java" value="Java" />
            <el-option label="数据结构" value="数据结构" />
            <el-option label="计算机网络" value="计算机网络" />
            <el-option label="操作系统" value="操作系统" />
            <el-option label="数据库原理" value="数据库原理" />
          </el-select>
        </el-form-item>
        
        <el-form-item label="难度">
          <el-radio-group v-model="form.difficulty">
            <el-radio :label="null">不限</el-radio>
            <el-radio :label="1">简单</el-radio>
            <el-radio :label="3">中等</el-radio>
            <el-radio :label="5">困难</el-radio>
          </el-radio-group>
        </el-form-item>
        
        <el-form-item label="总分" required>
          <el-input-number v-model="form.totalScore" :min="10" :max="200" />
        </el-form-item>
        
        <el-divider>题型分布</el-divider>
        
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
        
        <el-alert 
          title="提示：系统将根据您的设置自动从题库中随机抽取题目组成试卷" 
          type="info" 
          :closable="false"
          style="margin-top: 20px"
        />
      </el-form>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, inject } from 'vue'
import { useRouter } from 'vue-router'
import request from '@/utils/request'

const router = useRouter()
const showMessage = inject('showMessage')

const form = reactive({
  subject: '',
  difficulty: null,
  totalScore: 100,
  typeDistribution: {
    single_choice: 5,
    multiple_choice: 3,
    true_false: 2,
    fill_blank: 0,
    short_answer: 0
  }
})

const submitting = ref(false)

const handleSubmit = async () => {
  if (!form.subject) {
    showMessage('请选择科目', 'warning')
    return
  }
  
  const totalQuestions = Object.values(form.typeDistribution).reduce((sum, count) => sum + count, 0)
  if (totalQuestions === 0) {
    showMessage('请至少选择一种题型', 'warning')
    return
  }
  
  submitting.value = true
  try {
    const data = {
      subject: form.subject,
      difficulty: form.difficulty,
      totalScore: form.totalScore,
      typeDistribution: form.typeDistribution
    }
    
    console.log('发送数据:', data)
    
    await request.post('/papers/auto', data)
    showMessage('智能组卷成功', 'success')
    router.push('/dashboard/paper-management')
  } catch (error) {
    console.error('组卷失败:', error)
    showMessage(error.response?.data?.message || '组卷失败，可能题库中题目不足', 'error')
  } finally {
    submitting.value = false
  }
}

const handleCancel = () => {
  router.back()
}
</script>

<style scoped>
.paper-auto {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
