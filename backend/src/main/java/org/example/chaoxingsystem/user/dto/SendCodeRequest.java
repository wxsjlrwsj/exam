package org.example.chaoxingsystem.user.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public class SendCodeRequest {
  @NotBlank
  @Email
  @Size(max = 100)
  @Pattern(regexp = ".*@qq\\.com$")
  private String email;

  public String getEmail() {
    return email;
  }

  public void setEmail(String email) {
    this.email = email;
  }
}
