# Portal WZ — specyfikacja wymagań

Wersja 0.8, 14 listopada 2026 r. Dokument roboczy po siódmej rundzie brainstormingu.

## 1. Cel, źródła i status wymagań

Portal zbiera od klientów dane i dokumenty potrzebne pracownikowi do przygotowania wniosku o warunki zabudowy. Dokument jest podstawą projektowania formularzy, implementacji i odbioru pierwszej wersji produktu (MVP).

Źródła:

- Pierwotny `wymagania.md`; zachowana [kopia sprzed rozbudowy](wymagania.przed-rozbudowa-2026-11-14.md).
- [ARCHITEKTURA.md](ARCHITEKTURA.md): założenia i opis lokalnego wdrożenia z 12 listopada 2026 r.
- Rozmowa projektu „Przygotuj plan aplikacji WZ”: formularz krokowy, zapis, nieznane odpowiedzi i pilotaż.
- Rozmowa „Zaproponuj architekturę aplikacji WZ”: odczytano ostatnie 10 tur i dokument podsumowujący architekturę.
- Rozmowa „Wybierz płatności BLIK i portfele”: preferowane metody i przebieg płatności.
- Odpowiedzi użytkownika w rundach 1–2 bieżącej sesji: domy jednorodzinne, jedna cena, możliwość przekazania materiałów z brakami; cena obejmuje wyłącznie przygotowanie wniosku, uzupełnienia są w cenie, obsługa całej Polski.

Przejrzano też rozmowy ChatGPT „Porównanie płatności online” i „Wniosek o warunki zabudowy”. Ta druga dotyczy konkretnej inwestycji i nie stanowi podstawy uniwersalnych reguł prawnych. W dostępnej liście projektów ChatGPT nie znaleziono projektu o nazwie WZ; podstawą są dostępne rozmowy projektu lokalnego i wskazane pliki.

**Ustalone** oznacza wcześniejsze założenie lub odpowiedź użytkownika. Szczegóły wymagań i kryteria odbioru poniżej są **proponowaną specyfikacją realizacji**, a nie deklaracją wdrożenia. Priorytety: **M** — niezbędne w proponowanym MVP, **S** — pożądane, **L** — później. Priorytet nie oznacza zatwierdzenia nowej decyzji biznesowej.

Dokument nie ustala aktualnych obowiązków urzędowych ani podatkowych. Przed implementacją osoba przygotowująca wnioski zatwierdza katalog danych i dokumentów względem aktualnego wzoru i obsługiwanych przypadków. Nie zakładamy, że każda sprawa wymaga tego samego zestawu opinii o mediach.

## 2. Słownik pojęć

| Pojęcie | Znaczenie |
|---|---|
| Sprawa | Rekord inwestycji w portalu, widoczny klientowi jako „wniosek”. |
| Wniosek urzędowy | Dokument przygotowywany przez pracownika. Złożenie do urzędu nie jest objęte usługą. |
| Właściciel sprawy | Konto, które ją utworzyło; nie musi być wnioskodawcą ani właścicielem działki. |
| Wnioskodawca | Osoba lub podmiot wskazany w danych do wniosku. |
| Szkic | Edytowalne, zapisane odpowiedzi. |
| Przekazanie | Niezmienna wersja odpowiedzi i powiązań z plikami przeznaczona do oceny. |
| Brak | Nieznana informacja, niedostarczony dokument lub kwestia do wyjaśnienia. |
| Dane kompletne | Pracownik uznał materiały za wystarczające do dalszej pracy; nie oznacza decyzji WZ. |
| Zamówienie | Zakup usługi dla sprawy z utrwaloną ceną i zakresem. |
| Próba płatności | Osobna operacja płatnicza przypisana do zamówienia. |

## 3. Wizja i zakres

### 3.1 Ustalone założenia

1. Sprawę inicjuje klient; konto może mieć wiele spraw.
2. Potwierdzenie kompletności kończy etap zbierania danych. Pracownik następnie przygotowuje wniosek i udostępnia klientowi DOCX w portalu z powiadomieniem e-mail. Usługa nie obejmuje złożenia do urzędu, ale obejmuje poprawki po wezwaniu urzędu.
3. Pierwsza wersja obsługuje **domy jednorodzinne**.
4. Obowiązuje **cena 500 PLN za standardową sprawę, obejmująca przygotowanie wniosku i załącznika graficznego, uzupełnienia i poprawki po wezwaniu urzędu**. **500 PLN jest końcową kwotą do zapłaty za usługę** (50 000 groszy), bez doliczania podatku lub opłaty płatniczej do tej kwoty. Sposób wykazania podatku na dokumencie sprzedaży pozostaje kwestią rozliczeniową B-07 i nie zmienia ceny końcowej. Standard obejmuje **jeden dom z garażem i zagospodarowaniem, na jednej lub kilku działkach**. Pierwsza weryfikacja: **w ciągu 2 dni roboczych od opłacenia sprawy**. Termin przygotowania kompletu: **7 dni roboczych od zebrania kompletnych danych**. Poprawki po wezwaniu urzędu: **3 dni robocze od otrzymania kompletu informacji do danego zgłoszenia**. Załącznik graficzny jest osobnym PDF. Mapę źródłową dostarcza klient; jej zakup jest poza ceną usługi.
5. Klient **może przekazać materiały z oznaczonymi brakami**. Poprawność formularza nie oznacza kompletności merytorycznej.
6. Płatność przez **Przelewy24** przed kolejką weryfikacji. Preferowane metody: BLIK, Google Pay, Apple Pay.
7. Logowanie klienta przez Google lub Facebook; oddzielne uprawnienia personelu.
8. Maksymalnie 10 nowych spraw dziennie.
9. Jedna aplikacja Django i relacyjna baza na osobnej VM Proxmox; konfiguracja w `ARCHITEKTURA.md`.
10. Obsługiwane są inwestycje z **całej Polski**; brak ograniczenia do wybranych gmin lub województw.

**Pierwszeństwo ustaleń:** powyższy zakres aktualizuje wcześniejszy zapis w `ARCHITEKTURA.md` o składaniu wniosku przez pracownika. Opis architektury dokumentuje wcześniejsze założenia; aktualny zakres biznesowy określa niniejsza specyfikacja.

### 3.2 Proponowane MVP

Opis usługi i ceny, logowanie, lista spraw, formularz z zapisem, prywatne pliki, podsumowanie, płatność, kolejka pracownika, uzupełnienia, ponowne przekazanie, e-maile, historia, kompletność, publikacja DOCX i poprawki po wezwaniu urzędu. Panel może bazować na Django admin, ale musi realizować opisane reguły biznesowe.

Poza zakresem usługi: składanie wniosku do urzędu. Poza MVP: automatyczne śledzenie postępowania urzędowego, automatyczna ocena prawna działki, gwarantowanie WZ, automatyczne generowanie urzędowego formularza, GIS, OCR, chatbot AI, współdzielenie spraw i inne typy inwestycji. Robocze zestawienie danych nie jest wnioskiem urzędowym.

