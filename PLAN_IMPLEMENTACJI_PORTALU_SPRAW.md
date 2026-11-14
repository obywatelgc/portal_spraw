# Portal spraw — etapowy plan implementacji

Data: 14 listopada 2026 r.  
Podstawa: [specyfikacja wymagan.md](specyfikacja%20wymagan.md), wersja 1.3, oraz [ARCHITEKTURA.md](ARCHITEKTURA.md), stan na 14 listopada 2026 r.

Dokument opisuje kolejność prac, zależności i kryteria odbioru. Nie potwierdza wykonania funkcji ani gotowości produkcyjnej. Stan początkowy przyjęto z dokumentacji; konfiguracja VM i kod wymagają inwentaryzacji w etapie 0. Wymagania biznesowe wynikają ze specyfikacji, a opis istniejącej infrastruktury — z dokumentu architektury. Poniższe wybory techniczne są propozycją realizacji, o ile nie wskazano istniejącej konfiguracji lub ustalonego wymagania.

## 1. Punkt wyjścia i zakres zmiany

| Obszar | Stan opisany w architekturze | Dalsze prace |
|---|---|---|
| Środowisko | VM 101 na Proxmox, Debian, 2 vCPU, 3072 MiB RAM, dysk 40 GiB; wspólny host z Home Assistant | Zweryfikować zasoby, przygotować środowisko testowe, pojemność, kopie i monitoring hosta oraz VM |
| Aplikacja | Django 5.2, Gunicorn, PostgreSQL 17, Caddy i Docker Compose; działa strona startowa oraz ekran logowania `/admin/` | Modele, proces, interfejsy klienta/personelu, integracje i zadania w tle |
| Sieć | HTTP w LAN pod `192.168.3.123:8080`; panel administracyjny przez ten sam punkt wejścia | Publiczne HTTPS i logowanie klientów; panel personelu przez VPN; publicznie dostępne potwierdzenia P24 |
| Dane katalogowe | `CASE_DATA_ROOT=/srv/wz-portal/sprawy`, prywatny bind mount do `web`, trwałość po wymianie kontenera sprawdzona | Automatyczny JSON, rewizje, kopie plików, synchronizacja, alarmy i retencja |
| Pliki | Brak głównego prywatnego magazynu załączników w Compose | Osobny trwały magazyn, kwarantanna, kontrola i autoryzowane pobieranie |
| Poczta | Gmail SMTP/STARTTLS skonfigurowany; brak danych konta i testu dostarczenia | Dane skrzynki, test rzeczywistej wysyłki, trwała kolejka i ponowienia |
| Użytkownik procesu | `web` działa jako root; katalog danych ma `root:root`, tryb `700` | Zaplanować konto aplikacyjne bez root oraz zgodne prawa do trwałych katalogów |
| Kopie | Planowane kopie poza Dellem, bez potwierdzonego testu odtworzenia | Uzgodnić parametry, uruchomić kopie i wykazać skuteczne odtworzenie |

**Rozbieżności dokumentów:** sekcje 10.2 i 13.1 specyfikacji nadal opisują utworzenie katalogu i montowania jako pracę przyszłą. Architektura dokumentuje już ich wdrożenie; należy je sprawdzić, nie odtwarzać od zera. Funkcjonalność SU-036 pozostaje do wykonania. Dawny formularz WZ z danymi działek, inwestycji i wnioskodawców oraz status „Dane kompletne” nie są docelowym zakresem. Implementujemy „Portal spraw”, „Sprawę uniwersalną” oraz pola nazwa–opis–załączniki. Aktualizujemy także nazwę nadawcy poczty „Portal WZ”.

## 2. Docelowy sposób rozbudowy

Zachować jedną aplikację Django i PostgreSQL. Proponowany podział logiczny: konta i personel, sprawy i wersje, pliki, płatności, powiadomienia oraz utrzymanie. Nie wymaga to osobnych usług biznesowych ani aplikacji SPA. Interfejsy mogą korzystać z szablonów Django, z niewielkim JavaScript do przesyłania plików, potwierdzeń i ostrzegania o niezapisanych zmianach.

