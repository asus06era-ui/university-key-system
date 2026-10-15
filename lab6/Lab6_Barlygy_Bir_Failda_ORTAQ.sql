-- 6-ZERTHANA: 5-fail bir-birinen keiyn avto-oryndalady. ORTAQ DB: university_key_system_kz.

-- 6-ZERTHANA | 01: CREATE TABLE, PRIMARY KEY, FOREIGN KEY, CHECK
-- ORTAQ DB: university_key_system_kz (5-zhane 6-zerthana bir DB)
-- 5-lab SQL basynda oryndalsa, munda bar kesteler saqtalady.
-- DROP TABLE / DROP DATABASE KOLDANYLMAIDY.

-- Universitet kabinetterinin kiltin beru zhane kaitaru zhuiesi
-- SSMS ushin barlygy bir failda. F5 basyp tolyk oryndauga bolady.
-- Eskertu: university_key_system_kz atty ZHANA derekkor kurady.
-- Buryngy university_key_system derekkory ozgermeidi.

-- =============================================================
-- UNIVERSITET KABINETTERININ KILTIN BERU ZHANE KAITARU ZHUIESI
-- SQL Server (SSMS / T-SQL)
-- ATAULAR: KAZAKSHA SOZDER, LATYN ARIPTERI
-- =============================================================
-- Eskertu: bul skript buryngy university_key_system bazasyn ozgertpeidi.
-- Zhana database: university_key_system_kz

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




-- 6-ZERTHANA | 02: INSERT. Lab-5 derekterin saqtap, tek zhana synak derekterin kosady.
USE university_key_system_kz;
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM dbo.kyzmetkerler WHERE kyzmetker_kody = N'T-003')
        INSERT INTO dbo.kyzmetkerler(kyzmetker_kody, aty_zhoni, roli)
        VALUES (N'T-003', N'Әлия Бақытқызы', N'okytushy');

    IF NOT EXISTS (SELECT 1 FROM dbo.kabinetter WHERE gimarat = N'B' AND kabinet_nomeri = N'202')
        INSERT INTO dbo.kabinetter(gimarat, kabinet_nomeri, sipattama)
        VALUES (N'B', N'202', N'6-зертхананың тәжірибелік кабинеті');

    -- Bir kabinetke bir negizgi kilt: erterektegi bolshek kilt bar bolsa, katelik beremiz.
    IF EXISTS (
        SELECT 1 FROM dbo.kiltter k
        JOIN dbo.kabinetter b ON b.kabinet_id = k.kabinet_id
        WHERE b.gimarat = N'B' AND b.kabinet_nomeri = N'202'
          AND k.kilt_nomeri <> N'KEY-B-202'
    )
    BEGIN
        ;THROW 52001, N'B-202 kabinetinde basqa negizgi kilt bar; kolmen tekseriniz', 1;
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.kiltter WHERE kilt_nomeri = N'KEY-B-202')
        INSERT INTO dbo.kiltter(kabinet_id, kilt_nomeri)
        SELECT kabinet_id, N'KEY-B-202' FROM dbo.kabinetter
        WHERE gimarat = N'B' AND kabinet_nomeri = N'202';

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

SELECT kyzmetker_id, kyzmetker_kody, aty_zhoni, roli
FROM dbo.kyzmetkerler WHERE kyzmetker_kody = N'T-003';
SELECT k.kilt_id, b.gimarat, b.kabinet_nomeri, k.kilt_nomeri, k.martebe
FROM dbo.kiltter k JOIN dbo.kabinetter b ON b.kabinet_id = k.kabinet_id
WHERE k.kilt_nomeri = N'KEY-B-202';
GO


-- 6-ZERTHANA | 03: UPDATE. Tek 6-labka ushin kosylgan B-202 kabinetin ozgertemiz.
-- Bul shared DB-dagi basqa kabinettardi (A-101, A-102, B-201) ozgertpeidi.
USE university_key_system_kz;
GO
SELECT kabinet_id, gimarat, kabinet_nomeri, sipattama AS ozgertuge_deiin
FROM dbo.kabinetter WHERE gimarat = N'B' AND kabinet_nomeri = N'202';

UPDATE dbo.kabinetter
SET sipattama = N'Тәжірибелік кабинет (жаңартылды)'
WHERE gimarat = N'B' AND kabinet_nomeri = N'202';

SELECT @@ROWCOUNT AS ozgergen_zhazba_sany;
SELECT kabinet_id, gimarat, kabinet_nomeri, sipattama AS ozgertkennen_keiin
FROM dbo.kabinetter WHERE gimarat = N'B' AND kabinet_nomeri = N'202';
GO


