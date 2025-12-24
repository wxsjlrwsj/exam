package org.example.chaoxingsystem.user.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public class VerifyCodeRequest {
  @NotBlank
  @Size(max = 100)
  @Pattern(regexp = ".*@qq\\.com$")
  private String email;

  @NotBlank
  @Pattern(regexp = "\\d{6}")
  private String code;

  public String getEmail() {
    return email;
  }

  public void setEmail(String email) {
    this.email = email;
  }

  public String getCode() {
    return code;
  }

  public void setCode(String code) {
    this.code = code;
  }
}
