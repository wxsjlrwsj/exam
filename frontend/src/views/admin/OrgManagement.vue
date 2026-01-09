<template>
  <div class="org-container">
    <div class="page-header">
      <h2 class="page-title">组织机构管理</h2>
    </div>

    <el-row :gutter="20" class="main-content">
      <!-- Left: Org Tree -->
      <el-col :span="8">
        <el-card class="tree-card">
          <template #header>
            <div class="card-header">
              <span>组织架构图</span>
              <el-button type="primary" size="small" @click="handleAddRoot">
                <el-icon><Plus /></el-icon> 新增根机构
              </el-button>
            </div>
          </template>
          
          <el-input
            v-model="filterText"
            placeholder="输入关键字过滤"
            prefix-icon="Search"
            clearable
            style="margin-bottom: 15px"
          />

          <el-tree
            ref="treeRef"
            :data="orgTree"
            :props="defaultProps"
            node-key="id"
            default-expand-all
            :filter-node-method="filterNode"
            :expand-on-click-node="false"
            highlight-current
            draggable
            :allow-drop="allowDrop"
            :allow-drag="allowDrag"
            @node-click="handleNodeClick"
            @node-drop="handleNodeDrop"
          >
            <template #default="{ node, data }">
              <span class="custom-tree-node">
                <span class="node-label">
                  <el-icon v-if="data.type === 'school'"><School /></el-icon>
                  <el-icon v-else-if="data.type === 'college'"><OfficeBuilding /></el-icon>
                  <el-icon v-else-if="data.type === 'class'"><User /></el-icon>
                  <el-icon v-else><Connection /></el-icon>
                  {{ node.label }}
                </span>
                <span class="node-actions">
                  <el-button link type="primary" size="small" @click.stop="append(data)">
                    新增下级
                  </el-button>
                  <el-button link type="danger" size="small" @click.stop="remove(node, data)">
                    删除
                  </el-button>
                </span>
              </span>
            </template>
          </el-tree>
        </el-card>
      </el-col>

      <!-- Right: Details/Edit Form -->
      <el-col :span="16">
        <el-card class="detail-card">
          <template #header>
            <div class="card-header">
              <span>{{ form.id ? '编辑机构' : '新增机构' }}</span>
              <div v-if="form.id || form.parentId">
                <el-button type="primary" :loading="saving" @click="submitForm">保存</el-button>
                <el-button @click="resetForm">重置</el-button>
              </div>
            </div>
          </template>

          <div v-if="!currentParams.isEdit && !currentParams.isAdd" class="empty-tip">
            <el-empty description="请选择左侧机构或点击新增" />
          </div>

          <div v-else>
            <el-tabs v-model="activeTab">
              <el-tab-pane label="机构详情" name="detail">
                <el-form 
                  ref="formRef"
                  :model="form"
                  :rules="rules"
                  label-width="100px"
                  class="org-form"
                  style="margin-top: 20px"
                >
                  <el-form-item label="上级机构">
                    <el-tree-select
                      v-model="form.parentId"
                      :data="orgTree"
                      :props="{ label: 'name', value: 'id', children: 'children' }"
                      check-strictly
                      placeholder="请选择上级机构 (可留空作为根节点)"
                      style="width: 100%"
                    />
                  </el-form-item>
                  
                  <el-form-item label="机构名称" prop="name">
                    <el-input v-model="form.name" placeholder="请输入机构名称" />
                  </el-form-item>

                  <el-form-item label="机构编码" prop="code">
                    <el-input v-model="form.code" placeholder="唯一编码，如: DEV_DEPT" />
                  </el-form-item>

                  <el-form-item label="机构类型" prop="type">
                    <el-radio-group v-model="form.type">
                      <el-radio label="school">学校</el-radio>
                      <el-radio label="college">学院</el-radio>
                      <el-radio label="department">部门/系</el-radio>
                      <el-radio label="class">班级</el-radio>
                    </el-radio-group>
                  </el-form-item>

                  <el-form-item label="显示排序" prop="sortOrder">
                    <el-input-number v-model="form.sortOrder" :min="0" :max="999" />
                  </el-form-item>

                  <el-form-item label="负责人" prop="leader">
                    <el-input v-model="form.leader" placeholder="部门负责人姓名" />
                  </el-form-item>

                  <el-form-item label="联系电话" prop="phone">
                    <el-input v-model="form.phone" placeholder="联系电话" />
                  </el-form-item>

                  <el-form-item label="状态" prop="status">
                    <el-switch
                      v-model="form.status"
                      active-value="1"
                      inactive-value="0"
                      active-text="启用"
                      inactive-text="停用"
                    />
                  </el-form-item>

                  <el-form-item label="备注">
                    <el-input v-model="form.description" type="textarea" rows="3" />
                  </el-form-item>
                </el-form>
              </el-tab-pane>
              
              <el-tab-pane label="成员管理" name="members">
                <div class="member-toolbar" style="margin-bottom: 15px; display: flex; justify-content: space-between; align-items: center;">
                  <div>
                    <el-tag type="info">当前机构：{{ form.name || '未选择' }}</el-tag>
                    <el-tag type="success" style="margin-left: 8px;">类型：{{ typeLabel(form.type) }}</el-tag>
                  </div>
                  <div>
                    <el-button 
                      type="primary" 
                      size="small" 
                      icon="Plus"
                      :disabled="!assignAllowedOnTab()"
                      @click="openAssignDialog"
                    >
                      添加成员
                    </el-button>
                    <el-tooltip v-if="!assignAllowedOnTab()" placement="top" :content="assignDisabledTip()">
                      <el-icon style="margin-left: 6px"><Connection /></el-icon>
                    </el-tooltip>
                  </div>
                </div>

                <el-tabs v-model="memberTab">
              <el-tab-pane label="学生" name="student">
                    <el-table :data="studentList" v-loading="loadingMembers" border stripe style="width: 100%" @selection-change="onStudentSelectionChange">
                      <el-table-column type="selection" width="50" />
                      <el-table-column prop="username" label="用户名" width="140" />
                      <el-table-column prop="realName" label="姓名" width="140" />
                      <el-table-column label="学号" width="160">
                        <template #default="{ row }">
                          {{ row.studentNo || row.student_id || '-' }}
                        </template>
                      </el-table-column>
                      <el-table-column label="操作" width="220" fixed="right">
                        <template #default="{ row }">
                          <el-button link type="primary" size="small" @click="openMemberDetail(row)">查看</el-button>
                          <el-button link type="danger" size="small" @click="removeMember(row)">移除</el-button>
                        </template>
                      </el-table-column>
                    </el-table>
                    <div style="margin-top: 10px; text-align: right;">
                      <el-button type="danger" size="small" :disabled="selectedStudentIds.length === 0" @click="removeMembersBatch('student')">批量移除</el-button>
                    </div>
              </el-tab-pane>
              <el-tab-pane label="教师" name="teacher">
                    <el-table :data="teacherList" v-loading="loadingMembers" border stripe style="width: 100%" @selection-change="onTeacherSelectionChange">
                      <el-table-column type="selection" width="50" />
                      <el-table-column prop="username" label="用户名" width="140" />
                      <el-table-column prop="realName" label="姓名" width="140" />
                      <el-table-column label="工号" width="160">
                        <template #default="{ row }">
                          {{ row.teacherNo || '-' }}
                        </template>
                      </el-table-column>
                      <el-table-column label="操作" width="220" fixed="right">
                        <template #default="{ row }">
                          <el-button link type="primary" size="small" @click="openMemberDetail(row)">查看</el-button>
                          <el-button link type="danger" size="small" @click="removeMember(row)">移除</el-button>
                        </template>
                      </el-table-column>
                    </el-table>
                    <div style="margin-top: 10px; text-align: right;">
                      <el-button type="danger" size="small" :disabled="selectedTeacherIds.length === 0" @click="removeMembersBatch('teacher')">批量移除</el-button>
                    </div>
              </el-tab-pane>
                </el-tabs>

                <el-dialog v-model="showAssignDialog" :title="form.type === 'class' ? (memberTab === 'teacher' ? '添加教师' : '添加学生') : '添加教师'" width="700">
                  <div style="display: flex; justify-content: space-between; margin-bottom: 10px;">
                    <el-input
                      v-model="candidateKeyword"
                      placeholder="输入关键字搜索用户（用户名或姓名）"
                      clearable
                      style="width: 360px"
                      @keyup.enter="loadCandidates"
                    />
                    <el-button type="primary" @click="loadCandidates">搜索</el-button>
                  </div>
                  <el-table ref="candidateTableRef" :data="candidateList" v-loading="candidateLoading" border stripe @selection-change="onCandidateSelectionChange" row-key="id" reserve-selection>
                    <el-table-column type="selection" width="50" />
                    <el-table-column prop="username" label="用户名" width="160" />
                    <el-table-column prop="realName" label="姓名" width="180" />
                    <el-table-column prop="userType" label="类型" width="100">
                      <template #default="{ row }">
                        <el-tag v-if="row.userType === 'student'" type="success">学生</el-tag>
                        <el-tag v-else-if="row.userType === 'teacher'" type="warning">教师</el-tag>
                        <el-tag v-else>其他</el-tag>
                      </template>
                    </el-table-column>
                    <el-table-column label="操作" width="120" fixed="right">
                      <template #default="{ row }">
                        <el-button link type="primary" size="small" @click="assignMember(row)">分配</el-button>
                      </template>
                    </el-table-column>
                  </el-table>
                  <div style="margin-top: 10px; text-align: right;">
                    <el-button type="primary" :disabled="!canBatchAssign" @click="assignMembersBatch">批量分配</el-button>
                    <el-pagination
                      background
                      layout="prev, pager, next"
                      :total="candidateTotal"
                      :page-size="candidateSize"
                      :current-page="candidatePage"
                      @current-change="(p)=>{ candidatePage = p; loadCandidates() }"
                    />
                  </div>
                  <template #footer>
                    <span class="dialog-footer">
                      <el-button @click="showAssignDialog = false">取消</el-button>
                    </span>
                  </template>
                </el-dialog>
                
                <el-dialog v-model="showMemberDetail" :title="memberDetailTitle" width="520">
                  <el-descriptions :column="1" border>
                    <el-descriptions-item label="用户名">{{ currentMember?.username || '-' }}</el-descriptions-item>
                    <el-descriptions-item label="姓名">{{ currentMember?.realName || '-' }}</el-descriptions-item>
                    <el-descriptions-item label="类型">
                      <el-tag v-if="currentMember?.userType === 'student'" type="success">学生</el-tag>
                      <el-tag v-else-if="currentMember?.userType === 'teacher'" type="warning">教师</el-tag>
                      <el-tag v-else>其他</el-tag>
                    </el-descriptions-item>
                    <el-descriptions-item label="机构路径">{{ memberOrgPathStr }}</el-descriptions-item>
                    <el-descriptions-item v-if="currentMember?.userType === 'student'" label="学号">
                      {{ currentMember?.studentNo || '-' }}
                    </el-descriptions-item>
                    <el-descriptions-item v-else-if="currentMember?.userType === 'teacher'" label="工号">
                      {{ currentMember?.teacherNo || '-' }}
                    </el-descriptions-item>
                  </el-descriptions>
                  <template #footer>
                    <span class="dialog-footer">
                      <el-button type="primary" @click="showMemberDetail = false">关闭</el-button>
                    </span>
                  </template>
                </el-dialog>
              </el-tab-pane>
            </el-tabs>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, reactive, watch, onMounted, inject, computed } from 'vue'
