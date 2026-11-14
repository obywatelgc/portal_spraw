# Portal spraw

Aplikacja do zbierania od klientów danych do wniosków o warunki zabudowy. Pierwszy zapis zawiera kod pobrany z VM wz-portal oraz dokumentację projektu. Działa strona startowa i panel Django. Formularze spraw i logowanie Google/Facebook są opisane w dokumentacji wymagań.

Stos obejmuje Django, Gunicorn, PostgreSQL i Caddy, uruchamiane przez Docker Compose. Opis infrastruktury znajduje się w [ARCHITEKTURA.md](ARCHITEKTURA.md), a zakres prac w [PLAN_IMPLEMENTACJI_PORTALU_SPRAW.md](PLAN_IMPLEMENTACJI_PORTALU_SPRAW.md).

## Przygotowanie nowej instalacji na Linux

Skopiuj `.env.example` do `.env`, uzupełnij adres VM oraz wygeneruj osobne wartości `DJANGO_SECRET_KEY` i `POSTGRES_PASSWORD`, np. poleceniem `openssl rand -hex 32`. Dane Gmaila można uzupełnić później. Ustaw `chmod 600 .env`.

Compose wymaga istniejącego katalogu `/srv/wz-portal/sprawy`. Utwórz go na serwerze z uprawnieniami pozwalającymi aplikacji zapisywać dane. Katalog ten jest montowany do kontenera pod tą samą ścieżką.

```bash
docker compose -p wz-portal config --quiet
docker compose -p wz-portal build web
docker compose -p wz-portal up -d --wait db
docker compose -p wz-portal run --rm web python manage.py migrate
docker compose -p wz-portal run --rm web python manage.py collectstatic --noinput
docker compose -p wz-portal run --rm web python manage.py createsuperuser
docker compose -p wz-portal up -d
```

Otwórz `http://ADRES_VM:8080/` w LAN i `/admin/`, aby zalogować się do panelu. Parametr `-p wz-portal` utrzymuje nazwę projektu i wolumenów niezależnie od nazwy katalogu. Istniejąca VM używa tej nazwy projektu.

## Sekrety i dane

Repozytorium zawiera kod, migracje, dokumentację i przykładowe ustawienia. Hasła wpisuje się do lokalnego pliku `.env`. Kopie PostgreSQL i prywatny katalog spraw wymagają osobnego backupu. `docker compose down -v` usuwa wolumen bazy danych.

## Wdrażanie main na istniejącej VM

Na Windows uruchom poniższe polecenie. Skrypt działa w katalogu instalacji na VM i pobiera najnowszy commit gałęzi main.

```powershell
ssh wzportal "cd /opt/wz-portal && bash deploy.sh"
```

VM pobiera publiczne repozytorium przez HTTPS. Przy zmianie widoczności na prywatną trzeba skonfigurować uwierzytelnienie odczytu, np. osobny klucz wdrożeniowy.

Przed zmianami skrypt zapisuje kopię PostgreSQL w formacie pg_dump, pliku .env, kodu i identyfikatorów commitów w prywatnym katalogu ~/wz-portal-backups. Następnie aktualizuje kod przez fast-forward, buduje obraz, sprawdza Django, wykonuje migracje i zbiera zasoby statyczne. Odtwarza kontenery web i caddy w projekcie wz-portal i sprawdza HTTP oraz stan migracji. Baza pozostaje na dotychczasowym kontenerze i wolumenie. Zmiany obrazu lub konfiguracji usługi db wymagają osobnego wdrożenia bazy.

Skrypt wymaga uruchomionej bazy oraz czystego katalogu Git na gałęzi main. Plik .env i katalog danych spraw są poza Git. Blokada flock zapobiega równoległym wdrożeniom. Lokalne kopie przed wdrożeniem obejmują bazę i konfigurację; katalog spraw i kopia poza Dellem wymagają osobnego backupu. Kopie gromadzą się do czasu ich usunięcia przez administratora.

W razie błędu skrypt zatrzymuje się i wskazuje kopię. Migracje mogą już być zastosowane, dlatego odtworzenie poprzedniej wersji wymaga oceny zgodności kodu i bazy. Krótka przerwa występuje przy wymianie kontenerów. Po zmianie samego .env wykonaj docker compose -p wz-portal up -d web.
