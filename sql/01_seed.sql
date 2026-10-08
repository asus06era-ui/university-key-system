USE university_key_system;
GO
-- Қайта іске қосқанда қайталанбайтын сынақ жазбалары.
IF NOT EXISTS (SELECT 1 FROM dbo.staff WHERE staff_code=N'T-001')
    INSERT INTO dbo.staff (staff_code, full_name, role)
    VALUES (N'T-001', N'Айдана Серікқызы', N'teacher');
IF NOT EXISTS (SELECT 1 FROM dbo.staff WHERE staff_code=N'T-002')
    INSERT INTO dbo.staff (staff_code, full_name, role)
    VALUES (N'T-002', N'Нұржан Ермекұлы', N'teacher');
IF NOT EXISTS (SELECT 1 FROM dbo.staff WHERE staff_code=N'G-001')
    INSERT INTO dbo.staff (staff_code, full_name, role)
    VALUES (N'G-001', N'Марат Қасымұлы', N'guard');
IF NOT EXISTS (SELECT 1 FROM dbo.staff WHERE staff_code=N'A-001')
    INSERT INTO dbo.staff (staff_code, full_name, role)
    VALUES (N'A-001', N'Әкімшілік өкілі', N'admin_rep');
IF NOT EXISTS (SELECT 1 FROM dbo.staff WHERE staff_code=N'S-001')
    INSERT INTO dbo.staff (staff_code, full_name, role)
    VALUES (N'S-001', N'Жүйе әкімшісі', N'sysadmin');

IF NOT EXISTS (SELECT 1 FROM dbo.rooms WHERE building=N'A' AND room_number=N'101')
    INSERT INTO dbo.rooms (building, room_number, description)
    VALUES (N'A', N'101', N'Дәріс кабинеті');
IF NOT EXISTS (SELECT 1 FROM dbo.rooms WHERE building=N'A' AND room_number=N'102')
    INSERT INTO dbo.rooms (building, room_number, description)
    VALUES (N'A', N'102', N'Компьютерлік кабинет');
IF NOT EXISTS (SELECT 1 FROM dbo.rooms WHERE building=N'B' AND room_number=N'201')
    INSERT INTO dbo.rooms (building, room_number, description)
    VALUES (N'B', N'201', N'Зертхана кабинеті');

IF NOT EXISTS (SELECT 1 FROM dbo.room_keys WHERE serial_number=N'KEY-A-101')
    INSERT INTO dbo.room_keys (room_id, serial_number)
    SELECT id, N'KEY-A-101' FROM dbo.rooms WHERE building=N'A' AND room_number=N'101';
IF NOT EXISTS (SELECT 1 FROM dbo.room_keys WHERE serial_number=N'KEY-A-102')
    INSERT INTO dbo.room_keys (room_id, serial_number)
    SELECT id, N'KEY-A-102' FROM dbo.rooms WHERE building=N'A' AND room_number=N'102';
IF NOT EXISTS (SELECT 1 FROM dbo.room_keys WHERE serial_number=N'KEY-B-201')
    INSERT INTO dbo.room_keys (room_id, serial_number)
    SELECT id, N'KEY-B-201' FROM dbo.rooms WHERE building=N'B' AND room_number=N'201';

SELECT id, staff_code, full_name, role FROM dbo.staff ORDER BY id;
SELECT k.id, r.building, r.room_number, k.serial_number, k.status
FROM dbo.room_keys AS k INNER JOIN dbo.rooms AS r ON r.id=k.room_id ORDER BY k.id;