import { Search, Plus, OfficeBuilding, User, School, Connection } from '@element-plus/icons-vue'
import request from '@/utils/request'
import { ElMessageBox } from 'element-plus'

const showMessage = inject('showMessage')

// Data
const filterText = ref('')
const treeRef = ref(null)
const formRef = ref(null)
const saving = ref(false)
const activeTab = ref('detail')
const memberList = ref([])
const loadingMembers = ref(false)
const memberTab = ref('student')

const orgTree = ref([])
const defaultProps = {
  children: 'children',
  label: 'name'
}

// Current operation state
const currentParams = reactive({
  isEdit: false,
  isAdd: false,
  parentData: null
})

const form = reactive({
  id: null,
  parentId: null,
  name: '',
  code: '',
  type: 'department',
  sortOrder: 1,
  leader: '',
  phone: '',
  status: '1',
  description: ''
})

const parentName = ref('')

const rules = {
  name: [{ required: true, message: '请输入机构名称', trigger: 'blur' }],
  code: [{ required: true, message: '请输入机构编码', trigger: 'blur' }],
  type: [{ required: true, message: '请选择机构类型', trigger: 'change' }]
}

const loadOrgTree = async () => {
  try {
    const resp = await request.get('/org/tree')
    orgTree.value = resp || []
  } catch (e) {
    orgTree.value = [] // Empty fallback
    // showMessage(e.message || '加载组织机构失败', 'error') // handled
  }
}