Pilotaż: proponowane 5–10 spraw. Mierzymy ukończenie formularza, liczbę tur uzupełnień, czas pracy pracownika, najczęstsze nieznane odpowiedzi i błędy płatności. Cele liczbowe ustalamy po pilotażu. Każda wpłata musi mieć powiązaną sprawę; klient nie może uzyskać dostępu do cudzych materiałów.

## 4. Role i dostęp

| Rola | Dostęp |
|---|---|
| Gość | Opis, cena, zasady i logowanie. |
| Klient | Wyłącznie własne sprawy, dane, płatności i pliki; tworzenie i uzupełnianie. |
| Pracownik | Propozycja MVP: wspólna kolejka wszystkich spraw; ocena, braki, kompletność, publikacja DOCX i poprawki. |
| Administrator | Uprawnienia, konfiguracja i oferta; operacje rejestrowane. |
| Operator płatności | Dedykowana integracja, bez dostępu do dokumentów inwestycji. |

Każdy odczyt, zapis, eksport i pobranie pliku wymaga kontroli uprawnień na serwerze. Znajomość numeru albo adresu pliku nie daje dostępu. Notatki wewnętrzne są niewidoczne klientowi. Pracownik nie otrzymuje automatycznie administracji kontami i sekretami.

## 5. Proces i statusy

1. Klient poznaje usługę, loguje się i tworzy sprawę z numerem.
2. Uzupełnia kroki, zapisuje szkic, dodaje pliki. Niewiedzę oznacza „Nie wiem / potrzebuję pomocy”, brak dokumentu — „Nie mam”.
3. Podsumowanie pokazuje odpowiedzi, braki, pliki, cenę i zakres. Portal sprawdza minimum danych.
4. „Zapłać i przekaż do weryfikacji” utrwala wersję, warunki zamówienia i próbę płatności, następnie przekierowuje do P24.
5. Zweryfikowana przez serwer wpłata jednokrotnie przekazuje sprawę do kolejki. Powrót przeglądarki nie potwierdza zapłaty.
6. W ciągu 2 dni roboczych od opłacenia sprawy pracownik przeprowadza pierwszą weryfikację konkretnej wersji i publikuje braki albo potwierdzenie kompletności.
7. Klient poprawia i przekazuje nową wersję. Uzupełnienia są w cenie i nie wymagają kolejnej opłaty. Granica między uzupełnieniem a zmianą zamówionej inwestycji pozostaje do doprecyzowania (B-04).
8. Potwierdzenie kompletności wskazuje ocenioną wersję, pracownika i datę.
9. Pracownik przygotowuje dokumenty poza portalem i publikuje gotowy DOCX wraz z osobnym załącznikiem graficznym PDF w terminie 7 dni roboczych od zebrania kompletnych danych. Status zmienia się na „Wniosek gotowy”; klient otrzymuje e-mail z odsyłaczem do pobrania po zalogowaniu.
10. Po otrzymaniu wezwania urzędu klient zgłasza poprawki w tej samej sprawie, dodaje wezwanie lub jego treść i podaje wskazany w nim termin, jeśli występuje. Sprawa wraca do obsługi bez płatności.
11. Pracownik analizuje wezwanie, w razie potrzeby prosi o dane i w ciągu 3 dni roboczych od otrzymania kompletu informacji publikuje nową wersję kompletu, aktualizując DOCX lub załącznik graficzny stosownie do wymaganych poprawek. Poprzednia wersja pozostaje w historii; klient otrzymuje kolejne powiadomienie.

### 5.1 Proponowane przejścia statusu sprawy

| Z | Do | Wykonawca i warunek |
|---|---|---|
| Szkic | Oczekuje na płatność | Klient; minimum danych i utrwalona wersja. |
| Oczekuje na płatność | Do weryfikacji | System; zweryfikowane opłacenie zamówienia. |
| Do weryfikacji | W weryfikacji | Pracownik rozpoczyna ocenę. |
| W weryfikacji | Do uzupełnienia | Pracownik publikuje co najmniej jeden brak. |
| W weryfikacji | Dane kompletne | Pracownik rozstrzyga wszystkie braki. |
| Do uzupełnienia | Do weryfikacji | Klient przekazuje nową wersję i odpowiedzi. |
| Dane kompletne | W weryfikacji | Propozycja: pracownik wznawia z uzasadnieniem i zachowaniem historii. |
| Dane kompletne | W przygotowaniu | Pracownik rozpoczyna przygotowanie dokumentu. |
| W przygotowaniu | Do uzupełnienia | Pracownik publikuje dodatkowe pytania potrzebne do przygotowania. |
| W przygotowaniu | Wniosek gotowy | Pracownik publikuje sprawdzony DOCX i załącznik graficzny. |
| Wniosek gotowy | Poprawki zgłoszone | Klient przekazuje wezwanie urzędu lub opis wymaganych poprawek. |
| Poprawki zgłoszone | W weryfikacji | Pracownik rozpoczyna analizę; dalsza ścieżka prowadzi przez ewentualne uzupełnienia i przygotowanie nowej wersji. |

„Wniosek gotowy” oznacza udostępnienie dokumentu, a nie jego złożenie ani wydanie WZ. Kolejne wezwanie może ponownie otworzyć tę samą sprawę. Poprawki i ponowne publikacje nie zmieniają potwierdzonej płatności i nie wymagają nowego zamówienia. Portal nie monitoruje automatycznie korespondencji z urzędem.

Przerwanie płatności nie usuwa sprawy. Propozycja MVP: wersja oczekująca na wpłatę jest zablokowana do edycji, a ponowienie dotyczy tej samej wersji i ceny. Zmiana zakresu lub rezygnacja wymaga obsługi pracownika. Przy nieustalonym wyniku najpierw sprawdzamy poprzednią próbę, zanim utworzymy kolejną. Późne potwierdzenia nadal są rozliczane.

Anulowanie, wycofanie nieopłaconego zamówienia i zwroty wymagają B-06. Nie projektujemy automatycznego anulowania opłaconej sprawy ani usuwania jej materiałów przed ustaleniem zasad.

### 5.2 Płatność jako osobny stan

Status próby: utworzona, oczekująca, potwierdzona, nieudana, wygasła, wymaga wyjaśnienia. Zwrot jest osobną operacją, jeżeli wejdzie do zakresu.

Starsze zdarzenie nie cofa potwierdzonej wpłaty. Duplikat nie uruchamia drugiej realizacji. Dwie faktycznie opłacone próby pozostają dwiema wpłatami, ale jedną realizacją; nadpłata trafia do wyjaśnienia.

## 6. Wymagania funkcjonalne — klient

Zachowano identyfikatory RQ-001–RQ-005 z pierwotnego dokumentu.

