<template>
  <div class="register-container">
    <ParticlesBackground color="rgba(255, 255, 255, 0.6)" :count="80" />
    
    <!-- 左侧装饰区域 -->
    <div class="register-left">
      <div class="welcome-content">
        <div class="logo-section">
          <img src="../assets/logo.svg" alt="Logo" class="main-logo" />
          <h1 class="brand-name">超星考试系统</h1>
        </div>
        <p class="welcome-text">开启您的学习之旅</p>
        <div class="features">
          <div class="feature-item">
            <el-icon class="feature-icon"><CircleCheck /></el-icon>
            <span>安全可靠的身份验证</span>
          </div>
          <div class="feature-item">
            <el-icon class="feature-icon"><Lock /></el-icon>
            <span>数据加密保护</span>
          </div>
          <div class="feature-item">
            <el-icon class="feature-icon"><Message /></el-icon>
            <span>QQ邮箱快速注册</span>
          </div>
        </div>
      </div>
    </div>
    
    <!-- 右侧注册表单 -->
    <div class="register-box">
      <div class="register-header">
        <h1 class="title">创建账号</h1>
        <p class="subtitle">填写信息，即刻开始</p>
      </div>
      <el-form ref="registerFormRef" :model="registerForm" :rules="registerRules" class="register-form" label-position="top">
        <el-form-item prop="username">
          <el-input 
            v-model="registerForm.username" 
            placeholder="用户名" 
            prefix-icon="User"
            size="large"
          />
        </el-form-item>
        
        <div class="qq-row">
          <el-form-item prop="qqNumber" class="qq-number-item">
            <el-input 
              v-model="registerForm.qqNumber" 
              placeholder="QQ号码" 
              prefix-icon="ChatDotRound"
              size="large"
              @input="handleQQInput"
            />
          </el-form-item>
          
          <el-form-item prop="email" class="qq-email-item">
            <el-input 
              v-model="registerForm.email" 
              placeholder="QQ邮箱 (自动填充)" 
              prefix-icon="Message"
              size="large"
              disabled
            />
          </el-form-item>
        </div>
        
        <el-form-item prop="verificationCode">
          <div class="verification-row">
            <el-input 
              v-model="registerForm.verificationCode" 
              placeholder="邮箱验证码" 
              prefix-icon="Key"
              size="large"
              maxlength="6"
              style="flex: 1;"
            />
            <el-button 
              type="primary" 
              size="large" 
              :disabled="!canSendCode || countdown > 0"
              :loading="sendingCode"
              @click="handleSendCode"
              style="margin-left: 10px; width: 120px;"
            >
              {{ countdown > 0 ? `${countdown}秒后重试` : '发送验证码' }}
            </el-button>
          </div>
        </el-form-item>
        
        <el-form-item prop="password">
          <el-input 
            v-model="registerForm.password" 
            type="password" 
            placeholder="密码" 
            prefix-icon="Lock"
            size="large"
            show-password
          />
        </el-form-item>
        
        <el-form-item prop="confirmPassword">
          <el-input 
            v-model="registerForm.confirmPassword" 
            type="password" 
            placeholder="确认密码" 
            prefix-icon="Lock"
            size="large"
            show-password
          />
        </el-form-item>
        
        <el-form-item prop="userType">
          <el-select 
            v-model="registerForm.userType" 
            placeholder="选择身份" 
            size="large"
            style="width: 100%;"
          >
            <el-option label="学生" value="student" />
            <el-option label="教师" value="teacher" />
          </el-select>
        </el-form-item>
        
        <el-form-item>
          <el-button type="primary" :loading="loading" @click="handleRegister" class="register-button">立即注册</el-button>
        </el-form-item>
        <div class="extra-actions">
          <span class="has-account">已有账号？ <el-button link type="primary" @click="router.push('/login')">立即登录</el-button></span>
        </div>
      </el-form>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, inject, computed } from 'vue'
import { useRouter } from 'vue-router'
import { User, Lock, Message, ChatDotRound, Key, CircleCheck } from '@element-plus/icons-vue'
import ParticlesBackground from '../components/ParticlesBackground.vue'
import request from '@/utils/request'

const router = useRouter()
const showMessage = inject('showMessage')
const loading = ref(false)
const sendingCode = ref(false)
const countdown = ref(0)
const registerFormRef = ref(null)

const registerForm = reactive({
  username: '',
  qqNumber: '',
  email: '',
  verificationCode: '',
  password: '',
  confirmPassword: '',
  userType: 'student'
})

