#!/usr/bin/env python3
# Test BCrypt hash validation
# Run with: python test_bcrypt.py
# Install bcrypt first: pip install bcrypt

import bcrypt

password = '123456'.encode('utf-8')
hash1 = '$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS'.encode('utf-8')
hash2 = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'.encode('utf-8')

print('Testing password: 123456')
print()

print('Hash 1:', hash1.decode('utf-8'))
print('Hash 1 matches:', bcrypt.checkpw(password, hash1))
print()

print('Hash 2:', hash2.decode('utf-8'))
print('Hash 2 matches:', bcrypt.checkpw(password, hash2))
print()

# Generate new hash
new_hash = bcrypt.hashpw(password, bcrypt.gensalt())
print('New hash for "123456":', new_hash.decode('utf-8'))
print('New hash matches:', bcrypt.checkpw(password, new_hash))

