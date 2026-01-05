<template>
  <div class="paper-auto-generate-container">
    <div class="page-header">
      <h2 class="page-title">智能组卷</h2>
      <div>
        <el-button @click="handleCancel">取消</el-button>
        <el-button type="primary" @click="handleGenerate" :loading="generating">生成试卷</el-button>
      </div>
    </div>

    <el-card>
      <el-form :model="form" label-width="120px" style="max-width: 900px">
        <el-form-item label="科目" required>
          <el-select
            v-model="form.subject"
            placeholder="请选择或输入科目"
            filterable
            allow-create
            default-first-option
            style="width: 360px"
          >
            <el-option
              v-for="item in subjectOptions"
              :key="item"
              :label="item"
              :value="item"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="总分" required>
          <el-input-number v-model="form.totalScore" :min="1" :max="200" />
          <span class="summary-hint">题目总数：{{ totalQuestions }}</span>
        </el-form-item>

        <el-divider content-position="left">按难度题型分布</el-divider>

        <el-table :data="questionTypes" border style="width: 100%">
          <el-table-column prop="label" label="题型" width="140" />
          <el-table-column label="简单">
            <template #default="scope">
              <el-input-number
                v-model="form.difficultyDistribution.easy[scope.row.key]"
                :min="0"
                :max="50"
              />
            </template>
          </el-table-column>
          <el-table-column label="中等">
            <template #default="scope">
              <el-input-number
                v-model="form.difficultyDistribution.medium[scope.row.key]"
                :min="0"
                :max="50"
              />
            </template>
          </el-table-column>
          <el-table-column label="困难">
            <template #default="scope">
              <el-input-number
                v-model="form.difficultyDistribution.hard[scope.row.key]"
                :min="0"
                :max="50"
              />
            </template>
          </el-table-column>
        </el-table>

        <el-divider content-position="left">难度小计</el-divider>
        <div class="summary-grid">
          <div>简单：{{ difficultyTotals.easy }} 道</div>
          <div>中等：{{ difficultyTotals.medium }} 道</div>
          <div>困难：{{ difficultyTotals.hard }} 道</div>
          <div>总计：{{ totalQuestions }} 道</div>
        </div>
        <div class="summary-warning" v-if="totalQuestions === 0">
          请至少填写一种题型与难度的题目数量。
        </div>
        <div class="summary-warning" v-else-if="form.totalScore < totalQuestions">
          总分不能小于题目总数（每题至少 1 分）。
        </div>
      </el-form>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, inject, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { autoGeneratePaper, getSubjects } from '@/api/teacher'

const router = useRouter()
const showMessage = inject('showMessage')

const generating = ref(false)

const questionTypes = [
  { key: 'single_choice', label: '单选题' },
  { key: 'multiple_choice', label: '多选题' },
  { key: 'true_false', label: '判断题' },
  { key: 'fill_blank', label: '填空题' },
  { key: 'short_answer', label: '简答题' },
  { key: 'programming', label: '编程题' }
]

const subjectOptions = ref([])

const emptyDistribution = () => ({
  single_choice: 0,
  multiple_choice: 0,
  true_false: 0,
  fill_blank: 0,
  short_answer: 0,
  programming: 0
})

const form = reactive({
  subject: '',
  totalScore: 100,
  difficultyDistribution: {
    easy: { ...emptyDistribution(), single_choice: 10, multiple_choice: 5 },
    medium: { ...emptyDistribution(), true_false: 5, fill_blank: 3 },
    hard: { ...emptyDistribution(), short_answer: 2, programming: 0 }
  }
})

const difficultyTotals = computed(() => {
  const result = { easy: 0, medium: 0, hard: 0 }
  Object.entries(form.difficultyDistribution).forEach(([key, dist]) => {
    const sum = Object.values(dist).reduce((s, count) => s + count, 0)
    if (key === 'easy') result.easy = sum
    if (key === 'medium') result.medium = sum
    if (key === 'hard') result.hard = sum
  })
  return result
})

const totalQuestions = computed(() => {
  return Object.values(difficultyTotals.value).reduce((s, n) => s + n, 0)
})

const handleGenerate = async () => {
  if (!form.subject) {
    showMessage('请输入科目', 'warning')
    return
  }

  if (totalQuestions === 0) {
    showMessage('请至少选择一种题型', 'warning')
    return
  }
  if (form.totalScore < totalQuestions) {
    showMessage('总分不能小于题目总数', 'warning')
    return
  }

  generating.value = true
  try {
    const data = {
      subject: form.subject,
      totalScore: form.totalScore,
      difficultyDistribution: form.difficultyDistribution
    }

    await autoGeneratePaper(data)

    showMessage('智能组卷成功', 'success')
    router.push('/dashboard/teacher/paper-management')
  } catch (error) {
    console.error('智能组卷失败:', error)
    const errorMsg = error.response?.data?.message || error.message || '智能组卷失败，可能题库中题目不足'
    showMessage(errorMsg, 'error')
  } finally {
    generating.value = false
  }
}

const loadSubjects = async () => {
  try {
    const res = await getSubjects()
    const list = Array.isArray(res) ? res : (res?.list || [])
    subjectOptions.value = list.map(item => item.name || item.subject || item).filter(Boolean)
  } catch (error) {
    subjectOptions.value = []
  }
}

const handleCancel = () => {
  router.back()
}

onMounted(() => {
  loadSubjects()
})
</script>

<style scoped>
.paper-auto-generate-container {
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.page-title {
  font-size: 20px;
  font-weight: bold;
}

.summary-hint {
  margin-left: 12px;
  color: #909399;
}

.summary-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(120px, 1fr));
  gap: 10px;
  color: #606266;
}

.summary-warning {
  margin-top: 10px;
  color: #f56c6c;
}
</style>
