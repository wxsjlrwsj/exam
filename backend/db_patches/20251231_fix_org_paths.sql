SET NAMES utf8mb4;
USE chaoxing;

UPDATE sys_organization SET path = CONCAT('/', id, '/') WHERE parent_id IS NULL;
UPDATE sys_organization AS c
JOIN sys_organization AS p ON p.id = c.parent_id
SET c.path = CONCAT(p.path, c.id, '/');
UPDATE sys_organization AS c
JOIN sys_organization AS p ON p.id = c.parent_id
SET c.path = CONCAT(p.path, c.id, '/');
UPDATE sys_organization AS c
JOIN sys_organization AS p ON p.id = c.parent_id
SET c.path = CONCAT(p.path, c.id, '/');

