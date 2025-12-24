package org.example.chaoxingsystem.user;

import jakarta.validation.Valid;
import org.example.chaoxingsystem.user.dto.ApiResponse;
import org.example.chaoxingsystem.user.dto.LoginData;
import org.example.chaoxingsystem.user.dto.LoginRequest;
import org.example.chaoxingsystem.user.dto.RegisterRequest;
import org.example.chaoxingsystem.user.dto.ResetPasswordRequest;
import org.example.chaoxingsystem.user.dto.UserInfo;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import java.util.List;
import org.example.chaoxingsystem.user.dto.UserResponse;
import org.example.chaoxingsystem.user.dto.SendCodeRequest;
import org.example.chaoxingsystem.user.dto.VerifyCodeRequest;

/**
 * 鉴权接口：注册、登录、重置密码、获取当前用户信息、管理员用户列表
 */
@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class AuthController {
  private final UserService userService;
  private final TokenService tokenService;
  private final EmailVerificationService verificationService;
  private final MailService mailService;

  public AuthController(UserService userService, TokenService tokenService, EmailVerificationService verificationService, MailService mailService) {
    this.userService = userService;
    this.tokenService = tokenService;
    this.verificationService = verificationService;
    this.mailService = mailService;
  }

  @PostMapping("/register")
  public ResponseEntity<ApiResponse<Void>> register(@Valid @RequestBody RegisterRequest request) {
    userService.register(request);
    return ResponseEntity.ok(ApiResponse.success("注册成功", null));
  }

  @PostMapping("/auth/register")
  public ResponseEntity<ApiResponse<Void>> registerAlias(@Valid @RequestBody RegisterRequest request) {
    return register(request);
  }

  @PostMapping("/auth/send-code")
  public ResponseEntity<ApiResponse<Void>> sendCode(@Valid @RequestBody SendCodeRequest request) {
    var r = verificationService.generate(request.getEmail());
    if (!r.ok) {
      return ResponseEntity.status(429).body(ApiResponse.error(429, "发送过于频繁，请稍后再试"));
    }
    try {
      mailService.sendCode(request.getEmail(), r.code);
    } catch (Exception ex) {
      return ResponseEntity.status(502).body(ApiResponse.error(502, "邮件发送失败"));
    }
    return ResponseEntity.ok(ApiResponse.success("验证码已发送", null));
  }

  @PostMapping("/auth/verify-code")
  public ResponseEntity<ApiResponse<Void>> verifyCode(@Valid @RequestBody VerifyCodeRequest request) {
    boolean ok = verificationService.verify(request.getEmail(), request.getCode());
    if (!ok) {
      return ResponseEntity.status(400).body(ApiResponse.error(400, "验证码错误或已失效"));
    }
    return ResponseEntity.ok(ApiResponse.success("验证通过", null));
  }

  @PostMapping("/login")
  public ResponseEntity<ApiResponse<LoginData>> login(@Valid @RequestBody LoginRequest request) {
    User user = userService.authenticate(request.getUsername(), request.getPassword());
    if (user == null) {
      return ResponseEntity.status(401).body(ApiResponse.error(401, "用户名或密码错误"));
    }
    String token = tokenService.generateToken(user);
    String resolvedType = userService.resolveUserType(user);
    UserInfo info = new UserInfo(user.getId(), user.getUsername(), user.getRealName(), resolvedType, user.getAvatar());
    LoginData data = new LoginData(token, info);
    return ResponseEntity.ok(ApiResponse.success("登录成功", data));
  }

  @PostMapping("/auth/login")
  public ResponseEntity<ApiResponse<LoginData>> loginAlias(@Valid @RequestBody LoginRequest request) {
    return login(request);
  }

  @PostMapping("/reset-password")
  public ResponseEntity<ApiResponse<Void>> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
    boolean ok = userService.resetPassword(request);
    if (!ok) {
      return ResponseEntity.status(404).body(ApiResponse.error(404, "用户不存在"));
    }
    return ResponseEntity.ok(ApiResponse.success("密码重置成功", null));
  }

  @PostMapping("/auth/reset-password")
  public ResponseEntity<ApiResponse<Void>> resetPasswordAlias(@Valid @RequestBody ResetPasswordRequest request) {
    return resetPassword(request);
  }

  @GetMapping("/me")
  @PreAuthorize("hasAnyRole('STUDENT','TEACHER','ADMIN')")
  public ResponseEntity<ApiResponse<UserInfo>> me(Authentication authentication) {
    String username = authentication.getName();
    UserInfo info = userService.getUserInfoByUsername(username);
    if (info == null) {
      return ResponseEntity.status(404).body(ApiResponse.error(404, "用户不存在"));
    }
    return ResponseEntity.ok(ApiResponse.success("获取成功", info));
  }

  @GetMapping("/admin/users")
  @PreAuthorize("hasRole('ADMIN')")
  public ResponseEntity<ApiResponse<List<UserResponse>>> listUsers() {
    List<UserResponse> users = userService.listAllUsers();
    return ResponseEntity.ok(ApiResponse.success("获取成功", users));
  }
}
