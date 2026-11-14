# Portal spraw — inwentaryzacja etapu 0

Data kontroli: 14 listopada 2026 r.  
Plan: [PLAN_IMPLEMENTACJI_PORTALU_SPRAW.md](PLAN_IMPLEMENTACJI_PORTALU_SPRAW.md).  
Źródła wymagań: [specyfikacja wymagan.md](specyfikacja%20wymagan.md) i [ARCHITEKTURA.md](ARCHITEKTURA.md).

## 1. Zakres i status

Wykonano inwentaryzację lokalnego katalogu dokumentacji oraz odczyt kodu, konfiguracji, stanu kontenerów i bazy na VM przez istniejący alias SSH `wzportal` (użytkownik `wzadmin`, adres `192.168.3.123`). Wyniki poniżej pochodzą z bieżącej kontroli, o ile nie oznaczono inaczej. Nie odczytywano treści danych osobowych ani wartości sekretów do raportu; dla SMTP sprawdzono wyłącznie obecność konfiguracji.

**Status etapu 0: rozpoczęty; część inwentaryzacyjna wykonana dla dostępnej VM.** Pozostają organizacja repozytorium i odseparowanego środowiska testowego, weryfikacja hosta Proxmox i kopii oraz rozstrzygnięcia z rejestru decyzji. Nie wykonywano migracji zmieniających schemat, restartów, zakładania kont ani zmiany konfiguracji działającej instalacji. Kontrole HTTP mogą pozostawić zwykłe wpisy w logach dostępu.

## 2. Kod i pliki

### Katalog lokalny

`C:\GC\warunki_zabudowy\wz_gpt` zawiera dokumenty wymagań, architekturę, plan oraz makiety HTML/CSS i archiwa w `sites/`. Nie znaleziono lokalnego kodu Django ani plików Compose. Katalog nie jest repozytorium Git. Makiety są materiałem projektowym; nie są aplikacją obsługującą sprawy.

### Instalacja na VM

Katalog `/opt/wz-portal` zawiera:

| Element | Wynik odczytu |
|---|---|
| `app/manage.py`, `app/config/` | Startowy projekt Django; konfiguracje `settings.py`, `settings_portal.py`, URL, ASGI i WSGI |
| `app/config/urls.py` | Dwie trasy: `/` z prostym HTML „Portal warunków zabudowy” i `/admin/`; brak tras spraw, uploadu, OAuth i płatności |
| `app/requirements.txt` | `Django>=5.2,<5.3`, `gunicorn>=23,<26`, `psycopg[binary]>=3.2,<4`; zależności nie są przypięte do dokładnych wersji |
| `app/Dockerfile` | `python:3.13-slim`, instalacja requirements, kopia kodu do obrazu, Gunicorn z dwoma workerami; brak instrukcji `USER` |
| `compose.yaml` | Usługi `db`, `web`, `caddy`; brak workera, schedulera, skanera i odseparowanej konfiguracji testowej |
| `Caddyfile` | Nasłuch `:80`, `/static/*` z `/srv/static`, pozostałe żądania do `web:8000` |
| `.env` | Tryb `600`; sprawdzono nazwy parametrów, bez publikowania wartości sekretów |
| `deployment-backups/` | Katalog `case-data-20261114-162843`; sama obecność nie dowodzi kompletnej kopii bazy, plików ani VM |
| Git i testy | `/opt/wz-portal` nie jest repozytorium Git; w odczytanym drzewie aplikacji brak własnych testów i aplikacji domenowych |

Kod jest kopiowany do obrazu, zatem zmiana plików na VM wymaga przebudowy obrazu. Tagi `python:3.13-slim`, `postgres:17` i `caddy:2` oraz zakresy requirements mogą dać inne wersje przy kolejnej budowie. Brak obecnie identyfikatora wydania powiązanego z commitem.

`settings.py` jest bazową konfiguracją startową z SQLite, `DEBUG=True` i językiem angielskim. Działający kontener korzysta z `config.settings_portal`, które nadpisuje te ustawienia na PostgreSQL, `DEBUG=False`, język `pl` i `Europe/Warsaw`. Nie należy traktować samego `settings.py` jako konfiguracji uruchomionej usługi ani omyłkowo użyć go przy przyszłym wdrożeniu.

## 3. Baza, konta i dane do migracji

Odczyt przez Django ORM i introspekcję bazy:

| Obszar | Potwierdzony wynik |
|---|---|
| `INSTALLED_APPS` | Wyłącznie standardowe `admin`, `auth`, `contenttypes`, `sessions`, `messages`, `staticfiles` |
| Modele domenowe | Brak zarejestrowanych modeli poza standardowymi aplikacjami Django |
| Tabele | `auth_group`, `auth_group_permissions`, `auth_permission`, `auth_user`, `auth_user_groups`, `auth_user_user_permissions`, `django_admin_log`, `django_content_type`, `django_migrations`, `django_session` |
| Konta | 0 wszystkich użytkowników, 0 staff, 0 superuserów, 0 aktywnych |
| Grupy | 0 |
| Migracje | Wszystkie standardowe migracje oznaczone jako zastosowane; `migrate --check` zakończone poprawnie |
| Sprawy, wersje, zamówienia i wpłaty | Brak odpowiednich tabel i modeli w sprawdzonej bazie |
| Dodatkowy katalog spraw | 0 plików, 0 podkatalogów, 0 bajtów zawartości |

W obecnej aplikacji nie ma materiału biznesowego wymagającego mapowania historycznych statusów lub cen. Nie jest to stwierdzenie o innych maszynach, kopiach lub zewnętrznych kontach płatniczych. Ekran logowania Django istnieje, lecz żadne konto nie umożliwia obecnie zalogowania do panelu.

Przed pierwszą zmianą modeli ponownie sprawdzić liczby i wykonać kopię bazy oraz konfiguracji. Jeśli do tego czasu pojawią się dane, przygotować migrację próbną i kontrolę powiązań. Brak danych dzisiaj nie uzasadnia późniejszego resetowania bazy.

## 4. Uruchomienie i trwałość

| Obszar | Potwierdzony stan |
|---|---|
| System i zasoby | Debian 13.7, 2 dostępne CPU, około 2978 MiB RAM; w chwili kontroli około 2352 MiB pamięci dostępnej; swap około 2134 MiB, bez użycia |
| Dysk | Dysk wirtualny 40 GiB, partycja ext4 około 38 GiB; `df` wskazuje 2,8 GiB użyte i 33 GiB dostępne (8% użycia) |
| Kontenery | `web`, `caddy`, `db` uruchomione; `db` zdrowy, polityka restartu `unless-stopped` |
| Wersje Pythonowych zależności | Django 5.2.19, Gunicorn 25.3.0, psycopg/psycopg-binary 3.3.9; odczytane z działającego kontenera |
| Porty | Publikowane `192.168.3.123:8080 -> caddy:80`; brak publikacji portów Gunicorna i PostgreSQL na VM |
| Baza i statyczne | Wolumeny `postgres_data`, `static_data`; dodatkowo `caddy_data`, `caddy_config`; Caddy ma statyczne tylko do odczytu |
| Dane katalogowe | Bind mount `/srv/wz-portal/sprawy` do tej samej ścieżki w `web`, `create_host_path: false`; Caddy go nie montuje |
| Uprawnienia | `web` działa jako UID/GID `0:0`; katalog spraw `root:root`, `700`. Odczyt bezpośredni jako `wzadmin` zgłasza odmowę, z kontenera katalog jest dostępny |
| Główny magazyn | Brak osobnego montowania plików i kwarantanny; `MEDIA_ROOT` pusty, domyślne `MEDIA_URL=/` nie stanowi zaimplementowanej obsługi plików |
| Harmonogram | W odczytanych timerach systemd brak zadania portalu; użytkownik `wzadmin` nie ma crontaba. Nie sprawdzono wszystkich crontabów systemowych ani harmonogramu Proxmox |

Zajętość kontenerów w pojedynczym pomiarze wyniosła około 101 MiB (`web`), 15 MiB (`caddy`) i 28 MiB (`db`). Jest to pomiar bez ruchu biznesowego, nie test obciążenia ani dowód wystarczalności pamięci dla skanera.

Nie zweryfikowano wolnego miejsca puli Proxmox `local-lvm`, konfiguracji VM po stronie hypervisora, stanu fizycznego NVMe, kopii wykonywanych przez Proxmox ani zewnętrznego dostępu/VPN. Brak tych wyników nie oznacza braku takich mechanizmów. Bieżąca sesja obejmowała VM portalu, nie sesję administracyjną hosta `192.168.3.131`.

## 5. Integracje i bezpieczeństwo

