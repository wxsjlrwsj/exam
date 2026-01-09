/**
 * 数据验证工具
 * 用于过滤掉前端显示的不完整或无效数据
 */

/**
 * 验证题目数据是否完整
 * @param {Object} question - 题目对象
 * @returns {Boolean} - 是否有效
 */
export function isValidQuestion(question) {
  if (!question || typeof question !== 'object') return false

  if (!question.type) {
    const typeIdMap = {
      1: 'single_choice',
      2: 'multiple_choice',
      3: 'true_false',
      4: 'fill_blank',
      5: 'short_answer',
      6: 'programming'
    }
    const typeCodeMap = {
      SINGLE: 'single_choice',
      MULTI: 'multiple_choice',
      TRUE_FALSE: 'true_false',
      FILL: 'fill_blank',
      SHORT: 'short_answer',
      PROGRAM: 'programming'
    }
    if (question.typeId != null && typeIdMap[question.typeId]) {
      question.type = typeIdMap[question.typeId]
    } else if (question.typeCode && typeCodeMap[question.typeCode]) {
      question.type = typeCodeMap[question.typeCode]
    }
  }
  
  // 必须字段检查
  const requiredFields = ['id', 'content', 'type']
  for (const field of requiredFields) {
    if (!question[field]) return false
  }
  
  // ID必须是正数
  if (typeof question.id !== 'number' || question.id <= 0) return false
  
  // 内容不能为空
  if (typeof question.content !== 'string' || question.content.trim() === '') return false
  
  return true
}

/**
 * 验证试卷数据是否完整
 * @param {Object} paper - 试卷对象
 * @returns {Boolean} - 是否有效
 */
export function isValidPaper(paper) {
  if (!paper || typeof paper !== 'object') return false
  
  // 必须字段检查
  const requiredFields = ['id', 'name', 'subject']
  for (const field of requiredFields) {
    if (!paper[field]) return false
  }
  
  // ID必须是正数
  if (typeof paper.id !== 'number' || paper.id <= 0) return false
  
  // 名称不能为空
  if (typeof paper.name !== 'string' || paper.name.trim() === '') return false
  
  // 题目数量应该大于0
  if (paper.questionCount !== undefined && paper.questionCount <= 0) return false
  
  return true
}

/**
 * 验证考试数据是否完整
 * @param {Object} exam - 考试对象
 * @returns {Boolean} - 是否有效
 */
export function isValidExam(exam) {
  if (!exam || typeof exam !== 'object') return false
  
  // 必须字段检查
  const requiredFields = ['id', 'name', 'paperId', 'startTime']
  for (const field of requiredFields) {
    if (!exam[field]) return false
  }
  
  // ID必须是正数
  if (typeof exam.id !== 'number' || exam.id <= 0) return false
  if (typeof exam.paperId !== 'number' || exam.paperId <= 0) return false
  
  // 名称不能为空
  if (typeof exam.name !== 'string' || exam.name.trim() === '') return false
  
  // 开始时间应该是有效日期字符串
  if (typeof exam.startTime !== 'string' || exam.startTime.trim() === '') return false
  
  return true
}

/**
 * 验证成绩数据是否完整
 * @param {Object} score - 成绩对象
 * @returns {Boolean} - 是否有效
 */
export function isValidScore(score) {
  if (!score || typeof score !== 'object') return false
  
  // 必须字段检查
  const requiredFields = ['id', 'studentId', 'examId']
  for (const field of requiredFields) {
    if (!score[field]) return false
  }
  
  // ID必须是正数
  if (typeof score.id !== 'number' || score.id <= 0) return false
  
  return true
}

/**
 * 过滤题目列表，只保留有效数据
 * @param {Array} questions - 题目数组
 * @returns {Array} - 有效的题目数组
 */
export function filterValidQuestions(questions) {
  if (!Array.isArray(questions)) return []
  return questions.filter(q => isValidQuestion(q))
}

/**
 * 过滤试卷列表，只保留有效数据
 * @param {Array} papers - 试卷数组
 * @returns {Array} - 有效的试卷数组
 */
export function filterValidPapers(papers) {
  if (!Array.isArray(papers)) return []
  return papers.filter(p => isValidPaper(p))
}

/**
 * 过滤考试列表，只保留有效数据
 * @param {Array} exams - 考试数组
 * @returns {Array} - 有效的考试数组
 */
export function filterValidExams(exams) {
  if (!Array.isArray(exams)) return []
  return exams.filter(e => isValidExam(e))
}

/**
 * 过滤成绩列表，只保留有效数据
 * @param {Array} scores - 成绩数组
 * @returns {Array} - 有效的成绩数组
 */
export function filterValidScores(scores) {
  if (!Array.isArray(scores)) return []
  return scores.filter(s => isValidScore(s))
}

/**
 * 验证并清理API响应数据
 * @param {Object} response - API响应对象
 * @param {String} dataType - 数据类型 (question/paper/exam/score)
 * @returns {Object} - 清理后的响应对象
 */
export function cleanApiResponse(response, dataType) {
  if (!response || !response.data) return { list: [], total: 0 }
  
  const data = response.data
  let list = data.list || data || []
  
  // 根据数据类型过滤
  switch (dataType) {
    case 'question':
      list = filterValidQuestions(list)
      break
    case 'paper':
      list = filterValidPapers(list)
      break
    case 'exam':
      list = filterValidExams(list)
      break
    case 'score':
      list = filterValidScores(list)
      break
    default:
      break
  }
  
  return {
    list,
    total: data.total !== undefined ? data.total : list.length
  }
}

export default {
  isValidQuestion,
  isValidPaper,
  isValidExam,
  isValidScore,
  filterValidQuestions,
  filterValidPapers,
  filterValidExams,
  filterValidScores,
  cleanApiResponse
}


