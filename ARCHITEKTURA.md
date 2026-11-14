# Portal WZ — założenia i architektura

**Stan na 14 listopada 2026 r.** Na maszynie `101 (wz-portal)` działa lokalna wersja startowa. Z komputera w LAN można otworzyć [stronę główną](http://192.168.3.123:8080/) i [ekran logowania do panelu Django](http://192.168.3.123:8080/admin/). Zbieranie danych od klientów, obsługa spraw i publikacja w internecie stanowią docelowy zakres produktu.

## 1. Cel i założenia

Opis wysyłki e-mail zaktualizowano 14 listopada 2026 r. Konfiguracja transportu Gmail SMTP jest wdrożona. Uzupełnienie danych konta i test dostarczenia wiadomości pozostają do wykonania.

Portal ma zbierać od klientów dane i dokumenty potrzebne pracownikowi do przygotowania wniosku o warunki zabudowy. **Sprawę inicjuje klient**. Planowana skala to maksymalnie 10 nowych wniosków dziennie. Końcowym rezultatem procesu w portalu jest potwierdzenie kompletności materiałów. Przygotowanie dokumentu urzędowego i jego złożenie pozostają po stronie pracownika.

Przy tej skali przyjęto jedną aplikację Django i jedną relacyjną bazę danych. Formularze klienta i funkcje pracownika mogą korzystać z tego samego modelu sprawy, zasad walidacji i historii zmian. Osobna maszyna wirtualna pozwala aktualizować i restartować portal niezależnie od działającej na tym samym Dellu maszyny Home Assistant. Obie VM współdzielą jednak fizyczny dysk, pamięć, zasilanie i dostęp do sieci.

## 2. Docelowa obsługa sprawy

| Etap | Użytkownik i czynność | Wynik |
|---|---|---|
| Wejście do portalu | Klient loguje się przez Google lub Facebook i otwiera „Moje wnioski”. | Widzi sprawy przypisane do swojego konta. |
| Rozpoczęcie | Klient wybiera „Nowy wniosek o warunki zabudowy”. | Powstaje szkic z przypisanym właścicielem. |
| Zebranie danych | Klient podaje dane wnioskodawców, działki, opis inwestycji, dostęp do drogi i mediów oraz dodaje załączniki. | Zapis poszczególnych kroków pozwala wznowić pracę po ponownym logowaniu. |
| Przekazanie | Klient sprawdza podsumowanie. Aplikacja waliduje wymagane pola i zapisuje przekazaną wersję. | Klient otrzymuje potwierdzenie z numerem sprawy. Status przechodzi na „Do weryfikacji”. |
| Uzupełnienie | Pracownik wskazuje pola lub dokumenty do poprawy. Klient otrzymuje e-mail, poprawia dane i ponownie je przekazuje. | „Do uzupełnienia” → „Do weryfikacji”. Wcześniejsza wersja pozostaje w historii. |
| Zamknięcie weryfikacji | Pracownik potwierdza kompletność materiałów. | Klient widzi status „Dane kompletne”. |

**Model danych do wdrożenia.** Konto klienta może mieć wiele spraw. Sprawa łączy wnioskodawców, działki, dane inwestycji, metadane załączników, przekazane wersje odpowiedzi i historię statusu. Dane wnioskodawcy są osobnymi polami formularza, ponieważ właściciel konta może przygotowywać materiały dla innej osoby. Każdy odczyt, zapis i pobranie załącznika wymaga sprawdzenia uprawnienia do danej sprawy.

## 3. Infrastruktura lokalna

| Element | Przyjęta konfiguracja |
|---|---|
| Host | Dell OptiPlex 7050 Micro, Intel Core i5-7500T, 16 GB RAM, NVMe 256 GB |
| Wirtualizacja | Proxmox VE 9.1.1, węzeł `dellGreenOptiPlex`, adres zarządzania `192.168.3.131` |
| Maszyny | `100 (home-assistant)` i osobna `101 (wz-portal)` |
| Zasoby portalu | 1 gniazdo × 2 vCPU, typ CPU `host`, 3072 MiB RAM |
| Dysk portalu | 40 GiB w `local-lvm` (LVM-Thin), kontroler VirtIO SCSI single, włączone discard i IO thread |
| Sieć portalu | Karta VirtIO na moście `vmbr0`, adres LAN `192.168.3.123` |
| System VM | Debian GNU/Linux 13.7 (trixie), QEMU Guest Agent |
| Administracja | SSH przez alias `wzportal`, użytkownik `wzadmin`; dostęp do demona Docker przez grupę `docker` daje uprawnienia równoważne administratorowi VM |

## 4. Jak żądanie przechodzi przez system

```text
Przeglądarka klienta w LAN
  │ HTTP do 192.168.3.123:8080
  ▼
Caddy (caddy:80)
  ├── /static/*  → pliki z /srv/static, odczyt z wolumenu static_data
  └── pozostałe  → Gunicorn (web:8000) → aplikacja Django
                                             │ SQL przez psycopg
                                             ▼
                                        PostgreSQL (db:5432)
                                             │
                                             ▼
                                        wolumen postgres_data
```

Docker Compose uruchamia usługi `caddy`, `web` i `db` we wspólnej sieci projektu. Jedyny port aplikacji opublikowany na interfejsie VM to `192.168.3.123:8080`, przekierowany do portu 80 Caddy. Gunicorn i PostgreSQL są osiągalne dla innych kontenerów pod nazwami usług. Panel `/admin/` jest obecnie dostępny przez ten sam lokalny punkt wejścia co strona główna.

## 5. Stos technologiczny wdrożonej wersji

Wersje odczytano z działającej VM i kontenerów. Tagi obrazów oraz zakresy zależności pozwalają na zmianę wersji przy kolejnym pobraniu i budowie.

| Warstwa | Wersja | Rola i konfiguracja |
|---|---|---|
| Docker Engine / Compose | 29.9.3 / 5.7.1 | Budowanie aplikacji, uruchamianie usług, sieć i wolumeny. Wszystkie trzy usługi mają politykę restartu `unless-stopped`. |
| Caddy | 2.11.9, obraz `caddy:2` | Reverse proxy i serwer plików statycznych. Wdrożenie LAN korzysta z HTTP. |
| Python | 3.13.18, baza `python:3.13-slim` | Środowisko aplikacji, wbudowane w obraz `wz-portal-web:local`. |
| Gunicorn | 25.3.0 | Serwer WSGI, dwa procesy robocze, nasłuch na porcie 8000 wewnątrz kontenera. |
| Django | 5.2.19 | Routing, panel administracyjny, użytkownicy, sesje, ORM i migracje. Moduł `config.settings_portal`, język polski, strefa `Europe/Warsaw`, `DEBUG=False`. |
| psycopg | 3.3.9, wariant binary | Sterownik połączenia Django z PostgreSQL. |
| PostgreSQL | 17.12, obraz `postgres:17` | Trwała baza aplikacji. Gotowość sprawdza `pg_isready`. Compose czeka na zdrową bazę przed uruchomieniem usługi `web`. |
| Gmail SMTP | `smtp.gmail.com:587` | Wychodzące połączenie z kontenera Django, szyfrowane przez STARTTLS. Uwierzytelnianie adresem Gmail i hasłem do aplikacji. |

## 6. Pliki wdrożenia i trwałość danych

Katalog roboczy **na VM** to `/opt/wz-portal`. Polecenia Compose dotyczące tej instalacji wykonuje się w tym katalogu.

| Plik | Znaczenie |
|---|---|
| `compose.yaml` | Definicje trzech usług, zależności, portu LAN, wolumenów i testu gotowości bazy. |
| `.env` | Adres publikacji `PORTAL_IP`, lista `DJANGO_ALLOWED_HOSTS`, klucz Django, parametry bazy oraz `CASE_DATA_ROOT=/srv/wz-portal/sprawy` i zmienne `EMAIL_HOST`, `EMAIL_PORT`, `EMAIL_HOST_USER` i `EMAIL_HOST_PASSWORD`. Plik ma uprawnienia `600` i jest wykluczony z Git. |
| `.gitignore` | Wyklucza `.env` i `.env.*`, z wyjątkiem przykładowego `.env.example`. |
| `Caddyfile` | Reguły dla zasobów statycznych i proxy do `web:8000`. |
| `app/Dockerfile`, `app/requirements.txt` | Budowa obrazu Pythona, zależności Django, Gunicorna i psycopg oraz uruchomienie WSGI. Zmiany kodu wymagają przebudowania obrazu. |
| `app/manage.py`, `app/config/` | Polecenia administracyjne, konfiguracja Django, trasy i punkt wejścia WSGI. |

**Wolumeny.** `postgres_data` przechowuje dane PostgreSQL. `static_data` udostępnia zasoby zebrane poleceniem `collectstatic`; Django zapisuje je do wolumenu, a Caddy montuje go tylko do odczytu. `caddy_data` i `caddy_config` przechowują dane robocze Caddy. Wolumeny przetrwają wymianę kontenerów. Polecenie `docker compose down -v` usuwa również bazę. Obecny Compose nie definiuje magazynu prywatnych plików klientów.

**Katalog spraw — konfiguracja wdrożona 14 listopada 2026 r.** Na VM `101 (wz-portal)`, pod adresem `192.168.3.123`, utworzono `/srv/wz-portal/sprawy`. Katalogi `/srv/wz-portal` i `/srv/wz-portal/sprawy` mają właściciela `root:root` i uprawnienia `700`. Kontener `web` uruchamia obecnie Gunicorna i Django jako `root` (UID/GID `0:0`), co umożliwia zapis. Dostęp administracyjny wymaga uprawnień administratora VM; członkostwo w grupie `docker` również daje taki dostęp. Zmiana konta aplikacji wymaga dostosowania właściciela katalogu.

W `/opt/wz-portal/compose.yaml` skonfigurowano bind mount z katalogu hosta `/srv/wz-portal/sprawy` do tej samej ścieżki w `web`, z prawem odczytu i zapisu oraz `create_host_path: false`. Compose przekazuje `CASE_DATA_ROOT` z `.env`, gdzie ustawiono `/srv/wz-portal/sprawy`. Moduł `app/config/settings_portal.py` odczytuje tę zmienną jako ustawienie Django `CASE_DATA_ROOT`. Przebudowano obraz i odtworzono kontener `web`. Caddy nie montuje tego katalogu; konfiguracja WWW nie udostępnia jego zawartości. Katalog znajduje się na obecnym dysku systemowym VM, bez osobnego dysku danych.

**Weryfikacja z 14 listopada 2026 r.** Z poziomu Django potwierdzono wartość `CASE_DATA_ROOT`, właściciela i uprawnienia katalogu. Zapisano plik testowy z kontenera, odczytano go niezależnie przez montowanie katalogu hosta tylko do odczytu, następnie ponownie odtworzono `web` i potwierdzono zachowanie zawartości. Plik testowy usunięto. `docker compose config --quiet`, `manage.py check` i `manage.py migrate --check` zakończyły się poprawnie. Wszystkie trzy usługi działały, PostgreSQL był zdrowy, a strona główna, ekran logowania `/admin/` i `/static/admin/css/base.css` odpowiadały HTTP 200 po ewentualnym przekierowaniu. Kopie poprzednich plików `compose.yaml` i `settings_portal.py` zapisano w `/opt/wz-portal/deployment-backups/case-data-20261114-162843`.

**Pozostały zakres funkcjonalny.** Przygotowano trwały katalog i konfigurację aplikacji. Automatyczne tworzenie JSON, rewizji i kopii załączników według sekcji 10.2 specyfikacji wymagań pozostaje do implementacji, podobnie jak synchronizacja, ponawianie błędnych zapisów i retencja. Docelowo każda sprawa otrzyma podkatalog nazwany niezmiennym identyfikatorem systemowym, zawierający `sprawa.json`, `wersje/` oraz `zalaczniki/`. Katalog musi zostać objęty planowanymi kopiami poza Dellem; to wdrożenie nie weryfikowało kopii zapasowej.

**Kontrola po wdrożeniu.** Na VM stan usług pokazuje `docker compose ps`, a zaległe migracje wykrywa `docker compose exec -T web python manage.py migrate --check`. Z komputera w LAN sprawdzono odpowiedź strony głównej, przejście z `/admin/` do ekranu logowania oraz pobranie `/static/admin/css/base.css`. Wszystkie trzy żądania zakończyły się HTTP 200 po ewentualnym przekierowaniu. Sprawdzono aktualność migracji i stan zdrowia bazy. Test panelu objął ekran logowania.

## 7. Wysyłka e-mail przez Gmail

Na etap początkowy wybrano konto Gmail. Django korzysta z wbudowanego backendu `django.core.mail.backends.smtp.EmailBackend`. Wywołanie wysyłki nawiązuje połączenie wychodzące z Gmail SMTP, który przyjmuje wiadomość i obsługuje jej dalsze dostarczenie. VM potrzebuje dostępu do internetu na porcie TCP 587. Konfiguracja transportu znajduje się w `app/config/settings_portal.py`.

| Ustawienie | Wartość i źródło |
|---|---|
| `EMAIL_HOST` | `smtp.gmail.com`, przekazywane przez Compose z `.env`. |
| `EMAIL_PORT` | `587`, przekazywane przez Compose z `.env`. |
| `EMAIL_HOST_USER` | Pełny adres Gmail. Przy wdrożeniu pozostawiono puste pole do uzupełnienia przez właściciela. |
| `EMAIL_HOST_PASSWORD` | Hasło do aplikacji Google, wpisywane bez spacji. Przy wdrożeniu pozostawiono puste pole do uzupełnienia przez właściciela. |
| `EMAIL_USE_TLS` / `EMAIL_USE_SSL` | Odpowiednio `True` i `False`, zapisane w ustawieniach Django. |
| `EMAIL_TIMEOUT` | 20 sekund. |
| `DEFAULT_FROM_EMAIL` | Automatycznie budowane jako `Portal WZ <adres z EMAIL_HOST_USER>`. Przy pustym adresie ma wartość pustą. |

Compose przekazuje cztery zmienne `EMAIL_*` do usługi `web`. Puste dane uwierzytelniania pozwalają uruchomić portal podczas przygotowania konta. Konto Google musi umożliwiać utworzenie hasła do aplikacji i mieć włączoną weryfikację dwuetapową. Hasło pozostaje w `.env` na VM. Przykładowa konfiguracja w repozytorium powinna zawierać puste pole hasła.

Po wpisaniu adresu i hasła w `/opt/wz-portal/.env` należy wykonać na VM poniższe polecenia, aby kontener otrzymał nowe wartości.

```bash
cd /opt/wz-portal
docker compose up -d web
```

**Stan weryfikacji z 14 listopada 2026 r.** Przebudowano obraz Django, uruchomiono nowy kontener i wykonano kontrolę `manage.py check` bez błędów. Z kontenera potwierdzono połączenie z `smtp.gmail.com:587` i negocjację STARTTLS z weryfikacją certyfikatu. Portal odpowiadał HTTP 200. W chwili testu pola adresu Gmail i hasła były puste. Uwierzytelnienie SMTP oraz dostarczenie wiadomości do skrzynki wymagają testu po ich uzupełnieniu.

Automatyczne powiadomienia o przekazaniu sprawy, prośbie o uzupełnienie i potwierdzeniu kompletności wymagają podłączenia do zdarzeń aplikacji. Proponowany kolejny krok obejmuje zapis oczekującego powiadomienia w PostgreSQL razem ze zmianą sprawy oraz osobny proces wysyłający z ponawianiem prób. Obecne wdrożenie obejmuje konfigurację transportu SMTP. Kolejka powiadomień i proces wysyłający pozostają do implementacji.

## 8. Zakres kolejnego etapu

| Obszar | Przyjęte założenie lub decyzja do podjęcia |
|---|---|
| Aplikacja klienta | Wdrożyć model sprawy, formularz wieloetapowy, zapis szkiców, widok „Moje wnioski” i wersjonowanie przekazań. |
| Tożsamość | Dodać logowanie Google i Facebook, proponowane przez `django-allauth`. Skonfigurować powroty od dostawców po ustaleniu publicznej domeny. |
| Praca biura | Rozszerzyć panel Django o kolejkę spraw, weryfikację kompletności, wskazywanie braków i powiadomienia e-mail. |
| Dokumenty klientów | Dodać prywatny magazyn plików, metadane w bazie, limity i walidację plików oraz pobieranie po kontroli uprawnień. Katalog `/srv/wz-portal/sprawy`, bind mount do `web` i `CASE_DATA_ROOT` są skonfigurowane. Wdrożyć automatyczny zapis JSON i kopii załączników zgodnie z sekcją 10.2 specyfikacji wymagań. Osobno ustalić czas przechowywania. |
| Dostęp z internetu | Wybrać wariant według warunków łącza: publiczny adres i reverse proxy albo tunel wychodzący przy CGNAT. Skonfigurować domenę i HTTPS. Docelowo panel pracownika ma być dostępny przez VPN. |
| Odtwarzanie | Plan zakłada codzienną szyfrowaną kopię VM poza Dellem i test odtworzenia sprawy z załącznikiem. Uruchomienie portalu nie obejmowało weryfikacji takiej kopii. |

**Pojemność.** Przy 10 sprawach każdego dnia i średnio 10 MB plików na sprawę przyrost wynosi około 36,5 GB rocznie; przy 30 MB wynosi około 109,5 GB. Dodatkowy zapis w `/srv/wz-portal/sprawy` powiela fizyczne załączniki: łącznie z prywatnym magazynem daje to odpowiednio około 73 GB lub 219 GB rocznie, przed uwzględnieniem rewizji JSON i pozostałych danych. Dysk 40 GiB jest przydziałem początkowym, który obejmuje także Debiana, obrazy kontenerów i bazę. Przed wdrożeniem przechowywania plików należy zaplanować rozbudowę pojemności; po wdrożeniu trzeba mierzyć przyrost danych i wolne miejsce zarówno wewnątrz VM, jak i we współdzielonej puli `local-lvm`.
