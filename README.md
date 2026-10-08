# Университет кабинеттерінің кілтін беру және қайтаруды басқару жүйесі

**5-зертханалық жұмыс:** Git және GitHub көмегімен ақпараттық жүйе жобасын басқару.

**Технология:** Microsoft SQL Server (T-SQL), SQL Server Management Studio (SSMS), Git және GitHub. Python, MySQL, сабақ кестесі модулі қолданылмайды.

## Жоба
Жүйе университет кабинеттерінің кілтін күзетші арқылы оқытушыға беруді және қайтаруды тіркейді. Дерекқорда персонал, кабинеттер, кілттер, беру/қайтару операциялары және аудит журналы сақталады.

**Рөлдер:** `teacher` (оқытушы), `guard` (күзетші), `admin_rep` (әкімшілік), `sysadmin` (жүйе әкімшісі).

**Негізгі объектілер:** `dbo.staff`, `dbo.rooms`, `dbo.room_keys`, `dbo.key_issues`, `dbo.key_audit`; процедуралар: `dbo.sp_issue_key`, `dbo.sp_return_key`.

**Бизнес-ережелер:** тек белсенді оқытушыға бос кілтті күзетші береді; бір кілт бір уақытта бір адамға ғана беріледі; қайтару уақыты, растаушы күзетші, аудит сақталады. SQL Server-де бұған транзакция, `UPDLOCK`, `HOLDLOCK`, filtered UNIQUE index көмектеседі.

## SSMS-та орындау реті
1. SSMS іске қосып, SQL Server-ге қосылыңыз (`hostel` дерекқорына емес, серверге қосылу жеткілікті).
2. `File → Open → File` арқылы `sql/00_schema.sql` ашыңыз → **Execute (F5)**. Бұл файл `university_key_system` дерекқорын өзі жасайды.
3. Сол ретпен `sql/01_seed.sql` → F5; `sql/02_procedures.sql` → F5; `sql/03_demo.sql` → F5.
4. `sql/04_reports.sql` файлы **feature/sql-reports** тармағында бар. Оны сол тармақтан ашып F5 басыңыз (немесе PR merge-ден кейін `main`-нен).
5. Object Explorer → Databases → Refresh → `university_key_system` → Tables, Programmability, Views арқылы объектілерді көріңіз.

`GO` — SSMS-тың batch бөлгіші. MySQL командалары (`AUTO_INCREMENT`, `ENGINE=InnoDB`, `DELIMITER`, `CALL`) бұл жобада қолданылмайды.

## Жылдам сұраулар
```sql
USE university_key_system;
GO
SELECT * FROM dbo.room_keys;
SELECT TOP (20) * FROM dbo.key_issues ORDER BY id DESC;
SELECT TOP (20) * FROM dbo.key_audit ORDER BY id DESC;
-- 04_reports.sql файлын орындағаннан кейін:
SELECT * FROM dbo.v_key_status;
SELECT * FROM dbo.v_issuance_history;
```

## Git/GitHub (5-зертханалық жұмыс)
ZIP ішінде **нақты жергілікті Git тарихы**, 5 commit, екі тармақ (`main`, `feature/sql-reports`) және editable draw.io сызбалар бар. ZIP ашылғандағы белсенді тармақ — `feature/sql-reports`, сондықтан `04_reports.sql` де бірден көрінеді.
**GitHub репозиторийі, 3 Issue, Pull Request және merge әзірше онлайн жасалмаған.** Өз аккаунтыңызда орындау қадамдары: [docs/github-steps.md](docs/github-steps.md).

## Файлдар
```text
university-key-system-ssms/
├── README.md
├── sql/
│   ├── 00_schema.sql
│   ├── 01_seed.sql
│   ├── 02_procedures.sql
│   ├── 03_demo.sql
│   └── 04_reports.sql       # feature/sql-reports тармағында
├── docs/
│   ├── requirements.md
│   ├── use-case.md
│   ├── test-cases.md
│   ├── github-steps.md
│   ├── issues.md
│   └── diagrams/
│       ├── er-model.drawio
│       ├── key-workflow.drawio
│       └── system-architecture.drawio
└── .git/
```

**Шектеу:** бұл — SQL арқылы тексерілетін оқу прототипі; дайын GUI/QR сканер не аутентификация сервисі жоқ. Нақты жүйеде рұқсаттар мен қауіпсіздік қосымша жүзеге асырылады.
