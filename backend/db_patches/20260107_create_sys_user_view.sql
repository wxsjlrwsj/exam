-- Create a compatibility view for sys_user based on existing users table.
DROP VIEW IF EXISTS sys_user;
CREATE VIEW sys_user AS
SELECT
  id,
  username,
  password_hash AS password,
  user_type,
  real_name,
  email,
  phone,
  avatar,
  1 AS status,
  created_at
FROM users;
