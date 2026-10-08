USE university_key_system;
GO
-- UC-03: кілт беру. UPDLOCK/HOLDLOCK бір кілттің қатар берілуін тежейді.
CREATE OR ALTER PROCEDURE dbo.sp_issue_key
    @KeyId BIGINT,
    @TeacherId BIGINT,
    @GuardId BIGINT,
    @DueAt DATETIME2(0) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @KeyStatus NVARCHAR(20) = NULL;
    DECLARE @TeacherValid BIT = 0;
    DECLARE @GuardValid BIT = 0;
    DECLARE @IssueId BIGINT;

    BEGIN TRY
        BEGIN TRANSACTION;
        SELECT @KeyStatus = status
        FROM dbo.room_keys WITH (UPDLOCK, HOLDLOCK)
        WHERE id = @KeyId;

        IF @KeyStatus IS NULL
            THROW 50001, N'Кілт табылмады', 1;
        IF @KeyStatus <> N'available'
            THROW 50002, N'Кілт қазір қолжетімсіз', 1;

        SELECT @TeacherValid = 1 FROM dbo.staff
        WHERE id = @TeacherId AND role = N'teacher' AND is_active = 1;
        IF @TeacherValid = 0
            THROW 50003, N'Белсенді оқытушы тіркелмеген', 1;

        SELECT @GuardValid = 1 FROM dbo.staff
        WHERE id = @GuardId AND role = N'guard' AND is_active = 1;
        IF @GuardValid = 0
            THROW 50004, N'Кілтті тек белсенді күзетші бере алады', 1;

        IF @DueAt IS NOT NULL AND @DueAt <= SYSDATETIME()
            THROW 50005, N'Жоспарлы қайтару уақыты болашақта болуы тиіс', 1;

        INSERT INTO dbo.key_issues(key_id, recipient_id, issued_by_id, due_at)
        VALUES (@KeyId, @TeacherId, @GuardId, @DueAt);
        SET @IssueId = CONVERT(BIGINT, SCOPE_IDENTITY());

        UPDATE dbo.room_keys SET status = N'issued' WHERE id = @KeyId;
        INSERT INTO dbo.key_audit (issue_id, key_id, actor_id, event_type, details)
        VALUES (@IssueId, @KeyId, @GuardId, N'issue', N'Оқытушыға кілт берілді');

        COMMIT TRANSACTION;
        SELECT @IssueId AS issue_id, N'Кілт берілді' AS result;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- UC-04: кілтті қайтару, ашық жазбаны жабу және аудит жасау.
CREATE OR ALTER PROCEDURE dbo.sp_return_key
    @KeyId BIGINT,
    @GuardId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @KeyStatus NVARCHAR(20) = NULL;
    DECLARE @GuardValid BIT = 0;
    DECLARE @IssueId BIGINT = NULL;

    BEGIN TRY
        BEGIN TRANSACTION;
        SELECT @KeyStatus = status
        FROM dbo.room_keys WITH (UPDLOCK, HOLDLOCK)
        WHERE id = @KeyId;

        IF @KeyStatus IS NULL
            THROW 50011, N'Кілт табылмады', 1;
        IF @KeyStatus <> N'issued'
            THROW 50012, N'Бұл кілт қазір берілмеген', 1;

        SELECT @GuardValid = 1 FROM dbo.staff
        WHERE id = @GuardId AND role = N'guard' AND is_active = 1;
        IF @GuardValid = 0
            THROW 50013, N'Қайтаруды тек белсенді күзетші растайды', 1;

        SELECT @IssueId = id
        FROM dbo.key_issues WITH (UPDLOCK, HOLDLOCK)
        WHERE key_id = @KeyId AND returned_at IS NULL;
        IF @IssueId IS NULL
            THROW 50014, N'Ашық беру жазбасы табылмады', 1;

        UPDATE dbo.key_issues
            SET returned_at = SYSDATETIME(), returned_to_id = @GuardId
        WHERE id = @IssueId;
        UPDATE dbo.room_keys SET status = N'available' WHERE id = @KeyId;
        INSERT INTO dbo.key_audit (issue_id, key_id, actor_id, event_type, details)
        VALUES (@IssueId, @KeyId, @GuardId, N'return', N'Кілт қайтарылып қабылданды');

        COMMIT TRANSACTION;
        SELECT @IssueId AS issue_id, N'Кілт қайтарылды' AS result;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

SELECT name FROM sys.procedures WHERE name IN (N'sp_issue_key', N'sp_return_key');
