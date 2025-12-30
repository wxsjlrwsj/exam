package org.example.chaoxingsystem.face;

import org.example.chaoxingsystem.student.StudentProfileService;
import org.example.chaoxingsystem.user.dto.ApiResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
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
            return ResponseEntity.badRequest()
                .body(ApiResponse.error(400, "照片数据不能为空"));
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
            return ResponseEntity.status(500)
                .body(ApiResponse.error(500, "照片上传失败: " + e.getMessage()));
        }
    }

    @PostMapping("/verify")
    public ResponseEntity<ApiResponse<Map<String, Object>>> verifyFace(
            @RequestBody Map<String, String> request,
            Authentication authentication) {
        try {
            System.out.println("[FaceController] Verify request received");
            String username = authentication.getName();
            System.out.println("[FaceController] Username: " + username);
            
            String capturedPhoto = request.get("photo");
            System.out.println("[FaceController] Captured photo length: " + (capturedPhoto != null ? capturedPhoto.length() : 0));

            if (capturedPhoto == null || capturedPhoto.isEmpty()) {
                return ResponseEntity.badRequest()
                    .body(ApiResponse.error(400, "照片数据不能为空"));
            }

            if (capturedPhoto.startsWith("data:image")) {
                int commaIndex = capturedPhoto.indexOf(",");
                if (commaIndex != -1) {
                    capturedPhoto = capturedPhoto.substring(commaIndex + 1);
                }
            }

            System.out.println("[FaceController] Getting stored photo...");
            String storedPhoto = studentProfileService.getFacePhoto(username);
            System.out.println("[FaceController] Stored photo length: " + (storedPhoto != null ? storedPhoto.length() : 0));
            
            if (storedPhoto == null || storedPhoto.isEmpty()) {
                return ResponseEntity.status(404)
                    .body(ApiResponse.error(404, "未找到存储的人脸照片，请先上传照片"));
            }

            System.out.println("[FaceController] Calling compareFaces...");
            double score = faceRecognitionService.compareFaces(capturedPhoto, storedPhoto);
            boolean verified = faceRecognitionService.isSamePerson(score);
            System.out.println("[FaceController] Score: " + score + ", Verified: " + verified);

            Map<String, Object> result = Map.of(
                "score", score,
                "verified", verified,
                "threshold", faceRecognitionService.getThreshold()
            );

            return ResponseEntity.ok(ApiResponse.success(
                verified ? "人脸验证通过" : "人脸验证失败，相似度不足", 
                result
            ));
        } catch (Exception e) {
            System.err.println("[FaceController] Exception: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(500)
                .body(ApiResponse.error(500, "人脸验证失败: " + e.getMessage()));
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
            return ResponseEntity.status(500)
                .body(ApiResponse.error(500, "查询失败: " + e.getMessage()));
        }
    }
}