| ID / priorytet | Wymaganie | Kryterium odbioru |
|---|---|---|
| RQ-001 / M | Logowanie Google/Facebook, wylogowanie, bezpieczna sesja, potwierdzony kontakt e-mail. Konto oddzielone od wnioskodawcy. | Ponowne logowanie przywraca sprawy; błąd logowania nie tworzy sprawy. Brak e-maila od dostawcy uruchamia zebranie i potwierdzenie kontaktu. Kont nie łączymy wyłącznie po zgodnym e-mailu; odzyskanie dostępu wymaga potwierdzenia tożsamości. |
| RQ-002 / M | Dashboard: sprawy wymagające działania, ostatnie sprawy i nowa sprawa; numer, lokalizacja, status sprawy i osobno płatności. | Klient wie, czy ma dopisać dane, zapłacić, uzupełnić czy czekać. Nowe konto ma objaśnienie kroków. |
| RQ-003 / M | Lista własnych spraw: filtry statusu, sortowanie, stronicowanie; szczegóły danych, plików, uwag, przekazań i płatności. | Sprawy są niezależne; manipulacja identyfikatorem nie udostępnia cudzej sprawy; notatki wewnętrzne są ukryte. |
| RQ-004 / M | Formularz krokowy: kontakt, wnioskodawcy, działki, inwestycja, droga, media, dokumenty, podsumowanie. Zapis częściowy i powrót. | Szkic można wznowić po wylogowaniu. Błędy przy polach; jawne stany niewiedzy. „Zapisz i kontynuuj” i „Zapisz i wyjdź” pokazują wynik zapisu. Autosave jako S. |
| RQ-005 / M | Płatność P24 przez przekierowanie. Końcowa cena 500 PLN i zakres przed zakupem; serwer zapisuje 50 000 groszy, walutę PLN i wersję oferty. | Powrót bez potwierdzenia pokazuje oczekiwanie. Manipulacja kwotą nieskuteczna. Awaria rejestracji zachowuje materiały. Podwójne kliknięcie nie tworzy dwóch aktywnych zamówień. Zmiana cennika nie zmienia rozpoczętego zakupu. |
| RQ-006 / M | Prywatne pliki z kategorią, nazwą, rozmiarem, autorem, datą i powiązaniem z wersją. | Kontrola typu i zagrożeń; kwarantanna do zakończenia kontroli. Limit nie usuwa formularza. Zastąpienie nie nadpisuje historycznego pliku. |
| RQ-007 / M | Podsumowanie odpowiedzi, braków, plików, ceny i zakresu; numerowane, niezmienne przekazania. | Pracownik widzi materiały związane z opłaconą wersją. Poprawka nie zmienia historii. Potwierdzenie zawiera numer sprawy i następny krok. |
| RQ-008 / M | Pytania pracownika przy polu, pliku lub sprawie; odpowiedź tekstem, zmianą danych lub plikiem. Uzupełnienia w cenie. | Ponowne przekazanie uzupełnień nie wymaga płatności. Nowa wersja zachowuje wcześniejsze uwagi. Pracownik oznacza każdy brak jako rozwiązany albo nieistotny z uzasadnieniem przed kompletnością. |
| RQ-009 / M | E-maile po wpłacie i przekazaniu, publikacji braków, kompletności oraz każdej opublikowanej wersji DOCX; numer i link wymagający logowania, bez dokumentów. | Błąd poczty nie cofa statusu; trwały zapis do ponowienia i błąd widoczny obsłudze. Duplikat zdarzenia nie planuje następnych identycznych wiadomości. |
| RQ-010 / M | Publiczny opis usługi, ceny, kroków i kontaktu; zatwierdzone treści informacyjne i warunki. | Zakres i cena spójne z zamówieniem: 500 PLN za jeden dom z garażem i zagospodarowaniem na jednej lub kilku działkach: przygotowanie wniosku i załącznika graficznego, uzupełnienia i poprawki po wezwaniu urzędu, bez składania do urzędu; obsługa całej Polski. Oferta wskazuje wynik DOCX + osobny PDF, mapę dostarczaną przez klienta i jej zakup poza ceną, termin pierwszej weryfikacji 2 dni robocze od opłacenia, przygotowania 7 dni roboczych od kompletnych danych oraz poprawek 3 dni robocze od kompletu informacji. Kompletność danych odróżniona od wykonania usługi i decyzji urzędu. |

**Załączniki klienta — propozycja:** PDF, JPG, PNG; 20 MB na plik, 20 plików i 100 MB na sprawę. Limity konfigurowalne, do sprawdzenia na przykładowych mapach i względem pojemności. Kategorie: mapa, szkic, media, droga, reprezentacja, wezwanie urzędu, inne. Kategoria nie oznacza obowiązku dołączenia. Usunięcie pliku ze szkicu nie usuwa pliku historycznego; tym zarządza retencja.

**Metody płatności:** BLIK, Google Pay i Apple Pay wymagają potwierdzenia aktywacji na koncie operatora i sprawdzenia na właściwych urządzeniach przed startem. Portal nie przechowuje danych kart ani kodów BLIK. Szczegóły protokołu sprawdzamy w aktualnej dokumentacji przy implementacji.

**Powiadomienia:** portal jest źródłem aktualnego statusu. Nie obiecujemy dokładnie jednokrotnego doręczenia przez zewnętrzny serwer poczty.

## 7. Katalog danych i walidacja

### 7.1 Proponowane pytania

| Obszar | Dane | Obsługa niewiedzy |
|---|---|---|
| Kontakt | Osoba kontaktowa, potwierdzony e-mail; telefon proponowany jako opcjonalny. | E-mail wymagany przed płatnością. |
| Wnioskodawcy | Jedna lub wiele osób, imię, nazwisko, adres i rola osoby wypełniającej; podmiot, jeśli dopuszczony. | Brakujące dane do wyjaśnienia. |
| Lokalizacja | Województwo, powiat, gmina, miejscowość, obręb, numer działki; pełny identyfikator, jeśli znany. | Numer bez obrębu nie identyfikuje jednoznacznie działki. |
| Działki | Wiele działek, powierzchnia działki i osobno terenu inwestycji; całość albo część. | Zero nie zastępuje nieznanej powierzchni. |
| Zamierzenie | Rodzaj prac, liczba domów, opis, dodatkowe obiekty, istniejąca zabudowa. | Przypadek poza standardem do kontaktu przed zakupem. |
| Parametry domu | Powierzchnia zabudowy, wysokość, kondygnacje, szerokość elewacji, geometria i nachylenie dachu. | „Nie wiem”; możliwość dołączenia posiadanego materiału projektu. |
| Zagospodarowanie | Powierzchnia biologicznie czynna, utwardzenia, parking i opis zagospodarowania. | Bez automatycznego wyliczania wartości urzędowych z niepełnych danych. |
| Droga | Sposób dojazdu, działki drogowe i dostępne dokumenty. | „Nie wiem / do ustalenia”. |
| Media | Woda, ścieki sanitarne, energia, gaz, ogrzewanie, wody opadowe; stan istniejący i planowany. | „Nie wiem”, „Brak” i „Nie dotyczy” to różne odpowiedzi. |
| Dokumenty | Posiadane mapy, szkice i dokumenty; kategorie i pliki. | „Nie mam” i opis potrzebnej pomocy. |
| Rozliczenie | Dane nabywcy według wybranego procesu sprzedaży. | Zakres i obowiązkowość do decyzji B-07. |

To katalog roboczy, nie pełne odwzorowanie urzędowego wzoru. Nie dodajemy obowiązkowego PESEL, skanu dowodu ani numeru księgi wieczystej bez uzasadnienia konkretnego procesu.

