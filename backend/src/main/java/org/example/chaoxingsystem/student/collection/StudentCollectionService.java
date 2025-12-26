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
    public Long create(Long studentId, String name, String description) {
        StudentCollection collection = new StudentCollection();
        collection.setStudentId(studentId);
        collection.setName(name);
        collection.setDescription(description);
        collection.setIsDefault(false);
        collection.setQuestionCount(0);
        collectionMapper.insert(collection);
        return collection.getId();
    }

    public void update(Long id, String name, String description) {
        StudentCollection collection = new StudentCollection();
        collection.setId(id);
        collection.setName(name);
        collection.setDescription(description);
        collectionMapper.updateById(collection);
    }

    @Transactional
    public void delete(Long id) {
        collectionQuestionMapper.deleteByCollection(id);
        collectionMapper.deleteById(id);
    }

    public Map<String, Object> getQuestions(Long collectionId, String type, String subject, int page, int size) {
        int offset = (page - 1) * size;
        long total = collectionQuestionMapper.countByCollection(collectionId, type, subject);
        List<Map<String, Object>> list = collectionQuestionMapper.selectQuestionsByCollection(
            collectionId, type, subject, offset, size);
        
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
            defaultCollection.setDescription("系统自动创建的错题集");
            defaultCollection.setIsDefault(true);
            defaultCollection.setQuestionCount(0);
            collectionMapper.insert(defaultCollection);
        }
    }
}

