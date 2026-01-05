<template>
  <div class="ai-assistant-container">
    <!-- 悬浮按钮 -->
    <div 
      v-if="!isOpen" 
      class="ai-float-btn"
      @click="openChat"
    >
      <el-icon :size="24"><ChatDotRound /></el-icon>
      <span class="btn-text">AI助手</span>
    </div>

    <!-- 聊天窗口 -->
    <transition name="slide-up">
      <div v-if="isOpen" class="ai-chat-window">
        <!-- 头部 -->
        <div class="chat-header">
          <div class="header-left">
            <el-icon :size="20" color="#409EFF"><ChatDotRound /></el-icon>
            <span class="title">AI辅助解题</span>
          </div>
          <div class="header-right">
            <el-button link @click="clearHistory" title="清空对话">
              <el-icon><Delete /></el-icon>
            </el-button>
            <el-button link @click="closeChat" title="关闭">
              <el-icon><Close /></el-icon>
            </el-button>
          </div>
        </div>

        <!-- 当前题目信息 -->
        <div v-if="currentQuestion" class="question-info">
          <div class="question-tag">
            <el-tag size="small" type="info">当前题目</el-tag>
          </div>
          <div class="question-content">{{ truncateText(currentQuestion, 100) }}</div>
        </div>

        <!-- 消息列表 -->
        <div class="chat-messages" ref="messagesContainer">
          <div v-if="messages.length === 0" class="welcome-message">
            <el-icon :size="48" color="#409EFF"><ChatDotRound /></el-icon>
            <h3>AI辅助解题助手</h3>
            <p>我可以帮助你理解题目、解析知识点、提供解题思路</p>
            <div class="quick-actions">
              <el-button size="small" @click="sendQuickMessage('请帮我分析这道题的解题思路')">
                解题思路
              </el-button>
              <el-button size="small" @click="sendQuickMessage('请解释这道题涉及的知识点')">
                知识点解析
              </el-button>
              <el-button size="small" @click="sendQuickMessage('请给我一些类似的练习题')">
                类似题目
              </el-button>
            </div>
          </div>

          <div 
            v-for="(msg, index) in messages" 
            :key="index" 
            class="message-item"
            :class="msg.role"
          >
            <div class="message-avatar">
              <el-icon v-if="msg.role === 'user'" :size="20"><User /></el-icon>
              <el-icon v-else :size="20"><ChatDotRound /></el-icon>
            </div>
            <div class="message-content">
              <div class="message-text" v-html="renderMarkdown(msg.content)"></div>
              <div class="message-time">{{ msg.time }}</div>
            </div>
          </div>

          <!-- 加载中 -->
          <div v-if="isLoading" class="message-item assistant">
            <div class="message-avatar">
              <el-icon :size="20"><ChatDotRound /></el-icon>
            </div>
            <div class="message-content">
              <div class="message-text typing">
                <span class="dot"></span>
                <span class="dot"></span>
                <span class="dot"></span>
              </div>
            </div>
          </div>
        </div>

        <!-- 输入区域 -->
        <div class="chat-input">
          <el-input
            v-model="inputMessage"
            type="textarea"
            :rows="2"
            placeholder="输入你的问题，按Enter发送..."
            @keydown.enter.exact.prevent="sendMessage"
            :disabled="isLoading"
          />
          <el-button 
            type="primary" 
            :icon="Promotion" 
            @click="sendMessage"
            :loading="isLoading"
            :disabled="!inputMessage.trim()"
          >
            发送
          </el-button>
        </div>
      </div>
    </transition>
  </div>
</template>

<script setup>
import { ref, nextTick, watch, computed } from 'vue'
import { ChatDotRound, Close, Delete, User, Promotion } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import { useAiAssistantStore } from '@/stores/aiAssistant'
import axios from 'axios'

// 使用Pinia store
const aiStore = useAiAssistantStore()

const inputMessage = ref('')
const messagesContainer = ref(null)

// 从store获取状态
const isOpen = computed(() => aiStore.isVisible)
const messages = computed(() => aiStore.messages)
const isLoading = computed(() => aiStore.isLoading)
const currentQuestion = computed(() => aiStore.currentQuestion)

// 打开聊天窗口
const openChat = () => {
  aiStore.openAssistant()
}

// 关闭聊天窗口
const closeChat = () => {
  aiStore.closeAssistant()
}

// 清空历史
const clearHistory = () => {
  aiStore.clearMessages()
}

// 截断文本
const truncateText = (text, maxLength) => {
  if (!text) return ''
  return text.length > maxLength ? text.substring(0, maxLength) + '...' : text
}

// 获取当前时间
const getCurrentTime = () => {
  const now = new Date()
  return now.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })
}

