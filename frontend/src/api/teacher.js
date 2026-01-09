import request from '@/utils/request'

const TYPE_CODE_MAP = {
  single_choice: 'SINGLE',
  multiple_choice: 'MULTI',
  true_false: 'TRUE_FALSE',
  fill_blank: 'FILL',
  short_answer: 'SHORT',
  programming: 'PROGRAM'
}

const normalizeTypeCode = (value) => {
  if (!value) return value
  return TYPE_CODE_MAP[value] || value
}

const normalizeQuestionPayload = (data) => {
  if (!data || typeof data !== 'object') return data
  const payload = { ...data }
  if (payload.type && !payload.typeCode) {
    payload.typeCode = normalizeTypeCode(payload.type)
  }
  delete payload.type
  return payload
}

export function getSubjects() {
  return request({
    url: '/subjects',
    method: 'get'
  })
}

export function getClasses(params) {
  return request({
    url: '/classes',
    method: 'get',
    params
  })
}

// Question Bank
export function getQuestions(params) {
  const query = { ...(params || {}) }
  if (query.type && !query.typeCode) {
    query.typeCode = normalizeTypeCode(query.type)
    delete query.type
  }
  return request({
    url: '/questions',
    method: 'get',
    params: query
  })
}

export function getExamQuestions(params) {
  const query = { ...(params || {}) }
  if (query.type && !query.typeCode) {
    query.typeCode = normalizeTypeCode(query.type)
    delete query.type
  }
  return request({
    url: '/exam-questions',
    method: 'get',
    params: query
  })
}

export function createQuestion(data) {
  return request({
    url: '/questions',
    method: 'post',
    data: normalizeQuestionPayload(data)
  })
}

export function createExamQuestion(data) {
  return request({
    url: '/exam-questions',
    method: 'post',
    data: normalizeQuestionPayload(data)
  })
}

export function updateQuestion(id, data) {
  return request({
    url: `/questions/${id}`,
    method: 'put',
    data: normalizeQuestionPayload(data)
  })
}

export function updateExamQuestion(id, data) {
  return request({
    url: `/exam-questions/${id}`,
    method: 'put',
    data: normalizeQuestionPayload(data)
  })
}

export function deleteQuestion(id) {
  return request({
    url: `/questions/${id}`,
    method: 'delete'
  })
}

export function deleteExamQuestion(id) {
  return request({
    url: `/exam-questions/${id}`,
    method: 'delete'
  })
}

export function importQuestions(data) {
  return request({
    url: '/questions/import',
    method: 'post',
    data,
    headers: { 'Content-Type': 'multipart/form-data' }
  })
}

export function importExamQuestions(data) {
  return request({
    url: '/exam-questions/import',
    method: 'post',
    data,
    headers: { 'Content-Type': 'multipart/form-data' }
  })
}

export function auditQuestion(id, data) {
  const statusMap = { approved: 1, rejected: 2, pass: 1, reject: 2 }
  const statusValue = typeof data?.status === 'string' ? statusMap[data.status] : data?.status
  return request({
    url: '/audit/question/process',
    method: 'put',
    data: {
      ids: [id],
      status: statusValue,
      comment: data?.comment || ''
    }
  })
}

export function getAuditQuestions(params) {
  return request({
    url: '/audit/question/list',
    method: 'get',
    params
  })
}

export function getAuditQuestionDetail(id) {
  return request({
    url: `/audit/question/${id}`,
    method: 'get'
  })
}

// Paper Management
export function getPapers(params) {
  return request({
    url: '/papers',
    method: 'get',
    params
  })
}

export function createPaper(data) {
  return request({
    url: '/papers',
    method: 'post',
    data
  })
}

export function autoGeneratePaper(data) {
  return request({
    url: '/papers/auto-generate',
    method: 'post',
    data
  })
}

export function deletePaper(id) {
  return request({
    url: `/papers/${id}`,
    method: 'delete'
  })
}

export function getPaperDetail(id) {
  return request({
    url: `/papers/${id}`,
    method: 'get'
  })
}

export function updatePaper(id, data) {
  return request({
    url: `/papers/${id}`,
    method: 'put',
    data
  })
}

export function publishPaper(id) {
  return request({
    url: `/papers/${id}/publish`,
    method: 'put'
  })
}

export function unpublishPaper(id) {
  return request({
    url: `/papers/${id}/unpublish`,
    method: 'put'
  })
}

// Exam Management
export function getExams(params) {
  return request({
    url: '/exams',
    method: 'get',
    params
  })
}

export function createExam(data) {
  return request({
    url: '/exams',
    method: 'post',
    data
  })
}

export function deleteExam(id) {
  return request({
    url: `/exams/${id}`,
    method: 'delete'
  })
}

export function getExamDetail(id) {
  return request({
    url: `/exams/${id}`,
    method: 'get'
  })
}

export function setExamAllowReview(id, allowReview) {
  return request({
    url: `/exams/${id}/allow-review`,
    method: 'put',
    data: { allowReview }
  })
}

// Exam Students
export function getExamStudents(examId, params) {
  return request({
    url: `/exams/${examId}/students`,
    method: 'get',
    params
  })
}

// Score Management
export function getScoreList(params) {
  return request({
    url: '/scores',
    method: 'get',
    params
  })
}

export function getExamStats(examId) {
  return request({
    url: '/scores/stats',
    method: 'get',
    params: { examId }
  })
}

export function adjustScore(id, data) {
  const hasStudent = data && (data.studentId !== undefined && data.studentId !== null)
  const payload = hasStudent ? { score: data.score, reason: data.reason } : data
  const url = hasStudent ? `/scores/${id}/student/${data.studentId}` : `/scores/${id}`
  return request({
    url,
    method: 'put',
    data: payload
  })
}

export function getStudentPaperDetail(examId, studentId) {
  return request({
    url: `/scores/${examId}/student/${studentId}`,
    method: 'get'
  })
}

export function submitGrading(examId, studentId, data) {
  return request({
    url: `/scores/${examId}/student/${studentId}`,
    method: 'post',
    data
  })
}

export function batchPublishScores(scoreIds, published) {
  return request({
    url: '/scores/batch-publish',
    method: 'post',
    data: { scoreIds, published }
  })
}

export function exportScores(examId, format = 'excel') {
  return request({
    url: '/scores/export',
    method: 'get',
    params: { examId, format },
    responseType: 'blob'
  })
}

export function importScores(examId, file) {
  const formData = new FormData()
  formData.append('examId', examId)
  formData.append('file', file)
  return request({
    url: '/scores/import',
    method: 'post',
    data: formData,
    headers: { 'Content-Type': 'multipart/form-data' }
  })
}

// Monitor
export function getMonitorData(examId) {
  return request({
    url: `/monitor/${examId}`,
    method: 'get'
  })
}

export function sendWarning(examId, data) {
  return request({
    url: `/monitor/${examId}/warning`,
    method: 'post',
    data
  })
}

export function forceSubmit(examId, data) {
  return request({
    url: `/monitor/${examId}/force-submit`,
    method: 'post',
    data
  })
}

export function sendBroadcast(examId, data) {
  return request({
    url: `/monitor/${examId}/broadcast`,
    method: 'post',
    data
  })
}
