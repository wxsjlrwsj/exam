<template>
  <div class="face-photo-upload">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>人脸识别照片</span>
          <el-tag v-if="hasPhoto" type="success">已上传</el-tag>
          <el-tag v-else type="warning">未上传</el-tag>
        </div>
      </template>
      
      <div v-if="photoPreview" class="photo-preview">
        <el-image 
          :src="photoPreview" 
          fit="cover"
          style="width: 200px; height: 200px; border-radius: 8px;"
        />
        <p class="photo-info">已上传人脸照片</p>
      </div>
      
      <div class="upload-area">
        <el-upload
          class="photo-uploader"
          action="#"
          :show-file-list="false"
          :before-upload="beforeUpload"
          :http-request="handleUpload"
          accept="image/*"
        >
          <el-button type="primary" :icon="Camera">{{ hasPhoto ? '重新上传' : '上传人脸照片' }}</el-button>
        </el-upload>
        <p class="tip">用于考试前的人脸识别验证，请上传清晰的正面照片</p>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { Camera } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import request from '@/utils/request'

const hasPhoto = ref(false)
const photoPreview = ref('')

const checkHasPhoto = async () => {
  try {
    const response = await request.get('/face/has-photo')
    hasPhoto.value = response.hasPhoto
    if (response.hasPhoto && response.photo) {
      photoPreview.value = response.photo.startsWith('data:image') 
        ? response.photo 
        : `data:image/jpeg;base64,${response.photo}`
    }
  } catch (error) {
    console.error('检查照片失败:', error)
  }
}

const beforeUpload = (file) => {
  const isImage = file.type.startsWith('image/')
  const isLt5M = file.size / 1024 / 1024 < 5

  if (!isImage) {
    ElMessage.error('只能上传图片文件!')
    return false
  }
  if (!isLt5M) {
    ElMessage.error('图片大小不能超过 5MB!')
    return false
  }
  return true
}

const handleUpload = async ({ file }) => {
  const reader = new FileReader()
  reader.onload = async (e) => {
    try {
      const base64 = e.target.result
      await request.post('/face/upload-photo', { photo: base64 })
      ElMessage.success('照片上传成功!')
      hasPhoto.value = true
      photoPreview.value = base64
    } catch (error) {
      ElMessage.error('照片上传失败: ' + (error.message || '未知错误'))
    }
  }
  reader.readAsDataURL(file)
}

onMounted(() => {
  checkHasPhoto()
})
</script>

<style scoped>
.face-photo-upload {
  margin-top: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.upload-area {
  text-align: center;
  padding: 20px;
}

.photo-uploader {
  margin-bottom: 10px;
}

.tip {
  color: #909399;
  font-size: 12px;
  margin-top: 10px;
}

.photo-preview {
  margin-bottom: 20px;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.photo-info {
  margin-top: 10px;
  color: #606266;
  font-size: 14px;
}
</style>
