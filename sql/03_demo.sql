USE university_key_system;
GO
-- Алдымен 00_schema.sql, 01_seed.sql, 02_procedures.sql орындаңыз.
-- Жаңа дерекқорда KEY-A-101 кілті қолжетімді болады.
DECLARE @KeyId BIGINT = (SELECT id FROM dbo.room_keys WHERE serial_number=N'KEY-A-101');
DECLARE @TeacherId BIGINT = (SELECT id FROM dbo.staff WHERE staff_code=N'T-001');
DECLARE @GuardId BIGINT = (SELECT id FROM dbo.staff WHERE staff_code=N'G-001');
DECLARE @DueAt DATETIME2(0) = DATEADD(HOUR, 2, SYSDATETIME());

SELECT id, serial_number, status FROM dbo.room_keys WHERE id=@KeyId;

-- 1. Оқытушы кабинет кілтін алады.
EXEC dbo.sp_issue_key
    @KeyId=@KeyId, @TeacherId=@TeacherId, @GuardId=@GuardId, @DueAt=@DueAt;

-- 2. 'issued' және ашық берілім тексеріледі.
SELECT TOP (1) k.id, k.status, i.recipient_id, i.issued_at, i.returned_at
FROM dbo.room_keys AS k INNER JOIN dbo.key_issues AS i ON i.key_id=k.id
WHERE k.id=@KeyId ORDER BY i.id DESC;

-- 3. Кілт кері қабылданады.
EXEC dbo.sp_return_key @KeyId=@KeyId, @GuardId=@GuardId;

-- 4. 'available', қайтару уақыты және аудит көрсетіледі.
SELECT id, serial_number, status FROM dbo.room_keys WHERE id=@KeyId;
SELECT TOP (5) id, key_id, issued_at, returned_at FROM dbo.key_issues WHERE key_id=@KeyId ORDER BY id DESC;
SELECT TOP (10) a.event_type, a.event_time, k.serial_number, s.full_name AS guard_name
FROM dbo.key_audit AS a
JOIN dbo.room_keys AS k ON k.id=a.key_id
JOIN dbo.staff AS s ON s.id=a.actor_id
WHERE k.id=@KeyId ORDER BY a.id DESC;

-- ТЕРІС ТЕСТТЕРДІ жеке Query терезесінде орындаңыз:
-- Кілт берілген кезде қайта беру -> қате 50002.
-- Кілт бос кезде қайтару -> қате 50012.
-- Демо қайта орындалса, тарихта тағы бір беру/қайтару жұбы қосылады.
