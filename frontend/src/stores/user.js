import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useUserStore = defineStore('user', () => {
  // 状态
  const rememberMe = ref(localStorage.getItem('rememberMe') === 'true')
  const legacyLocalToken = localStorage.getItem('token') || ''
  const legacyLocalUserInfo = localStorage.getItem('userInfo') || 'null'
  const legacyLocalExpire = localStorage.getItem('tokenExpire') || ''
  const legacySessionToken = sessionStorage.getItem('token') || ''
  const legacySessionUserInfo = sessionStorage.getItem('userInfo') || 'null'
  const legacySessionExpire = sessionStorage.getItem('tokenExpire') || ''

  if (!rememberMe.value && legacyLocalToken) {
    sessionStorage.setItem('token', legacyLocalToken)
    sessionStorage.setItem('userInfo', legacyLocalUserInfo)
    if (legacyLocalExpire) sessionStorage.setItem('tokenExpire', legacyLocalExpire)
    localStorage.removeItem('token')
    localStorage.removeItem('userInfo')
    localStorage.removeItem('tokenExpire')
  }

  const token = ref(rememberMe.value ? (legacyLocalToken || '') : (legacySessionToken || ''))
  const userInfo = ref(JSON.parse(rememberMe.value ? legacyLocalUserInfo : legacySessionUserInfo))

  // 计算属性
  const isLoggedIn = computed(() => !!token.value)
  const userName = computed(() => userInfo.value?.name || '')
  const userRole = computed(() => userInfo.value?.role || '')
  const userId = computed(() => userInfo.value?.id || null)

  // 登录
  function login(loginData) {
    token.value = loginData.token
    userInfo.value = loginData.userInfo
    
    // 记住我功能
    if (loginData.rememberMe) {
      rememberMe.value = true
      localStorage.setItem('rememberMe', 'true')
      localStorage.setItem('token', loginData.token)
      localStorage.setItem('userInfo', JSON.stringify(loginData.userInfo))
      sessionStorage.removeItem('token')
      sessionStorage.removeItem('userInfo')
      sessionStorage.removeItem('tokenExpire')
      // 设置7天过期
      const expireTime = new Date().getTime() + 7 * 24 * 60 * 60 * 1000
      localStorage.setItem('tokenExpire', expireTime.toString())
    } else {
      rememberMe.value = false
      localStorage.removeItem('rememberMe')
      localStorage.removeItem('token')
      localStorage.removeItem('userInfo')
      localStorage.removeItem('tokenExpire')
      sessionStorage.setItem('token', loginData.token)
      sessionStorage.setItem('userInfo', JSON.stringify(loginData.userInfo))
      // 设置24小时过期
      const expireTime = new Date().getTime() + 24 * 60 * 60 * 1000
      sessionStorage.setItem('tokenExpire', expireTime.toString())
    }
  }

  // 登出
  function logout() {
    token.value = ''
    userInfo.value = null
    // 清除 token（不影响 rememberMe 偏好）
    localStorage.removeItem('token')
    localStorage.removeItem('userInfo')
    localStorage.removeItem('tokenExpire')
    sessionStorage.removeItem('token')
    sessionStorage.removeItem('userInfo')
    sessionStorage.removeItem('tokenExpire')
  }

  // 更新用户信息
  function updateUserInfo(newInfo) {
    userInfo.value = { ...userInfo.value, ...newInfo }
    const storage = rememberMe.value ? localStorage : sessionStorage
    storage.setItem('userInfo', JSON.stringify(userInfo.value))
  }

  // 更新Token
  function updateToken(newToken) {
    token.value = newToken
    const storage = rememberMe.value ? localStorage : sessionStorage
    storage.setItem('token', newToken)
  }

  // 检查Token是否过期
  function checkTokenExpire() {
    const storage = rememberMe.value ? localStorage : sessionStorage
    const expireTime = storage.getItem('tokenExpire')
    if (!expireTime) return false
    
    const now = new Date().getTime()
    if (now > parseInt(expireTime)) {
      // Token已过期，清除登录状态
      logout()
      return true
    }
    return false
  }

  // 刷新Token过期时间
  function refreshTokenExpire() {
    const storage = rememberMe.value ? localStorage : sessionStorage
    if (rememberMe.value) {
      const expireTime = new Date().getTime() + 7 * 24 * 60 * 60 * 1000
      storage.setItem('tokenExpire', expireTime.toString())
    } else {
      const expireTime = new Date().getTime() + 24 * 60 * 60 * 1000
      storage.setItem('tokenExpire', expireTime.toString())
    }
  }

  // 初始化时检查Token是否过期
  if (token.value) {
    checkTokenExpire()
  }

  return {
    // 状态
    token,
    userInfo,
    rememberMe,
    
    // 计算属性
    isLoggedIn,
    userName,
    userRole,
    userId,
    
    // 方法
    login,
    logout,
    updateUserInfo,
    updateToken,
    checkTokenExpire,
    refreshTokenExpire
  }
})
