# GitHub-қа қосылатын ортақ жоба (5 және 6-зертханалар)

- **lab5/**: ортақ `university_key_system_kz` SQL Server базасының құрылымы, процедуралар, VIEW.
- **lab6/**: CREATE, INSERT, UPDATE, DELETE және тексеру файлдары.
- **lab6/06_5_kabat_10_okytushy.sql**: 1–5-қабат, 7 кабинет, 10 мұғалім және олардың кілттері (алдыңғы нәтижемен бірдей).

**Маңызды:** `university_key_system_kz` базасы бұрыннан бар болғандықтан, GitHub-қа файлдарды жүктеу үшін SSMS-та қайтадан F5 басудың қажеті жоқ. SQL файлы дерекқорға енгізілген өзгерістерді код түрінде сақтайды. Егер оны кейін қайта орындасаң, бар мұғалімдер/кабинеттер қайталанып қосылмайды.

GitHub репозиторийі: https://github.com/asus06era-ui/university-key-system

## Қосу жолы

1. Бұрын GitHub-қа жүктеген **жергілікті git репозиторийінің** қалтасын аш: `C:\Users\asusv\Downloads\University_Key_System_SSMS_SQLServer_Lab5\university-key-system-ssms`.
2. Осы архив ішіндегі `lab5` және `lab6` қалталарын соған көшір. Ескі `sql` қалтасын жойма.
3. Сол қалтаның адрес жолағына `cmd` жазып аш.
4. Командаларды біртіндеп орында:

```cmd
git switch main
git pull --ff-only origin main
git status
git add lab5 lab6
git commit -m "lab6: combine labs and add 5 floors 10 teachers"
git push origin main
```

Соңында GitHub-та `lab5/`, `lab6/`, `lab6/06_5_kabat_10_okytushy.sql` барын тексер.

**Ескерту:** жергілікті каталог аталған орында болмаса, өз Git репозиторийіңнің нақты қалтасын таңда. `git init` қайталау қажет емес. Басқа адамның SQL Server логинін/құпиясөзін GitHub-қа қоспа.