### 7.2 Proponowane reguły

- Szkic dopuszcza częściowe dane; kontrolujemy format wpisanych wartości.
- Przed płatnością wymagamy kontaktu, standardowej usługi, opisu oraz lokalizacji umożliwiającej rozpoczęcie identyfikacji: gmina i numer z obrębem albo opis lokalizacji z oznaczonym brakiem. Minimum do zatwierdzenia w B-03.
- Istotne pytanie ma odpowiedź albo jawne „Nie wiem / Nie mam / Nie dotyczy”. Puste pole nie ukrywa braku.
- Liczby mają jednostki, poprawny format i ograniczenia techniczne. Zero nie zastępuje niewiedzy; minimum nie przekracza maksimum.
- Pola zależne pojawiają się po odpowiedniej odpowiedzi. Zmiana nadrzędnej odpowiedzi pokazuje, które wcześniejsze dane przestają obowiązywać.
- Ostrzeżenie o niespójności nie jest oceną dopuszczalności inwestycji.
- Wersjonujemy treści i reguły; ich aktualizacja nie zmienia wcześniejszych przekazań.

## 8. Wymagania funkcjonalne — pracownik

| ID / priorytet | Wymaganie | Kryterium odbioru |
|---|---|---|
| RQ-011 / M | Kolejka, filtry statusu, płatności i dat; sortowanie od najstarszych; wyszukiwanie numeru, klienta, działki. | Opłacone sprawy wymagające oceny są odróżnione od szkiców. |
| RQ-012 / M | Dane, wersje, prywatne pliki, braki i notatki wewnętrzne. | Starsze wersje są czytelne, notatki niewidoczne klientowi. |
| RQ-013 / M | Zmiany statusu zgodne z procesem, autor, czas i uzasadnienie wznowienia. | Niedozwolone przejście odrzucane także w bezpośrednim żądaniu do serwera. |
| RQ-014 / M | Publikowanie braków i kompletności dla wersji. | Nie można zatwierdzić starszej wersji po równoczesnym wpłynięciu nowszej. |
| RQ-015 / M | Podgląd prób płatności, wyjątków i ponowne sprawdzenie po błędzie. | Brak zwykłego przycisku dowolnie ustawiającego wpłatę jako potwierdzoną. |
| RQ-016 / S | Robocze zestawienie do wydruku lub eksportu. | Numer sprawy i wersji, nieznane odpowiedzi, spis plików, oznaczenie „materiał roboczy”. |
| RQ-017 / M | Historia istotnych zmian i operacji. | Kto, kiedy, co i dlaczego; pracownik nie edytuje historii przekazań i wpłat. |
| RQ-018 / S | Przypisanie prowadzącego i ostrzeżenie o równoczesnej pracy. Kontrola konfliktu zapisu jest M. | Drugi zapis nie nadpisuje po cichu pierwszego. |
| RQ-019 / M | Administracja uprawnieniami, ofertą i formularzem. | Odebranie uprawnień blokuje dalszy dostęp; nowa cena nie zmienia historycznych zamówień. |

## 9. Model informacji i integracje

### Dodatkowe wymagania po rundzie 3

| ID / priorytet | Wymaganie | Kryterium odbioru |
|---|---|---|
| RQ-020 / M | Pracownik przesyła i świadomie publikuje gotowy DOCX w prywatnej sprawie; wersja dokumentu, autor, data i opis zmian są zapisane. | Nieopublikowany dokument jest niewidoczny klientowi. Publikacja wymaga poprawnego pliku i zakończonej kontroli bezpieczeństwa; daje status „Wniosek gotowy” i planuje e-mail. Pobranie tylko przez uprawnionego użytkownika. |
| RQ-021 / M | Klient zgłasza poprawki po wezwaniu urzędu, załącza wezwanie lub wpisuje jego treść i termin, jeśli wskazany. | Zgłoszenie w istniejącej sprawie bez dopłaty; pracownik widzi wezwanie, termin i dotychczasowy DOCX, może poprosić o dane i opublikować poprawioną wersję. Historia pozostaje dostępna. |

DOCX jest formatem wyniku usługi, niezależnie od proponowanej listy formatów załączników klienta. Dla dokumentów wynikowych proponujemy limit 20 MB na wersję, prywatne przechowywanie i kontrolę rzeczywistego formatu oraz zagrożeń przed publikacją. Odrzucamy pliki z makrami zamiast traktować je jako DOCX. E-mail informuje o dostępności nowej wersji i zawiera link do portalu, bez załączonego dokumentu. Błąd wysyłki nie wycofuje publikacji; obowiązują ponowienia z RQ-009.

### Wymagania po rundzie 4 — zakres, termin i załącznik graficzny

| ID / priorytet | Wymaganie | Kryterium odbioru |
|---|---|---|
| RQ-022 / M | Standard obejmuje jeden dom z garażem i zagospodarowaniem na jednej lub kilku działkach, za 500 PLN. Formularz pozwala opisać garaż oraz powiązać wszystkie działki z jedną inwestycją. | Dodanie kolejnej działki tej samej inwestycji nie tworzy nowej sprawy ani dopłaty. Więcej niż jeden dom wymaga ustalenia zakresu przed płatnością. |
| RQ-023 / M | Termin przygotowania wniosku i załącznika graficznego: 7 dni roboczych od zebrania kompletnych danych. Pracownik potwierdza datę kompletności, a portal pokazuje termin klientowi i pracownikowi. | Termin nie jest liczony od płatności ani rozpoczęcia szkicu. Zapisana podstawa daty, termin i data publikacji pozwalają wykryć przekroczenie. Zmiana statusu nie zeruje po cichu terminu. |
| RQ-024 / M | Pracownik przygotowuje załącznik graficzny w cenie jako osobny PDF na mapie dostarczonej przez klienta i publikuje go razem z DOCX jako komplet wynikowy. | Status „Wniosek gotowy” wymaga obu elementów. Klient pobiera je po zalogowaniu i dostaje jedno powiadomienie o komplecie. Każda publikacja wskazuje konkretne wersje DOCX i załącznika; przy poprawce niezmieniony element może być użyty ponownie. |

RQ-024 uzupełnia RQ-020: sam DOCX nie wystarcza do publikacji gotowego kompletu; wymagany jest osobny PDF załącznika graficznego. Mapę źródłową dostarcza klient, a jej zakup nie jest objęty ceną 500 PLN. Brak mapy nie blokuje przekazania sprawy do weryfikacji zgodnie z D-03, ale jest oznaczonym brakiem: termin przygotowania nie rozpoczyna się przed otrzymaniem mapy i pozostałych kompletnych danych. Pracownik sprawdza przydatność mapy i wskazuje ewentualne braki.

