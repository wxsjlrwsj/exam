package org.example.chaoxingsystem.user;

import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.time.Duration;
import java.time.Instant;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class EmailVerificationService {
  private final SecureRandom random = new SecureRandom();
  private final Map<String, Entry> store = new ConcurrentHashMap<>();
  private final Duration ttl = Duration.ofMinutes(5);
  private final Duration resendCooldown = Duration.ofSeconds(60);

  public synchronized Result generate(String email) {
    Entry existing = store.get(email);
    Instant now = Instant.now();
    if (existing != null && existing.lastSent != null && Duration.between(existing.lastSent, now).compareTo(resendCooldown) < 0) {
      long wait = resendCooldown.minus(Duration.between(existing.lastSent, now)).toSeconds();
      return Result.rateLimited(wait);
    }
    String code = String.format("%06d", random.nextInt(1_000_000));
    Entry entry = new Entry();
    entry.code = code;
    entry.expiresAt = now.plus(ttl);
    entry.lastSent = now;
    store.put(email, entry);
    return Result.ok(code);
  }

  public boolean verify(String email, String code) {
    Entry entry = store.get(email);
    if (entry == null) return false;
    if (Instant.now().isAfter(entry.expiresAt)) {
      store.remove(email);
      return false;
    }
    boolean match = entry.code.equals(code);
    if (match) store.remove(email);
    return match;
  }

  public static class Result {
    public final boolean ok;
    public final String code;
    public final long retryAfterSeconds;

    private Result(boolean ok, String code, long retryAfterSeconds) {
      this.ok = ok;
      this.code = code;
      this.retryAfterSeconds = retryAfterSeconds;
    }

    public static Result ok(String code) { return new Result(true, code, 0); }
    public static Result rateLimited(long seconds) { return new Result(false, null, seconds); }
  }

  private static class Entry {
    String code;
    Instant expiresAt;
    Instant lastSent;
  }
}
