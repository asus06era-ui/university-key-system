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