// Methods
watch(filterText, (val) => {
  treeRef.value?.filter(val)
})

const filterNode = (value, data) => {
  if (!value) return true
  return data.name.includes(value)
}

const allowDrag = (draggingNode) => {
  return true
}

const allowDrop = (draggingNode, dropNode, type) => {
  return true
}

const handleNodeDrop = async (draggingNode, dropNode, dropType, ev) => {
  // Update backend using the specialized move endpoint
  try {
     await request.post('/org/move', {
       draggingNodeId: draggingNode.data.id,
       dropNodeId: dropNode.data.id,
       dropType: dropType
     })
    showMessage('移动成功', 'success')
  } catch (e) {
    console.error(e)
    showMessage('移动失败，正在还原...', 'error')
    loadOrgTree() // Reload to revert UI
  }
}

const resetFormFields = () => {
  form.id = null
  form.parentId = null
  form.name = ''
  form.code = ''
  form.type = 'department'
  form.sortOrder = 1
  form.leader = ''
  form.phone = ''
  form.status = '1'
  form.description = ''
  parentName.value = ''
}

const handleAddRoot = () => {
  resetFormFields()
  currentParams.isAdd = true
  currentParams.isEdit = false
  currentParams.parentData = null
  form.parentId = null // Explicitly null for root
  form.type = 'school'
  memberList.value = []
  activeTab.value = 'detail'
}

