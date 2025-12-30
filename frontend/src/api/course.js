import request from '@/utils/request'

// ==================== 课程管理 ====================

// 获取课程列表（老师能看到的所有课程）
export function getCourses(params) {
  return request({
    url: '/courses',
    method: 'get',
    params
  })
}

// 获取课程详情
export function getCourseDetail(id) {
  return request({
    url: `/courses/${id}`,
    method: 'get'
  })
}

// 创建课程
export function createCourse(data) {
  return request({
    url: '/courses',
    method: 'post',
    data
  })
}

// 更新课程
export function updateCourse(id, data) {
  return request({
    url: `/courses/${id}`,
    method: 'put',
    data
  })
}

// 删除课程
export function deleteCourse(id) {
  return request({
    url: `/courses/${id}`,
    method: 'delete'
  })
}

// 获取课程的教学组老师列表
export function getCourseTeachers(courseId) {
  return request({
    url: `/courses/${courseId}/teachers`,
    method: 'get'
  })
}

// 添加教学组老师
export function addCourseTeacher(courseId, teacherId) {
  return request({
    url: `/courses/${courseId}/teachers`,
    method: 'post',
    data: { teacherId }
  })
}

// 移除教学组老师
export function removeCourseTeacher(courseId, teacherId) {
  return request({
    url: `/courses/${courseId}/teachers/${teacherId}`,
    method: 'delete'
  })
}

// ==================== 教学班管理 ====================

// 获取课程下的教学班列表
export function getTeachingClasses(courseId, params) {
  return request({
    url: `/courses/${courseId}/classes`,
    method: 'get',
    params
  })
}

// 获取教学班详情
export function getTeachingClassDetail(classId) {
  return request({
    url: `/teaching-classes/${classId}`,
    method: 'get'
  })
}

// 创建教学班
export function createTeachingClass(courseId, data) {
  return request({
    url: `/courses/${courseId}/classes`,
    method: 'post',
    data
  })
}

// 更新教学班
export function updateTeachingClass(classId, data) {
  return request({
    url: `/teaching-classes/${classId}`,
    method: 'put',
    data
  })
}

// 删除教学班
export function deleteTeachingClass(classId) {
  return request({
    url: `/teaching-classes/${classId}`,
    method: 'delete'
  })
}

// 获取教学班学生列表
export function getTeachingClassStudents(classId) {
  return request({
    url: `/teaching-classes/${classId}/students`,
    method: 'get'
  })
}

// 从行政班批量添加学生到教学班
export function addStudentsFromAdminClass(classId, adminClassIds) {
  return request({
    url: `/teaching-classes/${classId}/students/batch`,
    method: 'post',
    data: { adminClassIds }
  })
}

// 添加单个学生到教学班
export function addStudentToClass(classId, studentId) {
  return request({
    url: `/teaching-classes/${classId}/students`,
    method: 'post',
    data: { studentId }
  })
}

// 从教学班移除学生
export function removeStudentFromClass(classId, studentId) {
  return request({
    url: `/teaching-classes/${classId}/students/${studentId}`,
    method: 'delete'
  })
}

// 分配老师到教学班
export function assignTeacherToClass(classId, teacherId) {
  return request({
    url: `/teaching-classes/${classId}/teacher`,
    method: 'put',
    data: { teacherId }
  })
}

// ==================== 辅助接口 ====================

// 获取组织机构树（用于选择行政班）
export function getOrgTree() {
  return request({
    url: '/org/tree',
    method: 'get'
  })
}

// 获取行政班学生列表
export function getAdminClassStudents(adminClassId) {
  return request({
    url: `/org/${adminClassId}/members`,
    method: 'get'
  })
}

// 获取所有老师列表（用于添加教学组老师）
export function getAllTeachers(params) {
  return request({
    url: '/users/teachers',
    method: 'get',
    params
  })
}

// 搜索学生（用于单独添加学生）
export function searchStudents(params) {
  return request({
    url: '/users/students',
    method: 'get',
    params
  })
}