**Ustalony sposób liczenia terminów (D-18):** dzień zdarzenia jest dniem 0 i nie wlicza się do terminu. Liczenie rozpoczynamy od następnego dnia po zdarzeniu, uwzględniając wyłącznie poniedziałek–piątek z wyłączeniem świąt ustawowych w Polsce. Jeśli następny dzień nie jest roboczy, pomijamy go. Zasada obowiązuje dla pierwszej weryfikacji (2 dni), przygotowania (7 dni) i poprawek (3 dni). Datę zdarzenia ustalamy w strefie Europe/Warsaw. Kalendarz musi być aktualizowany i sprawdzony przed wdrożeniem. Data faktycznego zebrania danych i data potwierdzenia przez pracownika są zapisywane osobno, jeśli się różnią. Późniejsza zmiana terminu wymaga powodu i pozostaje w historii. Ten sam zatwierdzony sposób liczenia stosujemy do terminu poprawek: 3 dni robocze od otrzymania kompletu informacji do danego zgłoszenia. Zasady wstrzymania biegu przy ujawnieniu nowych braków pozostają otwarte; nie przyjmujemy automatycznego resetu ani nowego terminu 7 dni dla każdej poprawki.

### Wymagania po rundzie 5 — termin poprawek

| ID / priorytet | Wymaganie | Kryterium odbioru |
|---|---|---|
| RQ-025 / M | Poprawki po wezwaniu urzędu są wykonywane w ciągu 3 dni roboczych od otrzymania kompletu informacji do danego zgłoszenia. Portal zapisuje podstawę terminu i pokazuje go klientowi oraz pracownikowi. | Niepełne zgłoszenie zachowuje listę braków i nie uruchamia terminu. Po otrzymaniu kompletu informacji powstaje termin 3 dni roboczych, bez dopłaty. Zmiana statusu nie resetuje terminu; publikacja poprawionego kompletu zapisuje datę wykonania. |

Termin na odpowiedź wskazany w wezwaniu urzędu jest osobnym polem i nie zastępuje terminu usługi. Propozycja: portal wyróżnia sprawę, gdy zapisany termin urzędowy wypada wcześniej niż termin przygotowania poprawek, aby pracownik mógł od razu uzgodnić dalsze działania z klientem. Nie oznacza to automatycznej zmiany zobowiązania ani złożenia pisma przez portal.

### Wymagania po rundzie 6 — pierwsza weryfikacja

| ID / priorytet | Wymaganie | Kryterium odbioru |
|---|---|---|
| RQ-026 / M | Pierwsza weryfikacja następuje w ciągu 2 dni roboczych od opłacenia sprawy. Portal zapisuje datę opłacenia, wylicza termin i pokazuje go klientowi oraz pracownikowi. | Pracownik publikuje wynik: listę braków albo potwierdzenie kompletności. Samo przejście na „W weryfikacji” nie oznacza wykonania zobowiązania. Braki danych lub mapy nie wstrzymują pierwszej oceny. Termin i faktyczna data wyniku pozostają w historii. |

Termin pierwszej weryfikacji jest niezależny od terminu przygotowania. Brak kompletnych danych pozwala zakończyć pierwszą weryfikację listą braków, ale nie uruchamia terminu przygotowania dokumentów. Jeśli komplet danych był dostępny już wcześniej, późniejsza weryfikacja nie przesuwa automatycznie daty jego otrzymania.

Propozycja implementacyjna: datę opłacenia ustalamy na podstawie zweryfikowanej informacji operatora; osobno zapisujemy czas odebrania potwierdzenia. Opóźnienie powiadomienia nie może automatycznie wydłużyć klientowi terminu. Jeśli daty opłacenia nie da się ustalić z integracji, sprawa wymaga uzgodnienia w obsłudze płatności. Dla 2 dni stosujemy ten sam zatwierdzony sposób liczenia dni roboczych co dla terminów 7 i 3 dni (D-18).

### Obiekty biznesowe

| Obiekt | Dane i relacje |
|---|---|
| Konto | Tożsamości logowania, kontakt, role; wiele spraw. |
| Sprawa | Numer, właściciel, status, daty; wnioskodawcy, działki, opcjonalny prowadzący. |
| Odpowiedzi robocze | Dane edytowalne, stany niewiedzy i wersja do wykrywania konfliktów. |
| Przekazanie | Niezmienne odpowiedzi, wersja formularza, konkretne pliki, autor i data. |
| Załącznik | Prywatna lokalizacja, typ, rozmiar, suma kontrolna, kategoria i wynik kontroli. |
| Uzupełnienie | Pytanie, pole lub dokument, odpowiedź, rozstrzygnięcie i wersje. |
| Zamówienie | Sprawa, zakres i wersja oferty, cena, waluta, wersja materiałów przy zakupie. |
| Próba płatności | Zamówienie, unikalny identyfikator, kwota, waluta, status, identyfikator operatora. |
| Zdarzenie płatnicze | Identyfikacja, wynik przetworzenia i bezpieczne ponowienie. |
| Powiadomienie | Odbiorca, zdarzenie źródłowe, stan i liczba prób. |
| Historia | Sprawa, użytkownik lub system, zdarzenie, czas i uzasadnienie. |
| Dokument wynikowy | Sprawa, numer wersji DOCX, prywatny plik, autor, daty dodania i publikacji, opis zmian, oceniona wersja danych i opcjonalne zgłoszenie poprawek. |
| Zgłoszenie poprawek | Sprawa, treść i pliki wezwania, data zgłoszenia, termin podany przez klienta, wersja dokumentu wymagająca poprawki i wynik obsługi. |
| Komplet wynikowy | Numer publikacji, konkretna wersja DOCX i załącznika graficznego, autor i data publikacji; podstawa powiadomienia klienta. |
| Termin realizacji | Rodzaj: pierwsza weryfikacja (2 dni robocze), przygotowanie (7 dni roboczych) lub poprawki (3 dni robocze); sprawa i opcjonalnie zgłoszenie poprawek, data opłacenia lub otrzymania kompletu danych/informacji, potwierdzenie, wersja kalendarza, termin, zmiany z uzasadnieniem oraz data publikacji wyniku weryfikacji lub kompletu dokumentów. |

Reguły integracji:

- **P24:** rejestracja, przekierowanie i weryfikacja potwierdzenia na serwerze, w tym zamówienia, kwoty i waluty. Szczegóły według dokumentacji aktualnej przy implementacji.
- **Spójność:** awaria pomiędzy zapisem wpłaty i przekazaniem sprawy naprawiana ponownym przetworzeniem bez kolejnej realizacji.
- **Google/Facebook:** konfiguracje testowe i produkcyjne, kontrolowane adresy powrotu, procedura utraty dostępu.
- **E-mail:** trwały zapis planowanej wiadomości, ponowienia i widok błędów; technologia wykonywania zadań jest decyzją implementacyjną.
- **Publikacja:** portal i endpoint operatora przez HTTPS. Panel pracownika przez VPN zgodnie z architekturą; ochrona panelu nie może blokować zdarzeń operatora.

## 10. Wymagania niefunkcjonalne

Wartości liczbowe, poza ustaloną skalą, są propozycjami do potwierdzenia.