- Caddy obsługuje HTTPS, zasoby statyczne i proxy do Gunicorna. Nie otrzymuje publicznego dostępu do prywatnego magazynu ani `CASE_DATA_ROOT`.
- PostgreSQL jest źródłem stanu spraw i trwałych zadań. Zapis katalogowy jest dodatkowym odwzorowaniem, a nie źródłem automatycznego importu do bazy.
- Proponowany proces `worker`, uruchamiany z tego samego obrazu co `web`, wykonuje synchronizację, kontrolę plików, pocztę i zadania okresowe. Zadania mają stan, klucz idempotencji, ponowienia i blokadę równoczesnego wykonania. Scheduler może działać jako osobne polecenie Django wywoływane przez timer. Na początek nie zakładać obowiązku Redis/Celery.
- Wymagane są trwałe lokalizacje głównego magazynu i kwarantanny oraz istniejący dodatkowy katalog spraw. Worker otrzymuje tylko potrzebne montowania i uprawnienia. Wybór skanera i jego koszt pamięci trzeba sprawdzić na VM z 3 GiB RAM.
- Zmiany procesu wykonują wspólne serwisy aplikacyjne. Widoki i panel Django nie mogą omijać walidacji, kontroli wersji, uprawnień i rejestracji zdarzeń przez swobodną edycję statusu.
- Transakcje PostgreSQL obejmują zmianę biznesową, historię i zlecenia dalszej pracy. Operacje plikowe i SMTP wymagają osobnego, odtwarzalnego protokołu — nie są częścią transakcji SQL.

## 3. Etapy i zależności

| Etap | Rezultat | Zależność |
|---|---|---|
| 0 | Zweryfikowana baza wdrożenia i rejestr decyzji | Dokumenty źródłowe |
| 1 | Model domeny, uprawnienia i mechanizmy spójności | 0 |
| 2 | Prywatne pliki i pełny zapis katalogowy | 1 |
| 3 | Panel klienta, logowanie i szkice | 1–2 |
| 4 | Niezmienne przekazania i płatność mock | 2–3 |
| 5 | Pełna obsługa operatora i administratora | 4 |
| 6 | Powiadomienia, reset haseł i przypomnienia | 1, zdarzenia z 3–5 |
| 7 | Przelewy24 i obsługa wyjątków płatniczych | 4, 6; konfiguracja sandboxa i HTTPS |
| 8 | Retencja, monitoring, kopie i przygotowanie produkcji | 2, 5–7 |
| 9 | Odbiór, pilotaż testowy i płatne uruchomienie | Zależnie od bramki opisanej poniżej |

Kolejność jest logiczna, nie kalendarzowa. Projekt kolejki zadań, bezpieczeństwa, kopii i retencji rozpoczyna się w etapach 0–1; etap 8 kończy ich integrację i odbiór. Mechanizm powiadomień można rozwijać po etapie 1, podłączając zdarzenia wraz z kolejnymi funkcjami. Lokalny pilotaż mock nie czeka na integrację P24 ani cenę handlową. Terminy i nakład pracy należy oszacować po sprawdzeniu kodu, danych i dostępności konfiguracji zewnętrznej.

### Etap 0. Inwentaryzacja i decyzje wdrożeniowe

**Status na 14 listopada 2026 r.:** rozpoczęty. Sprawdzono lokalne pliki oraz kod, konfigurację, bazę i usługi na VM. Wyniki, ograniczenia kontroli i rejestr decyzji zapisano w [INWENTARYZACJA_ETAP_0.md](INWENTARYZACJA_ETAP_0.md). Etap pozostaje otwarty do przygotowania repozytorium i środowiska testowego oraz domknięcia wymaganych kontroli infrastruktury i decyzji.

**Prace:**

1. Sprawdzić kod i konfigurację `/opt/wz-portal`, migracje, istniejące konta, sprawy, pliki i wpłaty. Zweryfikować Compose, montowania, uprawnienia, wolne miejsce VM i puli `local-lvm`; nie kopiować sekretów do dokumentacji.
2. Ustalić sposób wersjonowania kodu, testowania i wydawania. Przygotować odseparowaną bazę, katalogi, konfigurację i konta testowe; nie korzystać z produkcyjnych danych ani płatności w testach.
3. Jeżeli istnieją dane biznesowe: wykonać kopię, opracować mapowanie modeli i statusów, przeprowadzić migrację próbną i kontrolę relacji. Nie utożsamiać dawnego statusu z nową decyzją ani nie przeliczać historycznych cen.
4. Uzgodnić jednostkę MB, liczenie znaków, miesiące kalendarzowe, harmonogram zadań, czas ważności resetu, utrwalanie nazw operatorów oraz sposób potwierdzania listy kontrolnej. Proponowane wartości ze specyfikacji pozostają propozycjami.
5. Rozpocząć ustalanie domeny, wariantu publikacji przy publicznym IP/CGNAT, VPN, skrzynki, kopii i rozbudowy dysku. Cenę i zasady rozliczeń domknąć przed sprzedażą, bez blokowania prac nad mockiem.

