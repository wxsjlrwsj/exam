<template>
  <div class="course-container">
    <div class="page-header">
      <h2 class="page-title">课程与教学班管理</h2>
    </div>

    <el-row :gutter="20" class="main-content">
      <!-- 左侧: 课程列表 -->
      <el-col :span="8">
        <el-card class="course-list-card">
          <template #header>
            <div class="card-header">
              <span>我的课程</span>
              <el-button type="primary" size="small" @click="handleAddCourse">
                <el-icon><Plus /></el-icon> 新建课程
              </el-button>
            </div>
          </template>

          <el-input
            v-model="courseFilter"
            placeholder="搜索课程..."
            prefix-icon="Search"
            clearable
            style="margin-bottom: 15px"
          />

          <div class="course-list" v-loading="loadingCourses">
            <div
              v-for="course in filteredCourses"
              :key="course.id"
              class="course-item"
              :class="{ active: currentCourse?.id === course.id }"
              @click="selectCourse(course)"
            >
              <div class="course-info">
                <div class="course-name">
                  <el-icon><Reading /></el-icon>
                  {{ course.name }}
                </div>
                <div class="course-meta">
                  <el-tag v-if="course.isCreator" type="success" size="small">创建者</el-tag>
                  <el-tag v-else type="info" size="small">参与教学</el-tag>
                  <span class="class-count">{{ course.classCount || 0 }} 个教学班</span>
                </div>
              </div>
              <el-dropdown v-if="course.isCreator" @command="(cmd) => handleCourseCommand(cmd, course)" trigger="click">
                <el-icon class="more-btn" @click.stop><MoreFilled /></el-icon>
                <template #dropdown>
                  <el-dropdown-menu>
                    <el-dropdown-item command="edit">编辑课程</el-dropdown-item>
                    <el-dropdown-item command="teachers">管理教学组</el-dropdown-item>
                    <el-dropdown-item command="delete" divided>
                      <span style="color: #f56c6c">删除课程</span>
                    </el-dropdown-item>
                  </el-dropdown-menu>
                </template>
              </el-dropdown>
            </div>
            <el-empty v-if="filteredCourses.length === 0" description="暂无课程" />
          </div>
        </el-card>
      </el-col>

      <!-- 右侧: 课程详情和教学班 -->
      <el-col :span="16">
        <el-card class="detail-card" v-if="currentCourse">
          <template #header>
            <div class="card-header">
              <div class="course-title">
                <span>{{ currentCourse.name }}</span>
                <el-tag v-if="currentCourse.isCreator" type="success" size="small">我创建的</el-tag>
              </div>
              <el-button 
                v-if="currentCourse.isCreator" 
                type="primary" 
                @click="handleAddClass"
              >
                <el-icon><Plus /></el-icon> 新建教学班
              </el-button>
            </div>
          </template>

          <el-descriptions :column="2" border style="margin-bottom: 20px">
            <el-descriptions-item label="课程简介" :span="2">
              <div style="display: flex; justify-content: space-between; align-items: center;">
                <span>{{ currentCourse.description || '暂无简介' }}</span>
                <el-button 
                  v-if="currentCourse.isCreator" 
                  link 
                  type="primary" 
                  size="small"
                  @click="handleEditCourse(currentCourse)"
                >
                  <el-icon><Edit /></el-icon> 编辑
                </el-button>
              </div>
            </el-descriptions-item>
            <el-descriptions-item label="创建老师">
              {{ currentCourse.creatorName }}
            </el-descriptions-item>
            <el-descriptions-item label="教学组老师">
              <div style="display: flex; justify-content: space-between; align-items: center;">
                <div>
                  <template v-if="currentCourse.teachers?.length">
                    <el-tag 
                      v-for="teacher in currentCourse.teachers" 
                      :key="teacher.id"
                      style="margin-right: 5px"
                    >
                      {{ teacher.name }}
                    </el-tag>
                  </template>
                  <span v-else class="text-muted">暂无</span>
                </div>
                <el-button 
                  v-if="currentCourse.isCreator" 
                  link 
                  type="primary" 
                  size="small"
                  @click="handleManageTeachers(currentCourse)"
                >
                  <el-icon><UserFilled /></el-icon> 管理
                </el-button>
              </div>
            </el-descriptions-item>
          </el-descriptions>

          <!-- 课程操作按钮 -->
          <div v-if="currentCourse.isCreator" style="margin-bottom: 20px; text-align: right;">
            <el-button type="danger" plain size="small" @click="handleDeleteCourse(currentCourse)">
              <el-icon><Delete /></el-icon> 删除课程
            </el-button>
          </div>

          <!-- 教学班列表 -->
          <div class="class-section">
            <div class="section-header">
              <h4>教学班列表</h4>
              <div style="display: flex; gap: 10px; align-items: center;">
                <el-select
                  v-model="filterYear"
                  placeholder="学年"
                  clearable
                  style="width: 120px"
                >
                  <el-option label="全部" value="" />
                  <el-option
                    v-for="y in yearOptions"
                    :key="y"
                    :label="y"
                    :value="y"
                  />
                </el-select>
                <el-select
                  v-model="filterSemester"
                  placeholder="学期"
                  clearable
                  style="width: 110px"
                >
                  <el-option label="全部" value="" />
                  <el-option
                    v-for="s in semesterOptions"
                    :key="s"
                    :label="s"
                    :value="s"
                  />
                </el-select>
              <el-input
                v-model="classFilter"
                placeholder="搜索教学班..."
                prefix-icon="Search"
                clearable
                style="width: 200px"
              />
              </div>
            </div>

            <el-table 
              :data="filteredClasses" 
              v-loading="loadingClasses"
              border 
              stripe
              @row-click="handleClassRowClick"
              style="cursor: pointer; width: 100%"
            >
              <el-table-column prop="name" label="教学班名称" min-width="150">
                <template #default="{ row }">
                  <el-icon><Collection /></el-icon>
                  {{ row.name }}
                </template>
              </el-table-column>
              <el-table-column prop="assignedTeacherName" label="负责老师" width="120" />
              <el-table-column prop="studentCount" label="学生人数" width="100" align="center">
                <template #default="{ row }">
                  <el-tag type="info">{{ row.studentCount || 0 }}人</el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="academicYear" label="学年" width="100" />
              <el-table-column prop="semester" label="学期" width="90" />
              <el-table-column prop="createTime" label="创建时间" width="160" />
              <el-table-column label="操作" width="180" fixed="right">
                <template #default="{ row }">
                  <template v-if="currentCourse?.isCreator">
                    <el-button link type="primary" size="small" @click.stop="handleEditClass(row)">
                      编辑
                    </el-button>
                    <el-button link type="primary" size="small" @click.stop="handleManageStudents(row)">
                      学生管理
                    </el-button>
                    <el-button link type="danger" size="small" @click.stop="handleDeleteClass(row)">
                      删除
                    </el-button>
                  </template>
                </template>
              </el-table-column>
              </el-table>

              <el-empty v-if="filteredClasses.length === 0 && !loadingClasses" description="暂无教学班" />
          </div>
        </el-card>

        <el-card v-else class="detail-card">
          <el-empty description="请选择左侧课程查看详情" />
        </el-card>
      </el-col>
    </el-row>

    <!-- 新建/编辑课程对话框 -->
    <el-dialog
      v-model="courseDialogVisible"
      :title="courseForm.id ? '编辑课程' : '新建课程'"
      width="500px"
      destroy-on-close
    >
      <el-form
        ref="courseFormRef"
        :model="courseForm"
        :rules="courseRules"
        label-width="100px"
      >
        <el-form-item label="课程名称" prop="name">
          <el-input v-model="courseForm.name" placeholder="请输入课程名称" />
        </el-form-item>
        <el-form-item label="课程简介" prop="description">
          <el-input
            v-model="courseForm.description"
            type="textarea"
            :rows="4"
            placeholder="请输入课程简介"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="courseDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="savingCourse" @click="submitCourse">
          确定
        </el-button>
      </template>
    </el-dialog>

    <!-- 管理教学组老师对话框 -->
    <el-dialog
      v-model="teacherDialogVisible"
      title="管理教学组老师"
      width="600px"
      destroy-on-close
    >
      <div class="teacher-manage">
        <div class="add-teacher-section">
          <el-select
            v-model="newTeacherId"
            filterable
            remote
            reserve-keyword
            placeholder="搜索老师添加到教学组"
            :remote-method="searchTeachers"
            :loading="searchingTeachers"
            style="width: 300px"
          >
            <el-option
              v-for="teacher in teacherOptions"
              :key="teacher.id"
              :label="teacher.name"
              :value="teacher.id"
              :disabled="courseTeachers.some(t => t.id === teacher.id)"
            />
          </el-select>
          <el-button type="primary" @click="addTeacher" :disabled="!newTeacherId">
            添加
          </el-button>
        </div>

        <el-table :data="courseTeachers" border style="margin-top: 15px">
          <el-table-column prop="name" label="老师姓名" />
          <el-table-column prop="department" label="所属部门" />
          <el-table-column label="操作" width="100">
            <template #default="{ row }">
              <el-button 
                link 
                type="danger" 
                size="small" 
                @click="removeTeacher(row)"
                :disabled="row.id === currentCourse?.creatorId"
              >
                {{ row.id === currentCourse?.creatorId ? '创建者' : '移除' }}
              </el-button>
            </template>
          </el-table-column>
        </el-table>
      </div>
    </el-dialog>

    <!-- 新建/编辑教学班对话框 -->
    <el-dialog
      v-model="classDialogVisible"
      :title="classForm.id ? '编辑教学班' : '新建教学班'"
      width="500px"
      destroy-on-close
    >
      <el-form
        ref="classFormRef"
        :model="classForm"
        :rules="classRules"
        label-width="100px"
      >
        <el-form-item label="教学班名称" prop="name">
          <el-input v-model="classForm.name" placeholder="请输入教学班名称" />
        </el-form-item>
        <el-form-item label="负责老师" prop="assignedTeacherId">
          <el-select
            v-model="classForm.assignedTeacherId"
            placeholder="选择负责老师"
            style="width: 100%"
          >
            <el-option
              v-for="teacher in courseTeachers"
              :key="teacher.id"
              :label="teacher.name"
              :value="teacher.id"
            />
          </el-select>
          <div class="form-tip">从课程教学组中选择负责该教学班的老师</div>
        </el-form-item>
        <el-form-item label="学年" prop="academicYear">
          <el-input v-model="classForm.academicYear" placeholder="例如：2025" />
        </el-form-item>
        <el-form-item label="学期" prop="semester">
          <el-select v-model="classForm.semester" placeholder="选择学期" style="width: 100%">
            <el-option label="春" value="春" />
            <el-option label="秋" value="秋" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="classDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="savingClass" @click="submitClass">
          确定
        </el-button>
      </template>
    </el-dialog>

    <!-- 学生管理对话框 -->
    <el-dialog
      v-model="studentDialogVisible"
      title="教学班学生管理"
      width="900px"
      destroy-on-close
    >
      <div class="student-manage">
        <el-row :gutter="20">
          <!-- 左侧: 行政班选择 -->
          <el-col :span="10">
            <el-card shadow="never">
              <template #header>
                <span>从行政班添加学生</span>
              </template>
              <el-tree
                ref="orgTreeRef"
                :data="orgTree"
                :props="{ label: 'name', children: 'children' }"
                node-key="id"
                show-checkbox
                :check-strictly="false"
                check-on-click-node
                :filter-node-method="filterOrgNode"
                @check="handleOrgCheck"
              >
                <template #default="{ node, data }">
                  <span class="org-node">
                    <el-icon v-if="data.type === 'class'"><User /></el-icon>
                    <el-icon v-else><OfficeBuilding /></el-icon>
                    {{ node.label }}
                    <el-tag v-if="data.type === 'class'" size="small" type="info">
                      {{ data.memberCount || 0 }}人
                    </el-tag>
                  </span>
                </template>
              </el-tree>
              <div v-if="selectedAdminClassNames.length" style="margin-top: 10px;">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
                  <span>已勾选班级（{{ selectedAdminClassNames.length }}个）</span>
                  <el-button link type="primary" size="small" @click="clearSelectedClasses">清空</el-button>
                </div>
                <div>
                  <el-tag
                    v-for="name in selectedAdminClassNames"
                    :key="name"
                    size="small"
                    style="margin: 2px"
                  >
                    {{ name }}
                  </el-tag>
                </div>
              </div>
              <el-button 
                type="primary" 
                style="margin-top: 15px; width: 100%"
                :disabled="selectedAdminClasses.length === 0"
                :loading="addingFromAdminClass"
                @click="addStudentsFromAdminClasses"
              >
                添加选中班级学生 ({{ selectedAdminClasses.length }}个班)
              </el-button>
            </el-card>

            <el-card shadow="never" style="margin-top: 15px">
              <template #header>
                <span>单独添加学生</span>
              </template>
              <el-select
                v-model="singleStudentId"
                filterable
                remote
                reserve-keyword
                placeholder="搜索学生"
                :remote-method="searchStudentsForAdd"
                :loading="searchingStudents"
                style="width: 100%"
              >
                <el-option
                  v-for="student in studentSearchResults"
                  :key="student.id"
                  :label="`${student.name} (${student.studentNo})`"
                  :value="student.id"
                  :disabled="classStudents.some(s => s.id === student.id)"
                />
              </el-select>
              <el-button 
                type="primary" 
                style="margin-top: 10px; width: 100%"
                :disabled="!singleStudentId"
                @click="addSingleStudent"
              >
                添加学生
              </el-button>
            </el-card>
          </el-col>

          <!-- 右侧: 当前教学班学生列表 -->
          <el-col :span="14">
            <el-card shadow="never">
              <template #header>
                <div class="card-header">
                  <span>当前教学班学生 ({{ classStudents.length }}人)</span>
                  <el-input
                    v-model="studentFilter"
                    placeholder="搜索学生..."
                    prefix-icon="Search"
                    clearable
                    style="width: 150px"
                  />
                  <el-button
                    type="danger"
                    plain
                    size="small"
                    :disabled="selectedStudents.length === 0"
                    :loading="removingBatch"
                    @click="removeSelectedStudents"
                  >
                    批量移除
                  </el-button>
                </div>
              </template>
              <el-table 
                :data="filteredClassStudents" 
                v-loading="loadingStudents"
                border 
                max-height="400"
                @selection-change="handleStudentSelection"
              >
                <el-table-column type="selection" width="40" />
                <el-table-column prop="studentNo" label="学号" width="120" />
                <el-table-column prop="name" label="姓名" width="100" />
                <el-table-column prop="adminClassName" label="行政班" />
                <el-table-column label="操作" width="80" fixed="right">
                  <template #default="{ row }">
                    <el-popconfirm
                      title="确定要从教学班移除该学生吗?"
                      @confirm="removeStudent(row)"
                    >
                      <template #reference>
                        <el-button link type="danger" size="small">移除</el-button>
                      </template>
                    </el-popconfirm>
                  </template>
                </el-table-column>
              </el-table>
            </el-card>
          </el-col>
        </el-row>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, inject } from 'vue'
