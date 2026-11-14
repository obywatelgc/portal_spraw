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