// QQ号输入时自动填充邮箱
const handleQQInput = () => {
  const qq = registerForm.qqNumber.trim()
  if (qq && /^[1-9]\d{4,10}$/.test(qq)) {
    registerForm.email = qq + '@qq.com'
  } else {
    registerForm.email = ''
  }
}

// 判断是否可以发送验证码
const canSendCode = computed(() => {
  const qq = registerForm.qqNumber.trim()
  return qq && /^[1-9]\d{4,10}$/.test(qq)
})

// 验证规则
const validatePass2 = (rule, value, callback) => {
  if (value === '') {
    callback(new Error('请再次输入密码'))
  } else if (value !== registerForm.password) {
    callback(new Error('两次输入密码不一致!'))
  } else {
    callback()
  }
}

const validateQQ = (rule, value, callback) => {
  if (!value) {
    callback(new Error('请输入QQ号'))
  } else if (!/^[1-9]\d{4,10}$/.test(value)) {
    callback(new Error('请输入有效的QQ号（5-11位数字）'))
  } else {
    callback()
  }
}

const validateEmail = (rule, value, callback) => {
  if (!value) {
    callback(new Error('请先输入QQ号'))
  } else if (!value.endsWith('@qq.com')) {
    callback(new Error('必须使用QQ邮箱'))
  } else {
    callback()
  }
}

const registerRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 20, message: '长度在 3 到 20 个字符', trigger: 'blur' }
  ],
  qqNumber: [
    { required: true, validator: validateQQ, trigger: 'blur' }
  ],
  email: [
    { required: true, validator: validateEmail, trigger: 'blur' }
  ],
  verificationCode: [
    { required: true, message: '请输入验证码', trigger: 'blur' },
    { len: 6, message: '验证码为6位数字', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能少于 6 位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, validator: validatePass2, trigger: 'blur' }
  ],
  userType: [
    { required: true, message: '请选择身份', trigger: 'change' }
  ]
}

// 发送验证码
const handleSendCode = async () => {
  if (!canSendCode.value) {
    showMessage('请先输入有效的QQ号', 'warning')
    return
  }
  
  sendingCode.value = true
  try {
    const response = await request.post('/auth/send-code', {
      email: registerForm.email
    })
    
    showMessage('验证码已发送到您的QQ邮箱', 'success')
    
    // 开始倒计时
    countdown.value = 60
    const timer = setInterval(() => {
      countdown.value--
      if (countdown.value <= 0) {
        clearInterval(timer)
      }
    }, 1000)
  } catch (error) {
    const errorMsg = error.response?.data?.message || error.message || '发送失败'
    showMessage('验证码发送失败: ' + errorMsg, 'error')
  } finally {
    sendingCode.value = false
  }
}

// 注册
const handleRegister = async () => {
  if (!registerFormRef.value) return
  
  await registerFormRef.value.validate(async (valid) => {
    if (valid) {
      loading.value = true
      try {
        await request.post('/auth/register', {
          username: registerForm.username,
          qqNumber: registerForm.qqNumber,
          email: registerForm.email,
          verificationCode: registerForm.verificationCode,
          password: registerForm.password,
          userType: registerForm.userType
        })
        
        showMessage('注册成功，请登录', 'success')
        router.push('/login')
      } catch (error) {
        const errorMsg = error.response?.data?.message || error.message || '未知错误'
        showMessage('注册失败: ' + errorMsg, 'error')
      } finally {
        loading.value = false
      }
    }
  })
}
</script>