- Gmail SMTP jest skonfigurowany jako `smtp.gmail.com:587`, STARTTLS, timeout 20 s. `EMAIL_HOST_USER`, `EMAIL_HOST_PASSWORD` i wynikowe `DEFAULT_FROM_EMAIL` są puste. Nie wysyłano wiadomości; dostarczenie nie jest potwierdzone. Kod nadawcy nadal używa nazwy „Portal WZ”.
- Brak OAuth, zależności `django-allauth`, ustawień integracji P24 oraz parametru `PAYMENTS_MOCK_ENABLED`. Brak parametru mock w tym projekcie oznacza brak implementacji SU-038, a nie gotową ścieżkę realnych płatności.
- `ALLOWED_HOSTS` obejmuje adres LAN, `127.0.0.1` i `localhost`; `DEBUG=False`, standardowe middleware sesji, CSRF, uwierzytelniania i ochrony ramek są obecne.
- Ruch aplikacyjny działa przez HTTP. `SESSION_COOKIE_SECURE=False`, `CSRF_COOKIE_SECURE=False`, `SECURE_SSL_REDIRECT=False`, `SECURE_HSTS_SECONDS=0`. Kontrola `check --deploy` zwróciła cztery ostrzeżenia: W004, W008, W012, W016. Konfigurację HTTPS i ciasteczek należy domknąć przed publikacją.
- Caddy nie rozdziela dostępu klienta i personelu; `/admin/` przechodzi przez ten sam punkt wejścia LAN. W odczytanej konfiguracji aplikacji nie ma ograniczenia panelu do VPN. Nie oceniano zewnętrznych reguł routera/firewalla.
- Brak trwałej kolejki powiadomień i synchronizacji, kontroli plików, retencji i monitoringu biznesowego w kodzie aplikacji.

## 6. Wykonane kontrole

| Kontrola | Wynik |
|---|---|
| SSH w trybie bez interakcji | Dostęp do `wzportal` działa |
| `docker compose config --quiet` | Poprawna konfiguracja |
| `docker compose ps` | 3 usługi działają, PostgreSQL healthy |
| `python manage.py check` | Brak problemów |
| `python manage.py migrate --check` i `showmigrations` | Brak zaległych migracji; tylko aplikacje standardowe |
| `python manage.py check --deploy` | Cztery ostrzeżenia HTTPS/ciasteczek opisane wyżej |
| HTTP `/` | 200 |
| HTTP `/admin/` | 302 do logowania; bieżący test nie sprawdzał uwierzytelnienia |
| HTTP `/static/admin/css/base.css` | 200 |
| Odczyt konfiguracji i liczników ORM | Potwierdza brak domeny biznesowej i kont |

Nie powtarzano testu wymiany kontenera i zapisu pliku, opisanego w architekturze; aktualnie potwierdzono montowanie, prawa i odczyt. Nie wykonano testu SMTP, kopii, odtworzenia, OAuth, P24, skanera ani wydajności — brak odpowiedniej implementacji lub konfiguracji. Nie modyfikowano wdrożenia w celu usunięcia ostrzeżeń podczas inwentaryzacji.

## 7. Rejestr decyzji do doprecyzowania

Poniższe propozycje nie stanowią zatwierdzonych parametrów produktu. „Wykonawca” oznacza osobę implementującą, a „właściciel” — właściciela projektu.