**Odbiór:** lista potwierdzonych zasobów i braków, rejestr decyzji z właścicielem i bramką wdrożeniową, działające środowisko testowe oraz plan migracji/wycofania. Właściciel projektu rozstrzyga decyzje biznesowe i parametry utrzymania.

### Etap 1. Model danych, konta i spójność procesu

**Prace:**

1. Utworzyć modele zgodne z sekcją 10.1: sprawa, szkic z rewizją, przekazanie, plik i jego powiązania, runda, publikacja operatora, decyzja i cykl obsługi, notatka, przypisanie, prośba o wycofanie, zamówienie, próby/zdarzenia płatnicze, powiadomienie i synchronizacja. Dodać dziennik operacji oraz rejestr usunięć.
2. Rozdzielić numer sprawy, identyfikator systemowy, rewizję zapisu i numer formalnego przekazania. Zdefiniować niezmienność przekazań i historycznych decyzji.
3. Wprowadzić role klient/operator/administrator, indywidualne konta personelu, nazwę wyświetlaną oraz adresy odbiorców. Administrator nadaje i odbiera role; rejestracja klienta nigdy nie nadaje personelu.
4. Zaimplementować serwerowe reguły odczytu i zapisu dla spraw, wersji i plików, w tym niewidoczność szkiców dla operatora i notatek dla klienta. Oddzielić techniczną diagnostykę administratora od zwykłej obsługi spraw.
5. Zdefiniować pełną maszynę stanów z sekcji 6.2, oddzieloną od stanów płatności. Stosować kontrolę oczekiwanej rewizji i krótkie blokady transakcyjne przy konkurencyjnych akcjach.
6. Ograniczenia bazy mają chronić m.in. jedno zamówienie na sprawę, unikalność numeru wersji, jedną nierozpatrzoną prośbę, jedną aktualną decyzję w cyklu i idempotencję zadań. Przygotować trwałą kolejkę zadań i zdarzeń.

**Odbiór:** migracje przechodzą na pustej i testowo zmigrowanej bazie. Testy wykazują izolację klientów, odrzucanie niedozwolonych przejść, konfliktów oraz działań po odebraniu roli. Żaden widok administracyjny nie pozwala dowolnie zmieniać wpłat i decyzji.

**Powiązania:** SU-011, 013–014, 033, 035; NF-01, 02, 04, 12–13. Testy fundamentów AT-14, 15, 41, 46 i 48; pełne scenariusze zostaną domknięte po zbudowaniu UI.

### Etap 2. Pliki i dodatkowy zapis na dysku

**Prace:**

1. Dodać trwały prywatny magazyn, kwarantannę, bezpieczne klucze obiektów i pobieranie po autoryzacji. Nie budować ścieżek z nazw klienta; blokować wyjście poza katalog i odwołanie do pliku innej sprawy.
2. Obsłużyć PDF, JPG/JPEG, PNG i DOCX: rzeczywisty typ, strukturę DOCX, zagrożenia i sumy kontrolne. Niedostępny skaner utrzymuje kwarantannę; plik odrzucony, częściowy lub oczekujący nie może być przekazany ani opublikowany.
3. Egzekwować 20 MB/plik, 20 plików i 100 MB na przekazanie klienta albo publikację operatora. Wspólny limit historii to 500 MB unikalnych obiektów obu stron; ponowne wskazanie tego samego pliku i dodatkowa fizyczna kopia nie zwiększają go drugi raz. Zwiększenie limitu przez administratora zapisuje historię.
4. Wykorzystać istniejący `CASE_DATA_ROOT`: katalog `<id-sprawy>`, `sprawa.json`, `wersje/`, `zalaczniki/`. Schemat UTF-8 obejmuje wszystkie zapisane pola klienta, komentarze i powód wycofania, metadane procesu, tryb płatności oraz manifest plików klienta i operatora, także roboczych.
5. Rejestrować niezmienną rewizję i zadanie synchronizacji po każdej wymaganej zmianie. Kopiować oryginalne pliki, weryfikować sumy, publikować kompletną rewizję przez zapis tymczasowy i atomową wymianę wskaźnika/JSON na tym samym systemie plików. Starsze zadanie nie zastępuje nowszego stanu.
6. Udostępnić stan oczekujący/błąd/zakończony, ostatnią kompletną rewizję, ponowienie i uzgadnianie z bazą. Awaria dysku zachowuje zapis w bazie i poprzedni kompletny eksport; generuje alarm i czytelny stan dla użytkownika.
7. Przygotować bramkę publikacji: przekazanie do oceny oraz decyzja końcowa wymagają kompletnego zapisu ocenianych materiałów; publikacja plików operatora także ich kontroli i kopii. Po pracy poza transakcją serwer ponownie sprawdza status, wersję i wycofanie. Pliki robocze nie stają się widoczne przez samą obecność na dysku.
8. Uzgodnić opóźnione zadania z rejestrem usunięć. Usunięta sprawa nie może wrócić przez ponowienie synchronizacji. Zmiany stanu po zatwierdzonej operacji mają trwałe zadanie aktualizacji JSON; nie deklarować atomowości PostgreSQL i systemu plików.