import { 
  Plus, Search, Reading, MoreFilled, Collection, 
  User, OfficeBuilding, Edit, UserFilled, Delete
} from '@element-plus/icons-vue'
import { ElMessageBox } from 'element-plus'
import {
  getCourses,
  getCourseDetail,
  createCourse,
  updateCourse,
  deleteCourse,
  getCourseTeachers,
  addCourseTeacher,
  removeCourseTeacher,
  getTeachingClasses,
  createTeachingClass,
  updateTeachingClass,
  deleteTeachingClass,
  getTeachingClassStudents,
  addStudentsFromAdminClass,
  addStudentToClass,
  removeStudentFromClass,
  getOrgTree,
  getAllTeachers,
  searchStudents
} from '@/api/course'

const showMessage = inject('showMessage')

// ==================== 课程相关 ====================
const courses = ref([])
const currentCourse = ref(null)
const loadingCourses = ref(false)
const courseFilter = ref('')

const filteredCourses = computed(() => {
  if (!courseFilter.value) return courses.value
  return courses.value.filter(c => 
    c.name.toLowerCase().includes(courseFilter.value.toLowerCase())
  )
})

const loadCourses = async () => {
  loadingCourses.value = true
  try {
    const res = await getCourses()
    courses.value = res || []
  } catch (e) {
    courses.value = []
  } finally {
    loadingCourses.value = false
    if (!currentCourse.value && courses.value.length > 0) {
      await selectCourse(courses.value[0])
    }
  }
}

