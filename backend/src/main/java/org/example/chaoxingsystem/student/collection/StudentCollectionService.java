package org.example.chaoxingsystem.student.collection;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class StudentCollectionService {
    private final StudentCollectionMapper collectionMapper;
    private final CollectionQuestionMapper collectionQuestionMapper;

    public StudentCollectionService(StudentCollectionMapper collectionMapper,
                                    CollectionQuestionMapper collectionQuestionMapper) {
        this.collectionMapper = collectionMapper;
        this.collectionQuestionMapper = collectionQuestionMapper;
    }

    public List<StudentCollection> getByStudentId(Long studentId) {
        return collectionMapper.selectByStudentId(studentId);
    }

    public StudentCollection getById(Long id) {
        return collectionMapper.selectById(id);
    }

    @Transactional
    public Long create(Long studentId, String name) {
        StudentCollection collection = new StudentCollection();
        collection.setStudentId(studentId);
        collection.setName(name);
        collection.setIsDefault(false);
        collection.setQuestionCount(0);
        collectionMapper.insert(collection);
        return collection.getId();
    }

    public void update(Long id, String name) {
        StudentCollection collection = new StudentCollection();
        collection.setId(id);
        collection.setName(name);
        collectionMapper.updateById(collection);
    }

    @Transactional
    public void delete(Long id) {
        collectionQuestionMapper.deleteByCollection(id);
        collectionMapper.deleteById(id);
    }

    public Map<String, Object> getQuestions(Long collectionId, String type, String subject, int page, int size) {
        int offset = (page - 1) * size;
        String serverType = toServerTypeCode(type);
        long total = collectionQuestionMapper.countByCollection(collectionId, serverType, subject);
        List<Map<String, Object>> list = collectionQuestionMapper.selectQuestionsByCollection(
            collectionId, serverType, subject, offset, size);
        for (Map<String, Object> item : list) {
            Object code = item.get("type_code");
            String uiType = toUiType(code == null ? null : String.valueOf(code));
            item.remove("type_code");
            item.put("type", uiType);
        }
        
        Map<String, Object> result = new HashMap<>();
        result.put("list", list);
        result.put("total", total);
        return result;
    }

    @Transactional
    public void addQuestion(Long collectionId, Long questionId) {
        if (collectionQuestionMapper.exists(collectionId, questionId) > 0) {
            return; // Already exists
        }
        collectionQuestionMapper.insert(collectionId, questionId);
        collectionMapper.incrementQuestionCount(collectionId);
    }

    @Transactional
    public void removeQuestion(Long collectionId, Long questionId) {
        collectionQuestionMapper.delete(collectionId, questionId);
        collectionMapper.decrementQuestionCount(collectionId);
    }

    @Transactional
    public void ensureDefaultCollection(Long studentId) {
        List<StudentCollection> collections = collectionMapper.selectByStudentId(studentId);
        boolean hasDefault = collections.stream().anyMatch(c -> c.getIsDefault() != null && c.getIsDefault());
        
        if (!hasDefault) {
            StudentCollection defaultCollection = new StudentCollection();
            defaultCollection.setStudentId(studentId);
            defaultCollection.setName("我的错题集");
            defaultCollection.setIsDefault(true);
            defaultCollection.setQuestionCount(0);
            collectionMapper.insert(defaultCollection);
        }
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
    
    private String toUiType(String code) {
        if (code == null || code.isEmpty()) return "";
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
}

