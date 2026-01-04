-- Patch: Hide teacher audit module for admin and remove menu entry
UPDATE system_modules
SET show_in_menu = 0,
    route_path = '',
    allowed_roles = 'teacher'
WHERE code = 'tch_audit';