const append = (data) => {
  resetFormFields()
  currentParams.isAdd = true
  currentParams.isEdit = false
  currentParams.parentData = data
  
  form.parentId = data.id
  // Auto-suggest next level type
  if (data.type === 'school') form.type = 'college'
  else if (data.type === 'college') form.type = 'department'
  else if (data.type === 'department') form.type = 'class'
  else form.type = 'class'
  
  memberList.value = []
  activeTab.value = 'detail'
}

const loadMembers = async (orgId) => {
  loadingMembers.value = true
  try {
    const resp = await request.get(`/org/${orgId}/members`)
    memberList.value = resp || []
    autoSelectMemberTab()
  } catch (e) {
    console.error(e)
    memberList.value = []
  } finally {
    loadingMembers.value = false
  }
}

const handleNodeClick = (data) => {
  currentParams.isEdit = true
  currentParams.isAdd = false
  currentParams.parentData = null 
  activeTab.value = 'detail'

  Object.assign(form, {
    ...data,
    status: data.status || '1'
  })
  
  loadMembers(data.id)
}

const remove = (node, data) => {
  ElMessageBox.confirm(
    `确定要删除机构 "${data.name}" 吗? 此操作不可恢复。`,
    '警告',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning',
    }
  ).then(async () => {
    try {
      await request.delete(`/org/${data.id}`)
      
      // Optimistic update
      const parent = node.parent
      const children = parent.data.children || parent.data
      const index = children.findIndex((d) => d.id === data.id)
      children.splice(index, 1)
      
      resetFormFields()
      currentParams.isEdit = false
      showMessage('删除成功', 'success')
    } catch (e) {
      // showMessage('删除失败', 'error') // handled
    }
  })
}

const submitForm = async () => {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (valid) {
      saving.value = true
      try {
        await request.post('/org/save', form)
        
        // Reload Tree to sync
        loadOrgTree()

        showMessage('保存成功', 'success')
      } catch (e) {
        // showMessage('保存失败', 'error') // handled
      } finally {
        saving.value = false
      }
    }
  })
}

const resetForm = () => {
  if (formRef.value) formRef.value.resetFields()
}

onMounted(() => {
  loadOrgTree()
})

// Derived lists
const teacherList = computed(() => (memberList.value || []).filter(r => r.userType === 'teacher'))
const studentList = computed(() => (memberList.value || []).filter(r => r.userType === 'student'))

const typeLabel = (t) => {
  if (t === 'school') return '学校'
  if (t === 'college') return '学院'
  if (t === 'department' || t === 'dept') return '部门/系'
  if (t === 'class') return '班级'
  return '未知'
}

const canAssign = (t) => {
  return t === 'class' || t === 'college'
}

const assignAllowedOnTab = () => {
  if (!canAssign(form.type)) return false
  if (form.type === 'class') return memberTab.value === 'student' || memberTab.value === 'teacher'
  if (form.type === 'college') return memberTab.value === 'teacher'
  if (form.type === 'department' || form.type === 'dept') return false
  return false
}

const assignDisabledTip = () => {
  if (!canAssign(form.type)) return '请在学院或班级节点进行分配'
  if (form.type === 'college' && memberTab.value !== 'teacher') return '学院只能添加教师'
  if (form.type === 'department' || form.type === 'dept') return '教师归属到学院，不支持在系分配'
  return '不可分配'
}

const autoSelectMemberTab = () => {
  if (form.type === 'class') {
    memberTab.value = 'student'
  } else if (form.type === 'college') {
    memberTab.value = 'teacher'
  } else {
    memberTab.value = 'student'
  }
}

// Assign dialog
const showAssignDialog = ref(false)
const candidateKeyword = ref('')
const candidatePage = ref(1)
const candidateSize = ref(10)
const candidateLoading = ref(false)
const candidateList = ref([])
const candidateTotal = ref(0)
const selectedStudentIds = ref([])
const selectedTeacherIds = ref([])
const selectedCandidateIds = ref([])
const candidateTableRef = ref(null)
const canBatchAssign = computed(() => {
  const rows = candidateTableRef.value?.getSelectionRows?.() || []
  return selectedCandidateIds.value.length > 0 || rows.length > 0
})

