package org.example.chaoxingsystem.face;

import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
public class FaceRecognitionService {

    @Value("${baidu.face.api-key}")
    private String apiKey;

    @Value("${baidu.face.secret-key}")
    private String secretKey;

    @Value("${baidu.face.threshold}")
    private double threshold;

    public double compareFaces(String base64Image1, String base64Image2) {
        try {
            System.out.println("[FaceRecognition] Starting face comparison");
            System.out.println("[FaceRecognition] Image1 length: " + (base64Image1 != null ? base64Image1.length() : 0));
            System.out.println("[FaceRecognition] Image2 length: " + (base64Image2 != null ? base64Image2.length() : 0));
            
            // 获取 access token
            String accessToken = getAccessToken(apiKey, secretKey);
            System.out.println("[FaceRecognition] Got access token");
            
            // 调用人脸比对 API
            double score = faceMatchScore(accessToken, base64Image1, base64Image2);
            System.out.println("[FaceRecognition] Match score: " + score);
            
            return score;
        } catch (Exception e) {
            System.err.println("[FaceRecognition] Exception: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("人脸识别失败: " + e.getMessage(), e);
        }
    }

    private String getAccessToken(String apiKey, String secretKey) throws IOException {
        String url = "https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials"
                + "&client_id=" + URLEncoder.encode(apiKey, "UTF-8")
                + "&client_secret=" + URLEncoder.encode(secretKey, "UTF-8");
        String json = httpGet(url);
        Pattern p = Pattern.compile("\"access_token\"\\s*:\\s*\"([^\"]+)\"");
        Matcher m = p.matcher(json);
        if (m.find()) {
            return m.group(1);
        }
        throw new IllegalStateException("无法获取access_token: " + json);
    }

    private double faceMatchScore(String accessToken, String base64Img1, String base64Img2) throws IOException {
        // 先尝试 V2 API
        String endpointV2 = "https://aip.baidubce.com/rest/2.0/face/v2/match?access_token=" + URLEncoder.encode(accessToken, "UTF-8");
        String images = URLEncoder.encode(base64Img1 + "," + base64Img2, "UTF-8");
        String bodyV2 = "images=" + images + "&ext_fields=qualities&image_liveness=faceliveness,faceliveness";
        String respV2 = httpPost(endpointV2, bodyV2);
        
        System.out.println("[FaceRecognition] V2 API Response: " + respV2.substring(0, Math.min(200, respV2.length())));
        
        Pattern pScore = Pattern.compile("\"score\"\\s*:\\s*(\\d+(?:\\.\\d+)?)");
        Matcher mScore = pScore.matcher(respV2);
        if (mScore.find()) {
            return Double.parseDouble(mScore.group(1));
        }
        
        // 检查是否需要回退到 V3 API
        Pattern pErr = Pattern.compile("\"error_code\"\\s*:\\s*(\\d+)");
        Matcher mErr = pErr.matcher(respV2);
        if (mErr.find()) {
            int code = Integer.parseInt(mErr.group(1));
            System.out.println("[FaceRecognition] V2 API error code: " + code + ", trying V3 API");
            
            if (code == 6 || code == 17 || code == 100) {
                // 使用 V3 API
                String endpointV3 = "https://aip.baidubce.com/rest/2.0/face/v3/match?access_token=" + URLEncoder.encode(accessToken, "UTF-8");
                
                // 清理 base64 字符串中的换行符和空格
                String cleanImg1 = base64Img1.replaceAll("\\s+", "");
                String cleanImg2 = base64Img2.replaceAll("\\s+", "");
                
                // 使用 JSONArray 和 JSONObject 构建请求
                JSONArray jsonArray = new JSONArray();
                
                JSONObject img1Obj = new JSONObject();
                img1Obj.put("image", cleanImg1);
                img1Obj.put("image_type", "BASE64");
                img1Obj.put("face_type", "LIVE");
                img1Obj.put("quality_control", "LOW");
                img1Obj.put("liveness_control", "NONE");
                jsonArray.put(img1Obj);
                
                JSONObject img2Obj = new JSONObject();
                img2Obj.put("image", cleanImg2);
                img2Obj.put("image_type", "BASE64");
                img2Obj.put("face_type", "LIVE");
                img2Obj.put("quality_control", "NONE");
                jsonArray.put(img2Obj);
                
                String json = jsonArray.toString();
                System.out.println("[FaceRecognition] V3 API Request length: " + json.length());
                
                String respV3 = httpPostJson(endpointV3, json);
                
                System.out.println("[FaceRecognition] V3 API Response: " + respV3.substring(0, Math.min(200, respV3.length())));
                
                Matcher mScoreV3 = pScore.matcher(respV3);
                if (mScoreV3.find()) {
                    return Double.parseDouble(mScoreV3.group(1));
                }
                throw new IllegalStateException("V3 API响应中未找到score: " + respV3);
            }
        }
        
        throw new IllegalStateException("响应中未找到score: " + respV2);
    }

    private String httpGet(String urlStr) throws IOException {
        HttpURLConnection conn = (HttpURLConnection) new URL(urlStr).openConnection();
        conn.setRequestMethod("GET");
        conn.setConnectTimeout(15000);
        conn.setReadTimeout(15000);
        try (InputStream is = conn.getInputStream()) {
            return readAll(is);
        } catch (IOException e) {
            InputStream es = conn.getErrorStream();
            if (es != null) {
                return readAll(es);
            }
            throw e;
        }
    }

    private String httpPost(String urlStr, String body) throws IOException {
        byte[] data = body.getBytes(StandardCharsets.UTF_8);
        HttpURLConnection conn = (HttpURLConnection) new URL(urlStr).openConnection();
        conn.setRequestMethod("POST");
        conn.setConnectTimeout(15000);
        conn.setReadTimeout(30000);
        conn.setDoOutput(true);
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
        conn.setRequestProperty("Content-Length", String.valueOf(data.length));
        try (OutputStream os = conn.getOutputStream()) {
            os.write(data);
        }
        try (InputStream is = conn.getInputStream()) {
            return readAll(is);
        } catch (IOException e) {
            InputStream es = conn.getErrorStream();
            if (es != null) {
                return readAll(es);
            }
            throw e;
        }
    }

    private String httpPostJson(String urlStr, String json) throws IOException {
        byte[] data = json.getBytes(StandardCharsets.UTF_8);
        HttpURLConnection conn = (HttpURLConnection) new URL(urlStr).openConnection();
        conn.setRequestMethod("POST");
        conn.setConnectTimeout(15000);
        conn.setReadTimeout(30000);
        conn.setDoOutput(true);
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setRequestProperty("Content-Length", String.valueOf(data.length));
        try (OutputStream os = conn.getOutputStream()) {
            os.write(data);
        }
        try (InputStream is = conn.getInputStream()) {
            return readAll(is);
        } catch (IOException e) {
            InputStream es = conn.getErrorStream();
            if (es != null) {
                return readAll(es);
            }
            throw e;
        }
    }

    private String readAll(InputStream is) throws IOException {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        byte[] buf = new byte[8192];
        int n;
        while ((n = is.read(buf)) != -1) {
            baos.write(buf, 0, n);
        }
        return baos.toString(StandardCharsets.UTF_8);
    }

    public boolean isSamePerson(double score) {
        return score >= threshold;
    }

    public double getThreshold() {
        return threshold;
    }
}