| ID | Obszar | Wymaganie i weryfikacja |
|---|---|---|
| NFR-001 | Poufność — M | Autoryzacja danych, plików i eksportów. Test klienta A próbującego odczytać lub zmienić sprawę B. |
| NFR-002 | Bezpieczeństwo — M | HTTPS, bezpieczne sesje, ochrona żądań zmieniających dane, ograniczenie nadużyć, sekrety poza kodem i logami. VPN panelu, proponowane MFA personelu. Kontrola przed publikacją. |
| NFR-003 | Pliki — M | Prywatny magazyn, limity, kontrola typu i zagrożeń; niedostępność kontroli pozostawia plik w kwarantannie. Test niedozwolonych plików i limitów. |
| NFR-004 | Prywatność — M | Dane potrzebne do usługi, zatwierdzona retencja i procedura żądań dotyczących danych. Przed produkcją określić administratora danych, treści informacji i usuwanie. |
| NFR-005 | Integralność — M | Niezmienne przekazania, konflikty zapisów i jedna realizacja zamówienia. Test dwóch kart i powtórzonych zdarzeń. |
| NFR-006 | Użyteczność — M | Polski język, proste pytania, stan zapisu. Telefon 360 px bez poziomego przewijania formularza; klawiatura, etykiety, fokus i błędy niewskazywane tylko kolorem. Przejście całego procesu. |
| NFR-007 | Wydajność — M | 10 nowych spraw/dzień; test 20 aktywnych sesji i 4000 spraw. Propozycja: 95% zwykłych odczytów i zapisów do 2 s po stronie aplikacji, bez plików i czasu usług zewnętrznych. |
| NFR-008 | Dostępność — M | Cel 99% miesięcznie poza ogłoszonymi pracami, pomiar z zewnątrz. Wymaga potwierdzenia utrzymania; wspólny host, łącze i zasilanie są punktami awarii. |
| NFR-009 | Odtwarzanie — M | Codzienna szyfrowana kopia poza Dellem: baza, pliki i konfiguracja. Cel RPO 24 h, RTO 8 h. Test przed produkcją i co kwartał. |
| NFR-010 | Monitoring — M | Alerty niedostępności, błędów kopii i poczty, niewyjaśnionych wpłat, braku miejsca na VM i hoście; progi 75% i 85%, wskazany odbiorca. |
| NFR-011 | Pojemność — M | Pomiar przyrostu i plan rozbudowy. 10 spraw/dzień po 30 MB to ok. 109,5 GB plików/rok. Początkowe 40 GiB VM nie wystarczy na taki rok. |
| NFR-012 | Utrzymanie — M | Środowisko testowe, fikcyjne dane, plan aktualizacji i wycofania wdrożenia. Migracje zachowują przekazania i powiązania wpłat. |
| NFR-013 | Diagnostyka — M | Identyfikator błędu dla obsługi; logi bez pełnych formularzy, dokumentów, tokenów i sekretów; ustalona retencja. |

RPO oznacza zakładany maksymalny okres utraty danych, RTO — czas odtworzenia. Po odtworzeniu kopii uzgadniamy z operatorem wpłaty z okresu po jej wykonaniu; brak lokalnego potwierdzenia nie uzasadnia ponownego obciążenia klienta.

## 11. Scenariusze odbioru

| ID | Scenariusz | Oczekiwany wynik |
|---|---|---|
| AC-01 | Zapis dwóch kroków, wylogowanie i powrót. | Dane zachowane i właściwy właściciel. |
| AC-02 | Nieznana wysokość domu i brak mapy, spełnione minimum, opłacenie. | Sprawa do oceny z widocznymi brakami, bez deklaracji kompletności. |
| AC-03 | Przerwana płatność albo awaria operatora. | Materiały zachowane, bezpieczne sprawdzenie lub ponowienie. |
| AC-04 | Powrót klienta przed potwierdzeniem serwerowym. | Oczekiwanie; kolejka dopiero po weryfikacji. |
| AC-05 | Duplikat lub opóźnienie powiadomienia, awaria pomiędzy zapisami. | Jedna realizacja, uzgodniony stan sprawy i wpłaty. |
| AC-06 | Manipulacja kwotą, identyfikatorem albo adresem pliku. | Odrzucenie, brak dostępu do cudzych danych. |
| AC-07 | Dwa braki, poprawka danych, zastąpienie pliku. | Nowa wersja bez kolejnej opłaty za uzupełnienia; poprzednia i jej plik w historii. |
| AC-08 | Równoczesna zmiana przez dwóch pracowników. | Wykryty konflikt, brak cichego nadpisania. |
| AC-09 | Nadanie kompletności. | Braki rozstrzygnięte, autor, czas i wersja zapisane. |
| AC-10 | Awaria poczty. | Stan sprawy i wpłaty poprawny, ponowienie i widoczny błąd. |
| AC-11 | Niedozwolony lub zbyt duży plik. | Odrzucenie lub kwarantanna, formularz zachowany. |
| AC-12 | Odtworzenie kopii w odseparowanym środowisku. | Sprawa, wersje, wpłaty i pliki dostępne; zmierzony czas i uzgodnione nowsze wpłaty. |
| AC-13 | Cały proces na telefonie i klawiaturą. | Działania możliwe bez blokady interfejsu. |
| AC-14 | Dwie różne próby faktycznie opłacone. | Jedna realizacja, dwie zachowane wpłaty i nadpłata do obsługi. |
| AC-15 | Pracownik publikuje pierwszą wersję kompletu DOCX i załącznika graficznego. | Status „Wniosek gotowy”, prywatne pobranie, e-mail zaplanowany; nieopublikowany plik i cudzy dokument niedostępne klientowi. |
| AC-16 | Klient zgłasza wezwanie urzędu; pracownik publikuje poprawiony DOCX. | Bez kolejnej płatności, nowa wersja i e-mail; stare pliki, wezwanie i historia zachowane. |
| AC-17 | Zakup standardowej sprawy i późniejsze uzupełnienia. | Oferta, podsumowanie, zamówienie i P24 zgodne: końcowe 500 PLN / 50 000 groszy, bez doliczenia podatku lub opłaty płatniczej. Uzupełnienia i poprawki po wezwaniu urzędu nie tworzą nowej opłaty. |
| AC-18 | Standardowy dom z garażem i zagospodarowaniem obejmuje kilka działek. | Jedna sprawa, wszystkie działki zapisane, cena nadal 500 PLN. |
| AC-19 | Potwierdzenie kompletnych danych, weekend i dzień wolny w okresie przygotowania. | Termin 7 dni roboczych wyliczony według zatwierdzonego kalendarza; widoczny klientowi i obsłudze, bez cichego resetu statusami. |
| AC-20 | Pracownik próbuje opublikować sam DOCX, potem dodaje załącznik graficzny. | Sam DOCX nie daje statusu gotowości. Publikacja obu elementów udostępnia kompletny wynik i planuje powiadomienie bez dopłaty za grafikę. |
| AC-21 | Klient przekazuje sprawę bez mapy, następnie dostarcza mapę i pozostałe dane. | Początkowo sprawa może trafić do oceny, ale nie jest kompletna. Termin 7 dni roboczych rozpoczyna się od kompletu danych; zakup mapy nie jest pozycją opłaconą w ramach 500 PLN. |
| AC-22 | Zgłoszenie poprawek jest niepełne, a następnie klient dostarcza komplet informacji. | Termin 3 dni roboczych liczony od otrzymania kompletu, według zatwierdzonego kalendarza; widoczny obu stronom, bez dopłaty i resetu zmianą statusu. Zachowany osobno termin z wezwania urzędu. |
| AC-23 | Opłacona sprawa zawiera braki lub nie ma mapy; potwierdzenie płatności może przyjść z opóźnieniem. | Termin pierwszej oceny wynosi 2 dni robocze od zweryfikowanej daty opłacenia. Wynik to opublikowana lista braków albo kompletność, nie samo rozpoczęcie pracy. Braki nie zawieszają pierwszej oceny, a opóźnione powiadomienie nie resetuje terminu. |
| AC-24 | Obliczanie terminów 2, 7 i 3 dni roboczych dla zdarzenia w dzień roboczy, weekend i święto. | Dzień zdarzenia pominięty; od następnego dnia liczone wyłącznie dni poniedziałek–piątek niebędące świętami ustawowymi w Polsce. Przykład bez świąt: zdarzenie w piątek daje termin 2 dni we wtorek, 3 dni w środę, 7 dni we wtorek kolejnego tygodnia. Święto w dzień roboczy przesuwa wynik do kolejnego kwalifikującego się dnia; święto w weekend nie jest odejmowane drugi raz. |