**Odbiór:** komplet danych szkicu i wersji da się odczytać z JSON i manifestu. Wymiana kontenera nie usuwa plików. Wymuszone błędy miejsca, praw, sum kontrolnych i restart w trakcie zapisu nie niszczą danych ani nie publikują niekompletnych materiałów. Obie kopie pozostają prywatne.

**Powiązania:** SU-004, 028, 036–037; NF-03, 09–10. AT-03, 21, 25, 29, 39, 50–54; publikacje i retencję domykają etapy 5 i 8.

### Etap 3. Logowanie klienta, formularz i szkice

**Prace:**

1. Dodać Google i Facebook; rozważyć `django-allauth` wskazane w architekturze. Sprawdzić aktualne wymagania dostawców podczas implementacji. Przy braku e-maila zebrać i potwierdzić kontakt; nie łączyć kont wyłącznie po zgodności adresu.
2. Zbudować stronę usługi, „Moje sprawy” z filtrowaniem, sortowaniem i stronicowaniem oraz szczegóły z osobnym statusem sprawy i płatności, historią i następnym działaniem.
3. Formularz zawiera wyłącznie nazwę wniosku, opis i załączniki. Limity: 200 i 10 000 znaków; komentarze i uzasadnienia do 5 000. Nie obcinać tekstu po stronie serwera.
4. Ręczny zapis niepełnego szkicu, data ostatniego zapisu, ostrzeganie przed opuszczeniem niezapisanej treści i wykrywanie konfliktów dwóch kart. Błąd przesyłania pliku nie usuwa tekstu. Każdy skuteczny zapis wyzwala SU-036.
5. Umożliwić usunięcie własnego nieprzekazanego szkicu bez zamówienia, wraz z danymi katalogowymi. Operator nie widzi szkicu przez listę, adres ani pobranie pliku.
6. Zapewnić język polski, etykiety, fokus, obsługę klawiaturą, błędy niezależne od koloru i układ od szerokości 360 px. Terminy biznesowe wyznaczać według Europe/Warsaw.

**Odbiór:** klient po ponownym zalogowaniu odzyskuje szkic i pliki; formularz przyjmuje niepełny zapis, ale odrzuca niepoprawne przekazanie. Próby dostępu między kontami są blokowane. Test logowania obu dostawców wymaga skonfigurowanych aplikacji i adresów powrotu; lokalne konto testowe nie zastępuje tego odbioru.

**Powiązania:** SU-001–003, 016, 021, 028, 032–033; NF-05. AT-01–03, 15, 20, 28, 38, 45–46.

### Etap 4. Przekazania, zamówienia i lokalny mock

**Prace:**

1. Zbudować podsumowanie treści, plików i oferty. Formalne przekazanie wymaga poprawnych tekstów, minimum jednego gotowego pliku i wszystkich wybranych plików po kontroli.
2. Utrwalać wersję, warunki zakupu, jedno zamówienie i tryb `mock`/`p24`. Kwoty przechowywać w groszach; zmiana cennika nie zmienia istniejącego zamówienia. Po rozpoczęciu zakupu zablokować edycję materiałów.
3. Wprowadzić `PAYMENTS_MOCK_ENABLED`, domyślnie `false`, z jawną walidacją i audytem zmiany konfiguracji. Parametr żądania ani błąd P24 nie może go włączać.
4. W mocku użyć akcji „Złóż sprawę — płatność symulowana”; zapisać symulację z lokalnym identyfikatorem i ewentualną ceną testową. Brak ceny testowej nie oznacza bezpłatnej oferty handlowej. Nie wywoływać P24 dla zamówienia mock.
5. Po kompletnym zapisie kierować mock ze szkicu do weryfikacji, bez widocznego oczekiwania na płatność. Ponowienie po awarii lub podwójne kliknięcie daje jedną symulację, wersję i pozycję w kolejce.
6. Trwale oznaczać testowość w UI, historii, zamówieniu, JSON i zdarzeniach pocztowych. Przełączenie konfiguracji wpływa tylko na nowe zamówienia; testowe sprawy nie stają się należnościami ani nie wygasają jako nieopłacone.
7. Przygotować wspólną operację skutecznego złożenia, którą później uruchomi zweryfikowana płatność P24. W ścieżce rzeczywistej brak ceny lub konfiguracji blokuje zakup.

