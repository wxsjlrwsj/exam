package org.example.chaoxingsystem.student.errorbook;

import java.time.LocalDateTime;

/**
 * 错题本实体类
 */
public class ErrorBook {
    private Long id;
    private Long studentId;
    private Long questionId;
    private Long examId;
    private String wrongAnswer;
    private Integer wrongCount;
    private Integer mastered;
    private LocalDateTime lastWrongTime;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getStudentId() {
        return studentId;
    }

    public void setStudentId(Long studentId) {
        this.studentId = studentId;
    }

    public Long getQuestionId() {
        return questionId;
    }

    public void setQuestionId(Long questionId) {
        this.questionId = questionId;
    }

    public Long getExamId() {
        return examId;
    }

    public void setExamId(Long examId) {
        this.examId = examId;
    }

    public String getWrongAnswer() {
        return wrongAnswer;
    }

    public void setWrongAnswer(String wrongAnswer) {
        this.wrongAnswer = wrongAnswer;
    }

    public Integer getWrongCount() {
        return wrongCount;
    }

    public void setWrongCount(Integer wrongCount) {
        this.wrongCount = wrongCount;
    }

    public Integer getMastered() {
        return mastered;
    }

    public void setMastered(Integer mastered) {
        this.mastered = mastered;
    }

    public LocalDateTime getLastWrongTime() {
        return lastWrongTime;
    }

    public void setLastWrongTime(LocalDateTime lastWrongTime) {
        this.lastWrongTime = lastWrongTime;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}

