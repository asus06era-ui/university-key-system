IF DB_ID(N'university_key_system_kz') IS NULL
BEGIN
    CREATE DATABASE university_key_system_kz;
END;
GO

USE university_key_system_kz;
GO

-- 1. Okytushylar, kuzetshiler zhane basqa kyzmetkerler.
IF OBJECT_ID(N'dbo.kyzmetkerler', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.kyzmetkerler (
        kyzmetker_id BIGINT IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_kyzmetkerler PRIMARY KEY,
        kyzmetker_kody NVARCHAR(32) NOT NULL
            CONSTRAINT UQ_kyzmetkerler_kody UNIQUE,
        aty_zhoni NVARCHAR(150) NOT NULL,
        roli NVARCHAR(30) NOT NULL,
        belsendi BIT NOT NULL
            CONSTRAINT DF_kyzmetkerler_belsendi DEFAULT (1),
        tirkelgen_uakyty DATETIME2(0) NOT NULL
            CONSTRAINT DF_kyzmetkerler_tirkelgen DEFAULT (SYSDATETIME()),
        CONSTRAINT CK_kyzmetkerler_roli CHECK (
            roli IN (N'okytushy', N'kuzetshi', N'akimshilik', N'zhuiye_akimshisi')
        )
    );
END;
GO

-- 2. Universitet kabinetteri.
IF OBJECT_ID(N'dbo.kabinetter', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.kabinetter (
        kabinet_id BIGINT IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_kabinetter PRIMARY KEY,
        gimarat NVARCHAR(50) NOT NULL,
        kabinet_nomeri NVARCHAR(20) NOT NULL,
        sipattama NVARCHAR(255) NULL,
        CONSTRAINT UQ_kabinetter_oryn UNIQUE (gimarat, kabinet_nomeri)
    );
END;
GO

-- 3. Kabinet kiltteri, kilt martebesi.
IF OBJECT_ID(N'dbo.kiltter', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.kiltter (
        kilt_id BIGINT IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_kiltter PRIMARY KEY,
        kabinet_id BIGINT NOT NULL
            CONSTRAINT UQ_kiltter_kabinet UNIQUE,
        kilt_nomeri NVARCHAR(40) NOT NULL
            CONSTRAINT UQ_kiltter_nomeri UNIQUE,
        martebe NVARCHAR(20) NOT NULL
            CONSTRAINT DF_kiltter_martebe DEFAULT (N'bos'),
        CONSTRAINT FK_kiltter_kabinet FOREIGN KEY (kabinet_id)
            REFERENCES dbo.kabinetter(kabinet_id),
        CONSTRAINT CK_kiltter_martebe CHECK (
            martebe IN (N'bos', N'berilgen', N'zhondeude')
        )
    );
END;
GO

-- 4. Kilt beru zhane kaitaru zhazbalary.
IF OBJECT_ID(N'dbo.kilt_beru_tarihy', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.kilt_beru_tarihy (
        beru_id BIGINT IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_kilt_beru_tarihy PRIMARY KEY,
        kilt_id BIGINT NOT NULL,
        okytushy_id BIGINT NOT NULL,
        bergen_kuzetshi_id BIGINT NOT NULL,
        berilgen_uakyty DATETIME2(0) NOT NULL
            CONSTRAINT DF_kilt_beru_uakyty DEFAULT (SYSDATETIME()),
        kaitaru_merzimi DATETIME2(0) NULL,
        kaitarylgan_uakyty DATETIME2(0) NULL,
        kabildagan_kuzetshi_id BIGINT NULL,
        CONSTRAINT FK_kilt_beru_kilt FOREIGN KEY (kilt_id)
            REFERENCES dbo.kiltter(kilt_id),
        CONSTRAINT FK_kilt_beru_okytushy FOREIGN KEY (okytushy_id)
            REFERENCES dbo.kyzmetkerler(kyzmetker_id),
        CONSTRAINT FK_kilt_beru_bergen FOREIGN KEY (bergen_kuzetshi_id)
            REFERENCES dbo.kyzmetkerler(kyzmetker_id),
        CONSTRAINT FK_kilt_beru_kabildagan FOREIGN KEY (kabildagan_kuzetshi_id)
            REFERENCES dbo.kyzmetkerler(kyzmetker_id),
        CONSTRAINT CK_kilt_beru_kaitaru_uakyty CHECK (
            kaitarylgan_uakyty IS NULL OR kaitarylgan_uakyty >= berilgen_uakyty
        ),
        CONSTRAINT CK_kilt_beru_kaitaru_zhuby CHECK (
            (kaitarylgan_uakyty IS NULL AND kabildagan_kuzetshi_id IS NULL)
            OR
            (kaitarylgan_uakyty IS NOT NULL AND kabildagan_kuzetshi_id IS NOT NULL)
        )
    );
END;
GO

-- Bir kilt bir uakytta bir gana okytushyga berile alady.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.kilt_beru_tarihy')
      AND name = N'UX_kilt_beru_ashyk'
)
BEGIN
    CREATE UNIQUE INDEX UX_kilt_beru_ashyk
        ON dbo.kilt_beru_tarihy(kilt_id)
        WHERE kaitarylgan_uakyty IS NULL;
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.kilt_beru_tarihy')
      AND name = N'IX_kilt_beru_okytushy'
)
BEGIN
    CREATE INDEX IX_kilt_beru_okytushy
        ON dbo.kilt_beru_tarihy(okytushy_id, berilgen_uakyty);
END;
GO

-- 5. Kiltpen zhasalgan barlyk amaldardyn zhaksha zhur naly.
IF OBJECT_ID(N'dbo.kilt_amal_tarihy', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.kilt_amal_tarihy (
        amal_id BIGINT IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_kilt_amal_tarihy PRIMARY KEY,
        beru_id BIGINT NULL,
        kilt_id BIGINT NOT NULL,
        oryndagan_kyzmetker_id BIGINT NOT NULL,
        amal_turi NVARCHAR(20) NOT NULL,
        amal_uakyty DATETIME2(0) NOT NULL
            CONSTRAINT DF_kilt_amal_uakyty DEFAULT (SYSDATETIME()),
        tusinikteme NVARCHAR(500) NULL,
        CONSTRAINT FK_kilt_amal_beru FOREIGN KEY (beru_id)
            REFERENCES dbo.kilt_beru_tarihy(beru_id),
        CONSTRAINT FK_kilt_amal_kilt FOREIGN KEY (kilt_id)
            REFERENCES dbo.kiltter(kilt_id),
        CONSTRAINT FK_kilt_amal_kyzmetker FOREIGN KEY (oryndagan_kyzmetker_id)
            REFERENCES dbo.kyzmetkerler(kyzmetker_id),
        CONSTRAINT CK_kilt_amal_turi CHECK (
            amal_turi IN (N'beru', N'kaitaru', N'zhondeu')
        )
    );
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.kilt_amal_tarihy')
      AND name = N'IX_kilt_amal_kilt'
)
BEGIN
    CREATE INDEX IX_kilt_amal_kilt
        ON dbo.kilt_amal_tarihy(kilt_id, amal_uakyty);
END;
GO

PRINT N'01: Database pen 5 keste dayyn.';
SELECT DB_NAME() AS derekkor_aty, name AS keste_aty
FROM sys.tables
WHERE schema_id = SCHEMA_ID(N'dbo')
ORDER BY name;
GO


-- BASTAPKY DEREKTER: kaita oryndalganda birdey zhazbalar kobeimeidi.
USE university_key_system_kz;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.kyzmetkerler WHERE kyzmetker_kody = N'T-001')
    INSERT INTO dbo.kyzmetkerler (kyzmetker_kody, aty_zhoni, roli)
    VALUES (N'T-001', N'Айдана Серікқызы', N'okytushy');

IF NOT EXISTS (SELECT 1 FROM dbo.kyzmetkerler WHERE kyzmetker_kody = N'T-002')
    INSERT INTO dbo.kyzmetkerler (kyzmetker_kody, aty_zhoni, roli)
    VALUES (N'T-002', N'Нұржан Ермекұлы', N'okytushy');

IF NOT EXISTS (SELECT 1 FROM dbo.kyzmetkerler WHERE kyzmetker_kody = N'G-001')
    INSERT INTO dbo.kyzmetkerler (kyzmetker_kody, aty_zhoni, roli)
    VALUES (N'G-001', N'Марат Қасымұлы', N'kuzetshi');

IF NOT EXISTS (SELECT 1 FROM dbo.kyzmetkerler WHERE kyzmetker_kody = N'A-001')
    INSERT INTO dbo.kyzmetkerler (kyzmetker_kody, aty_zhoni, roli)
    VALUES (N'A-001', N'Әкімшілік өкілі', N'akimshilik');

IF NOT EXISTS (SELECT 1 FROM dbo.kyzmetkerler WHERE kyzmetker_kody = N'S-001')
    INSERT INTO dbo.kyzmetkerler (kyzmetker_kody, aty_zhoni, roli)
    VALUES (N'S-001', N'Жүйе әкімшісі', N'zhuiye_akimshisi');

IF NOT EXISTS (SELECT 1 FROM dbo.kabinetter WHERE gimarat = N'A' AND kabinet_nomeri = N'101')
    INSERT INTO dbo.kabinetter (gimarat, kabinet_nomeri, sipattama)
    VALUES (N'A', N'101', N'Дәріс кабинеті');

IF NOT EXISTS (SELECT 1 FROM dbo.kabinetter WHERE gimarat = N'A' AND kabinet_nomeri = N'102')
    INSERT INTO dbo.kabinetter (gimarat, kabinet_nomeri, sipattama)
    VALUES (N'A', N'102', N'Компьютерлік кабинет');

IF NOT EXISTS (SELECT 1 FROM dbo.kabinetter WHERE gimarat = N'B' AND kabinet_nomeri = N'201')
    INSERT INTO dbo.kabinetter (gimarat, kabinet_nomeri, sipattama)
    VALUES (N'B', N'201', N'Зертхана кабинеті');

IF NOT EXISTS (SELECT 1 FROM dbo.kiltter WHERE kilt_nomeri = N'KEY-A-101')
    INSERT INTO dbo.kiltter (kabinet_id, kilt_nomeri)
    SELECT kabinet_id, N'KEY-A-101' FROM dbo.kabinetter
    WHERE gimarat = N'A' AND kabinet_nomeri = N'101';

IF NOT EXISTS (SELECT 1 FROM dbo.kiltter WHERE kilt_nomeri = N'KEY-A-102')
    INSERT INTO dbo.kiltter (kabinet_id, kilt_nomeri)
    SELECT kabinet_id, N'KEY-A-102' FROM dbo.kabinetter
    WHERE gimarat = N'A' AND kabinet_nomeri = N'102';

IF NOT EXISTS (SELECT 1 FROM dbo.kiltter WHERE kilt_nomeri = N'KEY-B-201')
    INSERT INTO dbo.kiltter (kabinet_id, kilt_nomeri)
    SELECT kabinet_id, N'KEY-B-201' FROM dbo.kabinetter
    WHERE gimarat = N'B' AND kabinet_nomeri = N'201';

PRINT N'02: Bastapky derekter engizildi.';
SELECT kyzmetker_id, kyzmetker_kody, aty_zhoni, roli
FROM dbo.kyzmetkerler ORDER BY kyzmetker_id;
SELECT k.kilt_id, b.gimarat, b.kabinet_nomeri, k.kilt_nomeri, k.martebe
FROM dbo.kiltter AS k
JOIN dbo.kabinetter AS b ON b.kabinet_id = k.kabinet_id
ORDER BY k.kilt_id;
GO


-- KILT BERU ZHANE KILT KAITARU PROCEDURALARY.
USE university_key_system_kz;
GO

CREATE OR ALTER PROCEDURE dbo.sp_kilt_beru
    @KiltId BIGINT,
    @OkytushyId BIGINT,
    @KuzetshiId BIGINT,
    @KaitaruMerzimi DATETIME2(0) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @KiltMartebesi NVARCHAR(20) = NULL;
    DECLARE @BeruId BIGINT;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- UPDLOCK, HOLDLOCK: bir kilt eki adamga bir mezgilde berilmeui ushin.
        SELECT @KiltMartebesi = martebe
        FROM dbo.kiltter WITH (UPDLOCK, HOLDLOCK)
        WHERE kilt_id = @KiltId;

        IF @KiltMartebesi IS NULL
        BEGIN
            ;THROW 51001, N'Kilt tabylmady', 1;
        END;
        IF @KiltMartebesi <> N'bos'
        BEGIN
            ;THROW 51002, N'Bul kilt kazir bos emes', 1;
        END;

        IF NOT EXISTS (
            SELECT 1 FROM dbo.kyzmetkerler
            WHERE kyzmetker_id = @OkytushyId
              AND roli = N'okytushy' AND belsendi = 1
        )
        BEGIN
            ;THROW 51003, N'Belsendi okytushy tabylmady', 1;
        END;

        IF NOT EXISTS (
            SELECT 1 FROM dbo.kyzmetkerler
            WHERE kyzmetker_id = @KuzetshiId
              AND roli = N'kuzetshi' AND belsendi = 1
        )
        BEGIN
            ;THROW 51004, N'Kilt tek belsendi kuzetshi arkyly beriledi', 1;
        END;

        IF @KaitaruMerzimi IS NOT NULL AND @KaitaruMerzimi <= SYSDATETIME()
        BEGIN
            ;THROW 51005, N'Kaitaru merzimi bolashakta boluy kerek', 1;
        END;

        INSERT INTO dbo.kilt_beru_tarihy
            (kilt_id, okytushy_id, bergen_kuzetshi_id, kaitaru_merzimi)
        VALUES (@KiltId, @OkytushyId, @KuzetshiId, @KaitaruMerzimi);

        SET @BeruId = CONVERT(BIGINT, SCOPE_IDENTITY());

        UPDATE dbo.kiltter
        SET martebe = N'berilgen'
        WHERE kilt_id = @KiltId;

        INSERT INTO dbo.kilt_amal_tarihy
            (beru_id, kilt_id, oryndagan_kyzmetker_id, amal_turi, tusinikteme)
        VALUES (@BeruId, @KiltId, @KuzetshiId, N'beru', N'Okytushyga kilt berildi');

        COMMIT TRANSACTION;
        SELECT @BeruId AS beru_id, N'Kilt berildi' AS natizhe;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_kilt_kaitaru
    @KiltId BIGINT,
    @KuzetshiId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @KiltMartebesi NVARCHAR(20) = NULL;
    DECLARE @BeruId BIGINT = NULL;

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT @KiltMartebesi = martebe
        FROM dbo.kiltter WITH (UPDLOCK, HOLDLOCK)
        WHERE kilt_id = @KiltId;

        IF @KiltMartebesi IS NULL
        BEGIN
            ;THROW 51011, N'Kilt tabylmady', 1;
        END;
        IF @KiltMartebesi <> N'berilgen'
        BEGIN
            ;THROW 51012, N'Bul kilt kazir berilmegen', 1;
        END;

        IF NOT EXISTS (
            SELECT 1 FROM dbo.kyzmetkerler
            WHERE kyzmetker_id = @KuzetshiId
              AND roli = N'kuzetshi' AND belsendi = 1
        )
        BEGIN
            ;THROW 51013, N'Kaitarudy belsendi kuzetshi gana rastai alady', 1;
        END;

        SELECT @BeruId = beru_id
        FROM dbo.kilt_beru_tarihy WITH (UPDLOCK, HOLDLOCK)
        WHERE kilt_id = @KiltId AND kaitarylgan_uakyty IS NULL;

        IF @BeruId IS NULL
        BEGIN
            ;THROW 51014, N'Ashyk beru zhazbasy tabylmady', 1;
        END;

        UPDATE dbo.kilt_beru_tarihy
        SET kaitarylgan_uakyty = SYSDATETIME(),
            kabildagan_kuzetshi_id = @KuzetshiId
        WHERE beru_id = @BeruId;

        UPDATE dbo.kiltter
        SET martebe = N'bos'
        WHERE kilt_id = @KiltId;

        INSERT INTO dbo.kilt_amal_tarihy
            (beru_id, kilt_id, oryndagan_kyzmetker_id, amal_turi, tusinikteme)
        VALUES (@BeruId, @KiltId, @KuzetshiId, N'kaitaru', N'Kilt kaitarylyp kabyldandy');

        COMMIT TRANSACTION;
        SELECT @BeruId AS beru_id, N'Kilt kaitaryldy' AS natizhe;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

PRINT N'03: Eki procedura dayyn.';
SELECT name AS procedura_aty
FROM sys.procedures
WHERE name IN (N'sp_kilt_beru', N'sp_kilt_kaitaru')
ORDER BY name;
GO


-- BIR RET ORYNDALATYN MISAL: A-101 kiltin beru, sosyn kaitaru.
-- Ekinshi ret oryndasa, tarihta buryn zhazba bar bolsa kaytalamaydy.
USE university_key_system_kz;
GO

DECLARE @KiltId BIGINT = (
    SELECT kilt_id FROM dbo.kiltter WHERE kilt_nomeri = N'KEY-A-101'
);
DECLARE @OkytushyId BIGINT = (
    SELECT kyzmetker_id FROM dbo.kyzmetkerler WHERE kyzmetker_kody = N'T-001'
);
DECLARE @KuzetshiId BIGINT = (
    SELECT kyzmetker_id FROM dbo.kyzmetkerler WHERE kyzmetker_kody = N'G-001'
);
DECLARE @KaitaruMerzimi DATETIME2(0) = DATEADD(HOUR, 2, SYSDATETIME());

IF @KiltId IS NOT NULL AND @OkytushyId IS NOT NULL AND @KuzetshiId IS NOT NULL
   AND EXISTS (SELECT 1 FROM dbo.kiltter WHERE kilt_id = @KiltId AND martebe = N'bos')
   AND NOT EXISTS (SELECT 1 FROM dbo.kilt_beru_tarihy WHERE kilt_id = @KiltId)
BEGIN
    EXEC dbo.sp_kilt_beru
        @KiltId = @KiltId,
        @OkytushyId = @OkytushyId,
        @KuzetshiId = @KuzetshiId,
        @KaitaruMerzimi = @KaitaruMerzimi;

    SELECT kilt_id, kilt_nomeri, martebe AS berilgennen_keiin
    FROM dbo.kiltter WHERE kilt_id = @KiltId;

    EXEC dbo.sp_kilt_kaitaru
        @KiltId = @KiltId,
        @KuzetshiId = @KuzetshiId;

    PRINT N'04: A-101 kiltin beru zhane kaitaru synagy oryndaldy.';
END
ELSE
BEGIN
    PRINT N'04: Synak buryn zhasalgan nemese kilt bos emes. Derekkor ozgermegen.';
END;

SELECT kilt_id, kilt_nomeri, martebe
FROM dbo.kiltter ORDER BY kilt_id;

SELECT beru_id, kilt_id, okytushy_id, berilgen_uakyty,
       kaitaru_merzimi, kaitarylgan_uakyty
FROM dbo.kilt_beru_tarihy ORDER BY beru_id DESC;

SELECT amal_id, kilt_id, amal_turi, amal_uakyty
FROM dbo.kilt_amal_tarihy ORDER BY amal_id DESC;
GO


-- KILT KUII MEN TOLYK BERU/K AITARU TARIHY ES EPTERI.
USE university_key_system_kz;
GO

CREATE OR ALTER VIEW dbo.v_kiltter_kui
AS
SELECT
    k.kilt_id,
    CONCAT(b.gimarat, N'-', b.kabinet_nomeri) AS kabinet,
    k.kilt_nomeri,
    k.martebe,
    o.aty_zhoni AS kilt_kimde,
    t.berilgen_uakyty,
    t.kaitaru_merzimi
FROM dbo.kiltter AS k
INNER JOIN dbo.kabinetter AS b ON b.kabinet_id = k.kabinet_id
LEFT JOIN dbo.kilt_beru_tarihy AS t
    ON t.kilt_id = k.kilt_id AND t.kaitarylgan_uakyty IS NULL
LEFT JOIN dbo.kyzmetkerler AS o ON o.kyzmetker_id = t.okytushy_id;
GO

CREATE OR ALTER VIEW dbo.v_kilt_beru_tarihy
AS
SELECT
    t.beru_id,
    CONCAT(b.gimarat, N'-', b.kabinet_nomeri) AS kabinet,
    o.aty_zhoni AS okytushy_aty_zhoni,
    g.aty_zhoni AS bergen_kuzetshi,
    kg.aty_zhoni AS kabildagan_kuzetshi,
    t.berilgen_uakyty,
    t.kaitaru_merzimi,
    t.kaitarylgan_uakyty,
    CASE
        WHEN t.kaitarylgan_uakyty IS NULL THEN N'Berilgen'
        ELSE N'Kaitaryldy'
    END AS beru_martebesi
FROM dbo.kilt_beru_tarihy AS t
INNER JOIN dbo.kiltter AS k ON k.kilt_id = t.kilt_id
INNER JOIN dbo.kabinetter AS b ON b.kabinet_id = k.kabinet_id
INNER JOIN dbo.kyzmetkerler AS o ON o.kyzmetker_id = t.okytushy_id
INNER JOIN dbo.kyzmetkerler AS g ON g.kyzmetker_id = t.bergen_kuzetshi_id
LEFT JOIN dbo.kyzmetkerler AS kg ON kg.kyzmetker_id = t.kabildagan_kuzetshi_id;
GO

PRINT N'05: Eki VIEW dayyn. Natizheler tomende.';
SELECT * FROM dbo.v_kiltter_kui ORDER BY kabinet;
SELECT * FROM dbo.v_kilt_beru_tarihy ORDER BY beru_id DESC;
SELECT amal_turi, COUNT(*) AS amal_sany
FROM dbo.kilt_amal_tarihy
GROUP BY amal_turi
ORDER BY amal_turi;
GO