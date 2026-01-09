package org.example.chaoxingsystem.face;

import org.example.chaoxingsystem.student.StudentProfileService;
import org.example.chaoxingsystem.user.dto.ApiResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/face")
@CrossOrigin(origins = "*")
public class FaceController {

    private final FaceRecognitionService faceRecognitionService;
    private final StudentProfileService studentProfileService;

    public FaceController(FaceRecognitionService faceRecognitionService, 
                         StudentProfileService studentProfileService) {
        this.faceRecognitionService = faceRecognitionService;
        this.studentProfileService = studentProfileService;
    }

    @PostMapping("/upload-photo")
    public ResponseEntity<ApiResponse<Void>> uploadPhoto(
            @RequestBody Map<String, String> request,
            Authentication authentication) {
        String username = authentication.getName();
        String base64Photo = request.get("photo");
        
        if (base64Photo == null || base64Photo.isEmpty()) {
            return ResponseEntity.ok(ApiResponse.error(400, "照片数据不能为空"));
        }

        if (base64Photo.startsWith("data:image")) {
            int commaIndex = base64Photo.indexOf(",");
            if (commaIndex != -1) {
                base64Photo = base64Photo.substring(commaIndex + 1);
            }
        }

        try {
            studentProfileService.updateFacePhoto(username, base64Photo);
            return ResponseEntity.ok(ApiResponse.success("照片上传成功", null));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error(500, "照片上传失败，请稍后重试"));
        }
    }

    @PostMapping("/verify")
    public ResponseEntity<ApiResponse<Map<String, Object>>> verifyFace(
            @RequestBody Map<String, String> request,
            Authentication authentication) {
        try {
            String username = authentication.getName();
            
            String capturedPhoto = request.get("photo");

            if (capturedPhoto == null || capturedPhoto.isEmpty()) {
                return ResponseEntity.ok(ApiResponse.error(400, "照片数据不能为空"));
            }

            if (capturedPhoto.startsWith("data:image")) {
                int commaIndex = capturedPhoto.indexOf(",");
                if (commaIndex != -1) {
                    capturedPhoto = capturedPhoto.substring(commaIndex + 1);
                }
            }

            String storedPhoto = studentProfileService.getFacePhoto(username);
            
            if (storedPhoto == null || storedPhoto.isEmpty()) {
                return ResponseEntity.ok(ApiResponse.error(404, "未找到存储的人脸照片，请先上传照片"));
            }

            double score = faceRecognitionService.compareFaces(capturedPhoto, storedPhoto);
            boolean verified = faceRecognitionService.isSamePerson(score);

            Map<String, Object> result = Map.of(
                "score", score,
                "verified", verified,
                "threshold", faceRecognitionService.getThreshold()
            );

            return ResponseEntity.ok(ApiResponse.success(
                verified ? "人脸验证通过" : "人脸验证失败，相似度不足", 
                result
            ));
        } catch (FaceRecognitionService.FaceRecognitionException e) {
            return ResponseEntity.ok(ApiResponse.error(e.getCode(), e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.ok(ApiResponse.error(400, e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error(500, "人脸验证失败，请稍后重试"));
        }
    }

    @GetMapping("/has-photo")
    public ResponseEntity<ApiResponse<Map<String, Object>>> hasPhoto(Authentication authentication) {
        String username = authentication.getName();
        try {
            String photo = studentProfileService.getFacePhoto(username);
            boolean hasPhoto = photo != null && !photo.isEmpty();
            
            Map<String, Object> result = new java.util.HashMap<>();
            result.put("hasPhoto", hasPhoto);
            if (hasPhoto) {
                result.put("photo", photo);
            }
            
            return ResponseEntity.ok(ApiResponse.success("查询成功", result));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error(500, "查询失败，请稍后重试"));
        }
    }
}
