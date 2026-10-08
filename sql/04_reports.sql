USE university_key_system;
GO
-- Кілттердің ағымдағы мәртебесі мен пайдаланушысы.
CREATE OR ALTER VIEW dbo.v_key_status
AS
SELECT k.id AS key_id,
       CONCAT(r.building, N'-', r.room_number) AS room,
       k.serial_number,
       k.status,
       t.full_name AS current_holder,
       i.issued_at,
       i.due_at
FROM dbo.room_keys AS k
INNER JOIN dbo.rooms AS r ON r.id=k.room_id
LEFT JOIN dbo.key_issues AS i ON i.key_id=k.id AND i.returned_at IS NULL
LEFT JOIN dbo.staff AS t ON t.id=i.recipient_id;
GO

-- Беру мен қайтарудың толық тарихы.
CREATE OR ALTER VIEW dbo.v_issuance_history
AS
SELECT i.id AS issue_id,
       CONCAT(r.building, N'-', r.room_number) AS room,
       t.full_name AS teacher_name,
       g.full_name AS issued_by_guard,
       rg.full_name AS returned_to_guard,
       i.issued_at,
       i.due_at,
       i.returned_at,
       CASE WHEN i.returned_at IS NULL THEN N'Белсенді' ELSE N'Қайтарылды' END AS issue_state
FROM dbo.key_issues AS i
INNER JOIN dbo.room_keys AS k ON k.id=i.key_id
INNER JOIN dbo.rooms AS r ON r.id=k.room_id
INNER JOIN dbo.staff AS t ON t.id=i.recipient_id
INNER JOIN dbo.staff AS g ON g.id=i.issued_by_id
LEFT JOIN dbo.staff AS rg ON rg.id=i.returned_to_id;
GO

SELECT * FROM dbo.v_key_status ORDER BY room;
SELECT * FROM dbo.v_issuance_history ORDER BY issue_id DESC;
SELECT event_type, COUNT(*) AS total FROM dbo.key_audit GROUP BY event_type;