<style scoped>
.register-container {
  min-height: 100vh;
  width: 100vw;
  display: flex;
  background: linear-gradient(135deg, #1890ff 0%, #096dd9 100%);
  position: relative;
  overflow: hidden;
}

/* 左侧装饰区域 */
.register-left {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 60px;
  color: white;
  z-index: 1;
}

.welcome-content {
  max-width: 500px;
}

.logo-section {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 24px;
}

.main-logo {
  width: 64px;
  height: 64px;
  filter: drop-shadow(0 4px 8px rgba(0, 0, 0, 0.2));
}

.brand-name {
  font-size: 32px;
  font-weight: 700;
  color: white;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  margin: 0;
}

.welcome-text {
  font-size: 20px;
  margin-bottom: 40px;
  opacity: 0.95;
  font-weight: 300;
}

.features {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.feature-item {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 16px;
  opacity: 0.9;
  padding: 12px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 8px;
  backdrop-filter: blur(10px);
  transition: all 0.3s ease;
}

.feature-item:hover {
  background: rgba(255, 255, 255, 0.15);
  transform: translateX(8px);
}

.feature-icon {
  font-size: 24px;
  color: #ffd700;
}

/* 右侧注册表单 */
.register-box {
  width: 520px;
  max-height: 100vh;
  overflow-y: auto;
  padding: 60px 50px;
  background: white;
  box-shadow: -10px 0 30px rgba(0, 0, 0, 0.1);
  z-index: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.register-box::-webkit-scrollbar {
  width: 6px;
}

.register-box::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 3px;
}

.register-box::-webkit-scrollbar-thumb {
  background: #d0d0d0;
  border-radius: 3px;
}

.register-box::-webkit-scrollbar-thumb:hover {
  background: #b0b0b0;
}

.register-header {
  text-align: center;
  margin-bottom: 40px;
}

.title {
  font-size: 32px;
  font-weight: 700;
  color: #1a1a1a;
  margin-bottom: 8px;
  letter-spacing: -0.5px;
}

.subtitle {
  font-size: 15px;
  color: #666;
  font-weight: 400;
}

.register-form {
  margin-bottom: 24px;
}

.register-form :deep(.el-form-item) {
  margin-bottom: 24px;
}

.register-form :deep(.el-form-item__label) {
  font-weight: 500;
  color: #333;
  margin-bottom: 8px;
}

.register-form :deep(.el-input__wrapper) {
  border-radius: 8px;
  box-shadow: 0 0 0 1px #e0e0e0 inset;
  padding: 12px 16px;
  transition: all 0.3s ease;
}

.register-form :deep(.el-input__wrapper:hover) {
  box-shadow: 0 0 0 1px #1890ff inset;
}

.register-form :deep(.el-input__wrapper.is-focus) {
  box-shadow: 0 0 0 2px #1890ff inset;
}

.register-form :deep(.el-select .el-input__wrapper) {
  border-radius: 8px;
}

.qq-row {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  width: 100%;
}

.qq-number-item {
  flex: 1;
  margin-bottom: 24px;
}

.qq-email-item {
  flex: 1;
  margin-bottom: 24px;
}

.verification-row {
  display: flex;
  align-items: center;
  gap: 12px;
  width: 100%;
}

.verification-row :deep(.el-button) {
  border-radius: 8px;
  font-weight: 500;
  white-space: nowrap;
  padding: 12px 20px;
}

.register-button {
  width: 100%;
  height: 48px;
  font-size: 16px;
  font-weight: 600;
  border-radius: 8px;
  background: linear-gradient(135deg, #1890ff 0%, #096dd9 100%);
  border: none;
  transition: all 0.3s ease;
  letter-spacing: 0.5px;
}

.register-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 16px rgba(24, 144, 255, 0.4);
}

.register-button:active {
  transform: translateY(0);
}

.extra-actions {
  text-align: center;
  font-size: 14px;
  color: #666;
  padding-top: 16px;
  border-top: 1px solid #f0f0f0;
}

.extra-actions .has-account {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 4px;
}

.extra-actions :deep(.el-button) {
  font-weight: 500;
  padding: 0 4px;
}

/* 表单动画效果 */
.register-form :deep(.el-form-item),
.register-form .qq-row {
  animation: slideIn 0.5s ease forwards;
  opacity: 0;
}

.register-form :deep(.el-form-item:nth-child(1)) { animation-delay: 0.1s; }
.register-form .qq-row { animation-delay: 0.2s; }
.register-form :deep(.el-form-item:nth-child(3)) { animation-delay: 0.3s; }
.register-form :deep(.el-form-item:nth-child(4)) { animation-delay: 0.4s; }
.register-form :deep(.el-form-item:nth-child(5)) { animation-delay: 0.5s; }
.register-form :deep(.el-form-item:nth-child(6)) { animation-delay: 0.6s; }

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* 响应式设计 */
@media (max-width: 1024px) {
  .register-left {
    display: none;
  }
  
  .register-box {
    width: 100%;
    max-width: 500px;
    margin: 0 auto;
    border-radius: 0;
    box-shadow: none;
  }
  
  .register-container {
    justify-content: center;
    align-items: center;
  }
}

@media (max-width: 768px) {
  .register-box {
    width: 100%;
    padding: 40px 30px;
    min-height: 100vh;
  }
  
  .title {
    font-size: 28px;
  }
  
  .brand-name {
    font-size: 28px;
  }
  
  .qq-row {
    flex-direction: column;
    gap: 0;
  }
  
  .verification-row {
    flex-direction: column;
    gap: 12px;
  }
  
  .verification-row :deep(.el-button) {
    width: 100%;
  }
}

@media (max-width: 480px) {
  .register-box {
    padding: 30px 20px;
  }
  
  .title {
    font-size: 24px;
  }
}
</style>
