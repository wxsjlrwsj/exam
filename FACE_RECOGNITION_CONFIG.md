# 人脸识别功能配置说明

## 📋 功能概述

本项目集成了百度AI人脸识别功能，用于考试前的身份验证。所有必要的API配置已内置在代码中，**无需额外配置即可直接使用**。

## 🔑 API配置信息

### 百度人脸识别API凭证

配置文件位置：`backend/src/main/resources/application.yml`

```yaml
baidu:
  face:
    app-id: 121249541
    api-key: iFloNzCZGwX1QSAPkCQcm0eg
    secret-key: jGwzBT9G2QQKGV5kecsxy5MBzkbShIk4
    threshold: 80.0
```

### 配置说明

| 配置项 | 值 | 说明 |
|--------|-----|------|
| `app-id` | 121249541 | 百度AI应用ID |
| `api-key` | iFloNzCZGwX1QSAPkCQcm0eg | 百度AI API Key |
| `secret-key` | jGwzBT9G2QQKGV5kecsxy5MBzkbShIk4 | 百度AI Secret Key |
| `threshold` | 80.0 | 人脸相似度阈值（百分比） |

## 🚀 快速开始

### 1. 克隆项目后直接启动

```bash
# 1. 启动数据库
docker-compose up -d mysql

# 2. 启动后端
cd backend
mvn spring-boot:run

# 3. 启动前端
cd frontend
npm install
npm run dev
```

### 2. 使用人脸识别功能

**步骤1：上传人脸照片**
- 登录系统（student1 / 123456）
- 进入"个人空间" → "人脸识别"标签
- 点击"上传人脸照片"
- 选择清晰的正面照片

**步骤2：参加考试并验证**
- 进入"查看考试"页面
- 点击"参加考试"按钮
- 系统自动弹出人脸验证对话框
- 点击"开启摄像头"
- 点击"拍照验证"
- 验证通过后点击"确认进入考试"

## 🔧 技术实现

### 后端实现

**核心服务类**：`FaceRecognitionService.java`

```java
@Service
public class FaceRecognitionService {
    @Value("${baidu.face.api-key}")
    private String apiKey;
    
    @Value("${baidu.face.secret-key}")
    private String secretKey;
    
    @Value("${baidu.face.threshold}")
    private double threshold;
    
    // 使用百度人脸识别 V2/V3 API
    // 自动获取 access_token
    // 支持 V2 失败时自动切换到 V3
}
```

**API接口**：
- `POST /api/face/upload-photo` - 上传人脸照片
- `GET /api/face/has-photo` - 检查是否已上传照片
- `POST /api/face/verify` - 人脸验证

### 前端实现

**核心组件**：
- `FacePhotoUpload.vue` - 人脸照片上传组件
- `FaceVerification.vue` - 人脸验证组件
- `ExamList.vue` - 集成人脸验证的考试列表

**验证流程**：
1. 检查是否已上传人脸照片
2. 开启摄像头获取实时画面
3. 拍照并转换为 Base64
4. 调用后端API进行人脸比对
5. 显示验证结果（相似度分数）
6. 验证通过后进入考试

## 📊 API调用流程

```
前端 FaceVerification.vue
    ↓
    调用 POST /api/face/verify
    ↓
后端 FaceController.java
    ↓
    调用 FaceRecognitionService.compareFaces()
    ↓
    1. 获取百度 access_token
    2. 调用百度人脸识别 V2 API
    3. 如果失败（错误码 6/17/100），切换到 V3 API
    4. 返回相似度分数
    ↓
前端显示验证结果
```

## 🔐 环境变量（可选）

如果需要使用不同的API凭证，可以通过环境变量覆盖默认值：

```bash
# Linux/Mac
export BAIDU_FACE_APP_ID=your_app_id
export BAIDU_FACE_API_KEY=your_api_key
export BAIDU_FACE_SECRET_KEY=your_secret_key

# Windows PowerShell
$env:BAIDU_FACE_APP_ID="your_app_id"
$env:BAIDU_FACE_API_KEY="your_api_key"
$env:BAIDU_FACE_SECRET_KEY="your_secret_key"
```

## ⚠️ 注意事项

1. **API配额限制**
   - 百度人脸识别API有每日调用次数限制
   - 免费版：50,000次/天
   - 如需更多配额，请升级百度AI账号

2. **照片要求**
   - 格式：JPG、PNG、BMP
   - 大小：不超过 5MB
   - 内容：清晰的正面人脸照片
   - 光线：充足且均匀

3. **浏览器要求**
   - 支持 WebRTC（摄像头访问）
   - 推荐使用 Chrome、Edge、Firefox 最新版本
   - 需要 HTTPS 或 localhost（摄像头权限）

4. **相似度阈值**
   - 默认阈值：80%
   - 可在 `application.yml` 中调整
   - 建议范围：70-90%

## 🧪 测试账号

系统预置了测试账号，已上传人脸照片：

```
用户名: student1
密码: 123456
```

## 📝 数据库表结构

人脸照片存储在 `users` 表中：

```sql
ALTER TABLE users ADD COLUMN face_photo LONGTEXT COMMENT '人脸照片(Base64)';
```

## 🔄 API版本说明

**V2 API**：
- 端点：`https://aip.baidubce.com/rest/2.0/face/v2/match`
- 格式：URL编码表单数据
- 参数：`images`, `ext_fields`, `image_liveness`

**V3 API**（V2失败时自动切换）：
- 端点：`https://aip.baidubce.com/rest/2.0/face/v3/match`
- 格式：JSON
- 参数：`image`, `image_type`, `face_type`, `quality_control`, `liveness_control`

## 📞 技术支持

如遇到问题，请检查：
1. 后端日志：`[FaceRecognition]` 开头的日志
2. 前端控制台：`[FaceVerification]` 开头的日志
3. 网络请求：检查 `/api/face/*` 接口的响应

## ✅ 功能清单

- [x] 人脸照片上传
- [x] 照片预览显示
- [x] 摄像头实时预览
- [x] 人脸拍照验证
- [x] 百度AI API集成（V2/V3自动切换）
- [x] 相似度分数显示
- [x] 考试前强制验证
- [x] 验证通过后进入考试
- [x] 完整的错误处理
- [x] 详细的日志输出

---

**配置完成！项目可以直接使用，无需额外配置。** 🎉
