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