const selectCourse = async (course) => {
  currentCourse.value = course
  await loadCourseDetail(course.id)
  await Promise.all([
    loadTeachingClasses(course.id),
    loadCourseTeachers(course.id)
  ])
}

const loadCourseDetail = async (courseId) => {
  try {
    const res = await getCourseDetail(courseId)
    if (res) {
      Object.assign(currentCourse.value, res)
    }
  } catch (e) {
    console.error(e)
  }
}

// 课程对话框
const courseDialogVisible = ref(false)
const courseFormRef = ref(null)
const savingCourse = ref(false)
const courseForm = reactive({
  id: null,
  name: '',
  description: ''
})

const courseRules = {
  name: [{ required: true, message: '请输入课程名称', trigger: 'blur' }]
}

const handleAddCourse = () => {
  courseForm.id = null
  courseForm.name = ''
  courseForm.description = ''
  courseDialogVisible.value = true
}

const handleEditCourse = (course) => {
  courseForm.id = course.id
  courseForm.name = course.name
  courseForm.description = course.description
  courseDialogVisible.value = true
}

const handleManageTeachers = (course) => {
  currentCourse.value = course
  loadCourseTeachers(course.id)
  teacherDialogVisible.value = true
}

const handleCourseCommand = (command, course) => {
  if (command === 'edit') {
    handleEditCourse(course)
  } else if (command === 'teachers') {
    handleManageTeachers(course)
  } else if (command === 'delete') {
    handleDeleteCourse(course)
  }
}

