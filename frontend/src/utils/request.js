import axios from 'axios'
import { ElMessage } from 'element-plus'
import router from '@/router'
import { useUserStore } from '@/stores/user'

// Create an axios instance
const service = axios.create({
    baseURL: import.meta.env.VITE_APP_BASE_API || import.meta.env.VITE_API_BASE_URL || '/api',
    timeout: 5000
})

// Request interceptor（请求拦截器：携带Token）
service.interceptors.request.use(
    config => {
        // 从Pinia store获取token
        const userStore = useUserStore()
        if (userStore.token) {
            config.headers['Authorization'] = `Bearer ${userStore.token}`
        }
        return config
    },
    error => {
        console.log(error)
        return Promise.reject(error)
    }
)

// Response interceptor（响应拦截器：处理错误、401）
service.interceptors.response.use(
    response => {
        const ct = (response.headers && (response.headers['content-type'] || response.headers['Content-Type'])) || ''
        const isBlob = response.request && response.request.responseType === 'blob'
        if (isBlob || ct.includes('application/octet-stream') || ct.includes('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')) {
            return response.data
        }
        const res = response.data
        if (res.code !== 200) {
            return Promise.reject(new Error(res.message || 'Error'))
        }
        return res.data
    },
    error => {
        console.log('err' + error)
        // 401：未登录/Token失效，跳登录页
        if (error.response?.status === 401) {
            const userStore = useUserStore()
            userStore.logout() // 使用store的logout方法
            router.push('/login')
        }
        // 全局错误提示
        ElMessage({
            message: error.message || 'Request Error',
            type: 'error',
            duration: 5 * 1000
        })
        return Promise.reject(error)
    }
)

export default service
