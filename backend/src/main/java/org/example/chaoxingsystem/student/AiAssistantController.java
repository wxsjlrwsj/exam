package org.example.chaoxingsystem.student;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.Map;

/**
 * AI辅助解题控制器
 * 提供与DeepSeek AI交互的接口，支持流式输出
 */
@RestController
@RequestMapping("/api/student/ai")
public class AiAssistantController {

    @Autowired
    private AiAssistantService aiAssistantService;

    /**
     * 流式聊天接口 - 用于AI辅助解题
     * @param request 包含question(题目内容)和message(用户问题)
     * @return SSE流式响应
     */
    @PostMapping(value = "/chat/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter chatStream(@RequestBody Map<String, String> request) {
        String question = request.get("question");
        String message = request.get("message");
        String history = request.get("history");
        
        return aiAssistantService.chatStream(question, message, history);
    }

    /**
     * 非流式聊天接口 - 备用
     * @param request 包含question和message
     * @return AI回复
     */
    @PostMapping("/chat")
    public Map<String, Object> chat(@RequestBody Map<String, String> request) {
        String question = request.get("question");
        String message = request.get("message");
        String history = request.get("history");
        
        String reply = aiAssistantService.chat(question, message, history);
        return Map.of("code", 200, "data", Map.of("reply", reply));
    }
}
