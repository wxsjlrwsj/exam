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

    @Value("${baidu.face.api-key:}")
    private String apiKey;

    @Value("${baidu.face.secret-key:}")
    private String secretKey;

    @Value("${baidu.face.threshold:80.0}")
    private double threshold;

    public double compareFaces(String base64Image1, String base64Image2) {
        try {
            if (apiKey == null || apiKey.isBlank() || secretKey == null || secretKey.isBlank()) {
                throw new FaceRecognitionException(500, "人脸识别未配置，请联系管理员设置百度人脸API凭证");
            }

            String accessToken = getAccessToken(apiKey, secretKey);
            double score = faceMatchScore(accessToken, base64Image1, base64Image2);
            return score;
        } catch (FaceRecognitionException e) {
            throw e;
        } catch (Exception e) {
            throw new FaceRecognitionException(503, "人脸识别服务暂时不可用，请稍后重试");
        }
    }

    private String getAccessToken(String apiKey, String secretKey) throws IOException {
        String url = "https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials"
                + "&client_id=" + URLEncoder.encode(apiKey, "UTF-8")
                + "&client_secret=" + URLEncoder.encode(secretKey, "UTF-8");
        String json = httpGet(url);
        try {
            JSONObject obj = new JSONObject(json);
            String token = obj.optString("access_token", "");
            if (!token.isBlank()) {
                return token;
            }
            String err = obj.optString("error_description", obj.optString("error", ""));
            if (err.isBlank()) err = json;
            throw new FaceRecognitionException(503, "获取百度access_token失败: " + err);
        } catch (FaceRecognitionException e) {
            throw e;
        } catch (Exception e) {
            throw new FaceRecognitionException(503, "获取百度access_token失败");
        }
    }

    private double faceMatchScore(String accessToken, String base64Img1, String base64Img2) throws IOException {
        String cleanImg1 = (base64Img1 == null ? "" : base64Img1).replaceAll("\\s+", "");
        String cleanImg2 = (base64Img2 == null ? "" : base64Img2).replaceAll("\\s+", "");

        if (cleanImg1.isBlank() || cleanImg2.isBlank()) {
            throw new FaceRecognitionException(400, "照片数据不能为空");
        }

        FaceMatchAttempt v2Attempt = tryMatchV2(accessToken, cleanImg1, cleanImg2);
        if (v2Attempt.score != null) {
            return v2Attempt.score;
        }

        FaceMatchAttempt v3Attempt = tryMatchV3(accessToken, cleanImg1, cleanImg2);
        if (v3Attempt.score != null) {
            return v3Attempt.score;
        }

        FaceMatchAttempt err = v3Attempt.errorCode != null ? v3Attempt : v2Attempt;
        if (err.errorCode != null) {
            int code = err.errorCode;
            String msg = err.errorMessage == null ? "" : err.errorMessage;
            throw toFriendlyException(code, msg);
        }

        throw new FaceRecognitionException(503, "人脸识别服务返回异常，请稍后重试");
    }

    private FaceMatchAttempt tryMatchV2(String accessToken, String base64Img1, String base64Img2) throws IOException {
        String endpointV2 = "https://aip.baidubce.com/rest/2.0/face/v2/match?access_token=" + URLEncoder.encode(accessToken, "UTF-8");
        String images = URLEncoder.encode(base64Img1 + "," + base64Img2, "UTF-8");
        String bodyV2 = "images=" + images;
        String respV2 = httpPost(endpointV2, bodyV2);
        return parseMatchResponse(respV2);
    }

    private FaceMatchAttempt tryMatchV3(String accessToken, String base64Img1, String base64Img2) throws IOException {
        String endpointV3 = "https://aip.baidubce.com/rest/2.0/face/v3/match?access_token=" + URLEncoder.encode(accessToken, "UTF-8");

        JSONArray jsonArray = new JSONArray();
        JSONObject img1Obj = new JSONObject();
        img1Obj.put("image", base64Img1);
        img1Obj.put("image_type", "BASE64");
        img1Obj.put("face_type", "LIVE");
        img1Obj.put("quality_control", "LOW");
        img1Obj.put("liveness_control", "NONE");
        jsonArray.put(img1Obj);

        JSONObject img2Obj = new JSONObject();
        img2Obj.put("image", base64Img2);
        img2Obj.put("image_type", "BASE64");
        img2Obj.put("face_type", "LIVE");
        img2Obj.put("quality_control", "NONE");
        jsonArray.put(img2Obj);

        String respV3 = httpPostJson(endpointV3, jsonArray.toString());
        return parseMatchResponse(respV3);
    }

    private FaceMatchAttempt parseMatchResponse(String resp) {
        try {
            JSONObject obj = new JSONObject(resp);
            Integer errorCode = obj.has("error_code") ? obj.optInt("error_code") : null;
            if (errorCode != null && errorCode != 0) {
                return FaceMatchAttempt.error(errorCode, obj.optString("error_msg", ""));
            }

            JSONObject resultObj = obj.optJSONObject("result");
            if (resultObj != null) {
                if (resultObj.has("score")) {
                    return FaceMatchAttempt.score(resultObj.optDouble("score"));
                }
                JSONArray resultArr = resultObj.optJSONArray("result");
                if (resultArr != null && resultArr.length() > 0) {
                    JSONObject first = resultArr.optJSONObject(0);
                    if (first != null && first.has("score")) {
                        return FaceMatchAttempt.score(first.optDouble("score"));
                    }
                }
            }

            JSONArray resultArr = obj.optJSONArray("result");
            if (resultArr != null && resultArr.length() > 0) {
                JSONObject first = resultArr.optJSONObject(0);
                if (first != null && first.has("score")) {
                    return FaceMatchAttempt.score(first.optDouble("score"));
                }
            }

            Pattern pScore = Pattern.compile("\"score\"\\s*:\\s*(\\d+(?:\\.\\d+)?)");
            Matcher mScore = pScore.matcher(resp);
            if (mScore.find()) {
                return FaceMatchAttempt.score(Double.parseDouble(mScore.group(1)));
            }

            if (errorCode != null && errorCode == 0) {
                return FaceMatchAttempt.empty();
            }
            return FaceMatchAttempt.empty();
        } catch (Exception e) {
            return FaceMatchAttempt.empty();
        }
    }

    private FaceRecognitionException toFriendlyException(int errorCode, String errorMsg) {
        String msg = errorMsg == null ? "" : errorMsg;
        return switch (errorCode) {
            case 216201, 216202, 216200, 216203 -> new FaceRecognitionException(400, "照片无效，请重新拍照后重试");
            case 222202 -> new FaceRecognitionException(400, "未检测到人脸，请正对摄像头并保持光线充足");
            case 222203 -> new FaceRecognitionException(400, "人脸质量不佳，请重新拍照后重试");
            case 17, 18 -> new FaceRecognitionException(503, "人脸识别服务繁忙，请稍后重试");
            case 100 -> new FaceRecognitionException(503, "人脸识别服务授权失效，请联系管理员");
            default -> new FaceRecognitionException(503, "人脸识别失败: " + (msg.isBlank() ? ("error_code=" + errorCode) : msg));
        };
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

    public static class FaceRecognitionException extends RuntimeException {
        private final int code;

        public FaceRecognitionException(int code, String message) {
            super(message);
            this.code = code;
        }

        public int getCode() {
            return code;
        }
    }

    private static class FaceMatchAttempt {
        private final Double score;
        private final Integer errorCode;
        private final String errorMessage;

        private FaceMatchAttempt(Double score, Integer errorCode, String errorMessage) {
            this.score = score;
            this.errorCode = errorCode;
            this.errorMessage = errorMessage;
        }

        static FaceMatchAttempt score(double score) {
            return new FaceMatchAttempt(score, null, null);
        }

        static FaceMatchAttempt error(int errorCode, String errorMessage) {
            return new FaceMatchAttempt(null, errorCode, errorMessage);
        }

        static FaceMatchAttempt empty() {
            return new FaceMatchAttempt(null, null, null);
        }
    }
}
