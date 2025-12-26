package org.example.chaoxingsystem.student.error;

import java.time.LocalDateTime;

public class StudentError {
    private Long id;
    private Long studentId;
    private Long questionId;
    private Long examId;
    private Integer errorCount;
    private LocalDateTime firstErrorTime;
    private LocalDateTime lastErrorTime;
    private Boolean isSolved;
    private LocalDateTime solveTime;
    private String studentAnswer;
    private String correctAnswer;

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public Long getStudentId() { return studentId; }
    public void setStudentId(Long studentId) { this.studentId = studentId; }
    
    public Long getQuestionId() { return questionId; }
    public void setQuestionId(Long questionId) { this.questionId = questionId; }
    
    public Long getExamId() { return examId; }
    public void setExamId(Long examId) { this.examId = examId; }
    
    public Integer getErrorCount() { return errorCount; }
    public void setErrorCount(Integer errorCount) { this.errorCount = errorCount; }
    
    public LocalDateTime getFirstErrorTime() { return firstErrorTime; }
    public void setFirstErrorTime(LocalDateTime firstErrorTime) { this.firstErrorTime = firstErrorTime; }
    
    public LocalDateTime getLastErrorTime() { return lastErrorTime; }
    public void setLastErrorTime(LocalDateTime lastErrorTime) { this.lastErrorTime = lastErrorTime; }
    
    public Boolean getIsSolved() { return isSolved; }
    public void setIsSolved(Boolean isSolved) { this.isSolved = isSolved; }
    
    public LocalDateTime getSolveTime() { return solveTime; }
    public void setSolveTime(LocalDateTime solveTime) { this.solveTime = solveTime; }
    
    public String getStudentAnswer() { return studentAnswer; }
    public void setStudentAnswer(String studentAnswer) { this.studentAnswer = studentAnswer; }
    
    public String getCorrectAnswer() { return correctAnswer; }
    public void setCorrectAnswer(String correctAnswer) { this.correctAnswer = correctAnswer; }
}

