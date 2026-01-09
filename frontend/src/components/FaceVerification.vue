<template>
  <el-dialog
    v-model="dialogVisible"
    title="人脸识别验证"
    width="600px"
    :close-on-click-modal="false"
    :close-on-press-escape="false"
    :show-close="false"
  >
    <div class="face-verification">
      <div v-if="!hasPhoto" class="no-photo">
        <el-alert
          title="未上传人脸照片"
          type="warning"
          description="请先在个人中心上传您的人脸照片后再进行验证"
          :closable="false"
          show-icon
        />
        <el-button type="primary" @click="goToProfile" style="margin-top: 20px">
          前往上传照片
        </el-button>
      </div>

      <div v-else-if="!cameraStarted" class="camera-start">
        <el-alert
          title="准备开始人脸验证"
          type="info"
          description="点击下方按钮开启摄像头进行人脸识别验证"
          :closable="false"
          show-icon
        />
        <el-button type="primary" @click="startCamera" :loading="loading" style="margin-top: 20px">
          <el-icon><Camera /></el-icon>
          开启摄像头
        </el-button>
      </div>

      <div v-else class="camera-view">
        <video ref="videoRef" autoplay playsinline class="video-preview"></video>
        <canvas ref="canvasRef" style="display: none;"></canvas>
        
        <div class="verification-status" v-if="verificationResult">
          <el-alert
            :title="verificationResult.verified ? '验证通过' : '验证失败'"
            :type="verificationResult.verified ? 'success' : 'error'"
            :description="`相似度: ${verificationResult.score.toFixed(2)}% (阈值: ${verificationResult.threshold}%)`"
            :closable="false"
            show-icon
          />
        </div>

        <div class="action-buttons">
          <el-button type="primary" @click="captureAndVerify" :loading="verifying" :disabled="verificationResult?.verified">
            <el-icon><Camera /></el-icon>
            拍照验证
          </el-button>
          <el-button @click="stopCamera">关闭摄像头</el-button>
        </div>
      </div>
    </div>

    <template #footer>
      <el-button @click="handleCancel" :disabled="verifying">取消</el-button>
      <el-button 
        type="primary" 
        @click="handleConfirm" 
        :disabled="!verificationResult?.verified"
      >
        确认进入考试
      </el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { ref, computed, watch, onUnmounted, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import { Camera } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import request from '@/utils/request'

const props = defineProps({
  modelValue: Boolean
})

const emit = defineEmits(['update:modelValue', 'verified'])

const router = useRouter()
const dialogVisible = computed({
  get: () => props.modelValue,
  set: (val) => emit('update:modelValue', val)
})
const hasPhoto = ref(true)
const cameraStarted = ref(false)
const loading = ref(false)
const verifying = ref(false)
const verificationResult = ref(null)
const videoRef = ref(null)
const canvasRef = ref(null)
let stream = null

const checkHasPhoto = async () => {
  try {
    const response = await request.get('/face/has-photo')
    hasPhoto.value = response.hasPhoto
    if (!response.hasPhoto) {
      ElMessage.warning('请先上传人脸照片')
    }
  } catch (error) {
    ElMessage.error('检查照片失败: ' + (error.message || '未知错误'))
    hasPhoto.value = false
  }
}

const startCamera = async () => {
  loading.value = true
  try {
    // 先获取摄像头权限
    stream = await navigator.mediaDevices.getUserMedia({ 
      video: { width: 640, height: 480 } 
    })
    
    // 先设置状态，触发video元素渲染
    cameraStarted.value = true
    
    // 等待DOM更新完成
    await nextTick()
    
    // 再次等待确保元素完全渲染
    await new Promise(resolve => setTimeout(resolve, 100))
    
    // 检查videoRef是否存在
    if (!videoRef.value) {
      throw new Error('视频元素未就绪')
    }
    
    // 设置视频流
    videoRef.value.srcObject = stream
  } catch (error) {
    ElMessage.error('无法访问摄像头: ' + error.message)
    cameraStarted.value = false
    // 清理已获取的stream
    if (stream) {
      stream.getTracks().forEach(track => track.stop())
      stream = null
    }
  } finally {
    loading.value = false
  }
}

const stopCamera = () => {
  if (stream) {
    stream.getTracks().forEach(track => track.stop())
    stream = null
  }
  cameraStarted.value = false
  verificationResult.value = null
}

const captureAndVerify = async () => {
  verifying.value = true
  try {
    const canvas = canvasRef.value
    const video = videoRef.value
    
    // 检查元素是否存在
    if (!canvas || !video) {
      throw new Error('视频或画布元素未就绪')
    }
    
    canvas.width = video.videoWidth
    canvas.height = video.videoHeight
    const ctx = canvas.getContext('2d')
    ctx.drawImage(video, 0, 0)
    
    const base64Image = canvas.toDataURL('image/jpeg', 0.8)
    
    const response = await request.post('/face/verify', { photo: base64Image }, { timeout: 30000 })
    verificationResult.value = response
    
    if (response.verified) {
      ElMessage.success('人脸验证通过！')
    } else {
      ElMessage.error('人脸验证失败，请重新拍照')
    }
  } catch (error) {
    const serverMsg = error?.response?.data?.message
    ElMessage.error('验证失败: ' + (serverMsg || error.message || '未知错误'))
  } finally {
    verifying.value = false
  }
}

const goToProfile = () => {
  dialogVisible.value = false
  emit('update:modelValue', false)
  router.push({ name: 'StudentProfile', query: { tab: 'face' } })
}

const handleCancel = () => {
  stopCamera()
  dialogVisible.value = false
  emit('update:modelValue', false)
}

const handleConfirm = () => {
  console.log('[FaceVerification] handleConfirm called')
  console.log('[FaceVerification] verificationResult:', verificationResult.value)
  
  // 先保存验证结果，因为关闭对话框会触发 watch 重置它
  const result = verificationResult.value
  console.log('[FaceVerification] saved result:', result)
  
  stopCamera()
  
  // 先发送验证结果事件，再关闭对话框
  console.log('[FaceVerification] emitting verified event with:', result)
  emit('verified', result)
  
  // 最后关闭对话框（这会触发 watch 重置 verificationResult）
  dialogVisible.value = false
  emit('update:modelValue', false)
}

watch(() => props.modelValue, (newVal) => {
  if (newVal) {
    // 对话框打开时，检查照片但不重置验证结果
    checkHasPhoto()
    cameraStarted.value = false
  } else {
    // 对话框关闭时，重置验证结果
    verificationResult.value = null
  }
})

onUnmounted(() => {
  stopCamera()
})
</script>

<style scoped>
.face-verification {
  min-height: 300px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

.no-photo,
.camera-start {
  text-align: center;
  width: 100%;
}

.camera-view {
  width: 100%;
  text-align: center;
}

.video-preview {
  width: 100%;
  max-width: 640px;
  border-radius: 8px;
  margin-bottom: 20px;
}

.verification-status {
  margin-bottom: 20px;
}

.action-buttons {
  display: flex;
  gap: 10px;
  justify-content: center;
}
</style>
