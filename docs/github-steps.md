# GitHub арқылы 5-зертхананы аяқтау (SSMS нұсқасы)

## 1. ZIP-ті ашу және Git-ті тексеру
ZIP-тен `university-key-system-ssms` қалтасын толығымен шығарыңыз. `.git` жасырын қалтасын сақтаңыз. Git Bash немесе PowerShell-ді жоба қалтасында ашыңыз:
```bash
git status
git branch -a
git log --oneline --all --graph --decorate
```
ZIP ашылғанда `feature/sql-reports` branch белсенді. `main`-де SQL базалық файлы бар, feature-де қосымша есеп `sql/04_reports.sql` бар. Жергілікті Git-та **5 commit** жасалған.

## 2. GitHub-та репозиторий ашу
GitHub → New repository → Name: `university-key-system-ssms` → README қоспаңыз → Create repository.

## 3. Екі branch жүктеу
Git Bash-та (`USERNAME` орнына өз GitHub логиніңізді жазыңыз):
```bash
git remote add origin https://github.com/USERNAME/university-key-system-ssms.git
git push -u origin main
git push -u origin feature/sql-reports
```
`origin already exists` десе: `git remote set-url origin https://github.com/USERNAME/university-key-system-ssms.git`.

## 4. Кемінде 3 Issue жасау
GitHub репозиторийі → Issues → New issue. `docs/issues.md` құжатының үш тапсырмасын жеке-жеке ашыңыз.

## 5. Pull Request және merge
GitHub → Pull requests → New pull request → **base = main**, **compare = feature/sql-reports** → Create pull request. Title: `Add SQL Server views and history reports`. Файлдарда `sql/04_reports.sql` көрінеді. Одан кейін **Merge pull request → Confirm merge**.

## 6. Жергілікті main-ді жаңарту
```bash
git checkout main
git pull origin main
git log --oneline --all --graph --decorate
```

## 7. SSMS-та нәтижені тексеру
SQL файлдарын осы ретпен орындаңыз: `00_schema.sql` → `01_seed.sql` → `02_procedures.sql` → `03_demo.sql` → `04_reports.sql`. Әр файлды SSMS-та `File → Open → File` арқылы ашыңыз және F5 басыңыз. `Object Explorer` арқылы `Databases → university_key_system` көрінетінін тексеріңіз.

## 8. Дәлел скриншоттар
Word есебіне өз GitHub репозиторий беті, commit тарихы (кемінде 3), 2 branch, 3 Issue, `Merged` Pull Request және SSMS-та SQL орындалу терезесінің скриншоттарын қосыңыз.

**Ескерту:** дайын ZIP GitHub-тағы Issue/PR/merge қадамдарын автоматты түрде орындамайды. Оларды аккаунтыңызда шынайы жасаңыз.
