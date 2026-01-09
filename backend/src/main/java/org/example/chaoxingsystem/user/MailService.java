package org.example.chaoxingsystem.user;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class MailService {
  private final JavaMailSender sender;
  private final String from;

  public MailService(JavaMailSender sender, @Value("${spring.mail.username:}") String from) {
    this.sender = sender;
    this.from = from;
  }

  public void sendCode(String to, String code) {
    SimpleMailMessage message = new SimpleMailMessage();
    message.setFrom(from);
    message.setTo(to);
    message.setSubject("QQ邮箱验证码");
    message.setText("您的验证码为: " + code + "\n有效期5分钟。");
    sender.send(message);
  }
}