## 12. Brainstorm — decyzje, pytania i propozycje

### Runda 7 — decyzja użytkownika z 14 listopada 2026 r.

| ID | Decyzja | Wpływ |
|---|---|---|
| D-18 | Dni robocze liczymy od następnego dnia po zdarzeniu, od poniedziałku do piątku, z wyłączeniem świąt ustawowych w Polsce. | Jedna zatwierdzona zasada dla terminów 2, 7 i 3 dni; dzień zdarzenia nie jest wliczany, AC-24. |

Odpowiedź rundy 7 zamyka decyzję dotyczącą sposobu liczenia dni roboczych. Aktualność listy świąt wymaga weryfikacji przy wdrożeniu i utrzymaniu kalendarza.

### Runda 6 — decyzje użytkownika z 14 listopada 2026 r.

| ID | Decyzja | Wpływ |
|---|---|---|
| D-16 | 500 PLN to końcowa kwota do zapłaty przez klienta za usługę. | Oferta, podsumowanie i płatność zawsze wskazują 500 PLN; rozliczenie podatku nie zwiększa tej kwoty. Zakup mapy pozostaje poza usługą zgodnie z D-14. |
| D-17 | Pierwsza weryfikacja w ciągu 2 dni roboczych od opłacenia sprawy. | Termin i publikacja wyniku pierwszej oceny, RQ-026; zamknięcie B-05 w zakresie długości terminów. |

Odpowiedzi rundy 6 są źródłem doprecyzowania ceny końcowej i terminu pierwszej weryfikacji.

### Runda 5 — decyzje użytkownika z 14 listopada 2026 r.

| ID | Decyzja | Wpływ |
|---|---|---|
| D-13 | Załącznik graficzny jako osobny PDF. | Komplet wynikowy: wniosek DOCX i załącznik PDF. |
| D-14 | Mapę dostarcza klient, jej zakup jest poza ceną usługi. | Mapa stanowi materiał wejściowy; 500 PLN obejmuje przygotowanie załącznika, nie zakup mapy. |
| D-15 | Poprawki po wezwaniu urzędu w ciągu 3 dni roboczych od otrzymania kompletu informacji. | Osobny termin każdego zgłoszenia poprawek, RQ-025. |

Odpowiedzi rundy 5 są źródłem aktualizacji formatu wyniku, zakresu ceny i terminu poprawek. Sposób liczenia dni roboczych zatwierdzono następnie w D-18 i opisano przy RQ-023.

### Runda 4 — decyzje użytkownika z 14 listopada 2026 r.

| ID | Decyzja | Wpływ |
|---|---|---|
| D-10 | Standard: jeden dom z garażem i zagospodarowaniem, również na kilku działkach. | Jeden zakres zamówienia za 500 PLN, RQ-022. |
| D-11 | Przygotowanie w 7 dni roboczych od zebrania kompletnych danych. | Data kompletności i widoczny termin przygotowania, RQ-023. |
| D-12 | Załącznik graficzny jest w cenie. | Publikacja kompletu DOCX + załącznik graficzny, RQ-024. |

Odpowiedzi rundy 4 są źródłem powyższych ustaleń. Format załącznika, dostarczenie mapy i termin poprawek doprecyzowano w rundzie 5 (D-13–D-15).

### Runda 3 — decyzje użytkownika z 14 listopada 2026 r.

| ID | Decyzja | Wpływ |
|---|---|---|
| D-07 | Gotowy wniosek w DOCX i powiadomienie e-mail. | Prywatna publikacja dokumentu w portalu, status „Wniosek gotowy”, RQ-020. |
| D-08 | Cena obejmuje także poprawki po wezwaniu urzędu. | Ponowne otwarcie tej samej sprawy bez dopłaty, wersjonowanie wyników, RQ-021. |
| D-09 | Cena standardowej sprawy: 500 PLN. | Oferta i zamówienie: 500 PLN; serwer płatności zapisuje 50 000 groszy, PLN. |

Odpowiedzi rundy 3 są źródłem aktualizacji zakresu procesu i wymagań. Pracownik nadal przygotowuje dokument poza aplikacją; automatyczne generowanie DOCX nie zostało zamówione.

### 12.1 Runda 1 — decyzje użytkownika z 14 listopada 2026 r.

| ID | Pytanie | Odpowiedź | Wpływ |
|---|---|---|---|
| D-01 | Jakie inwestycje na start? | Domy jednorodzinne. | Jeden podstawowy scenariusz formularza. |
| D-02 | Jak wyceniać? | Jedna cena standardowej sprawy. | Kwota doprecyzowana w D-09, standard w D-10. |
| D-03 | Jak obsługiwać braki? | Można przekazać sprawę z oznaczonymi brakami. | Braki merytoryczne nie blokują automatycznie płatności i oceny. |

### 12.2 Runda 2 — decyzje i pozostałe pytania

Decyzje użytkownika z 14 listopada 2026 r.:

| ID | Decyzja | Wpływ |
|---|---|---|
| D-04 | Cena obejmuje wyłącznie przygotowanie wniosku. | Złożenie do urzędu poza usługą; sposób dostarczenia ustalony w D-07. |
| D-05 | Uzupełnienia są w cenie. | Ponowne przekazanie uzupełnień bez kolejnej płatności. |
| D-06 | Obsługa całej Polski. | Brak ograniczenia do wybranych gmin lub województw. |

Pozostałe pytania i propozycje (nie są jeszcze decyzjami):

