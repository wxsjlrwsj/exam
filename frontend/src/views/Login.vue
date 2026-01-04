<template>
  <div class="login-container">
    <ParticlesBackground color="rgba(255, 255, 255, 0.6)" :count="100" />
    <div class="login-box">
      <div class="login-header">
        <img src="../assets/logo.svg" alt="Logo" class="logo" />
        <h1 class="title">超星考试系统</h1>
        <p class="subtitle">智慧教学管理平台</p>
      </div>
      <el-form ref="loginFormRef" :model="loginForm" :rules="loginRules" class="login-form" autocomplete="on">
        <el-form-item prop="username">
          <el-input 
            v-model="loginForm.username" 
            placeholder="用户名 (admin/teacher/student)" 
            :prefix-icon="User"
            size="large"
            name="username"
            autocomplete="username"
          />
        </el-form-item>
        <el-form-item prop="password">
          <el-input 
            v-model="loginForm.password" 
            type="password" 
            placeholder="密码" 
            :prefix-icon="Lock"
            size="large"
            name="password"
            autocomplete="current-password"
            @keyup.enter="handleLogin"
          />
        </el-form-item>
        <el-form-item>
          <el-checkbox v-model="loginForm.rememberMe">记住我（7天免登录）</el-checkbox>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :loading="loading" @click="handleLogin" class="login-button">登录</el-button>
        </el-form-item>
        <div class="extra-actions">
          <el-button link type="info" @click="router.push('/forgot-password')">忘记密码？</el-button>
          <el-button link type="primary" @click="router.push('/register')">注册新账号</el-button>
        </div>
      </el-form>
      <div class="login-footer">
        <p>© {{ new Date().getFullYear() }} 超星考试系统 版权所有</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, inject, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { User, Lock } from '@element-plus/icons-vue'
import request from '@/utils/request'
import ParticlesBackground from '../components/ParticlesBackground.vue'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const route = useRoute()
const showMessage = inject('showMessage')
const userStore = useUserStore()
const loading = ref(false)

const loginForm = reactive({
  username: '',
  password: '',
  rememberMe: false
})

onMounted(async () => {
  try {
    const noAuto = String(route.query?.noAutoLogin || '') === '1'
    if (noAuto) return
    const preferRemember = localStorage.getItem('rememberMe') === 'true'
    const hasToken = !!userStore.token
    if (hasToken) {
      router.replace({ name: 'DashboardHome' })
      return
    }
    if (!preferRemember) return
    const last = Number(sessionStorage.getItem('autoLoginTriedAt') || '0')
    if (Date.now() - last < 3000) return
    sessionStorage.setItem('autoLoginTriedAt', String(Date.now()))
    const r = await request.post('/auth/refresh')
    if (r && r.token && r.userInfo) {
      const token = r.token
      let fullUserInfo = { ...r.userInfo }
      try {
        if (String(r.userInfo.userType).toLowerCase() === 'student') {
          const prof = await request.get('/student/profile', {
            headers: { Authorization: `Bearer ${token}` }
          })
          fullUserInfo = {
            ...r.userInfo,
            name: (prof && prof.name) ? prof.name : (r.userInfo.realName || r.userInfo.username),
            avatar: prof?.avatar || '',
            role: 'student'
          }
          window.dispatchEvent(new Event('user-info-update'))
        } else {
          fullUserInfo = {
            ...r.userInfo,
            name: r.userInfo.username,
            role: r.userInfo.userType
          }
        }
      } catch {}
      userStore.login({
        token,
        userInfo: fullUserInfo,
        rememberMe: true
      })
      localStorage.setItem('userType', fullUserInfo.role || r.userInfo.userType)
      localStorage.setItem('username', fullUserInfo.name || r.userInfo.username)
      localStorage.removeItem('disabledModules')
      router.replace({ name: 'DashboardHome' })
    }
  } catch (e) {}
})
 

const loginRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' }
  ]
}

