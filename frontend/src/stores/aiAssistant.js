import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useAiAssistantStore = defineStore('aiAssistant', () => {
  // 状态
  const isVisible = ref(false)
  const messages = ref([])
  const isLoading = ref(false)
  const currentQuestion = ref(null)
  const conversationHistory = ref([])

  // 计算属性
  const hasMessages = computed(() => messages.value.length > 0)
  const lastMessage = computed(() => messages.value[messages.value.length - 1])

  // 操作方法
  function openAssistant(questionData = null) {
    isVisible.value = true
    if (questionData) {
      currentQuestion.value = questionData
      // 自动发送问题上下文
      const contextMessage = formatQuestionContext(questionData)
      addMessage('user', contextMessage)
    }
  }

  function closeAssistant() {
    isVisible.value = false
  }

  function toggleAssistant() {
    isVisible.value = !isVisible.value
  }

  function addMessage(role, content) {
    messages.value.push({
      role,
      content,
      timestamp: new Date().toISOString()
    })
    
    // 更新对话历史
    conversationHistory.value.push({ role, content })
  }

  function clearMessages() {
    messages.value = []
    conversationHistory.value = []
    currentQuestion.value = null
  }

  function setLoading(loading) {
    isLoading.value = loading
  }

  function formatQuestionContext(question) {
    let context = `题目类型：${question.type}\n\n`
    context += `题目内容：${question.content}\n\n`
    
    if (question.options && question.options.length > 0) {
      context += '选项：\n'
      question.options.forEach(opt => {
        context += `${opt.label}. ${opt.content}\n`
      })
      context += '\n'
    }
    
    if (question.answer) {
      context += `参考答案：${question.answer}\n\n`
    }
    
    if (question.analysis) {
      context += `题目解析：${question.analysis}\n\n`
    }
    
    context += '请帮我详细解答这道题目。'
    return context
  }

  function updateLastMessage(content) {
    if (messages.value.length > 0) {
      messages.value[messages.value.length - 1].content = content
    }
  }

  function setCurrentQuestion(question) {
    currentQuestion.value = question
  }

  // 重置store
  function $reset() {
    isVisible.value = false
    messages.value = []
    isLoading.value = false
    currentQuestion.value = null
    conversationHistory.value = []
  }

  return {
    // 状态
    isVisible,
    messages,
    isLoading,
    currentQuestion,
    conversationHistory,
    
    // 计算属性
    hasMessages,
    lastMessage,
    
    // 方法
    openAssistant,
    closeAssistant,
    toggleAssistant,
    addMessage,
    clearMessages,
    setLoading,
    formatQuestionContext,
    updateLastMessage,
    setCurrentQuestion,
    $reset
  }
})
