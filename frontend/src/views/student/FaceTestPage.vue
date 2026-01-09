<template>
  <div class="face-test-page">
    <el-card>
      <template #header>
        <h2>人脸识别功能测试</h2>
      </template>
      
      <div class="test-content">
        <el-alert
          title="测试说明"
          type="info"
          :closable="false"
          style="margin-bottom: 20px"
        >
          <p>此页面用于测试人脸识别功能。点击下方按钮开始人脸验证流程。</p>
          <p>student1账号已预置人脸照片，可直接测试验证功能。</p>
        </el-alert>

        <div class="test-actions">
          <el-button type="primary" size="large" @click="showVerification = true">
            <el-icon><Camera /></el-icon>
            开始人脸验证测试
          </el-button>
        </div>

        <div v-if="verificationResult" class="result-display">
          <el-divider />
          <h3>验证结果：</h3>
          <el-descriptions :column="1" border>
            <el-descriptions-item label="验证状态">
              <el-tag :type="verificationResult.verified ? 'success' : 'danger'">
                {{ verificationResult.verified ? '✓ 通过' : '✗ 失败' }}
              </el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="相似度分数">
              {{ verificationResult.score }}%
            </el-descriptions-item>
            <el-descriptions-item label="阈值">
              {{ verificationResult.threshold }}%
            </el-descriptions-item>
          </el-descriptions>
        </div>
      </div>
    </el-card>

    <FaceVerification 
      v-model="showVerification" 
      @verified="handleVerified" 
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { Camera } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import FaceVerification from '@/components/FaceVerification.vue'

const showVerification = ref(false)
const verificationResult = ref(null)

const handleVerified = (success) => {
  if (success) {
    ElMessage.success('人脸验证通过！可以进入考试')
  } else {
    ElMessage.error('人脸验证失败')
  }
}

// 监听验证组件的结果
const updateResult = (result) => {
  verificationResult.value = result
}
</script>

<style scoped>
.face-test-page {
  padding: 20px;
  max-width: 800px;
  margin: 0 auto;
}

.test-content {
  padding: 20px;
}

.test-actions {
  text-align: center;
  margin: 30px 0;
}

.result-display {
  margin-top: 20px;
}

.result-display h3 {
  margin-bottom: 15px;
  color: #303133;
}
</style>