const handleLogin = async () => {
  if (!loginFormRef.value) return

  loading.value = true
  try {
    const preferRemember = loginForm.rememberMe || localStorage.getItem('rememberMe') === 'true'
    if (!loginForm.password && preferRemember) {
      try {
        const r = await request.post('/auth/refresh')
        if (r && r.token && r.userInfo) {
          const token = r.token
          let fullUserInfo = { ...r.userInfo }
          try {
            if (String(r.userInfo.userType).toLowerCase() === 'student') {
              const prof = await request.get('/student/profile', {
                headers: { Authorization: `Bearer ${token}` }
              })
              fullUserInfo = {
                ...r.userInfo,
                name: (prof && prof.name) ? prof.name : (r.userInfo.realName || r.userInfo.username),
                avatar: prof?.avatar || '',
                role: 'student'
              }
              window.dispatchEvent(new Event('user-info-update'))
            } else {
              fullUserInfo = {
                ...r.userInfo,
                name: r.userInfo.username,
                role: r.userInfo.userType
              }
            }
          } catch {}
          userStore.login({
            token,
            userInfo: fullUserInfo,
            rememberMe: true
          })
          localStorage.setItem('userType', fullUserInfo.role || r.userInfo.userType)
          localStorage.setItem('username', fullUserInfo.name || r.userInfo.username)
          showMessage('已使用免登录凭证进入', 'success')
          localStorage.removeItem('disabledModules')
          const redirect = typeof route.query.redirect === 'string' ? route.query.redirect : ''
          if (redirect) {
            router.replace(redirect)
            return
          }
          router.push({ name: 'DashboardHome' })
          return
        }
      } catch {}
    }
    await loginFormRef.value.validate(async (valid) => {
      if (!valid) return
      const resp = await request.post('/auth/login', {
        username: loginForm.username,
        password: loginForm.password,
        rememberMe: loginForm.rememberMe
      })
      // request.js 拦截器返回 res.data (即后端的 data 字段)
      // 所以 resp 就是 { token: "...", userInfo: {...} }
      const data = resp || {}
      const token = data.token
      const userInfo = data.userInfo || {}

      if (!token || !userInfo.userType) {
        throw new Error('登录响应不完整')
      }

      // 获取完整用户信息
      let fullUserInfo = { ...userInfo }
      try {
        if (String(userInfo.userType).toLowerCase() === 'student') {
          const prof = await request.get('/student/profile', {
            headers: {
              Authorization: `Bearer ${token}`
            }
          })
          fullUserInfo = {
            ...userInfo,
            name: (prof && prof.name) ? prof.name : (userInfo.realName || userInfo.username || loginForm.username),
            avatar: prof?.avatar || '',
            role: 'student'
          }
          window.dispatchEvent(new Event('user-info-update'))
        } else {
          fullUserInfo = {
            ...userInfo,
            name: userInfo.username || loginForm.username,
            role: userInfo.userType
          }
        }
      } catch (e) {
        fullUserInfo = {
          ...userInfo,
          name: userInfo.username || loginForm.username,
          role: userInfo.userType
        }
      }

      // 使用Pinia store保存登录状态
      userStore.login({
        token,
        userInfo: fullUserInfo,
        rememberMe: loginForm.rememberMe
      })

      // 兼容旧代码：同时保存到localStorage
      localStorage.setItem('userType', userInfo.userType)
      localStorage.setItem('username', fullUserInfo.name)

      showMessage('登录成功，欢迎回来！', 'success')

      // 清理缓存
      localStorage.removeItem('disabledModules')
      const redirect = typeof route.query.redirect === 'string' ? route.query.redirect : ''
      if (redirect) {
        router.replace(redirect)
        return
      }
      router.push({ name: 'DashboardHome' })
    })
  } catch (error) {
      // request.js 已经处理了错误提示，这里主要处理 fallback 逻辑
      // showMessage('登录失败: ' + (error.message || '未知错误'), 'error')

      // 开发环境或本地开关启用时，使用测试账号作为后备
      if (import.meta.env.MODE === 'development' || localStorage.getItem('useFakeAuth') === '1') {
        let userType = 'student'
        if (loginForm.username.includes('admin')) userType = 'admin'
        else if (loginForm.username.includes('teacher')) userType = 'teacher'

        const mockToken = 'mock-token-' + Date.now()
        const mockUserInfo = {
          id: Date.now(),
          name: loginForm.username,
          username: loginForm.username,
          role: userType,
          userType: userType
        }

        // 使用Pinia store保存
        userStore.login({
          token: mockToken,
          userInfo: mockUserInfo,
          rememberMe: loginForm.rememberMe
        })

        // 兼容旧代码
        localStorage.setItem('userType', userType)
        localStorage.setItem('username', loginForm.username)

        showMessage('登录成功（测试账号）', 'success')
        localStorage.removeItem('disabledModules')
        const redirect = typeof route.query.redirect === 'string' ? route.query.redirect : ''
        if (redirect) {
          router.replace(redirect)
          return
        }
        router.push({ name: 'DashboardHome' })
      }
    } finally {
      loading.value = false
    }
}
const loginFormRef = ref(null)
</script>

<style scoped>
.login-container {
  height: 100vh;
  width: 100vw;
  display: flex;
  justify-content: center;
  align-items: center;
  background: linear-gradient(135deg, #1890ff 0%, #096dd9 100%);
  position: relative;
  overflow: hidden;
}

.login-box {
  width: 400px;
  padding: 40px;
  background-color: rgba(255, 255, 255, 0.9);
  border-radius: 8px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  z-index: 1;
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.login-header {
  text-align: center;
  margin-bottom: 30px;
}

.logo {
  width: 80px;
  height: 80px;
  margin-bottom: 16px;
}

.title {
  font-size: 24px;
  color: #333;
  margin-bottom: 8px;
}

.subtitle {
  font-size: 16px;
  color: #666;
}

.login-form {
  margin-bottom: 20px;
}

.login-button {
  width: 100%;
  height: 44px;
  font-size: 16px;
}

.extra-actions {
  display: flex;
  justify-content: space-between;
  margin-top: -10px;
  margin-bottom: 20px;
  padding: 0 4px;
}

.login-footer {
  text-align: center;
  color: #999;
  font-size: 12px;
}

@media (max-width: 768px) {
  .login-box {
    width: 90%;
    max-width: 400px;
    padding: 30px;
  }
}
</style>