const submitCourse = async () => {
  if (!courseFormRef.value) return
  await courseFormRef.value.validate(async (valid) => {
    if (!valid) return
    savingCourse.value = true
    try {
      if (courseForm.id) {
        await updateCourse(courseForm.id, courseForm)
        showMessage('课程更新成功', 'success')
      } else {
        await createCourse(courseForm)
        showMessage('课程创建成功', 'success')
      }
      courseDialogVisible.value = false
      if (courseForm.id && currentCourse.value?.id === courseForm.id) {
        await loadCourseDetail(courseForm.id)
        currentCourse.value.name = courseForm.name
        currentCourse.value.description = courseForm.description
      }
      loadCourses()
    } catch (e) {
      console.error(e)
    } finally {
      savingCourse.value = false
    }
  })
}

const handleDeleteCourse = (course) => {
  ElMessageBox.confirm(
    `确定要删除课程 "${course.name}" 吗？该课程下的所有教学班也将被删除！`,
    '警告',
    { confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning' }
  ).then(async () => {
    try {
      await deleteCourse(course.id)
      showMessage('删除成功', 'success')
      if (currentCourse.value?.id === course.id) {
        currentCourse.value = null
      }
      loadCourses()
    } catch (e) {
      console.error(e)
    }
  })
}

// ==================== 教学组老师管理 ====================
const teacherDialogVisible = ref(false)
const courseTeachers = ref([])
const newTeacherId = ref(null)
const teacherOptions = ref([])
const searchingTeachers = ref(false)
const cnDigit = (ch) => {
  const m = { '零':0,'一':1,'二':2,'两':2,'三':3,'四':4,'五':5,'六':6,'七':7,'八':8,'九':9 }
  return m[ch] ?? NaN
}
const cn2num = (s) => {
  if (!s) return NaN
  if (s.includes('十')) {
    const parts = s.split('十')
    const left = parts[0]
    const right = parts[1]
    const tens = left ? cnDigit(left) : 1
    const ones = right ? cnDigit(right) : 0
    if (Number.isNaN(tens) || Number.isNaN(ones)) return NaN
    return tens * 10 + ones
  }
  const v = cnDigit(s)
  return Number.isNaN(v) ? NaN : v
}
const extractOrder = (row) => {
  const name = String(row.name || '')
  const m = name.match(/教师(.+)$/)
  if (m) {
    const n = cn2num(m[1].trim())
    if (!Number.isNaN(n)) return n
  }
  const uname = String(row.username || '')
  const dm = uname.match(/teacher(\d+)/i)
  if (dm) return parseInt(dm[1], 10)
  return Number.MAX_SAFE_INTEGER
}
const sortTeachers = (list) => {
  return (list || []).slice().sort((a, b) => {
    const na = extractOrder(a)
    const nb = extractOrder(b)
    if (na !== nb) return na - nb
    return String(a.name || '').localeCompare(String(b.name || ''), 'zh')
  })
}

const loadCourseTeachers = async (courseId) => {
  try {
    const res = await getCourseTeachers(courseId)
    courseTeachers.value = res || []
    if (currentCourse.value?.id === courseId) {
      currentCourse.value.teachers = courseTeachers.value
    }
  } catch (e) {
    courseTeachers.value = []
  }
}

const searchTeachers = async (query) => {
  if (!query) {
    teacherOptions.value = []
    return
  }
  searchingTeachers.value = true
  try {
    const res = await getAllTeachers({ keyword: query, pageSize: 100 })
    teacherOptions.value = sortTeachers(res || [])
  } catch (e) {
    teacherOptions.value = []
  } finally {
    searchingTeachers.value = false
  }
}

const addTeacher = async () => {
  if (!newTeacherId.value || !currentCourse.value) return
  try {
    await addCourseTeacher(currentCourse.value.id, newTeacherId.value)
    showMessage('添加成功', 'success')
    newTeacherId.value = null
    loadCourseTeachers(currentCourse.value.id)
  } catch (e) {
    console.error(e)
  }
}

const removeTeacher = async (teacher) => {
  if (!currentCourse.value) return
  try {
    await removeCourseTeacher(currentCourse.value.id, teacher.id)
    showMessage('移除成功', 'success')
    loadCourseTeachers(currentCourse.value.id)
  } catch (e) {
    console.error(e)
  }
}

// ==================== 教学班相关 ====================
const teachingClasses = ref([])
const loadingClasses = ref(false)
const classFilter = ref('')
const filterYear = ref('')
const filterSemester = ref('')

const filteredClasses = computed(() => {
  let list = teachingClasses.value
  if (filterYear.value) {
    list = list.filter(c => String(c.academicYear || '') === String(filterYear.value))
  }
  if (filterSemester.value) {
    list = list.filter(c => String(c.semester || '') === String(filterSemester.value))
  }
  if (classFilter.value) {
    const kw = classFilter.value.toLowerCase()
    list = list.filter(c => String(c.name || '').toLowerCase().includes(kw))
  }
  return list
})

const yearOptions = computed(() => {
  const s = new Set()
  for (const c of teachingClasses.value) {
    const y = String(c.academicYear || '').trim()
    if (y) s.add(y)
  }
  return Array.from(s).sort()
})

const semesterOptions = computed(() => {
  const s = new Set()
  for (const c of teachingClasses.value) {
    const v = String(c.semester || '').trim()
    if (v) s.add(v)
  }
  const arr = Array.from(s)
  return arr.length ? arr : ['春','秋']
})

const loadTeachingClasses = async (courseId) => {
  loadingClasses.value = true
  try {
    const res = await getTeachingClasses(courseId)
    teachingClasses.value = (res || []).map(r => ({
      ...r,
      academicYear: r.academicYear ?? '',
      semester: r.semester ?? ''
    }))
  } catch (e) {
    teachingClasses.value = []
  } finally {
    loadingClasses.value = false
  }
}

onMounted(() => {})

// 教学班对话框
const classDialogVisible = ref(false)
const classFormRef = ref(null)
const savingClass = ref(false)
const classForm = reactive({
  id: null,
  name: '',
  assignedTeacherId: null,
  academicYear: '',
  semester: ''
})

const classRules = {
  name: [{ required: true, message: '请输入教学班名称', trigger: 'blur' }],
  assignedTeacherId: [{ required: true, message: '请选择负责老师', trigger: 'change' }],
  academicYear: [
    { required: true, message: '请输入学年', trigger: 'blur' },
    { pattern: /^20\d{2}$/, message: '格式示例：2025', trigger: 'blur' }
  ],
  semester: [{ required: true, message: '请选择学期', trigger: 'change' }]
}

const handleAddClass = () => {
  classForm.id = null
  classForm.name = ''
  classForm.assignedTeacherId = null
  classForm.academicYear = ''
  classForm.semester = ''
  classDialogVisible.value = true
}

const handleEditClass = (row) => {
  classForm.id = row.id
  classForm.name = row.name
  classForm.assignedTeacherId = row.assignedTeacherId
  classForm.academicYear = row.academicYear || ''
  classForm.semester = row.semester || ''
  classDialogVisible.value = true
}

const handleClassRowClick = (row) => {
  if (!currentCourse.value?.isCreator) {
    // 非创建者点击查看学生
    handleManageStudents(row)
  }
}

const submitClass = async () => {
  if (!classFormRef.value || !currentCourse.value) return
  await classFormRef.value.validate(async (valid) => {
    if (!valid) return
    savingClass.value = true
    try {
      if (classForm.id) {
        await updateTeachingClass(classForm.id, classForm)
        showMessage('教学班更新成功', 'success')
      } else {
        await createTeachingClass(currentCourse.value.id, classForm)
        showMessage('教学班创建成功', 'success')
      }
      classDialogVisible.value = false
      loadTeachingClasses(currentCourse.value.id)
      loadCourses() // 刷新课程列表中的教学班数量
    } catch (e) {
      console.error(e)
    } finally {
      savingClass.value = false
    }
  })
}

const handleDeleteClass = (row) => {
  ElMessageBox.confirm(
    `确定要删除教学班 "${row.name}" 吗？`,
    '警告',
    { confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning' }
  ).then(async () => {
    try {
      await deleteTeachingClass(row.id)
      showMessage('删除成功', 'success')
      loadTeachingClasses(currentCourse.value.id)
      loadCourses()
    } catch (e) {
      console.error(e)
    }
  })
}

// ==================== 学生管理 ====================
const studentDialogVisible = ref(false)
const currentClass = ref(null)
const classStudents = ref([])
const loadingStudents = ref(false)
const studentFilter = ref('')
const selectedStudents = ref([])
const removingBatch = ref(false)

const filteredClassStudents = computed(() => {
  if (!studentFilter.value) return classStudents.value
  const keyword = studentFilter.value.toLowerCase()
  return classStudents.value.filter(s =>
    s.name.toLowerCase().includes(keyword) ||
    s.studentNo.toLowerCase().includes(keyword)
  )
})

const handleStudentSelection = (rows) => {
  selectedStudents.value = rows || []
}

const removeSelectedStudents = async () => {
  if (!currentClass.value || selectedStudents.value.length === 0) return
  await ElMessageBox.confirm(
    `确定要批量移除选中的 ${selectedStudents.value.length} 名学生吗？`,
    '警告',
    { confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning' }
  )
  removingBatch.value = true
  try {
    for (const s of selectedStudents.value) {
      await removeStudentFromClass(currentClass.value.id, s.id)
    }
    showMessage('批量移除成功', 'success')
    selectedStudents.value = []
    loadClassStudents(currentClass.value.id)
  } catch (e) {
    console.error(e)
  } finally {
    removingBatch.value = false
  }
}

// 组织机构树
const orgTree = ref([])
const orgTreeRef = ref(null)
const selectedAdminClasses = ref([])
const addingFromAdminClass = ref(false)
const selectedAdminClassNames = computed(() => {
  const nodes = orgTreeRef.value?.getCheckedNodes(true) || []
  return nodes.filter(n => n.type === 'class').map(n => n.name)
})

// 单独添加学生
const singleStudentId = ref(null)
const studentSearchResults = ref([])
const searchingStudents = ref(false)

const handleManageStudents = async (row) => {
  currentClass.value = row
  studentFilter.value = ''
  selectedAdminClasses.value = []
  singleStudentId.value = null
  studentDialogVisible.value = true
  
  await Promise.all([
    loadClassStudents(row.id),
    loadOrgTree()
  ])
}

const loadClassStudents = async (classId) => {
  loadingStudents.value = true
  try {
    const res = await getTeachingClassStudents(classId)
    classStudents.value = res || []
  } catch (e) {
    classStudents.value = []
  } finally {
    loadingStudents.value = false
    updateCurrentClassStudentCount()
  }
}

const updateCurrentClassStudentCount = () => {
  if (!currentClass.value) return
  const idx = teachingClasses.value.findIndex(c => c.id === currentClass.value.id)
  if (idx !== -1) {
    teachingClasses.value[idx].studentCount = classStudents.value.length
  }
}

const loadOrgTree = async () => {
  try {
    const res = await getOrgTree()
    orgTree.value = res || []
  } catch (e) {
    orgTree.value = []
  }
}

const filterOrgNode = (value, data) => {
  if (!value) return true
  return data.name.includes(value)
}

const handleOrgCheck = (data, checkedInfo) => {
  const nodes = checkedInfo?.checkedNodes || (orgTreeRef.value?.getCheckedNodes(true) || [])
  selectedAdminClasses.value = nodes
    .filter(n => n.type === 'class')
    .map(n => n.id)
}

const clearSelectedClasses = () => {
  selectedAdminClasses.value = []
  orgTreeRef.value?.setCheckedKeys([])
}

const addStudentsFromAdminClasses = async () => {
  if (!currentClass.value || selectedAdminClasses.value.length === 0) return
  addingFromAdminClass.value = true
  try {
    await addStudentsFromAdminClass(currentClass.value.id, selectedAdminClasses.value)
    showMessage('添加成功', 'success')
    selectedAdminClasses.value = []
    orgTreeRef.value?.setCheckedKeys([])
    loadClassStudents(currentClass.value.id)
  } catch (e) {
    console.error(e)
  } finally {
    addingFromAdminClass.value = false
  }
}

const searchStudentsForAdd = async (query) => {
  if (!query) {
    studentSearchResults.value = []
    return
  }
  searchingStudents.value = true
  try {
    const res = await searchStudents({ keyword: query })
    studentSearchResults.value = res || []
  } catch (e) {
    studentSearchResults.value = []
  } finally {
    searchingStudents.value = false
  }
}

const addSingleStudent = async () => {
  if (!currentClass.value || !singleStudentId.value) return
  try {
    await addStudentToClass(currentClass.value.id, singleStudentId.value)
    showMessage('添加成功', 'success')
    singleStudentId.value = null
    loadClassStudents(currentClass.value.id)
  } catch (e) {
    console.error(e)
  }
}

const removeStudent = async (student) => {
  if (!currentClass.value) return
  try {
    await removeStudentFromClass(currentClass.value.id, student.id)
    showMessage('移除成功', 'success')
    loadClassStudents(currentClass.value.id)
  } catch (e) {
    console.error(e)
  }
}

// ==================== 生命周期 ====================
onMounted(() => {
  loadCourses()
})
</script>

<style scoped>
.course-container {
  height: 100%;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding-bottom: 15px;
  border-bottom: 2px solid #E4E7ED;
}

.page-title {
  margin: 0;
  font-size: 24px;
  color: #303133;
  font-family: 'PingFang SC', 'Microsoft YaHei', sans-serif;
  letter-spacing: 1px;
}

.main-content {
  height: calc(100vh - 160px);
}

.course-list-card,
.detail-card {
  height: 100%;
  overflow-y: auto;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.course-title {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 16px;
  font-weight: 500;
}

.course-list {
  max-height: calc(100vh - 320px);
  overflow-y: auto;
}

.course-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s;
  border: 1px solid #ebeef5;
  margin-bottom: 10px;
}

.course-item:hover {
  background-color: #f5f7fa;
}

.course-item.active {
  background-color: #ecf5ff;
  border-color: #409eff;
}

.course-info {
  flex: 1;
}

.course-name {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 14px;
  font-weight: 500;
  margin-bottom: 6px;
}

.course-meta {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
  color: #909399;
}

.class-count {
  color: #606266;
}

.more-btn {
  padding: 4px;
  cursor: pointer;
  color: #909399;
}

.more-btn:hover {
  color: #409eff;
}

.class-section {
  margin-top: 10px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.section-header h4 {
  margin: 0;
  font-size: 15px;
}

.text-muted {
  color: #909399;
}

.form-tip {
  font-size: 12px;
  color: #909399;
  margin-top: 5px;
}

.teacher-manage .add-teacher-section {
  display: flex;
  gap: 10px;
  align-items: center;
}

.student-manage .card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.org-node {
  display: flex;
  align-items: center;
  gap: 6px;
}
</style>
