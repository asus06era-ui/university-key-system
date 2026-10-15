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
