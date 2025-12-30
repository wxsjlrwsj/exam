package org.example.chaoxingsystem.teacher.bank;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.usermodel.WorkbookFactory;
import org.example.chaoxingsystem.teacher.bank.dto.OptionItem;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.io.InputStream;
import java.util.*;

@Service
public class QuestionImportService {
  private static final Map<String, String> TYPE_CODE_MAP = buildTypeCodeMap();
  private static final Set<String> VALID_TYPE_CODES = Set.of("SINGLE", "MULTI", "TRUE_FALSE", "FILL", "SHORT", "PROGRAM");
  private static final int DEFAULT_DIFFICULTY = 3;
  private static final int MAX_ERRORS = 20;

  private final QuestionMapper questionMapper;
  private final QuestionTypeMapper typeMapper;
  private final ObjectMapper objectMapper = new ObjectMapper();

  public QuestionImportService(QuestionMapper questionMapper, QuestionTypeMapper typeMapper) {
    this.questionMapper = questionMapper;
    this.typeMapper = typeMapper;
  }

  public ImportResult importExcel(MultipartFile file, Long creatorId) {
    if (file == null || file.isEmpty()) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "file is empty");
    }
    try (InputStream inputStream = file.getInputStream(); Workbook workbook = WorkbookFactory.create(inputStream)) {
      Sheet sheet = workbook.getNumberOfSheets() > 0 ? workbook.getSheetAt(0) : null;
      if (sheet == null) {
        return new ImportResult(0, 0, 0, List.of("sheet not found"));
      }

      DataFormatter formatter = new DataFormatter();
      int headerRowIndex = sheet.getFirstRowNum();
      Row headerRow = sheet.getRow(headerRowIndex);
      Map<String, Integer> columnMap = buildColumnMap(headerRow, formatter);
      int firstDataRow = headerRowIndex + 1;

      int total = 0;
      int imported = 0;
      int failed = 0;
      List<String> errors = new ArrayList<>();

      for (int i = firstDataRow; i <= sheet.getLastRowNum(); i++) {
        Row row = sheet.getRow(i);
        if (row == null) {
          continue;
        }
        total++;
        try {
          Question question = parseRow(row, columnMap, formatter, creatorId);
          if (question == null) {
            failed++;
            if (errors.size() < MAX_ERRORS) {
              errors.add("row " + (i + 1) + ": empty content");
            }
            continue;
          }
          questionMapper.insert(question);
          imported++;
        } catch (Exception ex) {
          failed++;
          if (errors.size() < MAX_ERRORS) {
            errors.add("row " + (i + 1) + ": " + ex.getMessage());
          }
        }
      }

      return new ImportResult(total, imported, failed, errors);
    } catch (ResponseStatusException ex) {
      throw ex;
    } catch (Exception ex) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "failed to parse file");
    }
  }

  private Question parseRow(Row row, Map<String, Integer> columnMap, DataFormatter formatter, Long creatorId) throws Exception {
    String typeRaw = readCell(row, columnMap.get("type"), formatter);
    String subject = readCell(row, columnMap.get("subject"), formatter);
    String content = readCell(row, columnMap.get("content"), formatter);
    String difficultyRaw = readCell(row, columnMap.get("difficulty"), formatter);
    String optionsRaw = readCell(row, columnMap.get("options"), formatter);
    String answerRaw = readCell(row, columnMap.get("answer"), formatter);
    String analysis = readCell(row, columnMap.get("analysis"), formatter);
    String knowledgePoints = readCell(row, columnMap.get("knowledge"), formatter);
    String fileId = readCell(row, columnMap.get("fileId"), formatter);

    if (content == null || content.trim().isEmpty()) {
      return null;
    }
    if (subject == null || subject.trim().isEmpty()) {
      throw new IllegalArgumentException("subject is required");
    }

    String typeCode = normalizeTypeCode(typeRaw);
    if (typeCode == null || typeCode.isEmpty()) {
      throw new IllegalArgumentException("type is required");
    }
    QuestionType type = typeMapper.selectByCode(typeCode);
    if (type == null) {
      throw new IllegalArgumentException("unknown type: " + typeCode);
    }

    Integer difficulty = parseDifficulty(difficultyRaw);
    if (difficulty == null) {
      difficulty = DEFAULT_DIFFICULTY;
    }

    String optionsJson = normalizeOptionsJson(optionsRaw);
    String answerJson = normalizeAnswerJson(answerRaw, typeCode);
    if (answerJson == null || answerJson.isEmpty()) {
      throw new IllegalArgumentException("answer is required");
    }
    validateAnswerJson(answerJson);

    Question q = new Question();
    q.setTypeId(type.getTypeId());
    q.setContent(content);
    q.setOptions(optionsJson);
    q.setAnswer(answerJson);
    q.setAnalysis(analysis);
    q.setDifficulty(difficulty);
    q.setSubject(subject);
    q.setKnowledgePoints(knowledgePoints);
    q.setFileId(fileId);
    q.setCreatorId(creatorId);
    q.setStatus(1);
    return q;
  }

  private String readCell(Row row, Integer index, DataFormatter formatter) {
    if (row == null || index == null) {
      return null;
    }
    Cell cell = row.getCell(index);
    if (cell == null) {
      return null;
    }
    String value = formatter.formatCellValue(cell);
    return value != null ? value.trim() : null;
  }

  private Integer parseDifficulty(String raw) {
    if (raw == null || raw.isEmpty()) {
      return null;
    }
    try {
      int value = (int) Math.round(Double.parseDouble(raw));
      if (value <= 0) return null;
      return value;
    } catch (NumberFormatException ex) {
      return null;
    }
  }

  private String normalizeTypeCode(String raw) {
    if (raw == null) {
      return null;
    }
    String value = raw.trim();
    if (value.isEmpty()) {
      return null;
    }
    String mapped = TYPE_CODE_MAP.get(value);
    if (mapped != null) {
      return mapped;
    }
    String upper = value.toUpperCase(Locale.ROOT);
    if (VALID_TYPE_CODES.contains(upper)) {
      return upper;
    }
    return TYPE_CODE_MAP.get(upper);
  }

  private String normalizeOptionsJson(String raw) throws Exception {
    if (raw == null || raw.trim().isEmpty()) {
      return null;
    }
    String trimmed = raw.trim();
    if (looksLikeJson(trimmed)) {
      validateJson(trimmed);
      return trimmed;
    }
    List<OptionItem> options = parseOptions(trimmed);
    if (options.isEmpty()) {
      return null;
    }
    return objectMapper.writeValueAsString(options);
  }

  private List<OptionItem> parseOptions(String raw) {
    List<OptionItem> list = new ArrayList<>();
    String[] parts = raw.split("[;|\\n]+");
    int autoIndex = 0;
    String[] autoKeys = {"A", "B", "C", "D", "E", "F", "G", "H"};
    for (String part : parts) {
      String piece = part == null ? "" : part.trim();
      if (piece.isEmpty()) {
        continue;
      }
      String key = null;
      String value = null;
      int sepIndex = indexOfOptionSeparator(piece);
      if (sepIndex > 0) {
        key = piece.substring(0, sepIndex).trim();
        value = piece.substring(sepIndex + 1).trim();
      } else if (piece.length() >= 2 && Character.isLetter(piece.charAt(0))) {
        key = String.valueOf(Character.toUpperCase(piece.charAt(0)));
        value = piece.substring(1).replaceFirst("^[\\.\\)\\u3001\\uFF1A\\u003A\\uFF1B\\s]+", "").trim();
      } else {
        key = autoIndex < autoKeys.length ? autoKeys[autoIndex] : String.valueOf((char) ('A' + autoIndex));
        value = piece;
      }
      autoIndex++;
      if (value != null && !value.isEmpty()) {
        OptionItem item = new OptionItem();
        item.setKey(key);
        item.setValue(value);
        list.add(item);
      }
    }
    return list;
  }

  private int indexOfOptionSeparator(String piece) {
    int idx = piece.indexOf('=');
    if (idx > 0) return idx;
    idx = piece.indexOf(':');
    if (idx > 0) return idx;
    idx = piece.indexOf('\uFF1A');
    if (idx > 0) return idx;
    return -1;
  }

  private String normalizeAnswerJson(String raw, String typeCode) throws Exception {
    if (raw == null || raw.trim().isEmpty()) {
      return null;
    }
    String trimmed = raw.trim();
    if (looksLikeJson(trimmed)) {
      validateJson(trimmed);
      return trimmed;
    }
    if ("MULTI".equalsIgnoreCase(typeCode)) {
      List<String> answers = splitAnswers(trimmed);
      return objectMapper.writeValueAsString(answers);
    }
    if ("TRUE_FALSE".equalsIgnoreCase(typeCode)) {
      Boolean value = normalizeBoolean(trimmed);
      if (value != null) {
        return objectMapper.writeValueAsString(value);
      }
    }
    return objectMapper.writeValueAsString(trimmed);
  }

  private List<String> splitAnswers(String raw) {
    String normalized = raw.replace('\uFF0C', ',').replace('\u3001', ',');
    String[] parts = normalized.split("[,;|/\\s]+");
    List<String> list = new ArrayList<>();
    for (String part : parts) {
      String value = part.trim();
      if (!value.isEmpty()) {
        list.add(value);
      }
    }
    return list;
  }

  private Boolean normalizeBoolean(String raw) {
    String value = raw.trim().toLowerCase(Locale.ROOT);
    if (value.equals("true") || value.equals("t") || value.equals("1") || value.equals("\u5bf9") || value.equals("\u6b63\u786e")) {
      return Boolean.TRUE;
    }
    if (value.equals("false") || value.equals("f") || value.equals("0") || value.equals("\u9519") || value.equals("\u9519\u8bef")) {
      return Boolean.FALSE;
    }
    return null;
  }

  private boolean looksLikeJson(String raw) {
    return raw.startsWith("[") || raw.startsWith("{") || raw.startsWith("\"");
  }

  private void validateJson(String raw) throws Exception {
    objectMapper.readTree(raw);
  }

  private void validateAnswerJson(String answerJson) throws Exception {
    JsonNode node = objectMapper.readTree(answerJson);
    if (node == null || node.isNull()) {
      throw new IllegalArgumentException("invalid answer json");
    }
  }

  private static Map<String, Integer> buildColumnMap(Row headerRow, DataFormatter formatter) {
    Map<String, Integer> map = new HashMap<>();
    if (headerRow != null) {
      for (Cell cell : headerRow) {
        String header = formatter.formatCellValue(cell);
        if (header == null) continue;
        String key = normalizeHeader(header);
        if (key.isEmpty()) continue;
        if (isTypeHeader(key)) map.put("type", cell.getColumnIndex());
        else if (isSubjectHeader(key)) map.put("subject", cell.getColumnIndex());
        else if (isContentHeader(key)) map.put("content", cell.getColumnIndex());
        else if (isDifficultyHeader(key)) map.put("difficulty", cell.getColumnIndex());
        else if (isOptionsHeader(key)) map.put("options", cell.getColumnIndex());
        else if (isAnswerHeader(key)) map.put("answer", cell.getColumnIndex());
        else if (isAnalysisHeader(key)) map.put("analysis", cell.getColumnIndex());
        else if (isKnowledgeHeader(key)) map.put("knowledge", cell.getColumnIndex());
        else if (isFileIdHeader(key)) map.put("fileId", cell.getColumnIndex());
      }
    }

    map.putIfAbsent("type", 0);
    map.putIfAbsent("subject", 1);
    map.putIfAbsent("content", 2);
    map.putIfAbsent("difficulty", 3);
    map.putIfAbsent("options", 4);
    map.putIfAbsent("answer", 5);
    map.putIfAbsent("analysis", 6);
    map.putIfAbsent("knowledge", 7);
    map.putIfAbsent("fileId", 8);
    return map;
  }

  private static String normalizeHeader(String header) {
    String value = header.replace("\uFEFF", "").trim().toLowerCase(Locale.ROOT);
    return value.replace(" ", "").replace("_", "");
  }

  private static boolean isTypeHeader(String key) {
    return key.equals("type") || key.equals("typecode") || key.equals("\u9898\u578b") || key.equals("\u9898\u578b\u7f16\u7801") || key.equals("\u9898\u578b\u4ee3\u7801");
  }

  private static boolean isSubjectHeader(String key) {
    return key.equals("subject") || key.equals("\u5b66\u79d1") || key.equals("\u79d1\u76ee");
  }

  private static boolean isContentHeader(String key) {
    return key.equals("content") || key.equals("\u9898\u76ee") || key.equals("\u9898\u76ee\u5185\u5bb9") || key.equals("\u9898\u5e72");
  }

  private static boolean isDifficultyHeader(String key) {
    return key.equals("difficulty") || key.equals("\u96be\u5ea6");
  }

  private static boolean isOptionsHeader(String key) {
    return key.equals("options") || key.equals("\u9009\u9879") || key.equals("\u9009\u9879\u5217\u8868");
  }

  private static boolean isAnswerHeader(String key) {
    return key.equals("answer") || key.equals("\u7b54\u6848") || key.equals("\u6b63\u786e\u7b54\u6848");
  }

  private static boolean isAnalysisHeader(String key) {
    return key.equals("analysis") || key.equals("\u89e3\u6790");
  }

  private static boolean isKnowledgeHeader(String key) {
    return key.equals("knowledge") || key.equals("\u77e5\u8bc6\u70b9") || key.equals("\u77e5\u8bc6\u70b9\u5217\u8868");
  }

  private static boolean isFileIdHeader(String key) {
    return key.equals("fileid") || key.equals("\u9644\u4ef6id") || key.equals("\u6587\u4ef6id");
  }

  private static Map<String, String> buildTypeCodeMap() {
    Map<String, String> map = new HashMap<>();
    map.put("single_choice", "SINGLE");
    map.put("multiple_choice", "MULTI");
    map.put("true_false", "TRUE_FALSE");
    map.put("fill_blank", "FILL");
    map.put("short_answer", "SHORT");
    map.put("programming", "PROGRAM");
    map.put("SINGLE_CHOICE", "SINGLE");
    map.put("MULTIPLE_CHOICE", "MULTI");
    map.put("TRUEFALSE", "TRUE_FALSE");
    map.put("\u5355\u9009\u9898", "SINGLE");
    map.put("\u591a\u9009\u9898", "MULTI");
    map.put("\u5224\u65ad\u9898", "TRUE_FALSE");
    map.put("\u586b\u7a7a\u9898", "FILL");
    map.put("\u7b80\u7b54\u9898", "SHORT");
    map.put("\u7f16\u7a0b\u9898", "PROGRAM");
    return map;
  }

  public static class ImportResult {
    public final int total;
    public final int imported;
    public final int failed;
    public final List<String> errors;

    public ImportResult(int total, int imported, int failed, List<String> errors) {
      this.total = total;
      this.imported = imported;
      this.failed = failed;
      this.errors = errors == null ? List.of() : errors;
    }
  }
}
