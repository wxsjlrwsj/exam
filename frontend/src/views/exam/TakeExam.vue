<template>
  <div class="take-exam-container" v-loading="loading">
    <div class="exam-header">
      <div class="title">{{ paper.name || '考试' }}</div>
      <div class="sub">{{ paper.subject }}</div>
      <div class="timer">{{ formatTime(timer) }}</div>
    </div>
    <div v-if="questions.length === 0" class="empty">当前考试暂无试题或不在考试时间</div>
    <div v-else class="question-list">
      <div v-for="(q, idx) in questions" :key="q.id" class="q-card">
        <div class="q-head">
          <span class="no">{{ idx + 1 }}</span>
          <span class="type">{{ getTypeLabel(q.type) }}</span>
          <span class="score">{{ q.score }}分</span>
        </div>
        <div class="q-content">{{ q.content }}</div>
        <div class="q-input">
          <div v-if="q.type === 'single_choice'" class="choice-group">
            <div
              v-for="opt in parseOptions(q.options)"
              :key="opt.key"
              class="choice-item"
              :class="{ selected: answers[q.id] === opt.key }"
              @click="answers[q.id] = opt.key"
            >
              <span class="choice-key">{{ opt.key }}</span>
              <span class="choice-val">{{ opt.value }}</span>
            </div>
          </div>
          <div v-else-if="q.type === 'multiple_choice'" class="choice-group">
            <div
              v-for="opt in parseOptions(q.options)"
              :key="opt.key"
              class="choice-item"
              :class="{ selected: (answers[q.id] || []).includes(opt.key) }"
              @click="toggleMulti(q.id, opt.key)"
            >
              <span class="choice-key">{{ opt.key }}</span>
              <span class="choice-val">{{ opt.value }}</span>
            </div>
          </div>
          <div v-else-if="q.type === 'true_false'" class="choice-group horizontal">
            <div class="choice-item" :class="{ selected: answers[q.id] === 'T' }" @click="answers[q.id] = 'T'">
              <span class="choice-val">正确</span>
            </div>
            <div class="choice-item" :class="{ selected: answers[q.id] === 'F' }" @click="answers[q.id] = 'F'">
              <span class="choice-val">错误</span>
            </div>
          </div>
          <div v-else>
            <el-input
              type="textarea"
              v-model="answers[q.id]"
              placeholder="请输入答案"
              :rows="4"
              resize="none"
            />
          </div>
        </div>
      </div>
    </div>
    <div class="actions">
      <el-button type="primary" @click="submit">提交试卷</el-button>
      <el-button @click="goBack">返回</el-button>
    </div>
    <video ref="videoRef" autoplay playsinline style="display:none"></video>
    <canvas ref="canvasRef" style="display:none"></canvas>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onUnmounted, inject, nextTick } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import request from '@/utils/request'

const route = useRoute()
const router = useRouter()
const showMessage = inject('showMessage')

const loading = ref(false)
const paper = reactive({ name: '', subject: '' })
const questions = ref([])
const answers = reactive({})
const timer = ref(0)
let h = null
const videoRef = ref(null)
const canvasRef = ref(null)
let stream = null
let snapshotTimer = null
let warningTimer = null
const displayedWarningIds = new Set()
let lastWarningTime = null

const parseOptions = (str) => {
  if (!str) return []
  try { return JSON.parse(str) } catch { return [] }
}

const getTypeLabel = (t) => {
  if (t === 'single_choice') return '单选题'
  if (t === 'multiple_choice') return '多选题'
  if (t === 'true_false') return '判断题'
  if (t === 'fill_blank') return '填空题'
  if (t === 'short_answer') return '简答题'
  return t
}

const formatTime = (s) => {
  const m = Math.floor(s / 60)
  const ss = s % 60
  return `${String(m).padStart(2, '0')}:${String(ss).padStart(2, '0')}`
}

const toggleMulti = (qid, key) => {
  const arr = answers[qid] || []
  const has = arr.includes(key)
  answers[qid] = has ? arr.filter(k => k !== key) : [...arr, key]
}

