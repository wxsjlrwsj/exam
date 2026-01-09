// Node.js script to test BCrypt hash
// Run with: node test-bcrypt.js
// Or install bcrypt first: npm install bcrypt

const bcrypt = require('bcrypt');

const password = '123456';
const hash1 = '$2a$10$zJpIYkPp7OLoOqMZ9o4m3uQV1YVQdGmJ8VxgQf3o3PzF8q6QJk7uS';
const hash2 = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy';

console.log('Testing password:', password);
console.log('\nHash 1:', hash1);
bcrypt.compare(password, hash1, (err, result) => {
    console.log('Hash 1 matches:', result);
});

console.log('\nHash 2:', hash2);
bcrypt.compare(password, hash2, (err, result) => {
    console.log('Hash 2 matches:', result);
});

// Generate a new hash
bcrypt.hash(password, 10, (err, newHash) => {
    console.log('\nNew hash for "123456":', newHash);
    bcrypt.compare(password, newHash, (err, result) => {
        console.log('New hash matches:', result);
    });
});