// 简单的Markdown渲染
const renderMarkdown = (text) => {
  if (!text) return ''
  return text
    // 代码块
    .replace(/```(\w*)\n([\s\S]*?)```/g, '<pre><code class="language-$1">$2</code></pre>')
    // 行内代码
    .replace(/`([^`]+)`/g, '<code>$1</code>')
    // 粗体
    .replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>')
    // 斜体
    .replace(/\*([^*]+)\*/g, '<em>$1</em>')
    // 换行
    .replace(/\n/g, '<br>')
}

// 构建历史消息JSON
const buildHistoryJson = () => {
  if (aiStore.conversationHistory.length === 0) return ''
  return aiStore.conversationHistory.map(msg => {
    const role = msg.role === 'user' ? 'user' : 'assistant'
    const content = msg.content.replace(/"/g, '\\"').replace(/\n/g, '\\n')
    return `{"role":"${role}","content":"${content}"}`
  }).join(',')
}

// 发送快捷消息
const sendQuickMessage = (text) => {
  inputMessage.value = text
  sendMessage()
}

// 发送消息
const sendMessage = async () => {
  const message = inputMessage.value.trim()
  if (!message || aiStore.isLoading) return

  // 添加用户消息到store
  aiStore.addMessage('user', message)
  inputMessage.value = ''
  aiStore.setLoading(true)

  await nextTick()
  scrollToBottom()

  try {
    // 获取token（优先从sessionStorage，其次从localStorage）
    const token = sessionStorage.getItem('token') || localStorage.getItem('token')
    if (!token) {
      throw new Error('未登录或登录已过期')
    }
    
    // 使用流式API
    const response = await fetch('/api/student/ai/chat/stream', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify({
        question: aiStore.currentQuestion || '无具体题目',
        message: message,
        history: buildHistoryJson()
      })
    })

    if (!response.ok) {
      throw new Error('请求失败')
    }

    // 添加AI消息占位
    aiStore.addMessage('assistant', '')

    // 读取流式响应
    const reader = response.body.getReader()
    const decoder = new TextDecoder()
    let streamEnded = false

    while (true) {
      const { done, value } = await reader.read()
      if (done || streamEnded) break

      const chunk = decoder.decode(value)
      const lines = chunk.split('\n')

      for (const line of lines) {
        if (line.startsWith('data:')) {
          const data = line.substring(5).trim()
          if (data === '[DONE]') {
            streamEnded = true
            break
          }
          // 追加内容到最后一条消息
          const lastMsg = aiStore.messages[aiStore.messages.length - 1]
          if (lastMsg) {
            lastMsg.content += data
          }
          await nextTick()
          scrollToBottom()
        }
      }
    }
  } catch (error) {
    console.error('AI请求失败:', error)
    // 使用非流式API作为备用
    try {
      const token = sessionStorage.getItem('token') || localStorage.getItem('token')
      const res = await axios.post('/api/student/ai/chat', {
        question: aiStore.currentQuestion || '无具体题目',
        message: message,
        history: buildHistoryJson()
      }, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      })
      const lastMsg = aiStore.messages[aiStore.messages.length - 1]
      const fallbackText = res.data?.data?.reply || ''
      // 若已产生部分流式内容，则不再追加“抱歉”类文本，避免重复
      if (!lastMsg || !lastMsg.content || lastMsg.content.trim().length === 0) {
        aiStore.addMessage('assistant', fallbackText || '抱歉，AI服务暂时不可用')
      } else {
        // 如果已有内容且后端返回明确的补充文本，则谨慎追加
        if (fallbackText && fallbackText !== '抱歉，AI服务暂时不可用，请稍后重试。') {
          lastMsg.content += '\n' + fallbackText
        }
      }
    } catch (e) {
      const lastMsg = aiStore.messages[aiStore.messages.length - 1]
      if (!lastMsg || !lastMsg.content || lastMsg.content.trim().length === 0) {
        aiStore.addMessage('assistant', '抱歉，AI服务暂时不可用，请稍后重试。')
      }
    }
  } finally {
    aiStore.setLoading(false)
    await nextTick()
    scrollToBottom()
  }
}

// 滚动到底部
const scrollToBottom = () => {
  if (messagesContainer.value) {
    messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight
  }
}

// 设置当前题目
const setQuestion = (question) => {
  aiStore.setCurrentQuestion(question)
}

// 暴露方法
defineExpose({
  openChat,
  closeChat,
  setQuestion
})
</script>

<style scoped>
.ai-assistant-container {
  position: fixed;
  bottom: 20px;
  right: 20px;
  z-index: 2000;
}

/* 悬浮按钮 */
.ai-float-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 20px;
  background: linear-gradient(135deg, #409EFF 0%, #67C23A 100%);
  color: white;
  border-radius: 50px;
  cursor: pointer;
  box-shadow: 0 4px 15px rgba(64, 158, 255, 0.4);
  transition: all 0.3s ease;
}

.ai-float-btn:hover {
  transform: translateY(-3px);
  box-shadow: 0 6px 20px rgba(64, 158, 255, 0.5);
}

.ai-float-btn .btn-text {
  font-size: 14px;
  font-weight: 500;
}

/* 聊天窗口 */
.ai-chat-window {
  width: 420px;
  height: 600px;
  background: white;
  border-radius: 16px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.15);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

/* 头部 */
.chat-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  background: linear-gradient(135deg, #409EFF 0%, #67C23A 100%);
  color: white;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 10px;
}

.header-left .title {
  font-size: 16px;
  font-weight: 600;
}

.header-right {
  display: flex;
  gap: 8px;
}

.header-right .el-button {
  color: white;
}

/* 题目信息 */
.question-info {
  padding: 12px 16px;
  background: #f5f7fa;
  border-bottom: 1px solid #e4e7ed;
}

.question-tag {
  margin-bottom: 6px;
}

.question-content {
  font-size: 13px;
  color: #606266;
  line-height: 1.5;
}

/* 消息列表 */
.chat-messages {
  flex: 1;
  overflow-y: auto;
  padding: 16px;
  background: #fafafa;
}

/* 欢迎消息 */
.welcome-message {
  text-align: center;
  padding: 40px 20px;
}

.welcome-message h3 {
  margin: 16px 0 8px;
  color: #303133;
}

.welcome-message p {
  color: #909399;
  font-size: 14px;
  margin-bottom: 20px;
}

.quick-actions {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 8px;
}

/* 消息项 */
.message-item {
  display: flex;
  gap: 10px;
  margin-bottom: 16px;
}

.message-item.user {
  flex-direction: row-reverse;
}

.message-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.message-item.user .message-avatar {
  background: #409EFF;
  color: white;
}

.message-item.assistant .message-avatar {
  background: #67C23A;
  color: white;
}

.message-content {
  max-width: 75%;
}

.message-text {
  padding: 12px 16px;
  border-radius: 12px;
  font-size: 14px;
  line-height: 1.6;
  word-break: break-word;
}

.message-item.user .message-text {
  background: #409EFF;
  color: white;
  border-bottom-right-radius: 4px;
}

.message-item.assistant .message-text {
  background: white;
  color: #303133;
  border-bottom-left-radius: 4px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
}

.message-text :deep(code) {
  background: rgba(0, 0, 0, 0.1);
  padding: 2px 6px;
  border-radius: 4px;
  font-family: 'Consolas', monospace;
  font-size: 13px;
}

.message-text :deep(pre) {
  background: #2d2d2d;
  color: #f8f8f2;
  padding: 12px;
  border-radius: 8px;
  overflow-x: auto;
  margin: 8px 0;
}

.message-text :deep(pre code) {
  background: transparent;
  padding: 0;
}

.message-time {
  font-size: 11px;
  color: #909399;
  margin-top: 4px;
  text-align: right;
}

.message-item.user .message-time {
  text-align: left;
}

/* 打字动画 */
.typing {
  display: flex;
  gap: 4px;
  padding: 16px !important;
}

.typing .dot {
  width: 8px;
  height: 8px;
  background: #409EFF;
  border-radius: 50%;
  animation: typing 1.4s infinite ease-in-out;
}

.typing .dot:nth-child(2) {
  animation-delay: 0.2s;
}

.typing .dot:nth-child(3) {
  animation-delay: 0.4s;
}

@keyframes typing {
  0%, 80%, 100% {
    transform: scale(0.6);
    opacity: 0.5;
  }
  40% {
    transform: scale(1);
    opacity: 1;
  }
}

/* 输入区域 */
.chat-input {
  display: flex;
  gap: 10px;
  padding: 16px;
  background: white;
  border-top: 1px solid #e4e7ed;
}

.chat-input .el-textarea {
  flex: 1;
}

.chat-input .el-button {
  align-self: flex-end;
}

/* 动画 */
.slide-up-enter-active,
.slide-up-leave-active {
  transition: all 0.3s ease;
}

.slide-up-enter-from,
.slide-up-leave-to {
  opacity: 0;
  transform: translateY(20px);
}

/* 滚动条样式 */
.chat-messages::-webkit-scrollbar {
  width: 6px;
}

.chat-messages::-webkit-scrollbar-track {
  background: transparent;
}

.chat-messages::-webkit-scrollbar-thumb {
  background: #dcdfe6;
  border-radius: 3px;
}

.chat-messages::-webkit-scrollbar-thumb:hover {
  background: #c0c4cc;
}
</style>