const loadPaper = async () => {
  const examId = route.params.examId
  loading.value = true
  try {
    const data = await request.get(`/student/exams/${examId}/paper`)
    paper.name = data?.name || ''
    paper.subject = data?.subject || ''
    questions.value = data?.questions || []
    questions.value.forEach(q => { if (q.type === 'multiple_choice') answers[q.id] = [] })
    timer.value = 0
    if (h) clearInterval(h)
    h = setInterval(() => { timer.value++ }, 1000)
    await startCameraAndUpload()
  } catch (e) {
    questions.value = []
  } finally {
    loading.value = false
  }
}

const startCameraAndUpload = async () => {
  try {
    stream = await navigator.mediaDevices.getUserMedia({ video: { width: 640, height: 480 } })
    await nextTick()
    if (videoRef.value) videoRef.value.srcObject = stream
    if (snapshotTimer) clearInterval(snapshotTimer)
    const examId = route.params.examId
    snapshotTimer = setInterval(async () => {
      try {
        if (!canvasRef.value || !videoRef.value) return
        const canvas = canvasRef.value
        const video = videoRef.value
        canvas.width = video.videoWidth || 640
        canvas.height = video.videoHeight || 480
        const ctx = canvas.getContext('2d')
        ctx.drawImage(video, 0, 0)
        const base64 = canvas.toDataURL('image/jpeg', 0.5)
        await request.post(`/student/exams/${examId}/camera-snapshot`, { image: base64, contentType: 'image/jpeg' })
      } catch {}
    }, 5000)
  } catch {}
}

const stopCamera = () => {
  if (snapshotTimer) {
    clearInterval(snapshotTimer)
    snapshotTimer = null
  }
  if (warningTimer) {
    clearInterval(warningTimer)
    warningTimer = null
  }
  if (stream) {
    stream.getTracks().forEach(t => t.stop())
    stream = null
  }
}

const startWarningPolling = () => {
  const examId = route.params.examId
  if (warningTimer) clearInterval(warningTimer)
  warningTimer = setInterval(async () => {
    try {
      const params = {}
      if (lastWarningTime) params.since = lastWarningTime
      const res = await request.get(`/student/exams/${examId}/warnings`, { params })
      const list = res?.list || []
      if (list.length > 0) {
        list.reverse().forEach(w => {
          if (!displayedWarningIds.has(w.id)) {
            displayedWarningIds.add(w.id)
            const msg = w.type === 'force_submit' ? '教师已强制收卷，请停止作答' : `老师广播: ${w.message}`
            showMessage && showMessage(msg, w.type === 'force_submit' ? 'warning' : 'info')
          }
        })
        const latest = list[0]
        if (latest && latest.sendTime) {
          lastWarningTime = latest.sendTime
        }
      }
    } catch {}
  }, 3000)
}

const submit = async () => {
  const examId = route.params.examId
  await request.post(`/student/exams/${examId}/submit`, { answers, durationUsed: timer.value })
  showMessage && showMessage('提交成功', 'success')
  router.push('/dashboard/student/exam-list')
}

const goBack = () => {
  router.back()
}

onMounted(() => { loadPaper(); startWarningPolling() })
onUnmounted(() => { if (h) clearInterval(h); stopCamera() })
</script>

<style scoped>
.take-exam-container {
  padding: 20px;
}
.exam-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-bottom: 12px;
  border-bottom: 1px solid #ebeef5;
  margin-bottom: 12px;
}
.title {
  font-size: 20px;
  font-weight: 600;
}
.sub {
  color: #909399;
}
.timer {
  font-family: monospace;
  color: #409eff;
}
.empty {
  padding: 40px;
  text-align: center;
  color: #909399;
}
.question-list {
  margin-top: 10px;
}
.q-card {
  border: 1px solid #ebeef5;
  border-radius: 6px;
  padding: 12px;
  margin-bottom: 12px;
}
.q-head {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 8px;
}
.no {
  background: #409eff;
  color: #fff;
  border-radius: 4px;
  padding: 2px 6px;
}
.type {
  color: #606266;
}
.score {
  margin-left: auto;
  color: #909399;
}
.choice-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.choice-group.horizontal {
  flex-direction: row;
}
.choice-item {
  display: flex;
  align-items: center;
  gap: 8px;
  border: 1px solid #ebeef5;
  border-radius: 6px;
  padding: 8px;
  cursor: pointer;
}
.choice-item.selected {
  background: #ecf5ff;
  border-color: #c6e2ff;
}
.actions {
  display: flex;
  gap: 12px;
  margin-top: 16px;
}
</style>
