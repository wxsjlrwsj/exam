package org.example.chaoxingsystem;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class BCryptTest {
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        
        String password = "123456";
        String hash1 = "$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS";
        String hash2 = "$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy";
        
        System.out.println("Testing password: " + password);
        System.out.println();
        
        System.out.println("Hash 1: " + hash1);
        System.out.println("Matches: " + encoder.matches(password, hash1));
        System.out.println();
        
        System.out.println("Hash 2: " + hash2);
        System.out.println("Matches: " + encoder.matches(password, hash2));
        System.out.println();
        
        // Generate new hash
        String newHash = encoder.encode(password);
        System.out.println("New hash for '123456': " + newHash);
        System.out.println("New hash matches: " + encoder.matches(password, newHash));
    }
}

