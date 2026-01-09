/**
 * 学生端API接口
 */
import request from '@/utils/request'

/**
 * 获取考试列表
 * @param {Object} params - 查询参数
 * @returns {Promise}
 */
export function getExams(params) {
  return request({
    url: '/student/exams',
    method: 'get',
    params
  })
}

/**
 * 获取考试试卷
 * @param {Number} examId - 考试ID
 * @returns {Promise}
 */
export function getExamPaper(examId) {
  return request({
    url: `/student/exams/${examId}/paper`,
    method: 'get'
  })
}

export function getExamResult(examId) {
  return request({
    url: `/student/exams/${examId}/result`,
    method: 'get'
  })
}

export function getExamReview(examId) {
  return request({
    url: `/student/exams/${examId}/review`,
    method: 'get'
  })
}

/**
 * 提交考试答案
 * @param {Number} examId - 考试ID
 * @param {Object} data - 答案数据
 * @returns {Promise}
 */
export function submitExam(examId, data) {
  return request({
    url: `/student/exams/${examId}/submit`,
    method: 'post',
    data
  })
}

/**
 * 获取练习题目列表
 * @param {Object} params - 查询参数
 * @returns {Promise}
 */
export function getPracticeQuestions(params) {
  return request({
    url: '/student/practice/questions',
    method: 'get',
    params
  })
}

export function submitPracticeQuestion(data) {
  return request({
    url: '/student/questions/submit',
    method: 'post',
    data
  })
}

export function getMyPracticeSubjects() {
  return request({
    url: '/student/questions/subjects',
    method: 'get'
  })
}

/**
 * 获取个性化题库
 * @param {Object} params - 查询参数
 * @returns {Promise}
 */
export function getPersonalizedQuestions(params) {
  return request({
    url: '/student/personalized/questions',
    method: 'get',
    params
  })
}

/**
 * 获取错题本
 * @param {Object} params - 查询参数
 * @returns {Promise}
 */
export function getErrorQuestions(params) {
  return request({
    url: '/student/errors',
    method: 'get',
    params
  })
}

/**
 * 添加错题
 * @param {Object} data - 错题数据
 * @returns {Promise}
 */
export function addErrorQuestion(data) {
  return request({
    url: '/student/errors',
    method: 'post',
    data
  })
}

/**
 * 删除错题
 * @param {Number} id - 错题ID
 * @returns {Promise}
 */
export function deleteErrorQuestion(id) {
  return request({
    url: `/student/errors/${id}`,
    method: 'delete'
  })
}

/**
 * 获取收藏夹列表
 * @returns {Promise}
 */
export function getCollections() {
  return request({
    url: '/student/collections',
    method: 'get'
  })
}

/**
 * 创建收藏夹
 * @param {Object} data - 收藏夹数据
 * @returns {Promise}
 */
export function createCollection(data) {
  return request({
    url: '/student/collections',
    method: 'post',
    data
  })
}

/**
 * 删除收藏夹
 * @param {Number} id - 收藏夹ID
 * @returns {Promise}
 */
export function deleteCollection(id) {
  return request({
    url: `/student/collections/${id}`,
    method: 'delete'
  })
}

/**
 * 更新收藏夹
 * @param {Number} id - 收藏夹ID
 * @param {Object} data - 更新数据
 * @returns {Promise}
 */
export function updateCollection(id, data) {
  return request({
    url: `/student/collections/${id}`,
    method: 'put',
    data
  })
}

/**
 * 获取收藏夹题目
 * @param {Number} id - 收藏夹ID
 * @param {Object} params - 查询参数
 * @returns {Promise}
 */
export function getCollectionQuestions(id, params) {
  return request({
    url: `/student/collections/${id}/questions`,
    method: 'get',
    params
  })
}

/**
 * 添加题目到收藏夹
 * @param {Number} id - 收藏夹ID
 * @param {Object} data - 题目数据
 * @returns {Promise}
 */
export function addQuestionToCollection(id, data) {
  return request({
    url: `/student/collections/${id}/questions`,
    method: 'post',
    data
  })
}

/**
 * 从收藏夹移除题目
 * @param {Number} collectionId - 收藏夹ID
 * @param {Number} questionId - 题目ID
 * @returns {Promise}
 */
export function removeQuestionFromCollection(collectionId, questionId) {
  return request({
    url: `/student/collections/${collectionId}/questions/${questionId}`,
    method: 'delete'
  })
}

/**
 * 获取自测列表
 * @param {Object} params - 查询参数
 * @returns {Promise}
 */
export function getQuizzes(params) {
  return request({
    url: '/student/quizzes',
    method: 'get',
    params
  })
}

/**
 * 创建自测
 * @param {Object} data - 自测数据
 * @returns {Promise}
 */
export function createQuiz(data) {
  return request({
    url: '/student/quizzes',
    method: 'post',
    data
  })
}

/**
 * 提交自测答案
 * @param {Number} id - 自测ID
 * @param {Object} data - 答案数据
 * @returns {Promise}
 */
export function submitQuiz(id, data) {
  return request({
    url: `/student/quizzes/${id}/submit`,
    method: 'post',
    data
  })
}

/**
 * 获取用户信息
 * @returns {Promise}
 */
export function getUserProfile() {
  return request({
    url: '/student/profile',
    method: 'get'
  })
}

/**
 * 更新用户信息
 * @param {Object} data - 用户数据
 * @returns {Promise}
 */
export function updateUserProfile(data) {
  return request({
    url: '/student/profile',
    method: 'put',
    data
  })
}

/**
 * 修改密码
 * @param {Object} data - 密码数据
 * @returns {Promise}
 */
export function changePassword(data) {
  return request({
    url: '/student/profile/password',
    method: 'put',
    data
  })
}
