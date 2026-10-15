-- 6-zertkhana: 5 kabat zhane 10 okytushy
-- Ortak derekkor: university_key_system_kz
-- Tek SQL Server (SSMS) ushin. Buryngy kilt beru tarihy saktalady.
-- Bul faildy kaita oryndau zhana kabinetter men okytushylardy kobeitpeidi.
USE university_key_system_kz;
GO

-- 1. Buryngy A/B gimarattaryn 1/2 kabattar retinde belgileu.
-- ESKERTU: bul zhobada 'gimarat' bagany kabat ushyn koldanylady.
UPDATE dbo.kabinetter
SET gimarat = CASE
    WHEN gimarat = N'A' THEN N'1'
    WHEN gimarat = N'B' THEN N'2'
    ELSE gimarat
END
WHERE gimarat IN (N'A', N'B');

-- 2. Ush zhana kabinet: 3, 4, 5 kabattar.
INSERT INTO dbo.kabinetter (gimarat, kabinet_nomeri, sipattama)
SELECT x.gimarat, x.kabinet_nomeri, x.sipattama
FROM (VALUES
    (N'3', N'301', N'3-қабат дәріс кабинеті'),
    (N'4', N'401', N'4-қабат компьютерлік кабинет'),
    (N'5', N'501', N'5-қабат зертхана')
) AS x(gimarat, kabinet_nomeri, sipattama)
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.kabinetter AS k
    WHERE k.gimarat = x.gimarat AND k.kabinet_nomeri = x.kabinet_nomeri
);

-- 3. Zhana kabinetterge kiltterdi tirkeu.
INSERT INTO dbo.kiltter (kabinet_id, kilt_nomeri)
SELECT k.kabinet_id,
       CONCAT(N'KEY-', k.gimarat, N'-', k.kabinet_nomeri)
FROM dbo.kabinetter AS k
WHERE ((k.gimarat = N'3' AND k.kabinet_nomeri = N'301')
    OR (k.gimarat = N'4' AND k.kabinet_nomeri = N'401')
    OR (k.gimarat = N'5' AND k.kabinet_nomeri = N'501'))
  AND NOT EXISTS (
    SELECT 1 FROM dbo.kiltter AS t WHERE t.kabinet_id = k.kabinet_id
  );

-- 4. Buryngy T-001, T-002, T-003 saqtalady; 7 zhana okytushy.
INSERT INTO dbo.kyzmetkerler (kyzmetker_kody, aty_zhoni, roli)
SELECT x.kody, x.aty_zhoni, N'okytushy'
FROM (VALUES
    (N'T-004', N'Асқар Нұрланұлы'),
    (N'T-005', N'Мадина Ерболқызы'),
    (N'T-006', N'Данияр Болатұлы'),
    (N'T-007', N'Аружан Қайратқызы'),
    (N'T-008', N'Ермек Талғатұлы'),
    (N'T-009', N'Айгерім Мұратқызы'),
    (N'T-010', N'Самат Әлібекұлы')
) AS x(kody, aty_zhoni)
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.kyzmetkerler AS k
    WHERE k.kyzmetker_kody = x.kody
);

-- 5. Tekseru: kabinetter, okytushylar, kiltter.
SELECT kabinet_id, gimarat AS kabat, kabinet_nomeri, sipattama
FROM dbo.kabinetter
ORDER BY TRY_CONVERT(INT, gimarat), kabinet_nomeri;

SELECT kyzmetker_id, kyzmetker_kody, aty_zhoni, roli
FROM dbo.kyzmetkerler
WHERE roli = N'okytushy'
ORDER BY kyzmetker_kody;

SELECT COUNT(*) AS mugalim_sany
FROM dbo.kyzmetkerler
WHERE roli = N'okytushy';

SELECT k.gimarat AS kabat, k.kabinet_nomeri, t.kilt_nomeri, t.martebe
FROM dbo.kabinetter AS k
LEFT JOIN dbo.kiltter AS t ON t.kabinet_id = k.kabinet_id
ORDER BY TRY_CONVERT(INT, k.gimarat), k.kabinet_nomeri;
