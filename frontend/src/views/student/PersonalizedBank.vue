<template>
  <div class="personalized-bank-container">
    <div class="page-header">
      <h2 class="page-title">个性化题库</h2>
    </div>
    
    <el-card class="filter-card">
      <el-form :inline="true" :model="filterForm" class="filter-form">
        <el-form-item label="题目类型">
          <el-select v-model="filterForm.type" placeholder="请选择题型" clearable>
            <el-option v-for="item in questionTypes" :key="item.value" :label="item.label" :value="item.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="推荐来源">
          <el-select v-model="filterForm.source" placeholder="请选择来源" clearable>
            <el-option label="错题推荐" value="wrong" />
            <el-option label="薄弱知识点" value="weak" />
            <el-option label="每日一练" value="daily" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="resetFilter">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>
    
    <el-table v-loading="loading" :data="questionList" border style="width: 100%">
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="typeId" label="题型" width="120">
        <template #default="scope">
          {{ getQuestionTypeLabel(scope.row.typeId) }}
        </template>
      </el-table-column>
      <el-table-column prop="content" label="题目内容" show-overflow-tooltip />
      <el-table-column prop="difficulty" label="难度" width="150">
        <template #default="scope">
          <el-rate
            v-model="scope.row.difficulty"
            disabled
            text-color="#ff9900"
          />
        </template>
      </el-table-column>
      <el-table-column prop="recommendReason" label="推荐理由" width="150">
        <template #default="scope">
          <el-tag :type="getReasonType(scope.row.source)">{{ scope.row.recommendReason }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="120" fixed="right">
        <template #default="scope">
          <el-button link type="primary" @click="handlePractice(scope.row)">开始练习</el-button>
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
import http from '@/api/http'

const showMessage = inject('showMessage')

const loading = ref(false)
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const questionList = ref([])

const questionTypes = [
  { label: '单选题', value: 'SINGLE' },
  { label: '多选题', value: 'MULTI' },
  { label: '判断题', value: 'TRUE_FALSE' },
  { label: '填空题', value: 'FILL' },
  { label: '简答题', value: 'SHORT' }
]

const filterForm = reactive({
  type: '',
  source: ''
})

// 获取题型标签
const typeIdLabelMap = { 1: '单选题', 2: '多选题', 3: '判断题', 4: '填空题', 5: '简答题' }
const getQuestionTypeLabel = (typeId) => typeIdLabelMap[typeId] || '未知'

// 获取推荐理由样式
const getReasonType = (source) => {
  const map = {
    'wrong': 'danger',
    'weak': 'warning',
    'daily': 'success'
  }
  return map[source] || 'info'
}

const loadQuestionList = async () => {
  loading.value = true
  try {
    const resp = await http.get('/api/questions', {
      params: {
        page: currentPage.value,
        size: pageSize.value,
        typeCode: filterForm.type || undefined
      }
    })
    const data = resp?.data || {}
    const list = Array.isArray(data.list) ? data.list : []
    questionList.value = list
    total.value = Number(data.total) || list.length
  } catch (e) {
    questionList.value = []
    total.value = 0
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  currentPage.value = 1
  loadQuestionList()
}

const handleCurrentChange = () => {
  loadQuestionList()
}

const handleSizeChange = () => {
  currentPage.value = 1
  loadQuestionList()
}

// 处理开始练习
const handlePractice = (row) => {
  showMessage(`开始练习: ${row.content.substring(0, 10)}...`, 'success')
}

onMounted(() => {
  loadQuestionList()
})
</script>

<style scoped>
.personalized-bank-container {
  padding: 20px;
}

.page-header {
  margin-bottom: 20px;
}

.page-title {
  font-size: 24px;
  color: #303133;
  margin: 0;
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