| ID | Decyzja i proponowany kierunek | Odpowiedzialny | Termin / wpływ |
|---|---|---|---|
| D-01 | Gdzie utrzymywać główne repozytorium i kto ma dostęp? Propozycja: import obecnego kodu i konfiguracji bez `.env`, wydania oznaczane commitem; sekrety poza Git. Ustalić też usunięcie startowego klucza z bazowych settings przy porządkowaniu kodu | Właściciel + wykonawca | Przed rozbudową modeli i publikacją repozytorium |
| D-02 | Gdzie uruchamiać środowisko testowe? Propozycja: osobny projekt Compose, baza, wolumeny, katalog spraw, port i sekrety; kontrolowane adresy poczty, mock, następnie osobna konfiguracja sandboxa | Właściciel + wykonawca | Do zamknięcia etapu 0; samo użycie innej bazy nie izoluje plików ani poczty |
| D-03 | Powtarzalność wydań: wybrać sposób przypięcia zależności i obrazów, aktualizacji oraz kontroli przed wdrożeniem | Wykonawca | Przed pierwszym wydaniem funkcjonalnym |
| D-04 | Jednostka MB: proponowane dziesiętne 1 MB = 1 000 000 bajtów. Znaki: punkty kodowe Unicode, identyczne reguły serwera i licznika UI; przycięcie skrajnych spacji do testu wymaganych pól | Wykonawca, akceptacja właściciela | Przed walidacją w etapach 1–2 |
| D-05 | Daty: proponowane świadome strefowo daty zdarzeń, obliczenia dni/miesięcy według Europe/Warsaw; dla miesięcy kalendarzowych ograniczenie dnia do ostatniego dnia miesiąca docelowego. Ustalić dokładną godzinę graniczną i testy DST | Wykonawca | Przed terminami płatności, przypomnień i retencją |
| D-06 | Częstotliwość zadań, zasady ponowień i alarmowania. Propozycja: trwałe zadania PostgreSQL, worker z tego samego obrazu, osobny harmonogram; numery rewizji, blokady i rejestr usunięć | Wykonawca | Projekt w etapie 1, synchronizacja w etapie 2 |
| D-07 | Prywatny magazyn, kwarantanna, UID/GID procesu i skaner. Wybrać lokalizacje oraz sprawdzić zużycie pamięci skanera na VM 3 GiB | Wykonawca + opiekun infrastruktury | Przed odbiorem etapu 2 |
| D-08 | Przyrost i rozbudowa dysku: docelowa pojemność, zapas na obie kopie, historię i pliki tymczasowe. Najpierw odczytać `local-lvm` na hoście | Właściciel / opiekun infrastruktury | Przed rzeczywistymi dokumentami; obecne 33 GiB wolnego nie zamyka wymagań pojemności |
| D-09 | Reset operatora: proponowane 60 minut, token jednorazowy, unieważnienie po ponownym wydaniu; procedura odzyskania administratora | Właściciel + wykonawca | Przed etapem 6 |
| D-10 | Nazwa operatora: proponowany zapis nazwy z chwili czynności. Lista kontrolna: proponowane jawne potwierdzenie związane z wersją. Uzupełnienie bez zmian: niepusty komentarz wyjaśniający | Właściciel + wykonawca | Przed odbiorem etapu 5 |
| D-11 | Brak aktywnego prowadzącego/adresu: proponowane przekierowanie do wspólnej skrzynki; brak skrzynki jako widoczny błąd konfiguracji | Właściciel + wykonawca | Przed odbiorem powiadomień |
| D-12 | Domena, publiczny IP/CGNAT lub tunel, sposób VPN i granica dostępu personelu. Publiczny webhook P24 musi pozostać osiągalny | Właściciel / opiekun infrastruktury | Przed zewnętrznymi testami integracji i produkcją |
| D-13 | Jedna skrzynka: adres, dane dostępowe, adresy personelu i opiekuna. Sekrety przekazać poza raportem; ustalić adres nadawcy i odpowiedzi | Właściciel | Przed odbiorem etapu 6 |
| D-14 | Google/Facebook i P24: konta administracyjne, dostęp wykonawcy, aplikacje, adresy powrotu i dane sandboxa | Właściciel + wykonawca | Przed odbiorem odpowiednich integracji |
| D-15 | Cena, zasady wycofania/zakończenia bez akceptacji, nadpłat, dokumentów sprzedaży i ich retencji; oferta i zasady danych | Właściciel | Przed sprzedażą; nie blokuje lokalnego mocka |
| D-16 | Kopie poza Dellem: miejsce, częstotliwość, szyfrowanie, retencja, RPO/RTO i harmonogram testów. Ustalić dostęp do Proxmox i sprawdzić ewentualne istniejące kopie | Właściciel / opiekun infrastruktury | Przed odbiorem utrzymania i produkcją |
| D-17 | Zatwierdzić lub zmienić proponowane parametry: 20 sesji/4000 spraw, p95 2 s, dostępność 99%, progi miejsca 75%/85%; ustalić odbiorcę i kanał alarmów | Właściciel | Przed testami i deklarowaniem celów utrzymania |

## 8. Następne działania i migracja

1. Ustalić D-01–D-03 i utworzyć wersjonowaną bazę kodu oraz odseparowane środowisko testowe. Nie kopiować `.env` do repozytorium; przygotować `.env.example` bez sekretów i instrukcję uruchomienia.
2. Sprawdzić host Proxmox: wolne miejsce `local-lvm`, konfigurację zasobów VM i kopii, lokalizację docelową kopii poza hostem. Udokumentować wyniki oddzielnie od odczytu systemu plików VM.
3. Przed pierwszą migracją wykonać kopię bazy, kodu i konfiguracji oraz obu magazynów, jeśli pojawią się pliki. Zweryfikować możliwość odtworzenia w odseparowanym środowisku. Sam folder `deployment-backups` nie spełnia tego warunku.
4. Zdefiniować wydanie bazowe i procedurę powrotu. Dzisiaj nie ma historycznych danych biznesowych do mapowania. Po pojawieniu się wpłat lub decyzji wycofanie musi zachować nowe zdarzenia; nie może polegać na bezwarunkowym odtworzeniu starej bazy.
5. Po przygotowaniu środowiska i ustaleniu reguł technicznych rozpocząć etap 1 od modeli domeny, ograniczeń bazy i kontroli dostępu. Dzisiejszy raport jest podstawą tej pracy, ale nie potwierdzeniem odbioru całego etapu 0.