**Odbiór:** złożenie mock działa bez kluczy P24 i ceny handlowej, z zachowaniem uprawnień i kontroli dysku. Niepełny zapis daje oczekiwanie/błąd i możliwość bezpiecznego dokończenia, nie fikcyjne potwierdzenie wpłaty.

**Powiązania:** SU-005–006, 013–014, 032, 038. AT-04, 07, 17, 22, 45, 59, 61–62; przypadki P24 do pełnego odbioru w etapie 7.

### Etap 5. Obsługa operatora i administratora

**Prace:**

1. Zbudować wspólną kolejkę skutecznie złożonych spraw: filtr statusu i daty, wyszukiwanie numeru/nazwy/klienta, najstarsze pierwsze, daty oczekiwania i oznaczenie uzupełnień. Nie wprowadzać terminu obsługi.
2. „Podejmij sprawę” ustawia jednego prowadzącego; administrator zmienia przypisanie z historią. Każdy operator nadal może obsługiwać sprawę, a rzeczywisty autor czynności nie zastępuje automatycznie prowadzącego.
3. Obsłużyć rozpoczęcie oceny, ogólną listę kontrolną, notatki wewnętrzne i odczyt każdej przekazanej wersji. Operator nie edytuje danych klienta.
4. Zwrot wymaga publicznego uzasadnienia; tworzy rundę i odblokowuje kopię roboczą. Ponowne przekazanie tworzy niezmienną wersję, zachowuje prowadzącego i zamówienie, bez dopłaty. Komentarz może wyjaśnić brak zmian; minimum jednego pliku nadal obowiązuje. Operator rozstrzyga uwagi, nie samo kliknięcie klienta.
5. Akceptacja aktualnej wersji i zakończenie bez akceptacji zamykają obsługę. Drugie działanie wymaga niepustego uzasadnienia. Zachować autora, datę, wersję, historię i blokadę edycji.
6. Dodać prośbę klienta o wycofanie. Jedna oczekująca prośba blokuje wszystkie decyzje merytoryczne, także ze starego ekranu. Dowolny operator zatwierdza ją bez możliwości odmowy; status „Wycofana” nie uruchamia automatycznej refundacji.
7. Administrator może wznowić zakończoną sprawę z uzasadnieniem, jeśli dane istnieją. Powstaje nowy cykl, poprzednia decyzja pozostaje, nie powstaje nowa opłata. Klient edytuje dopiero po kolejnym zwrocie.
8. Dodać robocze załączniki operatora do rund i akceptacji: przed publikacją niewidoczne, po publikacji niezmienne, związane z konkretną wersją i rundą/decyzją. Publikacja oraz udostępnienie są jedną operacją biznesową po spełnieniu bramki etapu 2.
9. Trzy decyzje końcowe mają okno potwierdzenia numeru, nazwy, wersji i decyzji; zakończenie bez akceptacji pokazuje powód, akceptacja listę plików. Anulowanie jest bez skutków. Serwer ponownie weryfikuje stan i uprawnienia.
10. Publiczna historia pokazuje nazwę wyświetlaną rzeczywistego autora, bez loginu i służbowego e-maila. Administracja obejmuje cenę, limity i role z audytem zmian.

**Odbiór:** pełny cykl mock, wiele rund, wszystkie trzy zakończenia i wznowienie. Testy współbieżne wykazują jedną skuteczną decyzję lub przypisanie; nieaktualna publikacja nie ujawnia załączników. Historia i wpłata pozostają nienaruszone.

**Powiązania:** SU-007–011, 013–014, 017, 019–023, 027, 031, 035, 037. AT-09–14, 18, 22–24, 26–28, 30–31, 33–34, 37, 44, 48, 51, 55–58, 60.

### Etap 6. Powiadomienia i dostęp personelu

**Prace:**

