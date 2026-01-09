package org.example.chaoxingsystem.user;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import org.springframework.test.web.servlet.result.MockMvcResultMatchers;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;

@SpringBootTest(properties = {
  "spring.datasource.url=jdbc:mysql://localhost:3307/chaoxing?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true&useUnicode=true&characterEncoding=UTF-8",
  "spring.datasource.username=root",
  "spring.datasource.password=root",
  "spring.sql.init.mode=never"
})
@AutoConfigureMockMvc
public class AuthControllerTest {

  @Autowired
  private MockMvc mockMvc;

  @Autowired
  private EmailVerificationService verificationService;

  @MockBean
  private JavaMailSender mailSender;

  @Test
  void registerLoginResetFlow() throws Exception {
    long base = (System.currentTimeMillis() % 9_000_000_000L) + 1_000_000_000L;
    String qqNumber = String.valueOf(base);
    String username = "student" + qqNumber;
    String email = qqNumber + "@qq.com";
    String code = verificationService.generate(email).code;
    String registerJson = "{\"username\":\"" + username + "\",\"password\":\"password123\",\"userType\":\"student\",\"email\":\"" + email + "\",\"qqNumber\":\"" + qqNumber + "\",\"verificationCode\":\"" + code + "\"}";
    mockMvc.perform(MockMvcRequestBuilders.post("/api/register")
        .contentType(MediaType.APPLICATION_JSON)
        .content(registerJson))
      .andExpect(MockMvcResultMatchers.status().isOk())
      .andExpect(MockMvcResultMatchers.jsonPath("$.code").value(200))
      .andExpect(MockMvcResultMatchers.jsonPath("$.message").value("注册成功"))
      .andExpect(MockMvcResultMatchers.jsonPath("$.data").doesNotExist());

    mockMvc.perform(MockMvcRequestBuilders.post("/api/register")
        .contentType(MediaType.APPLICATION_JSON)
        .content(registerJson))
      .andExpect(MockMvcResultMatchers.status().isBadRequest())
      .andExpect(MockMvcResultMatchers.jsonPath("$.code").value(400));

    String loginJson = "{\"username\":\"" + username + "\",\"password\":\"password123\"}";
    mockMvc.perform(MockMvcRequestBuilders.post("/api/login")
        .contentType(MediaType.APPLICATION_JSON)
        .content(loginJson))
      .andExpect(MockMvcResultMatchers.status().isOk())
      .andExpect(MockMvcResultMatchers.jsonPath("$.code").value(200))
      .andExpect(MockMvcResultMatchers.jsonPath("$.data.token").exists())
      .andExpect(MockMvcResultMatchers.jsonPath("$.data.userInfo.username").value(username))
      .andExpect(MockMvcResultMatchers.jsonPath("$.data.userInfo.userType").value("student"));

    String resetJson = "{\"username\":\"" + username + "\",\"newPassword\":\"newpass123\",\"email\":\"" + email + "\"}";
    mockMvc.perform(MockMvcRequestBuilders.post("/api/reset-password")
        .contentType(MediaType.APPLICATION_JSON)
        .content(resetJson))
      .andExpect(MockMvcResultMatchers.status().isOk())
      .andExpect(MockMvcResultMatchers.jsonPath("$.code").value(200))
      .andExpect(MockMvcResultMatchers.jsonPath("$.message").value("密码重置成功"));

    String loginNewJson = "{\"username\":\"" + username + "\",\"password\":\"newpass123\"}";
    mockMvc.perform(MockMvcRequestBuilders.post("/api/login")
        .contentType(MediaType.APPLICATION_JSON)
        .content(loginNewJson))
      .andExpect(MockMvcResultMatchers.status().isOk())
      .andExpect(MockMvcResultMatchers.jsonPath("$.code").value(200));

    String badLoginJson = "{\"username\":\"" + username + "\",\"password\":\"badbad\"}";
    mockMvc.perform(MockMvcRequestBuilders.post("/api/login")
        .contentType(MediaType.APPLICATION_JSON)
        .content(badLoginJson))
      .andExpect(MockMvcResultMatchers.status().isUnauthorized())
      .andExpect(MockMvcResultMatchers.jsonPath("$.code").value(401));
  }
}
