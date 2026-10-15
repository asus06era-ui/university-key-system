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