1. Uzupełnić dane wspólnej skrzynki i adresy operatorów/opiekuna; zmienić nazwę nadawcy na „Portal spraw”. Sprawdzić uwierzytelnienie SMTP, dostarczenie oraz odbiór odpowiedzi. Dotychczasowy test STARTTLS nie potwierdza dostarczenia.
2. Zlecenia powiadomień zapisywać razem ze zdarzeniem biznesowym. Worker wysyła i ponawia; panel pokazuje błędy i umożliwia ponowienie. Awaria SMTP nie cofa przekazania, decyzji ani wpłaty.
3. Klient otrzymuje wiadomości o złożeniu, zwrocie, ponownym przekazaniu, decyzjach, zatwierdzeniu wycofania i wznowieniu. Nowa sprawa powiadamia zespół, uzupełnienie i prośba o wycofanie — prowadzącego lub zespół przy jego braku. Przed wysyłką ponownie sprawdzać uprawnienia odbiorcy.
4. Wiadomości zawierają numer, link po zalogowaniu, informację o opublikowanych plikach i oznaczenie mocka, bez dokumentów, pełnej treści i notatek. Odpowiedzi obsługuje człowiek we wspólnej skrzynce; formalne uzupełnienia wyłącznie w portalu.
5. Przypomnienia po 7 i 21 dniach kalendarzowych mają klucz sprawa–runda–próg. Przed wysyłką i ponowieniem sprawdzić aktualność rundy, status i oczekujące wycofanie. Zapis szkicu i odpowiedź e-mail nie zatrzymują przypomnień; przekazanie zatrzymuje.
6. Administrator inicjuje reset hasła operatora: jednorazowy token o uzgodnionej ważności, bez sekretów w logach. Reset nie przywraca odebranej roli. Opracować techniczną procedurę odzyskania administratora oraz ograniczenie prób logowania.

**Odbiór:** kontrolowane błędy SMTP nie gubią zleceń ani nie ujawniają sprawy byłemu operatorowi. Powtórne zdarzenie nie tworzy drugiego zlecenia; nie obiecywać dokładnie jednokrotnego doręczenia przez zewnętrzne SMTP. Testy czasu potwierdzają przypomnienia i wygasanie resetu.

**Powiązania:** SU-012, 026, 029–030, 034; NF-02, 09, 13. AT-16, 36, 40–43, 47 oraz pocztowe części AT-55–56 i 60.

### Etap 7. Przelewy24 i wyjątki finansowe

**Prace:**

1. Zweryfikować aktualną dokumentację P24 podczas implementacji, skonfigurować sandbox, publiczny HTTPS dla potwierdzeń i adres powrotu. Dostępność BLIK/Google Pay/Apple Pay sprawdzić na koncie operatora płatności.
2. Zarejestrować próby na istniejącym zamówieniu. Serwer ustala dodatnią cenę i wersję oferty; brak konfiguracji blokuje realny zakup. Powrót przeglądarki tylko pokazuje stan — nie potwierdza wpłaty.
3. Weryfikować serwerowo identyfikator, kwotę, walutę i zgodność transakcji z zamówieniem. Obsłużyć powtórzone i spóźnione zdarzenia oraz zakazać cofnięcia potwierdzonej wpłaty przez starszy komunikat.
4. Dodać uzgadnianie nieznanych wyników przed nową próbą, widok transakcji do wyjaśnienia i nadpłat. Dwie rzeczywiste wpłaty zachować jako dwa zdarzenia, z jednym skutecznym złożeniem.
5. Przy wpłacie i awarii dysku zachować wpłatę oraz oczekujące przekazanie. Po naprawie dokończyć skierowanie do kolejki bez nowego obciążenia i duplikatów.
6. Termin 30 dni liczyć od utworzenia zamówienia według Europe/Warsaw; pokazywać go klientowi. Po terminie blokować nowe próby i uzgodnić stare. Nieznana płatność blokuje usuwanie; wpłata wykonana w terminie jest ważna mimo późnego potwierdzenia. Wpłata po terminie wymaga wyjaśnienia.
7. Zachować tryb każdego zamówienia po przełączeniu mocka. Nadal przetwarzać rzeczywiste potwierdzenia starych zamówień P24; webhook nie może opłacić zamówienia mock. Rozdzielić konfiguracje sandbox/produkcja i transakcje testowe/rzeczywiste.
8. Wdrożyć uzgodnioną procedurę rozliczeń i powiązania dokumentów sprzedaży. Nie wyprowadzać refundacji ani bezzwrotności z samej decyzji w sprawie.

**Odbiór:** sandbox przechodzi ścieżkę poprawną, duplikaty, niezgodne dane, zamknięcie przeglądarki, awarie i uzgadnianie. Ponowne wykonanie procesu daje jeden efekt biznesowy. Zwykły operator nie może ręcznie oznaczyć dowolnej sprawy jako opłaconej.