-- 6-ZERTHANA | 04: DELETE. Tek arnaiy osy fail koskan synak kyzmetkerin oshiredi.
-- Lab-5-tegi tarihi zhazbalarga tiispeidi. DROP/DELETE WHERE-syz zhok.
USE university_key_system_kz;
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM dbo.kyzmetkerler WHERE kyzmetker_kody = N'TEST-DELETE-001')
        INSERT INTO dbo.kyzmetkerler(kyzmetker_kody, aty_zhoni, roli)
        VALUES (N'TEST-DELETE-001', N'Уақытша сынақ қызметкері', N'akimshilik');

    -- Derekkordy sau saqtau: testerdi tarihta paidalansak, oshirmeu.
    IF EXISTS (
        SELECT 1 FROM dbo.kyzmetkerler s
        WHERE s.kyzmetker_kody = N'TEST-DELETE-001'
          AND (
            EXISTS (SELECT 1 FROM dbo.kilt_beru_tarihy t WHERE t.okytushy_id = s.kyzmetker_id
                OR t.bergen_kuzetshi_id = s.kyzmetker_id OR t.kabildagan_kuzetshi_id = s.kyzmetker_id)
            OR EXISTS (SELECT 1 FROM dbo.kilt_amal_tarihy a WHERE a.oryndagan_kyzmetker_id = s.kyzmetker_id)
          )
    )
    BEGIN
        ;THROW 52002, N'Synak kyzmetkeri tarihta paidalanylgan, oshiruge bolmaidy', 1;
    END;

    DELETE FROM dbo.kyzmetkerler
    WHERE kyzmetker_kody = N'TEST-DELETE-001'
      AND aty_zhoni = N'Уақытша сынақ қызметкері';

    DECLARE @Oshirilgen INT = @@ROWCOUNT;
    COMMIT TRANSACTION;

    SELECT @Oshirilgen AS oshirilgen_zhazba_sany;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
SELECT COUNT(*) AS kalgan_synak_zhazbasy
FROM dbo.kyzmetkerler WHERE kyzmetker_kody = N'TEST-DELETE-001';
GO


-- 6-ZERTHANA | 05: TEKSERU. 5 zhane 6 lab bir bazada saqtalady.
USE university_key_system_kz;
GO
SELECT DB_NAME() AS ortaq_derekkor;

SELECT name AS keste_aty FROM sys.tables
WHERE schema_id = SCHEMA_ID(N'dbo') ORDER BY name;

SELECT fk.name AS bailanys_aty,
       OBJECT_NAME(fk.parent_object_id) AS bastaushy_keste,
       OBJECT_NAME(fk.referenced_object_id) AS bailanysty_keste
FROM sys.foreign_keys AS fk
WHERE fk.parent_object_id IN (
    OBJECT_ID(N'dbo.kiltter'), OBJECT_ID(N'dbo.kilt_beru_tarihy'), OBJECT_ID(N'dbo.kilt_amal_tarihy')
)
ORDER BY bastaushy_keste, bailanys_aty;

SELECT kyzmetker_id, kyzmetker_kody, aty_zhoni, roli
FROM dbo.kyzmetkerler ORDER BY kyzmetker_id;
SELECT kabinet_id, gimarat, kabinet_nomeri, sipattama
FROM dbo.kabinetter ORDER BY kabinet_id;
SELECT kilt_id, kabinet_id, kilt_nomeri, martebe
FROM dbo.kiltter ORDER BY kilt_id;
SELECT beru_id, kilt_id, okytushy_id, berilgen_uakyty, kaitarylgan_uakyty
FROM dbo.kilt_beru_tarihy ORDER BY beru_id;
SELECT amal_id, beru_id, kilt_id, amal_turi, amal_uakyty
FROM dbo.kilt_amal_tarihy ORDER BY amal_id;

-- Lab-5 procs/views bar ekenin tekseru.
SELECT name AS procedura_aty FROM sys.procedures
WHERE name IN (N'sp_kilt_beru', N'sp_kilt_kaitaru') ORDER BY name;
SELECT name AS korinis_aty FROM sys.views
WHERE name IN (N'v_kiltter_kui', N'v_kilt_beru_tarihy') ORDER BY name;

SELECT COUNT(*) AS synak_oshirilgenin_rastau
FROM dbo.kyzmetkerler WHERE kyzmetker_kody = N'TEST-DELETE-001';
GO
