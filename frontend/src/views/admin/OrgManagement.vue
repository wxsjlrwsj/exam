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
                <el-tabs v-model="memberSubTab">
                  <el-tab-pane label="教师管理" name="teacher">
                    <div class="member-toolbar" style="margin-bottom: 15px; text-align: right;">
                      <el-button type="primary" size="small" icon="Plus" @click="openAddMemberDialog" :disabled="!isTeacherAssignable">添加教师</el-button>
                    </div>
                    <el-table :data="teacherList" v-loading="loadingMembers" border stripe style="width: 100%">
                      <el-table-column prop="username" label="用户名" width="120" />
                      <el-table-column prop="realName" label="姓名" width="120" />
                      <el-table-column prop="userType" label="角色" width="100">
                        <template #default="{ row }">
                          <el-tag type="warning">教师</el-tag>
                        </template>
                      </el-table-column>
                      <el-table-column prop="studentNo" label="学号/工号" width="120" />
                      <el-table-column label="操作" width="150" fixed="right">
                        <template #default>
                          <el-button link type="primary" size="small">编辑</el-button>
                          <el-button link type="danger" size="small">移除</el-button>
                        </template>
                      </el-table-column>
                    </el-table>
                  </el-tab-pane>
                  <el-tab-pane label="学生管理" name="student">
                    <div class="member-toolbar" style="margin-bottom: 15px; text-align: right;">
                      <el-button type="primary" size="small" icon="Plus" @click="openAddMemberDialog" :disabled="!isStudentAssignable">添加学生</el-button>
                    </div>
                    <el-table :data="studentList" v-loading="loadingMembers" border stripe style="width: 100%">
                      <el-table-column prop="username" label="用户名" width="120" />
                      <el-table-column prop="realName" label="姓名" width="120" />
                      <el-table-column prop="userType" label="角色" width="100">
                        <template #default="{ row }">
                          <el-tag type="success">学生</el-tag>
                        </template>
                      </el-table-column>
                      <el-table-column prop="studentNo" label="学号/工号" width="120" />
                      <el-table-column label="操作" width="150" fixed="right">
                        <template #default>
                          <el-button link type="primary" size="small">编辑</el-button>
                          <el-button link type="danger" size="small">移除</el-button>
                        </template>
                      </el-table-column>
                    </el-table>
                  </el-tab-pane>
                </el-tabs>
              </el-tab-pane>
            </el-tabs>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-dialog v-model="addMemberDialogVisible" title="添加成员" width="700px">
      <div style="margin-bottom: 10px; display: flex; gap: 8px;">
        <el-input v-model="candidateKeyword" placeholder="输入姓名或用户名" clearable />
        <el-button type="primary" @click="loadCandidates">搜索</el-button>
      </div>
      <el-table :data="candidateList" v-loading="candidateLoading" highlight-current-row @current-change="onCandidateChange" style="width: 100%">
        <el-table-column prop="username" label="用户名" width="140" />
        <el-table-column prop="realName" label="姓名" width="160" />
        <el-table-column prop="userType" label="类型" width="120" />
      </el-table>
      <div style="margin-top: 10px; display: flex; justify-content: space-between; align-items: center;">
        <div>共 {{ candidateTotal }} 条</div>
        <el-pagination
          small
          layout="prev, pager, next"
          :total="candidateTotal"
          :page-size="candidatePageSize"
          :current-page="candidatePageNum"
          @current-change="onCandidatePageChange"
        />
      </div>
      <template #footer>
        <el-button @click="addMemberDialogVisible = false">取消</el-button>
        <el-button type="primary" :disabled="!selectedCandidate" @click="assignMember">确认添加</el-button>
      </template>
    </el-dialog>
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
const memberSubTab = ref('student')
const addMemberDialogVisible = ref(false)
const candidateList = ref([])
const candidateLoading = ref(false)
const candidateKeyword = ref('')
const candidateTotal = ref(0)
const candidatePageNum = ref(1)
const candidatePageSize = ref(10)
const selectedCandidate = ref(null)

const studentList = computed(() => memberList.value.filter(m => (m.userType || '').toLowerCase() === 'student'))
const teacherList = computed(() => memberList.value.filter(m => (m.userType || '').toLowerCase() === 'teacher'))
const isTeacherAssignable = computed(() => {
  const t = (form.type || '').toLowerCase()
  return t === 'department' || t === 'dept'
})
const isStudentAssignable = computed(() => (form.type || '').toLowerCase() === 'class')

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
    orgTree.value = resp.data || []
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
    const type = (form.type || '').toLowerCase()
    if (type === 'class') {
      const resp = await request.get(`/org/${orgId}/members`)
      memberList.value = resp.data || []
    } else {
      const collectIds = (nodes, targetId) => {
        const stack = [...nodes]
        let found = null
        while (stack.length) {
          const n = stack.shift()
          if (n.id === targetId) {
            found = n
            break
          }
          if (n.children && n.children.length) stack.push(...n.children)
        }
        const classIds = []
        const deptIds = []
        const walk = (node) => {
          const t = (node.type || '').toLowerCase()
          if (t === 'class') classIds.push(node.id)
          if (t === 'department' || t === 'dept') deptIds.push(node.id)
          if (node.children && node.children.length) {
            node.children.forEach(walk)
          }
        }
        if (found) {
          walk(found)
          const selfType = (found.type || '').toLowerCase()
          if (selfType === 'department' || selfType === 'dept') {
            if (!deptIds.includes(found.id)) deptIds.push(found.id)
          }
        }
        return { classIds, deptIds }
      }
      const { classIds, deptIds } = collectIds(orgTree.value, orgId)
      const reqs = []
      classIds.forEach(id => reqs.push(request.get(`/org/${id}/members`)))
      deptIds.forEach(id => reqs.push(request.get(`/org/${id}/members`)))
      const results = await Promise.allSettled(reqs)
      const merged = []
      results.forEach(r => {
        if (r.status === 'fulfilled') {
          const list = r.value?.data || []
          if (Array.isArray(list) && list.length) merged.push(...list)
        }
      })
      memberList.value = merged
    }
  } catch (e) {
    console.error(e)
    memberList.value = []
  } finally {
    loadingMembers.value = false
  }
}

const openAddMemberDialog = () => {
  addMemberDialogVisible.value = true
  candidatePageNum.value = 1
  selectedCandidate.value = null
  loadCandidates()
}

const loadCandidates = async () => {
  if (!form.id) return
  candidateLoading.value = true
  try {
    const resp = await request.get(`/org/${form.id}/members/candidates`, {
      params: {
        keyword: candidateKeyword.value,
        pageNum: candidatePageNum.value,
        pageSize: candidatePageSize.value
      }
    })
    candidateList.value = (resp.data?.list) || []
    candidateTotal.value = (resp.data?.total) || 0
  } catch (e) {
    candidateList.value = []
    candidateTotal.value = 0
  } finally {
    candidateLoading.value = false
  }
}

const onCandidateChange = (row) => {
  selectedCandidate.value = row || null
}

const onCandidatePageChange = (p) => {
  candidatePageNum.value = p
  loadCandidates()
}

const assignMember = async () => {
  if (!form.id || !selectedCandidate.value) return
  try {
    await request.post(`/org/${form.id}/members/assign`, { userId: selectedCandidate.value.id })
    addMemberDialogVisible.value = false
    loadMembers(form.id)
    showMessage('添加成功', 'success')
  } catch (e) {
    showMessage('添加失败', 'error')
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
  const t = (data.type || '').toLowerCase()
  memberSubTab.value = (t === 'department' || t === 'dept') ? 'teacher' : 'student'
  
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