**Powiązania:** SU-005–006, 014, 016, 025, 038; NF-04. AT-04–08, 17, 24, 35, 61–62.

### Etap 8. Retencja, bezpieczeństwo wdrożenia i utrzymanie

**Prace:**

1. Wdrożyć idempotentne usuwanie: szkice bez zamówienia po 30 dniach bezczynności, zakończone sprawy po 6 miesiącach od ostatniego zakończenia, logi techniczne po 90 dniach. Nieopłacone zamówienia usuwać po terminie wyłącznie po potwierdzeniu braku wpłaty; pozostawić minimalne metadane rozliczeń według osobno ustalonej retencji.
2. Przed usunięciem ponownie sprawdzić stan, datę zapisu i cykl obsługi. Wznowienie lub nowy zapis chroni przed starym zadaniem. Objąć bazę treści, główny magazyn, kwarantannę, pliki operatora, JSON i rewizje. Rejestr usunięć blokuje odtworzenie przez spóźniony worker i po przywróceniu kopii.
3. Skonfigurować domenę, HTTPS, bezpieczne sesje, ochronę żądań zmieniających stan, ograniczenie nadużyć i sekrety poza kodem. Panel personelu oraz jego endpointy dostępne tylko przez VPN; publiczne logowanie klientów i webhook P24 pozostają osiągalne. Sprawdzić to z sieci publicznej i VPN, także po adresach bezpośrednich.
4. Dostosować UID/GID aplikacji i prawa montowań, przetestować zapis z `web` i workera. Ustawić limity żądań i transferu zgodnie z plikami do 20 MB oraz zestawami do 100 MB; uwzględnić narzut protokołu i przerwane przesyłania.
5. Zaplanować i wykonać rozbudowę pojemności przed rzeczywistym gromadzeniem dokumentów. Dla 10 spraw/dzień po 30 MB dwie fizyczne kopie oznaczają około 219 GB rocznego przyrostu przed retencją, rewizjami i przestrzenią tymczasową. To oszacowanie przepływu, nie gwarantowane zajęcie po retencji; aktywne sprawy nie mają limitu czasu obsługi. Monitorować VM i współdzieloną pulę hosta.
6. Uruchomić uzgodnione szyfrowane kopie poza Dellem: baza, prywatny magazyn, katalog spraw i niezbędna konfiguracja. Kopia na tym samym dysku nie jest zabezpieczeniem przed awarią hosta. Ustalić spójny punkt odtworzenia, RPO/RTO, retencję i cykliczne testy.
7. Odtworzyć w odseparowanym środowisku sprawę z wersjami i plikami obu stron; sprawdzić sumy, rejestr usunięć oraz uzgodnienie późniejszych wpłat P24. Zmierzyć czas i porównać z zatwierdzonym celem.
8. Dodać monitoring dostępności, workerów i zaległości, SMTP, synchronizacji, niewyjaśnionych wpłat, kopii, skanera i miejsca. Alarmy kierować do właściciela projektu. Logować identyfikator błędu bez treści spraw, tokenów i sekretów.

**Odbiór:** AT-19, 32, 35, 42, 53–54 oraz testy awarii i odtworzenia. Retencja nie usuwa danych aktualnie zapisanych, wznowionych ani płatności do wyjaśnienia. Monitoring wykrywa zasymulowane awarie. Parametry NF-06/07 i progi 75%/85% wymagają zatwierdzenia, zanim będą traktowane jako gwarancje.

**Powiązania:** SU-024–025, 036; NF-01–13, zwłaszcza NF-08–13.

### Etap 9. Odbiór i uruchomienie

**Brama A — pilotaż lokalny mock:** po etapach 1–6 oraz przygotowaniu izolacji, diagnostyki i kontroli danych testowych. Przeprowadzić proponowane 5–10 fikcyjnych spraw, z oddzielnymi kontami klienta, operatora i administratora. Przejść uzupełnienia, pliki operatora, trzy zakończenia, wycofanie i wznowienie; potwierdzić oznaczenia symulacji. Nie wymaga to ustalonej ceny handlowej ani P24. Nie jest to odbiór produkcji.

**Brama B — odbiór MVP w środowisku testowym:** po etapach 7–8. Wykonać wszystkie AT-01–AT-62 z rejestrem wyniku i dowodów. Oddzielić lokalny mock od testów sandboxa P24. Scenariusze współbieżności, izolacji, awarii i retencji sprawdzać również bezpośrednimi żądaniami do serwera. Testy współbieżności uruchamiać na PostgreSQL. NF-05 zweryfikować na 360 px i klawiaturą; test wydajności przeprowadzić według zatwierdzonych parametrów. AT-49 dokumentuje pilotaż i separację środowisk.

