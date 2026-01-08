<template>
  <div class="score-management-container">
    <el-tabs v-model="activeTab" type="border-card" @tab-change="handleTabChange">
      <!-- ==================== 1. 阅卷管理 ==================== -->
      <el-tab-pane label="阅卷管理" name="grading">
        <div class="grading-pane">
          <div class="page-header">
            <div class="header-left" style="display: flex; align-items: center;">
            <el-button v-if="showBackButton" :icon="ArrowLeft" circle @click="goBack" style="margin-right: 15px;" />
            <h2 class="page-title">阅卷管理</h2>
          </div>
            <div class="header-actions">
              <el-button type="warning" @click="registerScores" v-if="!isGrading && isAllGraded">
                <el-icon><Upload /></el-icon>登记成绩
              </el-button>
              <el-button type="primary" @click="startGrading" v-if="!isGrading">
                <el-icon><Edit /></el-icon>开始批�?              </el-button>
              <el-button type="success" @click="finishGrading" v-if="isGrading">
                <el-icon><Check /></el-icon>完成批阅
              </el-button>
            </div>
          </div>
          
          <el-card class="exam-info-card" v-if="!isGrading">
            <template #header>
              <div class="card-header">
                <span>考试信息</span>
              </div>
            </template>
            <div class="exam-info">
              <div class="info-item">
                <span class="label">考试名称�?/span>
                <span class="value">{{ currentExam.name }}</span>
              </div>
              <div class="info-item">
                <span class="label">科目�?/span>
                <span class="value">{{ currentExam.subject }}</span>
              </div>
              <div class="info-item">
                <span class="label">考试时间�?/span>
                <span class="value">{{ currentExam.examTime }}</span>
              </div>
              <div class="info-item">
                <span class="label">考试时长�?/span>
                <span class="value">{{ currentExam.duration }}分钟</span>
              </div>
              <div class="info-item">
                <span class="label">总分�?/span>
                <span class="value">{{ currentExam.totalScore }}�?/span>
              </div>
              <div class="info-item">
                <span class="label">参考人数：</span>
                <span class="value">{{ currentExam.studentCount }}�?/span>
              </div>
              <div class="info-item">
                <span class="label">批阅进度�?/span>
                <span class="value">{{ gradedCount }}/{{ currentExam.studentCount }}</span>
              </div>
            </div>
          </el-card>
          
          <div class="grading-content" v-if="isGrading">
            <el-row :gutter="20">
              <el-col :span="16">
                <el-card class="paper-card">
                  <template #header>
                    <div class="card-header">
                      <span>试卷内容</span>
                      <div>
                        <span>学生：{{ currentGradingStudent.name }}</span>
                        <el-tag type="info" style="margin-left: 10px">{{ currentGradingStudent.studentNo }}</el-tag>
                      </div>
                    </div>
                  </template>
                  <div class="paper-content">
                    <div v-for="(question, index) in paperQuestions" :key="index" class="question-item">
                      <div class="question-header">
                        <div class="question-title">
                          <span class="question-number">{{ index + 1 }}.</span>
                          <span class="question-type">[{{ getQuestionTypeLabel(question.type) }}]</span>
                          <span>{{ question.content }}</span>
                        </div>
                        <div class="question-score">
                          <span>{{ question.score }}�?/span>
                        </div>
                      </div>
                      
                      <div class="student-answer">
                        <div class="answer-label">学生答案�?/div>
                        <div class="answer-content" v-html="formatStudentAnswer(question)"></div>
                      </div>
                      
                      <div class="correct-answer" v-if="question.type !== 'essay' && question.type !== 'short'">
                        <div class="answer-label">正确答案�?/div>
                        <div class="answer-content" v-html="formatCorrectAnswer(question)"></div>
                      </div>
                      
                      <div class="grading-area" v-if="!question.autoGraded">
                        <div class="score-input">
                          <span>评分�?/span>
                          <el-input-number 
                            v-model="question.givenScore" 
                            :min="0" 
                            :max="question.score" 
                            :step="0.5"
                            size="small"
                          />
                          <span class="max-score">/ {{ question.score }}�?/span>
                        </div>
                        <div class="comment-input">
                          <span>评语�?/span>
                          <el-input 
                            v-model="question.comment" 
                            type="textarea" 
                            :rows="2" 
                            placeholder="请输入评语（可选）"
                          />
                        </div>
                      </div>
                      <div class="auto-graded" v-else>
                        <el-tag type="success">系统已自动评�? {{ question.givenScore }}�?/el-tag>
                      </div>
                    </div>
                  </div>
                </el-card>
              </el-col>
              
              <el-col :span="8">
                <el-card class="student-list-card">
                  <template #header>
                    <div class="card-header">
                      <span>学生列表</span>
                      <el-select v-model="gradingFilterStatus" placeholder="筛选状�? size="small" style="width: 100px">
                        <el-option label="全部" value="" />
                        <el-option label="未批�? value="ungraded" />
                        <el-option label="已批�? value="graded" />
                      </el-select>
                    </div>
                  </template>
                  <div class="student-list">
                    <el-table
                      :data="filteredGradingStudents"
                      style="width: 100%"
                      height="calc(100vh - 350px)"
                      @row-click="handleStudentSelect"
                      highlight-current-row
                    >
                      <el-table-column prop="name" label="姓名" width="100" />
                      <el-table-column prop="studentNo" label="学号" width="120" />
                      <el-table-column prop="status" label="状�? width="100">
                        <template #default="scope">
                          <el-tag :type="scope.row.status === 'graded' ? 'success' : 'info'">
                            {{ scope.row.status === 'graded' ? '已批�? : '未批�? }}
                          </el-tag>
                        </template>
                      </el-table-column>
                    </el-table>
                  </div>
                  <div class="grading-actions">
                    <el-button type="primary" @click="handleSubmitGrading">提交评分</el-button>
                    <el-button @click="handleNextStudent" :disabled="!hasNextStudent">下一�?/el-button>
                  </div>
                </el-card>
              </el-col>
            </el-row>
          </div>
          
          <div class="grading-summary" v-else>
            <el-card>
              <template #header>
                <div class="card-header">
                  <span>批阅统计</span>
                </div>
              </template>
              <el-table :data="allStudents" border style="width: 100%">
                <el-table-column prop="studentNo" label="学号" width="120" />
                <el-table-column prop="name" label="姓名" width="100" />
                <el-table-column prop="className" label="班级" width="120" />
                <el-table-column prop="score" label="总分" width="100">
                   <template #default="scope">
                    {{ scope.row.score !== null ? scope.row.score : '-' }}
                  </template>
                </el-table-column>
                <el-table-column prop="status" label="状�? width="100">
                  <template #default="scope">
                    <el-tag :type="scope.row.status === 'graded' ? 'success' : 'info'">
                      {{ scope.row.status === 'graded' ? '已批�? : '未批�? }}
                    </el-tag>
                  </template>
                </el-table-column>
                <el-table-column prop="submitTime" label="提交时间" width="180" />
                <el-table-column prop="gradingTime" label="批阅时间" width="180" />
                <el-table-column label="操作" width="150">
                  <template #default="scope">
                    <el-button link type="primary" @click="viewStudentPaper(scope.row)">查看</el-button>
                    <el-button link type="primary" @click="editGrading(scope.row)" v-if="scope.row.status === 'graded'">修改</el-button>
                  </template>
                </el-table-column>
              </el-table>
            </el-card>
          </div>
        </div>
      </el-tab-pane>
      
      <!-- ==================== 2. 成绩管理 ==================== -->
      <el-tab-pane label="成绩管理" name="score">
        <div class="score-pane">
          <!-- 筛选与操作�?-->
          <el-card class="filter-card">
            <div class="filter-header">
               <span class="filter-title">筛选查�?/span>
               <div class="filter-actions">
                  <el-button type="primary" plain @click="handleImportScores">
                    <el-icon><Upload /></el-icon> 批量导入
                  </el-button>
                  <el-button type="success" plain @click="exportResults">
                    <el-icon><Download /></el-icon> 导出成绩�?                  </el-button>
               </div>
            </div>
            <div class="filter-container">
              <el-form :inline="true" :model="scoreFilterForm" class="filter-form">
                <el-form-item label="考试名称">
                  <el-select v-model="scoreFilterForm.examId" placeholder="选择考试" clearable @change="handleScoreExamChange" style="width: 200px">
                    <el-option v-for="item in examOptions" :key="item.id" :label="item.name" :value="item.id" />
                  </el-select>
                </el-form-item>
                <el-form-item label="班级">
                  <el-select v-model="scoreFilterForm.classId" placeholder="选择班级" clearable style="width: 150px">
                    <el-option v-for="item in classOptions" :key="item.id" :label="item.name" :value="item.id" />
                  </el-select>
                </el-form-item>
                <el-form-item label="学号/姓名">
                  <el-input v-model="scoreFilterForm.keyword" placeholder="输入学号或姓�? clearable prefix-icon="Search" />
                </el-form-item>
                <el-form-item>
                  <el-button type="primary" @click="handleScoreSearch">搜索</el-button>
                  <el-button @click="resetScoreFilter">重置</el-button>
                </el-form-item>
              </el-form>
            </div>
          </el-card>

          <!-- 成绩列表 -->
          <el-card class="results-table-card">
              <template #header>
                <div class="card-header">
                  <div class="left">
                    <span>成绩列表</span>
                    <el-tag type="info" style="margin-left: 10px">�?{{ filteredScoreList.length }} 条数�?/el-tag>
                  </div>
                  <div class="right" v-if="selectedStudents.length > 0">
                    <el-button type="success" size="small" @click="batchPublish(true)">批量发布</el-button>
                    <el-button type="warning" size="small" @click="batchPublish(false)">批量撤回</el-button>
                  </div>
                </div>
              </template>
              <el-table 
                :data="paginatedScoreList" 
                border 
                stripe
                style="width: 100%" 
                id="score-table"
                @selection-change="handleSelectionChange"
              >
                <el-table-column type="selection" width="55" />
                <el-table-column prop="studentId" label="学号" width="120" sortable />
                <el-table-column prop="name" label="姓名" width="100" />
                <el-table-column prop="className" label="班级" width="120" sortable />
                <el-table-column prop="score" label="成绩" width="100" sortable>
                  <template #default="scope">
                    <span :class="getScoreClass(scope.row.score)" style="font-size: 16px;">{{ scope.row.score !== null ? scope.row.score : '-' }}</span>
                  </template>
                </el-table-column>
                <el-table-column label="排名" width="80" align="center">
                  <template #default="scope">
                    <el-tag effect="plain" type="info">{{ getRank(scope.row) }}</el-tag>
                  </template>
                </el-table-column>
                <el-table-column prop="submitTime" label="提交时间" width="180" sortable />
                <el-table-column prop="status" label="状�? width="100" align="center">
                  <template #default="scope">
                    <el-tag :type="scope.row.status === 'graded' ? 'success' : 'info'" effect="dark">
                      {{ scope.row.status === 'graded' ? '已发�? : '未发�? }}
                    </el-tag>
                  </template>
                </el-table-column>
                <el-table-column label="操作" min-width="200" fixed="right">
                  <template #default="scope">
                    <el-button link type="primary" @click="viewDetail(scope.row)">
                      <el-icon><Document /></el-icon> 详情
                    </el-button>
                    <el-button link type="primary" @click="handleAdjustScore(scope.row)">
                      <el-icon><Edit /></el-icon> 调整
                    </el-button>
                  </template>
                </el-table-column>
              </el-table>
              
              <div class="pagination-container">
                <el-pagination
                  v-model:current-page="scoreCurrentPage"
                  v-model:page-size="scorePageSize"
                  :page-sizes="[10, 20, 30, 50]"
                  layout="total, sizes, prev, pager, next, jumper"
                  :total="filteredScoreList.length"
                />
              </div>
          </el-card>
        </div>
      </el-tab-pane>

      <!-- ==================== 3. 成绩分析 ==================== -->
      <el-tab-pane label="成绩分析" name="analysis">
        <div class="analysis-pane">
            <div class="page-header">
                <h2 class="page-title">成绩分析</h2>
            </div>
            
            <el-card class="filter-card">
                <el-form :inline="true" :model="analysisFilterForm">
                    <el-form-item label="选择考试">
                        <el-select v-model="analysisFilterForm.examId" placeholder="请选择考试" @change="calculateAnalysisData">
                            <el-option v-for="item in examOptions" :key="item.id" :label="item.name" :value="item.id" />
                        </el-select>
                    </el-form-item>
                    <el-form-item>
                         <el-button type="primary" @click="calculateAnalysisData">刷新分析</el-button>
                    </el-form-item>
                </el-form>
            </el-card>

            <div class="analysis-content" v-if="analysisData.totalCount > 0">
                 <el-card class="exam-info-card">
                    <template #header>
                        <div class="card-header">
                        <span>{{ currentExam.name }} - 概览 (�?{{ analysisData.totalCount }} �?</span>
                        <el-tag type="success">实时统计</el-tag>
                        </div>
                    </template>
                    
                    <el-row :gutter="20" class="score-summary-row">
                        <el-col :span="6">
                            <el-card shadow="hover" class="summary-card">
                                <template #header><div class="card-header-small">平均�?/div></template>
                                <div class="summary-value text-primary">{{ analysisData.avgScore }}</div>
                            </el-card>
                        </el-col>
                        <el-col :span="6">
                            <el-card shadow="hover" class="summary-card">
                                <template #header><div class="card-header-small">最高分</div></template>
                                <div class="summary-value text-success">{{ analysisData.maxScore }}</div>
                            </el-card>
                        </el-col>
                        <el-col :span="6">
                            <el-card shadow="hover" class="summary-card">
                                <template #header><div class="card-header-small">最低分</div></template>
                                <div class="summary-value text-danger">{{ analysisData.minScore }}</div>
                            </el-card>
                        </el-col>
                        <el-col :span="6">
                            <el-card shadow="hover" class="summary-card">
                                <template #header><div class="card-header-small">及格�?/div></template>
                                <div class="summary-value text-warning">{{ analysisData.passRate }}%</div>
                            </el-card>
                        </el-col>
                    </el-row>
                 </el-card>

                 <div class="charts-container">
                    <el-row :gutter="20">
                        <el-col :span="12">
                        <el-card class="chart-card">
                            <template #header>
                            <div class="card-header"><span>分数段分�?/span></div>
                            </template>
                            <div class="chart-placeholder">
                            <div class="chart-mock">
                                <div class="chart-bar" :style="{height: analysisData.dist[4] + '%', backgroundColor: '#67C23A'}"><div class="chart-label">90-100<br>({{analysisData.distCount[4]}}�?</div></div>
                                <div class="chart-bar" :style="{height: analysisData.dist[3] + '%', backgroundColor: '#409EFF'}"><div class="chart-label">80-89<br>({{analysisData.distCount[3]}}�?</div></div>
                                <div class="chart-bar" :style="{height: analysisData.dist[2] + '%', backgroundColor: '#E6A23C'}"><div class="chart-label">70-79<br>({{analysisData.distCount[2]}}�?</div></div>
                                <div class="chart-bar" :style="{height: analysisData.dist[1] + '%', backgroundColor: '#F56C6C'}"><div class="chart-label">60-69<br>({{analysisData.distCount[1]}}�?</div></div>
                                <div class="chart-bar" :style="{height: analysisData.dist[0] + '%', backgroundColor: '#909399'}"><div class="chart-label">0-59<br>({{analysisData.distCount[0]}}�?</div></div>
                            </div>
                            </div>
                        </el-card>
                        </el-col>
                        <el-col :span="12">
                        <el-card class="chart-card">
                            <template #header>
                            <div class="card-header"><span>班级平均分对�?/span></div>
                            </template>
                            <div class="chart-placeholder">
                            <div class="chart-mock horizontal">
                                <div class="chart-row" v-for="cls in analysisData.classStats" :key="cls.name">
                                  <div class="chart-label">{{cls.name}}</div>
                                  <div class="chart-bar-h" :style="{width: cls.avg + '%', backgroundColor: '#409EFF'}">{{cls.avg}}</div>
                                </div>
                            </div>
                            </div>
                        </el-card>
                        </el-col>
                    </el-row>
                    
                    <el-row :gutter="20" style="margin-top: 20px;">
                        <el-col :span="24">
                           <el-card class="chart-card">
                            <template #header>
                            <div class="card-header"><span>知识点掌握情况分�?/span></div>
                            </template>
                             <el-table :data="analysisData.knowledgePoints" border>
                                <el-table-column prop="name" label="知识�? />
                                <el-table-column label="错误�? width="200">
                                   <template #default="scope">
                                      <el-progress :percentage="scope.row.errorRate" status="exception" />
                                   </template>
                                </el-table-column>
                                <el-table-column prop="suggestion" label="教学建议" />
                             </el-table>
                           </el-card>
                        </el-col>
                    </el-row>
                 </div>
            </div>
             <div class="no-exam-selected" v-else>
                <el-empty description="当前考试暂无数据或未选择考试" />
            </div>
        </div>
      </el-tab-pane>
    </el-tabs>

    <!-- 调整分数对话�?-->
    <el-dialog v-model="adjustScoreDialog.visible" title="调整分数" width="500px">
      <el-form :model="adjustScoreDialog.form" label-width="100px">
        <el-form-item label="学生">
          <span>{{ adjustScoreDialog.form.name }} ({{ adjustScoreDialog.form.studentId }})</span>
        </el-form-item>
        <el-form-item label="原始分数">
          <span>{{ adjustScoreDialog.form.originalScore }}</span>
        </el-form-item>
        <el-form-item label="调整后分�?>
          <el-input-number v-model="adjustScoreDialog.form.newScore" :min="0" :max="100" />
        </el-form-item>
        <el-form-item label="调整原因">
          <el-input v-model="adjustScoreDialog.form.reason" type="textarea" :rows="3" placeholder="请输入调整原�? />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="adjustScoreDialog.visible = false">取消</el-button>
          <el-button type="primary" @click="confirmAdjustScore">确认</el-button>
        </span>
      </template>
    </el-dialog>
    <!-- 试卷详情抽屉 -->
    <el-drawer
      v-model="detailVisible"
      title="试卷详情"
      size="50%"
      direction="rtl"
    >
      <div class="detail-drawer-content" v-if="detailStudent">
        <div class="detail-header">
           <h3>{{ detailStudent.name }} - {{ detailStudent.studentNo }}</h3>
           <div class="detail-score">
             总分�?span class="score-value">{{ detailStudent.score }}</span>
           </div>
        </div>
        <el-divider />
        <!-- Reuse paper view structure, simplified -->
        <div class="paper-preview">
            <div v-for="(question, index) in paperQuestions" :key="index" class="question-item-preview">
                <div class="q-title">
                    <span class="q-no">{{ index + 1 }}.</span>
                    <span class="q-text">{{ question.content }}</span>
                    <span class="q-score">({{ question.score }}�?</span>
                </div>
                <div class="q-student-answer">
                    <span class="label">学生答案�?/span>
                    <span class="value">{{ formatStudentAnswer(question) }}</span>
                </div>
                 <div class="q-grading">
                    <span class="label">得分�?/span>
                    <span class="value score-text">{{ question.givenScore }}</span>
                    <span class="label" style="margin-left: 15px">评语�?/span>
                    <span class="value">{{ question.comment || '�? }}</span>
                </div>
            </div>
        </div>
      </div>
    </el-drawer>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed, inject } from 'vue'
import { ArrowLeft, Edit, Upload, Check, Download, Search, Document } from '@element-plus/icons-vue'
import { useRouter, useRoute } from 'vue-router'
import { getScoreList, getExamStats, adjustScore, getStudentPaperDetail, submitGrading, getExamDetail, getExams, batchPublishScores, exportScores, importScores } from '@/api/teacher'

const router = useRouter()
const route = useRoute()
const showMessage = inject('showMessage')
const showConfirm = inject('showConfirm')

const activeTab = ref('grading')

// ================= 导航逻辑 =================
const showBackButton = computed(() => ['finished', 'monitor', 'paper'].includes(route.query.from))

const goBack = () => {
  const from = route.query.from
  if (from === 'finished') {
    router.push({
      name: 'TeacherExamManagement',
      query: {
        examStatusTab: 'finished',
        activeModule: 'exam'
      }
    })
  } else if (from === 'monitor') {
    router.push({
      name: 'TeacherExamManagement',
      query: {
        examStatusTab: 'ongoing',
        activeModule: 'exam'
      }
    })
  } else if (from === 'paper') {
    router.push({
      name: 'TeacherExamManagement',
      query: {
        activeModule: 'paper'
      }
    })
  } else {
    router.push({ name: 'TeacherExamManagement' })
  }
}

const isAllGraded = computed(() => {
  return allStudents.value.length > 0 && allStudents.value.every(s => s.status === 'graded')
})

const registerScores = () => {
  // In real app: Call API to change exam status to "Published" or "ScoresRegistered"
  showMessage('成绩登记成功！已同步至成绩管�?, 'success')
  activeTab.value = 'score'
}

// ================= 核心数据 (Shared Data) =================
const currentExam = ref({
  id: 1,
  name: '加载�?..',
  subject: '',
  examTime: '',
  duration: 0,
  totalScore: 0,
  studentCount: 0
})

const examOptions = ref([]) // To be loaded from API
const classOptions = ref([
  { id: 1, name: '计科1�? },
  { id: 2, name: '计科2�? },
  { id: 3, name: '软工1�? },
  { id: 4, name: '软工2�? }
])

// 统一的学生数据源
const allStudents = ref([])

const gradedCount = computed(() => allStudents.value.filter(s => s.status === 'graded').length)

// ================= 阅卷管理逻辑 =================
const isGrading = ref(false)
const currentGradingStudent = ref({})
const gradingFilterStatus = ref('')

// 映射 id -> studentId
const filteredGradingStudents = computed(() => {
  let list = allStudents.value
  if (gradingFilterStatus.value) {
    list = list.filter(student => student.status === gradingFilterStatus.value)
  }
  return list
})

const hasNextStudent = computed(() => {
  const currentIndex = allStudents.value.findIndex(s => s.studentId === currentGradingStudent.value.studentId)
  return currentIndex < allStudents.value.length - 1
})

// Paper Questions
const paperQuestions = ref([])

const questionTypes = [
  { label: '单选题', value: 'single_choice' },
  { label: '多选题', value: 'multiple_choice' },
  { label: '判断�?, value: 'true_false' },
  { label: '填空�?, value: 'fill_blank' },
  { label: '简答题', value: 'short_answer' },
  { label: '编程�?, value: 'programming' }
]

const getQuestionTypeLabel = (type) => {
  const found = questionTypes.find(item => item.value === type)
  return found ? found.label : type
}

const formatStudentAnswer = (question) => {
    if (Array.isArray(question.studentAnswer)) return question.studentAnswer.join(', ')
    return question.studentAnswer || '未作�?
}

const formatCorrectAnswer = (question) => {
    if (Array.isArray(question.correctAnswer)) return question.correctAnswer.join(', ')
    return question.correctAnswer
}

const startGrading = () => {
    // Find first ungraded student or first student
    const firstUngraded = allStudents.value.find(s => s.status === 'ungraded')
    if (firstUngraded) {
        handleGradeStudent(firstUngraded)
    } else if (allStudents.value.length > 0) {
        handleGradeStudent(allStudents.value[0])
    } else {
        showMessage('暂无学生数据', 'warning')
    }
}

const handleGradeStudent = async (row) => {
    try {
        currentGradingStudent.value = row
        // Fetch paper detail for this student
        const res = await getStudentPaperDetail(currentExam.value.id, row.studentId)
        if (res && res.questions) {
            paperQuestions.value = res.questions
        } else {
             paperQuestions.value = []
        }
        isGrading.value = true
    } catch (error) {
        console.error(error)
        showMessage('获取答卷失败', 'error')
    }
}

const handleNextStudent = () => {
    const currentIndex = allStudents.value.findIndex(s => s.studentId === currentGradingStudent.value.studentId)
    if (currentIndex < allStudents.value.length - 1) {
        handleGradeStudent(allStudents.value[currentIndex + 1])
    }
}

const finishGrading = () => {
    isGrading.value = false
    paperQuestions.value = []
    currentGradingStudent.value = {}
    loadData() // Refresh list
}

const handleSubmitGrading = async () => {
    // Collect scores
    const gradingData = {
        questions: paperQuestions.value.map(q => ({
            id: q.id,
            givenScore: q.givenScore,
            comment: q.comment
        }))
    }
    
    try {
        await submitGrading(currentExam.value.id, currentGradingStudent.value.studentId, gradingData)
        showMessage('提交成功', 'success')
        
        // Update local status
        const student = allStudents.value.find(s => s.studentId === currentGradingStudent.value.studentId)
        if (student) {
            student.status = 'graded'
            student.score = paperQuestions.value.reduce((sum, q) => sum + (q.givenScore || 0), 0)
        }
        
        if (hasNextStudent.value) {
            handleNextStudent()
        } else {
            showConfirm('已是最后一名学生，是否结束阅卷�?, '提示', 'success')
            .then(() => finishGrading())
            .catch(() => {})
        }
    } catch (error) {
        console.error(error)
        showMessage('提交失败', 'error')
    }
}

const handleStudentSelect = (row) => {
    // Just highlight or select, but if in grading mode, maybe switch to that student?
    if (isGrading.value) {
        handleGradeStudent(row)
    }
}

const saveCurrentGrading = () => {
    handleSubmitGrading()
}

// ================= 成绩查询逻辑 =================
const scoreFilterForm = reactive({
    classId: '',
    keyword: '',
    examId: ''
})
const scoreCurrentPage = ref(1)
const scorePageSize = ref(10)

const filteredScoreList = computed(() => {
    let list = allStudents.value
    if (scoreFilterForm.classId) {
        const cls = classOptions.value.find(c => c.id === scoreFilterForm.classId)
        if (cls) list = list.filter(s => s.className === cls.name)
    }
    if (scoreFilterForm.keyword) {
        list = list.filter(s => s.name?.includes(scoreFilterForm.keyword) || s.studentNo?.includes(scoreFilterForm.keyword))
    }
    return list
})

const paginatedScoreList = computed(() => {
    const start = (scoreCurrentPage.value - 1) * scorePageSize.value
    const end = start + scorePageSize.value
    return filteredScoreList.value.slice(start, end)
})

const handleScoreSearch = () => {
    scoreCurrentPage.value = 1
    loadData()
}

const handleScoreExamChange = () => {
    loadData()
}

const resetScoreFilter = () => {
    scoreFilterForm.classId = ''
    scoreFilterForm.keyword = ''
    scoreFilterForm.examId = ''
    handleScoreSearch()
}

const selectedStudents = ref([])
const handleSelectionChange = (val) => {
    selectedStudents.value = val
}

const batchPublish = (publish) => {
    if (selectedStudents.value.length === 0) {
        showMessage('请先选择需要操作的学生', 'warning')
        return
    }
    const ids = selectedStudents.value.map(s => s.scoreId).filter(Boolean)
    if (ids.length === 0) {
        showMessage('选择的数据缺少成绩ID，无法操�?, 'error')
        return
    }
    batchPublishScores(ids, publish)
      .then(res => {
          const affected = res?.affected ?? ids.length
          showMessage(`�?{publish ? '发布' : '撤回'} ${affected} 条成绩`, 'success')
          loadData()
      })
      .catch(() => {
          showMessage('批量操作失败', 'error')
      })
}

const handleImportScores = () => {
    const examId = scoreFilterForm.examId || currentExam.value.id
    if (!examId) {
        showMessage('请先选择考试', 'warning')
        return
    }
    const input = document.createElement('input')
    input.type = 'file'
    input.accept = '.xlsx,.xls,.csv'
    input.onchange = async () => {
        const file = input.files && input.files[0]
        if (!file) return
        try {
            const res = await importScores(examId, file)
            const imported = res?.imported ?? 0
            showMessage(`导入成功，记录数�?{imported}`, 'success')
            loadData()
        } catch (e) {
            console.error(e)
            showMessage('导入失败', 'error')
        }
    }
    input.click()
}

const exportResults = () => {
    const examId = scoreFilterForm.examId || currentExam.value.id
    if (!examId) {
        showMessage('请先选择考试', 'warning')
        return
    }
    exportScores(examId, 'excel')
      .then((blobData) => {
        const blob = new Blob([blobData], { type: 'application/octet-stream' })
        const url = URL.createObjectURL(blob)
        const a = document.createElement('a')
        a.href = url
        a.download = `scores_${examId}.xlsx`
        document.body.appendChild(a)
        a.click()
        document.body.removeChild(a)
        URL.revokeObjectURL(url)
      })
      .catch((e) => {
        console.error(e)
        showMessage('导出失败', 'error')
      })
}

const viewDetail = (row) => {
    viewStudentPaper(row)
}

const detailVisible = ref(false)
const detailStudent = ref(null)

const viewStudentPaper = async (row) => {
    detailStudent.value = row
    try {
        const res = await getStudentPaperDetail(currentExam.value.id, row.studentId)
        if (res && res.questions) {
            paperQuestions.value = res.questions
        } else {
             paperQuestions.value = []
        }
        detailVisible.value = true
    } catch (error) {
        console.error(error)
        showMessage('获取详情失败', 'error')
    }
}

const editGrading = (row) => {
    handleGradeStudent(row)
}

const getScoreClass = (score) => {
    if (score === null) return ''
    if (score < 60) return 'text-danger'
    if (score >= 90) return 'text-success'
    return 'text-primary'
}

const getRank = (row) => {
    const sorted = [...allStudents.value].sort((a, b) => (b.score || 0) - (a.score || 0))
    const index = sorted.findIndex(s => s.studentId === row.studentId)
    return index + 1
}

const adjustScoreDialog = reactive({
    visible: false,
    form: {
        studentId: '',
        name: '',
        originalScore: 0,
        newScore: 0,
        reason: ''
    }
})

const handleAdjustScore = (row) => {
    adjustScoreDialog.form = {
        studentId: row.studentId,
        name: row.name,
        originalScore: row.score,
        newScore: row.score,
        reason: ''
    }
    adjustScoreDialog.visible = true
}

const confirmAdjustScore = async () => {
    try {
        await adjustScore(currentExam.value.id, { 
            studentId: adjustScoreDialog.form.studentId,
            score: adjustScoreDialog.form.newScore,
            reason: adjustScoreDialog.form.reason
        })
        showMessage('成绩调整成功', 'success')
        adjustScoreDialog.visible = false
        loadData()
    } catch (error) {
        console.error(error)
        showMessage('调整失败', 'error')
    }
}

// ================= 成绩分析逻辑 =================
const analysisFilterForm = reactive({
    examId: ''
})
const analysisData = ref({
    totalCount: 0,
    avgScore: 0,
    maxScore: 0,
    minScore: 0,
    passRate: 0,
    dist: [0, 0, 0, 0, 0],
    distCount: [0, 0, 0, 0, 0],
    classStats: [],
    knowledgePoints: []
})

const calculateAnalysisData = async () => {
    if (!analysisFilterForm.examId) return
    
    try {
        const res = await getExamStats(analysisFilterForm.examId)
        if (res) {
            analysisData.value = res
        }
    } catch (error) {
        console.error(error)
    }
}

const loadData = async () => {
    // Load exam options
    try {
        const examsRes = await getExams({ size: 100 })
        if (examsRes && examsRes.list) {
            examOptions.value = examsRes.list
        }
    } catch (error) {
        console.error(error)
    }

    // Load exam info
    const examId = route.query.examId || analysisFilterForm.examId || scoreFilterForm.examId
    if (examId) {
        analysisFilterForm.examId = Number(examId)
        scoreFilterForm.examId = Number(examId)
        try {
             const examRes = await getExamDetail(examId)
             if (examRes) currentExam.value = examRes
             
             const scoresRes = await getScoreList({ examId: examId })
             if (scoresRes && scoresRes.list) {
                 allStudents.value = scoresRes.list
             } else {
                 allStudents.value = []
             }
             
             calculateAnalysisData()
             
        } catch (error) {
            console.error(error)
        }
    }
}

const handleTabChange = (tab) => {
    if (tab === 'analysis') {
        calculateAnalysisData()
    }
}

onMounted(() => {
  if (route.query.activeTab) {
    activeTab.value = route.query.activeTab
  }
  loadData()
})
</script>

<style scoped>
.score-management-container {
  padding: 20px;
}
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}
.page-title {
  margin: 0;
  font-size: 20px;
  font-weight: bold;
}
.score-summary-row {
  margin-bottom: 20px;
}
.summary-card {
  text-align: center;
}
.card-header-small {
  font-size: 14px;
  color: #909399;
}
.summary-value {
  font-size: 24px;
  font-weight: bold;
  margin-top: 10px;
}
.text-primary { color: var(--el-color-primary); }
.text-success { color: var(--el-color-success); }
.text-danger { color: var(--el-color-danger); }
.text-warning { color: var(--el-color-warning); }

.filter-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 15px;
}
.filter-title {
    font-weight: bold;
    font-size: 16px;
}
.detail-header {
    margin-bottom: 20px;
}
.detail-score {
    font-size: 18px;
    font-weight: bold;
    margin-top: 10px;
}
.score-value {
    color: var(--el-color-danger);
    font-size: 24px;
}
.question-item-preview {
    margin-bottom: 20px;
    padding: 15px;
    background-color: #f5f7fa;
    border-radius: 4px;
}
</style>
