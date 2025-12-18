<template>
  <div class="exam-list-container">
    <div class="page-header">
      <h2 class="page-title">我的考试</h2>
    </div>

    <el-card class="filter-card">
      <el-form :inline="true" :model="filterForm" class="filter-form">
        <el-form-item label="考试名称">
          <el-input v-model="filterForm.name" placeholder="请输入考试名称" clearable />
        </el-form-item>
        <el-form-item label="考试状态">
          <el-select v-model="filterForm.status" placeholder="请选择考试状态" clearable>
            <el-option label="未开始" value="not_started" />
            <el-option label="进行中" value="in_progress" />
            <el-option label="已结束" value="finished" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="resetFilter">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-tabs v-model="activeTab" @tab-click="handleTabChange">
      <el-tab-pane label="全部考试" name="all"></el-tab-pane>
      <el-tab-pane label="未开始" name="not_started"></el-tab-pane>
      <el-tab-pane label="进行中" name="in_progress"></el-tab-pane>
      <el-tab-pane label="已结束" name="finished"></el-tab-pane>
    </el-tabs>

    <el-table
      v-loading="loading"
      :data="examList"
      border
      style="width: 100%"
      @row-click="handleRowClick"
    >
      <el-table-column prop="name" label="考试名称" min-width="180" />
      <el-table-column label="科目" min-width="120">
        <template #default="scope">
          {{ scope.row.subject || '-' }}
        </template>
      </el-table-column>
      <el-table-column label="考试时间" min-width="240">
        <template #default="scope">
          {{ formatDate(scope.row.startTime) }} 至 {{ formatDate(scope.row.endTime) }}
        </template>
      </el-table-column>
      <el-table-column prop="duration" label="考试时长" min-width="100">
        <template #default="scope">
          {{ scope.row.duration }} 分钟
        </template>
      </el-table-column>
      <el-table-column prop="status" label="状态" min-width="100">
        <template #default="scope">
          <el-tag :type="getStatusType(scope.row.status)">
            {{ getStatusText(scope.row.status) }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" fixed="right" width="200">
        <template #default="scope">
          <el-button 
            v-if="scope.row.status === 'in_progress'"
            link 
            type="success" 
            @click.stop="handleTakeExam(scope.row)"
          >
            参加考试
          </el-button>
          <el-button 
            v-if="scope.row.status === 'finished'"
            link 
            type="primary" 
            @click.stop="handleViewResult(scope.row)"
          >
            查看成绩
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <div class="pagination-container">
      <el-pagination
        v-model:current-page="currentPage"
        v-model:page-size="pageSize"
        :page-sizes="[10, 20, 30, 50]"
        layout="total, sizes, prev, pager, next, jumper"
        :total="total"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, inject } from 'vue'
import { useRouter } from 'vue-router'
import { Plus } from '@element-plus/icons-vue'
import http from '@/api/http'

const router = useRouter()
const showMessage = inject('showMessage')

const loading = ref(false)
const activeTab = ref('all')
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const examList = ref([])

const filterForm = reactive({
  name: '',
  status: ''
})

const tabToParam = {
  all: null,
  not_started: 'upcoming',
  in_progress: 'ongoing',
  finished: 'finished'
}
const statusIntToText = (n) => {
  if (n === 0) return 'not_started'
  if (n === 1) return 'in_progress'
  if (n === 2) return 'finished'
  return 'not_started'
}

// 格式化日期
const formatDate = (dateStr) => {
  const date = new Date(dateStr)
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')} ${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}`
}

// 获取状态类型
const getStatusType = (status) => {
  switch (status) {
    case 'not_started':
      return 'info'
    case 'in_progress':
      return 'success'
    case 'finished':
      return ''
    default:
      return ''
  }
}

// 获取状态文本
const getStatusText = (status) => {
  switch (status) {
    case 'not_started':
      return '未开始'
    case 'in_progress':
      return '进行中'
    case 'finished':
      return '已结束'
    default:
      return '未知'
  }
}

const loadExamList = async () => {
  loading.value = true
  try {
    const statusParam = tabToParam[activeTab.value] || null
    const resp = await http.get('/api/student/exams', {
      params: {
        status: statusParam,
        page: currentPage.value,
        size: pageSize.value
      }
    })
    const data = resp?.data || {}
    let list = Array.isArray(data.list) ? data.list.map(e => ({
      id: e.id,
      name: e.name,
      subject: e.subject,
      startTime: e.startTime,
      endTime: e.endTime,
      duration: e.duration,
      status: statusIntToText(e.status)
    })) : []
    if (filterForm.name) {
      list = list.filter(exam => exam.name.includes(filterForm.name))
    }
    if (filterForm.status) {
      list = list.filter(exam => exam.status === filterForm.status)
    }
    total.value = Number(data.total) || list.length
    examList.value = list
  } catch (e) {
    examList.value = []
    total.value = 0
  } finally {
    loading.value = false
  }
}

// 处理搜索
const handleSearch = () => {
  currentPage.value = 1
  loadExamList()
}

// 重置筛选条件
const resetFilter = () => {
  filterForm.name = ''
  filterForm.status = ''
  handleSearch()
}

// 处理标签页切换
const handleTabChange = () => {
  currentPage.value = 1
  loadExamList()
}

// 处理页码变化
const handleCurrentChange = () => {
  loadExamList()
}

// 处理每页数量变化
const handleSizeChange = () => {
  currentPage.value = 1
  loadExamList()
}

// 处理行点击
const handleRowClick = (row) => {
  router.push(`/student/exam-detail/${row.id}`)
}

// 处理参加考试
const handleTakeExam = (row) => {
  showMessage('进入考试界面', 'success')
  // router.push(`/take-exam/${row.id}`)
}

// 处理查看成绩
const handleViewResult = (row) => {
  showMessage('查看成绩详情', 'info')
  // router.push(`/student/results?examId=${row.id}`)
}

onMounted(() => {
  loadExamList()
})
</script>

<style scoped>
.exam-list-container {
  padding: 20px;
}

.filter-card {
  margin-bottom: 20px;
}

.filter-form {
  display: flex;
  flex-wrap: wrap;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

@media (max-width: 768px) {
  .filter-form {
    flex-direction: column;
  }
  
  .filter-form .el-form-item {
    margin-right: 0;
  }
}
</style>