**Brama C — płatny pilotaż:** wymagane są dodatnia cena, zatwierdzone zasady rozliczeń i dokumentów sprzedaży, oferta i zasady danych, domena, HTTPS/VPN, działająca poczta, konta dostawców, pojemność, kopie z testem odtworzenia i odbiorca alarmów. Sprawdzić produkcyjną konfigurację P24, wyłączenie mocka dla nowych zamówień i trwałe zachowanie testowych oznaczeń historycznych spraw. Właściciel projektu zatwierdza odbiór i start.

**Procedura wydania:** kopia przed migracją → kontrolowane wdrożenie migracji i obrazu → `collectstatic` → kontrola Compose/Django/migracji → test dostępu klienta i personelu, prywatnych plików, workera i konfiguracji płatności. Plan wycofania musi uwzględniać migracje oraz wpłaty otrzymane po wdrożeniu; nie odtwarzać ślepo starej bazy kosztem nowych wpłat lub decyzji. W razie problemu można wstrzymać nowe zakupy, zachowując obsługę potwierdzeń i uzgadnianie.

Po starcie mierzyć liczbę rund, czas oceny oraz problemy z plikami, płatnościami, dyskiem i pocztą. Nie tworzy to zobowiązania do obsługi w określonym terminie.

## 4. Decyzje i ich najpóźniejsze terminy

| Decyzja | Najpóźniej przed | Konsekwencja braku |
|---|---|---|
| Jednostki limitów, znaki, daty, protokół synchronizacji i usuwania | Implementacją odpowiednich mechanizmów w etapach 1–2 | Brak jednoznacznych testów i ryzyko niespójności |
| Skaner, prywatny magazyn i zasoby | Odbiorem etapu 2 | Pliki pozostają niegotowe do przekazania |
| OAuth i adresy powrotu obu dostawców | Odbiorem logowania | Lokalny test kont nie odbiera SU-001 |
| Skrzynka, adresy personelu i opiekuna, ważność resetu | Odbiorem etapu 6 | Brak odbioru powiadomień i resetu |
| Cena, rozliczenia, dokument sprzedaży, oferta i zasady danych | Płatnym startem | Mock może działać; sprzedaż zablokowana |
| Domena, dostęp publiczny i VPN | Zewnętrznymi testami integracji i produkcją | Brak docelowego odbioru HTTPS/OAuth/P24 |
| Kopie, RPO/RTO, retencja rozliczeń i kopii, odtwarzanie | Odbiorem etapu 8 i produkcją | Brak gotowości produkcyjnej |
| Pojemność, parametry wydajności/dostępności i progi alarmów | Odbiorem utrzymania | Propozycje nie stają się gwarancjami |

Właściciel projektu podejmuje decyzje biznesowe i utrzymaniowe; wykonawca przygotowuje warianty techniczne oraz dowody odbioru. Otwarte decyzje blokują tylko zależne funkcje lub odpowiednią bramkę, nie cały rozwój.

## 5. Kontrola kompletności i zakres odłożony

Każdy etap kończy się migracjami lub konfiguracją możliwą do odtworzenia, wynikami właściwych testów, opisem obsługi błędów i aktualizacją dokumentacji. Przy wdrażaniu aktualizować `ARCHITEKTURA.md`, wyraźnie oddzielając stan wykonany od planowanego. W rejestrze odbioru zachować identyfikatory SU/NF/AT ze specyfikacji; wymienienie testu przy etapie oznacza plan jego wykonania, nie zaliczenie.

Wspólna kontrola przed płatnym MVP obejmuje wszystkie wymagania M i AT-01–AT-62. Testy fundamentów wykonuje się wcześniej, a końcowy odbiór potwierdza ich działanie w całym procesie. Szczególną uwagę poświęcić równoczesnym decyzjom i wycofaniu, wpłacie przy awarii dysku, wyścigowi retencji ze wznowieniem oraz opóźnionej synchronizacji po usunięciu.

Po MVP pozostają: porównywanie wersji z wyróżnieniem różnic (SU-018), autosave, szablony uwag i wyszukiwanie pełnotekstowe opisów. Nie wprowadzać do planu MVP formularzy branżowych WZ, dynamicznych pól klienta, generowania dokumentów, podpisu elektronicznego, współdzielenia spraw, automatycznych decyzji AI, czatu, logowania linkiem e-mail ani dalszej realizacji po akceptacji.
