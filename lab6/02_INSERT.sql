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
