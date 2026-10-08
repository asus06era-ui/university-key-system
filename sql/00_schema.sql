-- Microsoft SQL Server / SSMS (T-SQL). Сабақ кестесімен интеграция жоқ.
-- Жаңа university_key_system дерекқорын жасау.
IF DB_ID(N'university_key_system') IS NULL
    CREATE DATABASE university_key_system;
GO
USE university_key_system;
GO

IF OBJECT_ID(N'dbo.staff', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.staff (
        id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_staff PRIMARY KEY,
        staff_code NVARCHAR(32) NOT NULL CONSTRAINT UQ_staff_code UNIQUE,
        full_name NVARCHAR(150) NOT NULL,
        role NVARCHAR(20) NOT NULL,
        is_active BIT NOT NULL CONSTRAINT DF_staff_is_active DEFAULT (1),
        created_at DATETIME2(0) NOT NULL CONSTRAINT DF_staff_created_at DEFAULT (SYSDATETIME()),
        CONSTRAINT CK_staff_role CHECK (role IN (N'teacher', N'guard', N'admin_rep', N'sysadmin'))
    );
END;
GO

IF OBJECT_ID(N'dbo.rooms', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.rooms (
        id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_rooms PRIMARY KEY,
        building NVARCHAR(50) NOT NULL,
        room_number NVARCHAR(20) NOT NULL,
        description NVARCHAR(255) NULL,
        CONSTRAINT UQ_rooms_building_number UNIQUE (building, room_number)
    );
END;
GO

IF OBJECT_ID(N'dbo.room_keys', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.room_keys (
        id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_room_keys PRIMARY KEY,
        room_id BIGINT NOT NULL CONSTRAINT UQ_room_keys_room UNIQUE,
        serial_number NVARCHAR(40) NOT NULL CONSTRAINT UQ_room_keys_serial UNIQUE,
        status NVARCHAR(20) NOT NULL CONSTRAINT DF_room_keys_status DEFAULT (N'available'),
        CONSTRAINT FK_room_keys_room FOREIGN KEY (room_id) REFERENCES dbo.rooms(id),
        CONSTRAINT CK_room_keys_status CHECK (status IN (N'available', N'issued', N'maintenance'))
    );
END;
GO

IF OBJECT_ID(N'dbo.key_issues', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.key_issues (
        id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_key_issues PRIMARY KEY,
        key_id BIGINT NOT NULL,
        recipient_id BIGINT NOT NULL,
        issued_by_id BIGINT NOT NULL,
        issued_at DATETIME2(0) NOT NULL CONSTRAINT DF_key_issues_issued DEFAULT (SYSDATETIME()),
        due_at DATETIME2(0) NULL,
        returned_at DATETIME2(0) NULL,
        returned_to_id BIGINT NULL,
        CONSTRAINT FK_key_issues_key FOREIGN KEY (key_id) REFERENCES dbo.room_keys(id),
        CONSTRAINT FK_key_issues_recipient FOREIGN KEY (recipient_id) REFERENCES dbo.staff(id),
        CONSTRAINT FK_key_issues_issuer FOREIGN KEY (issued_by_id) REFERENCES dbo.staff(id),
        CONSTRAINT FK_key_issues_returner FOREIGN KEY (returned_to_id) REFERENCES dbo.staff(id),
        CONSTRAINT CK_key_issues_return_time CHECK (returned_at IS NULL OR returned_at >= issued_at),
        CONSTRAINT CK_key_issues_return_pair CHECK (
            (returned_at IS NULL AND returned_to_id IS NULL) OR
            (returned_at IS NOT NULL AND returned_to_id IS NOT NULL)
        )
    );
END;
GO

-- Әр кілттің БІР ГАНА ашық беру жазбасы болуы мүмкін.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.key_issues') AND name = N'UX_key_issues_active_key'
)
BEGIN
    CREATE UNIQUE INDEX UX_key_issues_active_key
        ON dbo.key_issues(key_id) WHERE returned_at IS NULL;
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'dbo.key_issues') AND name=N'IX_key_issues_recipient')
    CREATE INDEX IX_key_issues_recipient ON dbo.key_issues(recipient_id, issued_at);
GO

IF OBJECT_ID(N'dbo.key_audit', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.key_audit (
        id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_key_audit PRIMARY KEY,
        issue_id BIGINT NULL,
        key_id BIGINT NOT NULL,
        actor_id BIGINT NOT NULL,
        event_type NVARCHAR(20) NOT NULL,
        event_time DATETIME2(0) NOT NULL CONSTRAINT DF_key_audit_time DEFAULT (SYSDATETIME()),
        details NVARCHAR(500) NULL,
        CONSTRAINT FK_key_audit_issue FOREIGN KEY (issue_id) REFERENCES dbo.key_issues(id),
        CONSTRAINT FK_key_audit_key FOREIGN KEY (key_id) REFERENCES dbo.room_keys(id),
        CONSTRAINT FK_key_audit_actor FOREIGN KEY (actor_id) REFERENCES dbo.staff(id),
        CONSTRAINT CK_key_audit_type CHECK (event_type IN (N'issue', N'return', N'maintenance'))
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'dbo.key_audit') AND name=N'IX_key_audit_key')
    CREATE INDEX IX_key_audit_key ON dbo.key_audit(key_id, event_time);
GO

SELECT N'Құрылым дайын' AS result, DB_NAME() AS database_name;
SELECT name FROM sys.tables WHERE schema_id = SCHEMA_ID(N'dbo') ORDER BY name;
