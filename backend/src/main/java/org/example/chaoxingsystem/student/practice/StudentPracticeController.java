package org.example.chaoxingsystem.student.practice;

import org.example.chaoxingsystem.teacher.bank.Question;
import org.example.chaoxingsystem.teacher.bank.QuestionMapper;
import org.example.chaoxingsystem.teacher.bank.QuestionService;
import org.example.chaoxingsystem.teacher.bank.QuestionType;
import org.example.chaoxingsystem.teacher.bank.QuestionTypeMapper;
import org.example.chaoxingsystem.user.dto.ApiResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.ArrayList;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/student/practice")
public class StudentPracticeController {
    private final QuestionService questionService;
    private final QuestionMapper questionMapper;
    private final QuestionTypeMapper typeMapper;

    public StudentPracticeController(QuestionService questionService, QuestionMapper questionMapper, QuestionTypeMapper typeMapper) {
        this.questionService = questionService;
        this.questionMapper = questionMapper;
        this.typeMapper = typeMapper;
    }

    @GetMapping("/questions")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> listQuestions(
        @RequestParam(required = false) String type,
        @RequestParam(required = false) String subject,
        @RequestParam(required = false) String difficulty,
        @RequestParam(required = false) String keyword,
        @RequestParam(defaultValue = "1") int page,
        @RequestParam(defaultValue = "10") int size
    ) {
        String serverType = toServerTypeCode(type);
        Integer diff = null;
        if (difficulty != null && !difficulty.isEmpty()) {
            try {
                int d = Integer.parseInt(difficulty);
                if (d > 0) diff = d;
            } catch (Exception ignored) {}
        }
        long total = questionService.count(serverType, keyword, diff, subject);
        List<Question> list = questionService.page(serverType, keyword, diff, subject, page, size);
        List<QuestionType> types = typeMapper.selectActive();
        Map<Integer, String> idToCode = types.stream().collect(Collectors.toMap(QuestionType::getTypeId, QuestionType::getTypeCode));
        List<Map<String, Object>> viewList = new ArrayList<>();
        for (Question q : list) {
            Map<String, Object> item = new HashMap<>();
            item.put("id", q.getId());
            String serverCode = idToCode.getOrDefault(q.getTypeId(), "");
            String uiType = toUiType(serverCode);
            if (uiType == null || uiType.isEmpty()) {
                uiType = toUiTypeById(q.getTypeId());
            }
            item.put("type", uiType);
            item.put("subject", q.getSubject());
            item.put("content", q.getContent());
            item.put("options", q.getOptions());
            item.put("answer", q.getAnswer());
            item.put("analysis", q.getAnalysis());
            item.put("difficulty", q.getDifficulty());
            viewList.add(item);
        }

        Map<String, Object> result = new HashMap<>();
        result.put("list", viewList);
        result.put("total", total);
        return ResponseEntity.ok(ApiResponse.success("获取成功", result));
    }

    @GetMapping("/questions/{id}")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getQuestion(@PathVariable Long id) {
        Question question = questionMapper.selectById(id);
        if (question == null) {
            return ResponseEntity.badRequest().body(ApiResponse.error(404, "题目不存在"));
        }
        return ResponseEntity.ok(ApiResponse.success("获取成功", Map.of("question", question)));
    }

    private String toUiType(String code) {
        if (code == null) return "";
        return switch (code) {
            case "SINGLE" -> "single_choice";
            case "MULTI" -> "multiple_choice";
            case "TRUE_FALSE" -> "true_false";
            case "FILL" -> "fill_blank";
            case "SHORT" -> "short_answer";
            case "PROGRAM" -> "programming";
            default -> code;
        };
    }

    private String toUiTypeById(Integer typeId) {
        if (typeId == null) return "";
        return switch (typeId) {
            case 1 -> "single_choice";
            case 2 -> "multiple_choice";
            case 3 -> "true_false";
            case 4 -> "fill_blank";
            case 5 -> "short_answer";
            default -> "";
        };
    }

    private String toServerTypeCode(String ui) {
        if (ui == null || ui.isEmpty()) return ui;
        return switch (ui) {
            case "single_choice" -> "SINGLE";
            case "multiple_choice" -> "MULTI";
            case "true_false" -> "TRUE_FALSE";
            case "fill_blank" -> "FILL";
            case "short_answer" -> "SHORT";
            case "programming" -> "PROGRAM";
            default -> ui;
        };
    }
}