const openAssignDialog = () => {
  if (!assignAllowedOnTab()) {
    showMessage(assignDisabledTip(), 'warning')
    return
  }
  showAssignDialog.value = true
  candidateKeyword.value = ''
  candidatePage.value = 1
  loadCandidates()
}

const loadCandidates = async () => {
  if (!form.id) return
  candidateLoading.value = true
  try {
    const resp = await request.get(`/org/${form.id}/members/candidates`, {
      params: {
        keyword: candidateKeyword.value,
        pageNum: candidatePage.value,
        pageSize: candidateSize.value,
        userType: memberTab.value
      }
    })
    candidateList.value = resp?.list || []
    candidateTotal.value = resp?.total || 0
  } catch (e) {
    candidateList.value = []
    candidateTotal.value = 0
  } finally {
    candidateLoading.value = false
  }
}

const assignMember = async (user) => {
  if (!form.id) return
  try {
    await request.post(`/org/${form.id}/members/assign`, {
      userId: user.id
    })
    showMessage('分配成功', 'success')
    showAssignDialog.value = false
    loadMembers(form.id)
  } catch (e) {
    // 错误提示在拦截器内统一处理
  }
}

const assignMembersBatch = async () => {
  if (!form.id) return
  try {
    const rows = candidateTableRef.value?.getSelectionRows?.() || []
    const ids = selectedCandidateIds.value.length > 0 ? selectedCandidateIds.value : rows.map(r => r.id)
    if (!ids || ids.length === 0) return
    await request.post(`/org/${form.id}/members/assign-batch`, { userIds: ids })
    showMessage('分配成功', 'success')
    showAssignDialog.value = false
    loadMembers(form.id)
  } catch (e) {}
}

const removeMember = async (row) => {
  if (!form.id) return
  try {
    await request.post(`/org/${form.id}/members/remove`, {
      userId: row.userId
    })
    showMessage('移除成功', 'success')
    loadMembers(form.id)
  } catch (e) {}
}

const removeMembersBatch = async (type) => {
  if (!form.id) return
  const ids = type === 'student' ? selectedStudentIds.value : selectedTeacherIds.value
  if (!ids.length) return
  try {
    await request.post(`/org/${form.id}/members/remove-batch`, {
      userIds: ids
    })
    showMessage('移除成功', 'success')
    loadMembers(form.id)
  } catch (e) {}
}

const onStudentSelectionChange = (rows) => {
  selectedStudentIds.value = rows.map(r => r.userId)
}
const onTeacherSelectionChange = (rows) => {
  selectedTeacherIds.value = rows.map(r => r.userId)
}
const onCandidateSelectionChange = (rows) => {
  selectedCandidateIds.value = rows.map(r => r.id)
}

// Member detail
const showMemberDetail = ref(false)
const currentMember = ref(null)
const memberDetailTitle = computed(() => {
  const t = currentMember.value?.userType
  return t === 'student' ? '学生详情' : t === 'teacher' ? '教师详情' : '成员详情'
})
const openMemberDetail = (row) => {
  currentMember.value = row
  showMemberDetail.value = true
}

const findPath = (nodes, targetId, pathAcc = []) => {
  for (const n of nodes || []) {
    const nextPath = [...pathAcc, n]
    if (n.id === targetId) return nextPath
    const res = findPath(n.children || [], targetId, nextPath)
    if (res) return res
  }
  return null
}
const memberOrgPathStr = computed(() => {
  const originId = currentMember.value?.originOrgId || form.id
  const pathNodes = findPath(orgTree.value, originId) || []
  // 仅展示到最小单位（叶节点），但包含从学院到叶子
  return pathNodes.map(n => n.name).join('/')
})
</script>

<style scoped>
.page-container {
  padding: 20px;
  height: 100%;
}
.page-header {
  margin-bottom: 16px;
}
.page-title {
  margin: 0;
  font-size: 20px;
}
.main-content {
  height: calc(100vh - 140px);
}
.tree-card, .detail-card {
  height: 100%;
  overflow-y: auto;
}
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.custom-tree-node {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 14px;
  padding-right: 8px;
}
.node-label {
  display: flex;
  align-items: center;
  gap: 6px;
}
.empty-tip {
  height: 300px;
  display: flex;
  justify-content: center;
  align-items: center;
}
.org-form {
  max-width: 600px;
}
</style>