| ID | Pytanie | Propozycja wyjściowa | Wpływ |
|---|---|---|---|
| B-01 — zamknięte | Co obejmuje standard? | Jeden dom z garażem i zagospodarowaniem, na jednej lub kilku działkach (D-10); cała Polska (D-06). | Wiele działek nie powoduje dopłaty; formularz obejmuje garaż i zagospodarowanie. |
| B-02 — zamknięte | Jaka jest cena standardowej sprawy? | 500 PLN (D-09), z uzupełnieniami i poprawkami po wezwaniu urzędu. | Oferta i płatność: 50 000 groszy, PLN. |
| B-03 | Co jest absolutnym minimum do podjęcia pracy? | Kontakt, opis zamiaru i lokalizacja umożliwiająca rozpoczęcie identyfikacji; pozostałe braki oznaczone. | Blokady przekazania i ilość wyjaśnień. |
| B-04 | Kiedy zmiana inwestycji stanowi nową usługę? | Uzupełnienia i poprawki po wezwaniu urzędu są w cenie (D-05, D-08). Do ustalenia granica między poprawką a nową inwestycją. | Samo wezwanie urzędu nie uruchamia dopłaty. |
| B-05 — zamknięte | Jaki termin przygotowania i obsługi? | Pierwsza weryfikacja: 2 dni robocze od opłacenia (D-17). Przygotowanie: 7 dni roboczych od kompletnych danych (D-11). Poprawki: 3 dni robocze od kompletu informacji (D-15). | Terminy usługi są odrębne od terminów urzędu; sposób liczenia zatwierdzony w D-18. |
| B-06 | Jak obsłużyć rezygnację, sprawę poza zakresem i zwrot? | Ręczna decyzja uprawnionej osoby z uzasadnieniem i osobnym stanem rozliczenia. | Domknięcie procesu; wymagane przed płatną produkcją. |
| B-07 | Osoba prywatna czy firma jako nabywca? Gdzie wystawiamy dokument sprzedaży? | Rozliczenia poza portalem na start, powiązane z zamówieniem. | Dane nabywcy i księgowość. |
| B-08 | Jakie podmioty są wnioskodawcami i kto może działać za inną osobę? | Konto oddzielone od wnioskodawców; doprecyzować reprezentację i firmy. | Pola i dokumenty. |

### 12.3 Runda 3 — wygoda i utrzymanie

| ID | Pytanie | Propozycja wyjściowa | Wpływ |
|---|---|---|---|
| B-09 | Czat czy lista uwag? | Pytania i odpowiedzi przy brakach, bez czatu na żywo. | Komunikacja i historia. |
| B-10 | Czy wystarczą Google i Facebook? | Zachować ustalone metody; e-mail z jednorazowym linkiem rozważyć później. | Dostępność i odzyskiwanie konta. |
| B-11 | Jak długo przechowujemy szkice, sprawy, pliki, historię i kopie? | Osobne okresy zatwierdzone przed produkcją, bez arbitralnego wspólnego terminu. | Retencja i magazyn. |
| B-12 | Ilu pracowników i kto widzi wszystkie sprawy? | Wspólna kolejka małego zespołu, osobne konta i historia. | Uprawnienia i prowadzący. |
| B-13 | Jaka domena, publikacja, poczta, kopie? Kto reaguje na alarmy? | Osobna VM, publiczny HTTPS, panel przez VPN i wskazany opiekun. | Integracje i dostępność. |
| B-14 | Czy potrzebne są pobierane PDF i paczki ZIP? | Najpierw podsumowanie i wydruk; eksport po potwierdzeniu potrzeby. | RQ-016 i bezpieczeństwo plików. |

### 12.3a Dostarczenie wyniku usługi — ustalone

| ID | Pytanie | Propozycja wyjściowa | Wpływ |
|---|---|---|---|
| B-15 — zamknięte | Jak klient otrzymuje przygotowany wniosek? | DOCX w prywatnej sprawie i powiadomienie e-mail (D-07). | RQ-020, status „Wniosek gotowy”, AC-15–AC-16. |

### Pozostałe szczegóły załącznika graficznego

| ID | Pytanie | Propozycja | Wpływ |
|---|---|---|---|
| B-16 — zamknięte | W jakim formacie klient otrzymuje załącznik graficzny? | Osobny PDF, obok wniosku DOCX (D-13). | Publikacja wymaga obu plików. |
| B-17 — zamknięte | Kto dostarcza mapę i czy jej zakup jest w cenie? | Mapę dostarcza klient; zakup poza ceną usługi (D-14). | Brak mapy jest brakiem materiałów; 500 PLN obejmuje opracowanie załącznika, nie zakup mapy. |

### 12.4 Pomysły do backlogu

| Pomysł | Korzyść | Proponowany moment |
|---|---|---|
| Przykłady odpowiedzi i ilustracje parametrów domu | Mniej błędów i niezrozumiałych pojęć. | MVP w trudnych pytaniach. |
| „Nie wiem — pomóż mi ustalić” | Zebranie problemu zamiast przypadkowej liczby. | MVP, zgodnie z D-03. |
| Podświetlenie zmian między wersjami | Szybsza ponowna ocena. | Po pilotażu; w MVP odczyt wersji. |
| Przypomnienie po 7 dniach bez odpowiedzi | Mniej porzuconych uzupełnień. | Po ustaleniu zasad i częstotliwości. |
| Podpowiadanie działek na mapie | Mniej pomyłek lokalizacji. | Później, po ocenie źródła danych. |
| OCR dokumentów | Mniej przepisywania. | Później, z zatwierdzeniem człowieka. |
| Projekt wniosku urzędowego | Krótsza praca pracownika. | Osobny etap z kontrolą wzoru i testami. |
| Współdzielenie z małżonkiem lub pełnomocnikiem | Wspólne uzupełnianie. | Później, z odwoływalnymi uprawnieniami. |

Po każdej rundzie odpowiedzi trafiają do rejestru decyzji i aktualizują wymagania oraz odbiór. Propozycja nie staje się ustaleniem bez odpowiedzi właściciela produktu.

## 13. Kolejność realizacji i warunki uruchomienia

1. **Domknięcie produktu:** pozostałe kwestie B-03–B-04 i B-06–B-08; katalog pytań i przykład standardowej sprawy zatwierdzone przez osobę przygotowującą wnioski.
2. **Prototyp:** logowanie, sprawa, formularz, zapis, prywatne pliki i podsumowanie; fikcyjna sprawa z brakami.
3. **Praca biura:** wersje, kolejka, uzupełnienia, kompletność, publikacja DOCX, poprawki po wezwaniu urzędu i historia.
4. **Płatności i e-maile:** środowisko testowe, duplikaty, opóźnienia, awarie i rozliczenie wyjątków.
5. **Produkcja:** domena, HTTPS, VPN, aktywacja metod, zatwierdzone zasady sprzedaży i danych, kopia i odtworzenie, pojemność, monitoring i odpowiedzialna osoba.
6. **Pilotaż:** 5–10 spraw; korekta pytań i zakresu na podstawie rzeczywistych trudności.

Warunki płatnego uruchomienia: uzgodniona cena i zakres, procedura rezygnacji i rozliczeń, zatwierdzony formularz i treści informacyjne, sprawdzone uprawnienia oraz scenariusze AC-01–AC-24, potwierdzone działanie operatora i poczty, test odtworzenia. Oznaczenie wymagania jako M nie oznacza wdrożenia.
