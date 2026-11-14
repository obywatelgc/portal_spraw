# Portal spraw — specyfikacja wymagań

Wersja 1.8 — 14 listopada 2026 r. Portal spraw po dziewiątej rundzie brainstormingu.

## 1. Cel i status dokumentu

Portal umożliwia klientowi złożenie **sprawy uniwersalnej**: podanie nazwy, opisu i załączników, wniesienie jednej opłaty oraz obsługę uzupełnień. Operator zwraca sprawę do uzupełnienia, akceptuje ją albo kończy bez akceptacji z uzasadnieniem. **Akceptacja, zakończenie bez akceptacji i wycofanie są stanami końcowymi.** Administrator może wyjątkowo ponownie otworzyć sprawę z uzasadnieniem.

Podstawą jest bieżąca instrukcja użytkownika i odpowiedzi w brainstormingu. Starsze ustalenia zachowujemy tylko w zakresie zgodnym z nowym procesem, zgodnie z analizą w sekcji 2. Dokument opisuje docelowe zachowanie; nie potwierdza wdrożenia funkcji.

- **Ustalone:** decyzja użytkownika z bieżącej rozmowy lub wyraźnie wskazane zachowane ustalenie.
- **Propozycja:** szczegół projektu wymagający omówienia. Niezatwierdzone liczby i warianty nie stają się automatycznie zobowiązaniem wobec klienta.
- **M:** niezbędne w proponowanej pierwszej wersji (MVP). **S:** pożądane. **L:** późniejszy etap. Priorytet nie zastępuje decyzji biznesowej.

Poprzednia specyfikacja i rejestr decyzji zostały zachowane w [archiwum WZ v0.8](wymagania.WZ-v0.8-2026-11-14.md). [ARCHITEKTURA.md](ARCHITEKTURA.md) opisuje wcześniejsze wdrożenie techniczne; jego proces biznesowy jest nieaktualny. W razie rozbieżności zakres produktu określa niniejszy dokument. Ta aktualizacja nie zmienia konfiguracji serwera ani istniejących danych.

Nowa numeracja `SU-*`, `NF-*`, `AT-*`, `DEC-*` i `Q-*` zastępuje stare identyfikatory wymagań w aktywnej specyfikacji. Stare identyfikatory pozostają wyłącznie w archiwum.

## 2. Analiza zmiany zakresu

### 2.1 Co zmieniamy i dlaczego

| Obszar | Rozstrzygnięcie | Konsekwencja |
|---|---|---|
| Przedmiot usługi | Sprawa uniwersalna zastępuje wniosek o warunki zabudowy. | Usuwamy specjalistyczne pojęcia z aktywnych ekranów, komunikatów i modelu sprawy. |
| Formularz | Nazwa, opis, co najmniej jeden załącznik. | Jeden prosty ekran zamiast formularza inwestycji; nie dodajemy pól branżowych ani kreatora własnych formularzy. |
| Wynik procesu | Akceptacja albo zakończenie bez akceptacji z uzasadnieniem. | Oba wyniki kończą sprawę; rozliczenie zakończenia bez akceptacji pozostaje do ustalenia. |
| Poprawki | Zwrot do klienta i ponowne przekazanie w tej samej sprawie. | Każde przekazanie jest wersjonowane; opłata nie jest pobierana ponownie. |
| Cena | Jedna opłata; **kwota zostanie ustalona później**. | Poprzednie 500 PLN nie obowiązuje. Brak ceny nie oznacza ceny zerowej. |
| Moment płatności | Zachowujemy wcześniejsze ustalenie: przed pierwszą weryfikacją. | Opłacenie odblokowuje kolejkę operatora; nie jest automatyczną akceptacją. |
| Czas obsługi | Brak limitu dni na obsługę, zarówno pierwszą, jak i kolejne oceny. | Wycofujemy wcześniejsze 2 dni i liczenie dni roboczych. Pozostają daty zdarzeń i sortowanie kolejki. |
| Dawne etapy i terminy | Wycofujemy przygotowanie dokumentów w 7 dni i poprawki urzędowe w 3 dni. | Nie przenosimy tych terminów na nowy proces przez zmianę nazwy. |
| Technologia i integracje | Zachowujemy Django, PostgreSQL, osobną VM, Google/Facebook, P24 i e-mail. | Zmiana domeny biznesowej nie wymaga sama w sobie nowej architektury technicznej. |
| Bezpieczeństwo | Zachowujemy prywatne pliki, kontrolę dostępu, historię, kopie i odporność płatności na duplikaty. | Uproszczenie formularza nie osłabia ochrony materiałów klientów. |

Wycofane z aktywnego zakresu: działki, wnioskodawcy urzędowi, dom i garaż, droga, media, mapa źródłowa, załącznik graficzny, gotowy DOCX/PDF, wezwania urzędu, statusy „Dane kompletne”, „W przygotowaniu”, „Wniosek gotowy” i „Poprawki zgłoszone”. PDF i DOCX są dopuszczonymi załącznikami wejściowymi, obok JPG/JPEG i PNG.

### 2.2 Najważniejsze wnioski projektowe

1. **Sprawa jest głównym obiektem**, a nie plik urzędowy. Jej nazwa nie musi być unikalna; identyfikuje ją numer nadany przez system.
2. **Zapis szkicu nie jest złożeniem.** Szkic może być niekompletny. Pierwsze przekazanie wymaga nazwy, opisu i minimum jednego poprawnego załącznika.
3. **Jedna opłata nie oznacza jednej próby płatności.** Sprawa ma jedno zamówienie, ale może mieć kilka prób w przypadku niepowodzeń.
4. **Zwrot do uzupełnienia nie jest odrzuceniem ani zwrotem pieniędzy.** W interfejsie używamy pełnej nazwy akcji, aby uniknąć nieporozumień.
5. **Operator ocenia konkretną, niezmienną wersję.** Nowe uzupełnienie nie nadpisuje materiałów, na których oparto wcześniejszą decyzję.
6. **Decyzja kończy zwykłą obsługę.** Wyjątek: administrator może ponownie otworzyć sprawę z uzasadnieniem, zachowaniem wcześniejszej decyzji, powiadomieniem klienta i bez ponownej opłaty.
7. **Uniwersalność nie określa kryteriów merytorycznych.** Przed sprzedażą trzeba opisać, jakie zgłoszenia są obsługiwane i według jakich kryteriów potwierdzana jest ich poprawność i kompletność.
8. Największe otwarte kwestie to kwota, rozliczenia, sprawy poza zakresem oraz zasady kopii i retencja dokumentów rozliczeniowych.

## 3. Zakres MVP i słownik

### 3.1 Ustalone podstawy

- Nazwa portalu: **Portal spraw**. Nazwa procesu/rodzaju zgłoszenia: **Sprawa uniwersalna**. Domena zostanie ustalona później. Klient tworzy i składa sprawę.
- Dane formularza: **nazwa wniosku, opis, załączniki**; co najmniej jeden załącznik obowiązkowy.
- Operator może **zwrócić do uzupełnienia**, **zaakceptować** albo **zakończyć bez akceptacji z uzasadnieniem**.
- Akceptacja kończy sprawę, blokuje dalszą edycję i powoduje powiadomienie e-mail.
- Operator może zakończyć sprawę bez akceptacji z uzasadnieniem; również ten stan kończy edycję. Zasady rozliczenia zostaną ustalone później.
- Brak limitu dni na obsługę. Dopuszczone pliki: PDF, JPG/JPEG, PNG i DOCX, do 20 MB na plik.
- Jedna opłata za sprawę, bez dopłat za kolejne uzupełnienia; kwota otwarta.
- Konto może mieć wiele spraw. Zachowane: logowanie Google/Facebook, kontakt e-mail i płatność P24 przed weryfikacją.
- Akceptacja potwierdza poprawność i kompletność sprawy. Uzupełnienie może zawierać opcjonalny komentarz klienta do danej rundy.
- Operatorzy pracują we wspólnej kolejce z prowadzącym; klient może zgłosić prośbę o wycofanie. Ustalone limity każdego przekazania: 20 plików i 100 MB łącznie, przy 20 MB na plik.
- Zachowana skala planowania: do 10 nowych spraw dziennie. Język polski, strefa Europe/Warsaw.

### 3.2 Zakres pierwszej wersji

Logowanie, zapis szkicu, formularz, prywatne pliki, podsumowanie, jedna opłata, lista i szczegóły spraw, kolejka operatora, zwrot z uzasadnieniem, ponowne przekazanie, akceptacja lub zakończenie bez akceptacji, historia, e-maile, podstawowe monitorowanie i administracja uprawnieniami.

Poza MVP: własne typy formularzy, pola dynamiczne konfigurowane przez klienta, generowanie dokumentów, podpis elektroniczny, współdzielenie sprawy między klientami, automatyczne decyzje AI, czat na żywo, integracje branżowe oraz dalszy proces realizacji po akceptacji. Zakończenie bez akceptacji jest jawną akcją operatora z uzasadnieniem. Zgłoszenie prośby o wycofanie przez klienta należy do MVP. Zatwierdzenie prośby daje status „Wycofana”. Ponowne otwarcie zastrzeżone jest dla administratora z uzasadnieniem. Wycofanie zatwierdzamy bez możliwości odmowy; rozliczenia pozostają otwarte w Q-05. Logowanie jednorazowym linkiem e-mail jest poza obecnym zakresem.

### 3.3 Słownik i nazwy interfejsu

| Pojęcie | Znaczenie |
|---|---|
| Sprawa uniwersalna | Zgłoszenie klienta zawierające nazwę, opis i pliki. |
| Nazwa wniosku | Edytowalny tytuł sprawy wpisany przez klienta. |
| Numer sprawy | Unikalny, niezmienny identyfikator nadawany przez system. |
| Operator | Osoba oceniająca sprawę, dawniej nazywana pracownikiem. |
| Szkic | Dane robocze przed pierwszym przekazaniem. |
| Wersja przekazana | Utrwalona nazwa, opis i konkretne pliki przekazane do oceny. |
| Runda uzupełnień | Opublikowane uwagi operatora i powiązane ponowne przekazanie klienta. |
| Akceptacja | Potwierdzenie poprawności i kompletności konkretnej wersji sprawy po zapoznaniu się z treścią i załącznikami; kończy obsługę, z datą i autorem. |
| Zakończenie bez akceptacji | Końcowa decyzja operatora z publicznym uzasadnieniem; nie jest zwrotem do uzupełnienia ani operacją finansową. |
| Zamówienie / próba płatności | Jedna należność za sprawę / pojedyncza próba jej opłacenia. |

Proponowane etykiety: „Moje sprawy”, „Nowa sprawa”, „Nazwa wniosku”, „Opis”, „Załączniki”, „Zapłać i złóż sprawę”, „Przekaż uzupełnienia”, „Zwróć do uzupełnienia”, „Zaakceptuj sprawę”.

## 4. Role i uprawnienia

Operatorzy i administrator korzystają z indywidualnych kont personelu z loginem i hasłem, zakładanych przez administratora. Samodzielna rejestracja nie nadaje uprawnień personelu. Hasła są przechowywane w postaci bezpiecznych skrótów; obowiązują ograniczenie prób logowania i możliwość odebrania dostępu. Administrator uruchamia reset hasła operatora: jednorazowy link do ustawienia nowego hasła jest wysyłany na adres przypisany do konta operatora. Odzyskanie konta administratora jest procedurą techniczną opiekuna. Reset nie dodaje logowania klienta linkiem e-mail.

| Rola | Dozwolone działania |
|---|---|
| Gość | Informacje o usłudze, cenie i logowanie. |
| Klient | Własne szkice, składanie i opłacanie spraw, uzupełnienia, historia i własne pliki. |
| Operator | Wspólna kolejka opłaconych spraw z przypisanym prowadzącym; odczyt wersji, notatki wewnętrzne, publikacja uwag, akceptacja i zakończenie bez akceptacji z uzasadnieniem. |
| Administrator | Konta personelu, uprawnienia, ustawienia ceny i plików, diagnostyka; bez dowolnego nadpisywania decyzji i wpłat. |
| Operator płatności | Wyłącznie integracja finansowa; bez treści spraw i dokumentów. |

Autoryzacja obowiązuje na serwerze dla odczytu, zapisu, pobrania pliku i każdej akcji. Operator nie edytuje w imieniu klienta nazwy, opisu ani plików. Klient nie ustawia statusu ani ceny. Notatki wewnętrzne nie trafiają do klienta i e-maili. Ustalone: nieprzekazane szkice są widoczne wyłącznie właścicielowi; operator nie ma dostępu także przez bezpośredni adres lub pobranie pliku. Do kolejki trafiają dopiero opłacone sprawy. Administrator zachowuje dostęp techniczny do diagnostyki, nie używa go do zwykłej obsługi szkiców.

**Prowadzenie sprawy:** wszyscy operatorzy widzą wspólną kolejkę i każdy może obsługiwać każdą sprawę, niezależnie od przypisania. Prowadzący służy organizacji pracy, nie jest blokadą uprawnień. „Podejmij sprawę” przypisuje jednego prowadzącego; administrator może go zmienić z historią. Inny operator może publikować uwagi, podejmować decyzje i rozpatrywać wycofanie bez przepisywania prowadzącego. Każda operacja zapisuje rzeczywistego autora i nie zmienia automatycznie przypisania. Powrót po uzupełnieniu zachowuje prowadzącego. Nadal obowiązują kontrola aktualnej wersji i ochrona przed równoczesnymi sprzecznymi decyzjami.

## 5. Formularz, pliki i walidacja

### 5.1 Pola klienta

| Pole | Reguła | Status szczegółu |
|---|---|---|
| Nazwa wniosku | Wymagana przy przekazaniu; tekst po usunięciu skrajnych spacji nie może być pusty. Limit 200 znaków. | Ustalone. |
| Opis | Wymagany; zwykły tekst, wielowierszowy, nie tylko białe znaki. Limit 10 000 znaków. | Ustalone. |
| Załączniki | Co najmniej jeden przy każdym przekazaniu; stary plik może pozostać w nowej wersji. | Obowiązkowość ustalona. |

Numer, właściciel, daty, status, wersja i płatność są metadanymi systemowymi, a nie dodatkowymi polami formularza. Adres kontaktowy pochodzi z konta; ewentualne dane rozliczeniowe zbierane są oddzielnie przy zakupie. Nie dokładamy kategorii, priorytetu ani dodatkowych ankiet do MVP.

### 5.2 Ustalone limity i proponowane zasady obsługi plików

- Ustalone formaty: **PDF, JPG/JPEG, PNG i DOCX**. Maksymalny rozmiar: **20 MB na plik**. DOCX podlega kontroli struktury i zagrożeń; pliki z makrami (np. DOCM) ani pliki z samą zmienioną nazwą rozszerzenia nie są dopuszczone.
- Ustalone limity: **20 MB na plik, maksymalnie 20 plików i 100 MB łącznie w każdym przekazaniu**. Pliki zachowane z poprzedniej wersji wliczamy do bieżącego przekazania. Dawne pliki niewchodzące do bieżącej wersji nie zajmują jej limitu. Ustalony limit fizycznego magazynu sprawy wraz z historią wynosi **500 MB**. Administrator może go zwiększyć z zapisem zmiany w historii; starszych wersji nie usuwamy w trakcie obsługi w celu zwolnienia limitu. Ponownie użyty ten sam plik nie zajmuje limitu fizycznego magazynu drugi raz.
- Plik ma losowy klucz w prywatnym magazynie, oryginalną nazwę do wyświetlenia, rozmiar, rzeczywisty typ, sumę kontrolną, autora, datę i wynik kontroli.
- Kontrola typu i zagrożeń przed udostępnieniem. Plik w trakcie kontroli, niedokończony albo odrzucony nie spełnia minimum jednego załącznika.
- Wszystkie pliki wybrane do przekazania muszą mieć zakończoną kontrolę. Klient może poczekać albo usunąć problematyczny plik z wersji; nie można uznać go za doręczony operatorowi przed kontrolą.
- Zastąpienie pliku tworzy nowy obiekt. Usunięcie z wersji roboczej nie usuwa go z historycznego przekazania. Brak publicznych adresów plików i wykonywania przesłanej treści.
- Osiągnięcie limitu historii nie usuwa starszych materiałów; klient widzi komunikat i kontakt do obsługi. Administrator może zwiększyć limit z zapisem w historii.

### 5.3 Zapis i błędy

Ustalone limity tekstu: nazwa 200 znaków, opis 10 000 znaków, komentarz klienta do uzupełnienia i każde uzasadnienie operatora 5 000 znaków. Teksty zwykłe z obsługą akapitów; licznik pokazuje wykorzystany limit. Serwer odrzuca przekroczenie zamiast cicho obcinać treść. Limit 5 000 dotyczy także uzasadnienia zwrotu do uzupełnienia oraz zakończenia bez akceptacji; obowiązkowe uzasadnienia nadal nie mogą składać się wyłącznie z białych znaków.

Szkic można zapisać bez kompletu pól; błędy formatów i limitów są pokazywane przy polach. Zapis potwierdzony przez serwer ma widoczną datę. Nieudane wysłanie pliku nie oznacza utraty nazwy i opisu. Ustalone MVP: ręczny zapis przyciskiem „Zapisz szkic”, widoczna data ostatniego zapisu i ostrzeżenie przy opuszczaniu formularza z niezapisanymi zmianami. Autosave jest poza MVP i może zostać dodany później. Zasada obejmuje też zapis roboczych uzupełnień. Dwie karty przeglądarki nie nadpisują zmian bez wykrycia konfliktu wersji.

## 6. Proces i maszyna stanów

### 6.1 Ścieżka podstawowa

1. Klient loguje się, wybiera „Nowa sprawa” i zapisuje nazwę, opis oraz pliki.
2. Portal sprawdza wymagane pola, kontrolę plików i limity. Pokazuje podsumowanie i jedną cenę końcową.
3. „Zapłać i złóż sprawę” utrwala wersję 1, warunki zakupu i zamówienie. Następuje przekierowanie do Przelewy24.
4. Po zweryfikowaniu wpłaty serwer jednokrotnie kieruje sprawę do weryfikacji, nadaje datę złożenia i planuje potwierdzenie e-mail. Wcześniejsze przechowanie wersji nie jest potwierdzeniem skutecznego złożenia.
5. Operator rozpoczyna ocenę konkretnej wersji, następnie publikuje uwagi i zwraca sprawę, akceptuje ją albo kończy bez akceptacji z uzasadnieniem.
6. Po zwrocie klient edytuje kopię ostatniej przekazanej wersji. Widzi uwagi, poprawia nazwę, opis lub pliki i klika „Przekaż uzupełnienia”.
7. Powstaje kolejna niezmienna wersja; ta sama sprawa wraca do kolejki bez płatności. Cykl może się powtarzać.
8. Akceptacja zapisuje wersję, operatora i datę, zamyka edycję i planuje e-mail. Klient zachowuje podgląd oraz pobieranie plików w okresie retencji.
9. Alternatywnie operator kończy sprawę bez akceptacji, podając uzasadnienie. Klient widzi wynik i powód, otrzymuje e-mail, zachowuje odczyt historii i nie może już przekazać uzupełnień. Rozliczenie pozostaje odrębną kwestią.

### 6.2 Status sprawy

| Z | Do | Kto i pod jakim warunkiem |
|---|---|---|
| Szkic | Oczekuje na płatność | Klient; walidacja, gotowe pliki, ustalona cena, utrwalona wersja i zamówienie. |
| Oczekuje na płatność | Do weryfikacji | System; zweryfikowana wpłata zgodna z zamówieniem. |
| Do weryfikacji | W weryfikacji | Operator rozpoczyna ocenę bieżącej wersji. |
| W weryfikacji | Do uzupełnienia | Operator publikuje niepuste uzasadnienie z konkretnymi uwagami. |
| Do uzupełnienia | Do weryfikacji | Klient przekazuje poprawną nową wersję. |
| W weryfikacji | Zaakceptowana | Operator potwierdza akceptację bieżącej wersji; sprawa opłacona, uwagi rozstrzygnięte. |
| W weryfikacji | Zakończona bez akceptacji | Operator podaje niepuste uzasadnienie dla bieżącej wersji opłaconej sprawy. Wcześniejsze zwrócenie do uzupełnienia nie jest wymagane. |
| Do weryfikacji / W weryfikacji / Do uzupełnienia | Wycofana | Dowolny operator zatwierdza oczekującą prośbę klienta. |
| Zaakceptowana / Zakończona bez akceptacji / Wycofana | Do weryfikacji | Wyłącznie administrator z niepustym uzasadnieniem, jeśli dane jeszcze dostępne. |

Przy oczekującej prośbie o wycofanie blokujemy decyzje merytoryczne; zatwierdzenie wycofania jest dozwolone.

Każde inne przejście jest odrzucane, również przy bezpośrednim żądaniu do serwera. Zakończenie bez akceptacji i anulowanie nie są synonimami zwrotu do uzupełnienia. Z żadnego stanu końcowego nie ma zwykłego przejścia powrotnego dla klienta lub operatora. Administrator może wyjątkowo wznowić sprawę zgodnie z sekcją 6.6; wcześniejsza decyzja pozostaje w historii.

### 6.3 Dostępność edycji

| Status | Klient | Operator |
|---|---|---|
| Szkic | Edytuje własną wersję roboczą. | Bez dostępu w zwykłej kolejce. |
| Oczekuje na płatność | Odczyt, sprawdzenie lub ponowienie płatności. | Bez decyzji merytorycznej. |
| Do weryfikacji / W weryfikacji | Odczyt przekazanych danych, bez edycji. | Ocena i wewnętrzne notatki; decyzja tylko w „W weryfikacji”. |
| Do uzupełnienia | Edytuje kopię roboczą, zachowując stare przekazanie. | Odczyt ostatniej przekazanej wersji; niewysłane poprawki klienta nie są podstawą decyzji. |
| Zaakceptowana | Odczyt historii i plików, bez edycji i ponownego przekazania. | Odczyt zakończonej sprawy, bez zmiany decyzji zwykłą akcją. |
| Zakończona bez akceptacji | Odczyt uzasadnienia, historii i plików, bez edycji i ponownego przekazania. | Odczyt zakończonej sprawy, bez zmiany decyzji zwykłą akcją. |
| Wycofana | Odczyt historii i plików, bez edycji. | Odczyt; wznowienie wyłącznie przez administratora. |

Ustalone: rozpoczęcie płatności, czyli utrwalenie zamówienia i przejście do „Oczekuje na płatność”, blokuje edycję nazwy, opisu i listy plików. Przerwaną płatność można ponowić dla tej samej wersji. Edycja wraca dopiero po zwrocie sprawy przez operatora do uzupełnienia; zmiana treści przed opłaceniem nie jest funkcją MVP. Przerwanie płatności zachowuje materiały; nie tworzymy automatycznie nowej sprawy. Prośba klienta o wycofanie jest osobnym zgłoszeniem opisanym poniżej.

### 6.4 Uzupełnienia i decyzje

**Ustalona lista kontrolna oceny:**

1. Opis jasno określa przedmiot sprawy.
2. Załączniki są czytelne i związane ze sprawą.
3. Informacje w treści i plikach nie są sprzeczne.
4. Wcześniejsze uwagi zostały wyjaśnione; przy pierwszym przekazaniu punkt nie dotyczy.

Lista jest wspólna dla wszystkich spraw, bez kategorii i dodatkowych formularzy. Operator przeprowadza ocenę merytoryczną; system sprawdza wymagane pola, pliki i limity. Proponowana realizacja: lista widoczna przy ocenie, z potwierdzeniem jej sprawdzenia przy akceptacji, przypisanym do ocenianej wersji.

**Rundy uzupełnień są bez limitu i bez dodatkowych opłat.** Limit magazynu historii nie jest limitem liczby rund. Gdy dalsze uzupełnienia nie prowadzą do rozwiązania, operator może zakończyć bez akceptacji z uzasadnieniem; liczba rund nie wywołuje automatycznej decyzji.

Operator publikuje jedno uzasadnienie rundy, opcjonalnie podzielone na numerowane uwagi. Mogą odnosić się do nazwy, opisu, konkretnego pliku lub całej sprawy. Wymagane jest wskazanie, co klient ma zmienić albo dostarczyć. Notatka wewnętrzna nie zastępuje opublikowanego uzasadnienia.

Przy ponownym przekazaniu klient może dodać opcjonalny **„Komentarz do uzupełnienia”**, niezależny od opisu sprawy i przypisany do danej rundy. Komentarz widzą klient i operator; pozostaje w historii przekazania. Propozycja walidacji: klient zmienia nazwę, opis lub pliki albo wpisuje niepusty komentarz wyjaśniający brak zmian. Nie wymagamy zmiany opisu tylko po to, by odpowiedzieć operatorowi. Wymóg minimum jednego pliku i limity obowiązują również przy odpowiedzi samym komentarzem. Ostatecznie operator ocenia, czy uwagi zostały uwzględnione; samo kliknięcie przez klienta nie zamyka uwagi.

Akceptacja potwierdza, że operator zapoznał się z treścią i załącznikami oraz uznał całą sprawę w konkretnej wersji za poprawną i kompletną. Kończy obsługę i nie uruchamia dalszej usługi; nie ma częściowych akceptacji. Opcjonalny komentarz operatora jest widoczny klientowi. System nie generuje dokumentu wynikowego. Obowiązkowe są numer zaakceptowanej wersji, data i operator. Publikacja decyzji i zmiana statusu następują jako jedna spójna operacja; powtórzone kliknięcie nie tworzy drugiej decyzji.

### 6.5 Wycofanie sprawy

**Potwierdzenie decyzji końcowych:** przed akceptacją, zakończeniem bez akceptacji i zatwierdzeniem wycofania operator widzi okno z numerem i nazwą sprawy, numerem ocenianej wersji oraz nazwą decyzji. Dla zakończenia bez akceptacji widoczne jest również wpisane uzasadnienie. Anulowanie okna nie zmienia statusu. Potwierdzenie wykonuje jedną akcję, a serwer ponownie sprawdza bieżący status, wersję, uprawnienia i prośbę o wycofanie. Samo otwarcie okna nie rezerwuje decyzji ani nie omija blokad.

Klient może usunąć własny nieprzekazany szkic bez zamówienia. Po opłaceniu aktywnej sprawy wybiera „Zgłoś wycofanie”. Powstaje osobny rekord z datą, autorem i opcjonalnym powodem; w sprawie może istnieć jedna nierozpatrzona prośba. Klient widzi potwierdzenie, operatorzy oznaczenie w kolejce. Samo zgłoszenie nie usuwa danych, nie zmienia głównego statusu ani płatności.

**Od chwili zgłoszenia blokujemy decyzje merytoryczne:** akceptację, zakończenie bez akceptacji i publikację zwrotu do uzupełnienia, do czasu rozpatrzenia prośby. Operator może nadal czytać sprawę i rozpatrzyć wycofanie. Blokada jest sprawdzana na serwerze również dla wcześniej otwartego ekranu; sprzeczne równoczesne akcje nie mogą zostać obie zatwierdzone.

Zatwierdzenie prośby przez dowolnego operatora kończy sprawę statusem **„Wycofana”**, blokuje edycję i ponowne przekazanie oraz planuje e-mail. Zapisujemy operatora, datę i powiązaną prośbę, zachowując historię i pliki przez okres retencji. Nie utożsamiamy wycofania z zakończeniem bez akceptacji. Nie uruchamiamy automatycznej refundacji ani nie zakładamy bezzwrotności opłaty. Operator zatwierdza każdą prawidłową prośbę dotyczącą aktywnej sprawy; nie ma akcji odmowy wycofania. Operator nadal rejestruje zatwierdzenie, a oczekująca prośba blokuje decyzje do tego momentu. Zasady finansowe pozostają do ustalenia w Q-05.

### 6.6 Ponowne otwarcie przez administratora

Wyłącznie administrator może ponownie otworzyć zakończoną sprawę, podając niepuste uzasadnienie. Dotyczy statusów „Zaakceptowana”, „Zakończona bez akceptacji” i „Wycofana”, dopóki dane nie zostały usunięte w ramach retencji. Sprawa wraca do „Do weryfikacji”, bez nowego zamówienia i bez ponownej opłaty. Nie przywracamy danych, które zostały już usunięte.

Zapisujemy poprzedni status i decyzję, administratora, datę, powód oraz nowy cykl obsługi. Poprzednia decyzja nie jest usuwana ani nadpisywana; pozostaje historyczna. Klient otrzymuje e-mail i widzi wznowienie, ale nie edytuje treści do czasu zwrotu do uzupełnienia. Ponowne zamknięcie tworzy nową decyzję w historii. Przy wznowieniu sprawy wycofanej poprzednia prośba pozostaje rozpatrzona i nie blokuje nowego cyklu.

## 7. Jedna opłata i wyjątki płatnicze

Zakończenie bez akceptacji nie uruchamia automatycznego zwrotu środków, dodatkowej opłaty ani zmiany potwierdzonej wpłaty. Nie oznacza też ustalenia, że opłata jest bezzwrotna. Zasady rozliczenia pozostają otwarte zgodnie z decyzją użytkownika. Interfejs rozdziela wynik sprawy od stanu wpłaty i nie pokazuje nieuzgodnionej obietnicy refundacji.

### 7.1 Reguły biznesowe

- **Kwota nie jest ustalona.** Administrator musi skonfigurować dodatnią końcową cenę przed uruchomieniem płatnych zgłoszeń. Brak konfiguracji blokuje rozpoczęcie płatności z czytelną informacją; nie oznacza darmowego złożenia. Szkice mogą działać niezależnie.
- Zachowana waluta PLN i Przelewy24. Docelowe BLIK, Google Pay i Apple Pay wymagają uruchomienia na koncie operatora i sprawdzenia przy wdrożeniu.
- Jedna cena za sprawę obejmuje wszystkie jej rundy uzupełnień. Nowa, odrębna sprawa ma własną opłatę. Nie ma abonamentu, opłat za plik ani za akceptację.
- Serwer wylicza kwotę, przechowuje ją w groszach oraz zapisuje wersję oferty. Cena nie pochodzi z przeglądarki. Zmiana cennika dotyczy nowych zamówień, nie rozpoczętych zakupów.
- Potwierdzenie wpłaty nie gwarantuje akceptacji; opis usługi musi wyjaśnić zakres oceny. Zasady rezygnacji, zwrotu i spraw nienadających się do akceptacji muszą być ustalone przed płatnym startem.

### 7.2 Stan płatności niezależny od stanu sprawy

Jedno zamówienie powiązane ze sprawą może mieć wiele prób: utworzona, oczekująca, potwierdzona, nieudana, wygasła, wymaga wyjaśnienia. Zwrot finansowy, jeśli wykonywany, jest osobną operacją z kwotą i statusem; nie oznacza automatycznego usunięcia sprawy ani cofnięcia decyzji.

| Sytuacja | Wymagane zachowanie |
|---|---|
| Klient wrócił z P24 przed potwierdzeniem | Ekran oczekiwania; brak przekazania do operatora na podstawie samego adresu powrotu. |
| Klient zamknął przeglądarkę | Wersja i próba pozostają; potwierdzenie serwerowe może złożyć sprawę bez otwartej przeglądarki. |
| Błąd rejestracji lub nieznany wynik | Najpierw uzgodnienie istniejącej próby; bez ślepego zakładania kolejnej. |
| Powtórzone potwierdzenie | Idempotentne przetworzenie: jedna sprawa w kolejce, jeden efekt biznesowy. |
| Niezgodna kwota, waluta lub zamówienie | Brak oznaczenia jako opłacone; zdarzenie do wyjaśnienia. |
| Starsze zdarzenie po sukcesie | Nie cofa potwierdzonej wpłaty. |
| Dwie faktyczne wpłaty | Zachowujemy obie; jedna realizacja i zgłoszona nadpłata do obsługi, bez drugiej opłaty wymaganej od klienta. |
| Awaria pomiędzy wpłatą i skierowaniem do kolejki | Ponowne przetworzenie przywraca spójność bez duplikatów. |
| Powrót do uzupełnień | Zachowany status opłacenia i pierwotne zamówienie, bez nowej płatności. |

Szczegóły API weryfikujemy według dokumentacji operatora aktualnej przy implementacji. Portal nie przechowuje danych kart ani kodów BLIK. Niewyjaśnione transakcje mają widok dla obsługi; zwykły operator nie ustawia dowolnie statusu „opłacone”.

## 8. Wymagania funkcjonalne i kryteria odbioru

Poniższe szczegóły stanowią proponowaną realizację ustalonego zakresu.

| ID | Priorytet | Wymaganie | Kryterium odbioru |
|---|---|---|---|
| SU-001 | M | Logowanie Google/Facebook i kontakt e-mail. | Klient wraca do swoich spraw; brak e-maila od dostawcy wymaga zebrania i potwierdzenia kontaktu. Kont nie łączymy tylko po zgodności e-maila. |
| SU-002 | M | Lista „Moje sprawy”: numer, nazwa, status sprawy i płatności, data aktualizacji, następne działanie. | Filtry, sortowanie i stronicowanie; klient widzi tylko własne rekordy. |
| SU-003 | M | Formularz nazwa–opis–załączniki, zapis szkicu. | Zapis niepełnych danych możliwy; do przekazania oba teksty i minimum jeden gotowy plik. |
| SU-004 | M | Prywatne załączniki i kontrola bezpieczeństwa. | Brak publicznego pobrania, kontrola uprawnień, typów i limitów; plik oczekujący na kontrolę nie spełnia minimum. |
| SU-005 | M | Podsumowanie i niezmienne przekazania. | Klient widzi treść i cenę przed zakupem; każda wersja ma numer, autora, datę oraz konkretne pliki. |
| SU-006 | M | Jedno zamówienie i obsługa prób płatności. | Opłata potwierdzana serwerowo, cena utrwalona, duplikaty bez drugiego przekazania; brak ceny blokuje zakup. |
| SU-007 | M | Kolejka operatora. | Filtrowanie statusu i daty, wyszukiwanie numeru/nazwy/klienta, sortowanie od najstarszych; widoczne sprawy po uzupełnieniu oraz daty oczekiwania, bez terminów granicznych. |
| SU-008 | M | Zwrot do uzupełnienia. | Wymagane opublikowane uzasadnienie; klient widzi uwagi i może edytować kopię. Zwrot nie oznacza refundacji. |
| SU-009 | M | Ponowne przekazanie. | Nowa wersja w tej samej sprawie, zachowana historia, żadnej ponownej opłaty. |
| SU-010 | M | Akceptacja potwierdzająca poprawność i kompletność, kończąca obsługę. | Tylko operator, aktualna wersja, opłacona sprawa i rozstrzygnięte uwagi; zapis autora/czasu i blokada edycji. |
| SU-011 | M | Historia i wersje. | Odczyt każdej przekazanej wersji, powiązanych uwag i decyzji; notatki wewnętrzne ukryte dla klienta. |
| SU-012 | M | Powiadomienia e-mail. | Po skutecznym złożeniu, zwrocie, ponownym przekazaniu, akceptacji i zakończeniu bez akceptacji; numer i link po zalogowaniu, bez plików i pełnej treści. |
| SU-013 | M | Kontrola statusów i konfliktów. | Niedozwolone przejścia odrzucane serwerowo; dwie karty lub dwóch operatorów nie nadpisują wzajemnie decyzji. |
| SU-014 | M | Administracja ceną, uprawnieniami i limitami. | Historia zmian konfiguracji; cena nie zmienia opłaconej sprawy, odebranie roli blokuje kolejną akcję. |
| SU-015 | — | Wycofane: termin pierwszej oceny. | Nie obowiązuje limit dni; identyfikator pozostaje zarezerwowany dla historii zmian. |
| SU-016 | M | Opis usługi i warunków zakupu. | Jasne minimum pól, jedna cena, znaczenie akceptacji, zasady uzupełnień i rezygnacji. Bez obietnic starego procesu. |
| SU-017 | M | Wspólna kolejka z prowadzącym. | Operator wybiera „Podejmij sprawę”; jedna osoba zostaje prowadzącym organizacyjnie, każdy operator może nadal obsługiwać sprawę. Administrator może przepisać sprawę innemu operatorowi. Zmiany przypisania zapisane w historii; klient nadal widzi wyłącznie własne sprawy. |
| SU-018 | S | Porównanie dwóch wersji. | Pokazane zmiany nazwy, opisu i listy plików; w MVP bez tej funkcji wystarczy odczyt obu wersji. |
| SU-019 | M | Zakończenie sprawy bez akceptacji z uzasadnieniem. | Operator ocenia aktualną wersję opłaconej sprawy; niepuste uzasadnienie jest obowiązkowe i widoczne klientowi. Zapis decyzji, autora, czasu i wersji, status końcowy, blokada edycji i e-mail. Brak automatycznej operacji finansowej. |
| SU-020 | M | Opcjonalny komentarz do uzupełnienia. | Komentarz utrwalony z daną wersją/rundą, widoczny obu stronom; klient może wyjaśnić brak zmian bez dopisywania do opisu. Nie zastępuje wymaganego pliku. |
| SU-021 | M | Usunięcie szkicu i zgłoszenie wycofania. | Klient usuwa własny nieprzekazany szkic bez zamówienia; po opłaceniu aktywnej sprawy składa prośbę widoczną operatorowi. Samo zgłoszenie nie usuwa danych, nie kończy sprawy ani nie zmienia płatności. Zatwierdzenie bez odmowy według SU-022; rozliczenie do ustalenia w Q-05. |
| SU-022 | M | Wycofanie sprawy i blokada decyzji. | Oczekująca prośba blokuje decyzje merytoryczne każdego operatora; zatwierdzenie daje „Wycofana”, blokadę edycji i e-mail, bez automatycznej refundacji. |
| SU-023 | M | Ponowne otwarcie przez administratora. | Obowiązkowe uzasadnienie, historia, powrót do weryfikacji, e-mail i brak dopłaty; zwykły operator nie może wznowić sprawy. |
| SU-024 | M | Retencja. | 6 miesięcy od zakończenia sprawy, 30 dni bezczynności szkicu; ochrona aktualnie zapisanych i wznowionych spraw przed usunięciem według starej daty. |
| SU-025 | M | 30 dni na opłacenie sprawy od utworzenia zamówienia. | Ponowienie próby płatności nie resetuje terminu. Po upływie okresu blokada nowych prób, uzgodnienie wpłat i zamknięcie nieopłaconego zamówienia; usunięcie materiałów bez ostrzeżenia dopiero po potwierdzeniu braku wpłaty. |
| SU-026 | M | Przypomnienia o uzupełnieniu po 7 i 21 dniach. | Po dwa e-maile na rundę, jeśli klient nadal nie przekazał uzupełnień. Przed wysyłką kontrola aktualnego statusu, rundy i prośby o wycofanie; brak automatycznego zakończenia. |
| SU-027 | M | Ogólna lista kontrolna i nielimitowane rundy. | Operator ocenia jasność opisu, czytelność i związek plików, spójność informacji i wyjaśnienie uwag. Kolejna runda nie tworzy opłaty ani automatycznego zakończenia. |
| SU-028 | M | Limity tekstu i magazynu historii. | Liczniki i walidacja serwerowa: 200/10 000/5 000 znaków. Historia plików do 500 MB, ponownie użyty plik liczony raz; administrator może zwiększyć limit z historią zmiany. |
| SU-029 | M | Powiadomienia operatorów w pierwszej wersji. | Nowa opłacona sprawa: adres zespołu. Uzupełnienie i prośba o wycofanie: prowadzący, a przy jego braku adres zespołu. E-maile bez plików i pełnej treści; trwała wysyłka, ponowienia i kontrola uprawnień odbiorcy. |
| SU-030 | M | Reset hasła personelu przez e-mail. | Administrator inicjuje reset operatora; jednorazowy, ograniczony czasowo link jest przypisany do konta. Ponowne użycie, wygaśnięcie i konto bez uprawnień nie dają dostępu. Hasła ani tokeny nie trafiają do logów. |
| SU-031 | M | Potwierdzenie trzech decyzji końcowych. | Akceptacja, zakończenie bez akceptacji i zatwierdzenie wycofania wymagają potwierdzenia identyfikacji sprawy, wersji i decyzji; dla zakończenia bez akceptacji także podglądu uzasadnienia. Anulowanie bez skutków; nieaktualny stan odrzucany na serwerze. |
| SU-032 | M | Ręczny zapis i dostępność edycji. | Data ostatniego zapisu, ostrzeżenie o niezapisanych zmianach, brak autosave w MVP. Rozpoczęta płatność blokuje edycję serwerowo; ponowienie dotyczy tej samej wersji, powrót edycji po zwrocie do uzupełnienia. |
| SU-033 | M | Prywatność szkiców. | Nieprzekazany szkic i jego pliki dostępne tylko klientowi-właścicielowi; niedostępne operatorowi przez listę, bezpośrednie żądanie i pobranie. Osobny dostęp administratora wyłącznie do diagnostyki. |
| SU-034 | M | Odpowiedzi na e-maile obsługiwane ręcznie. | Zespół odbiera odpowiedzi we wspólnej skrzynce. Nie są automatycznie dołączane do sprawy i nie stanowią formalnego uzupełnienia; wiadomości wskazują, że uzupełnienia przekazuje się w portalu. |
| SU-035 | M | Nazwa wyświetlana operatora dla klienta. | Publiczna historia czynności i decyzji pokazuje nazwę wyświetlaną rzeczywistego autora, bez loginu i służbowego e-maila. Wewnętrzna historia zachowuje jednoznaczny identyfikator konta. |

Propozycja techniczna resetu: token ważny 60 minut, jednokrotny, unieważniany po ustawieniu hasła i ponownym wydaniu. Czas ważności jest parametrem implementacji do doprecyzowania; nie zmienia zatwierdzonej metody resetu. Reset nie nadaje ani nie przywraca odebranej roli. Błąd poczty jest widoczny administratorowi i nie zmienia hasła do czasu poprawnego użycia linku. Opiekun odzyskuje konto administratora procedurą techniczną z rejestracją operacji.

Powiadomienia są zapisywane trwale i ponawiane po błędzie. Awaria poczty nie cofa wpłaty, przekazania ani akceptacji. Zdarzenie biznesowe nie tworzy duplikatów zleceń wysyłki; zewnętrzna poczta może mimo to doręczyć wiadomość ponownie. Operator widzi błędy dostarczania i może ponowić wysyłkę.

### 8.1 Powiadomienia zespołu

**Odpowiedzi klientów:** zespół obsługuje je ręcznie we wspólnej skrzynce. Portal nie importuje wiadomości ani załączników z poczty do sprawy. Odpowiedź e-mail nie zmienia treści, wersji, statusu ani harmonogramu przypomnień. Powiadomienia dotyczące uzupełnień zawierają informację „Uzupełnienia przekaż w portalu” i odsyłacz do sprawy. Kontakt mailowy może wyjaśniać obsługę, ale formalne przekazanie pozostaje akcją zalogowanego klienta w portalu.

**Tożsamość operatora:** klient widzi nazwę wyświetlaną autora publicznej czynności, bez loginu i służbowego adresu. Nazwa jest polem profilu personelu wymaganym przed wykonywaniem publicznych czynności. Nie musi być unikalna; wewnętrzna identyfikacja opiera się na koncie. Propozycja zachowania historii: przy zdarzeniu zapisujemy nazwę wyświetlaną z chwili czynności, aby późniejsza edycja profilu nie zmieniała wcześniejszych wpisów. Notatki wewnętrzne nadal są niewidoczne klientowi.

**Jedna skrzynka portalu:** wspólna skrzynka służy do wysyłania wiadomości, odbierania powiadomień zespołu i kontaktu klientów z obsługą. Jej adres i parametry pocztowe zostaną ustalone później. Nie wymagamy teraz osobnych skrzynek ani aliasów dla tych funkcji. Zachowujemy indywidualne adresy operatorów jako odbiorców wiadomości dotyczących prowadzonych spraw — nie oznacza to dodatkowych skrzynek technicznych portalu. Skrzynka zespołu jest dostępna wyłącznie uprawnionemu personelowi.

Adres zespołu jest konfigurowany przez administratora, a każdy operator ma adres służbowy do powiadomień. Pierwsze opłacone przekazanie planuje jedną wiadomość na adres zespołu. Każde ponowne przekazanie i zgłoszenie wycofania planuje wiadomość do prowadzącego; jeśli go nie przypisano, na adres zespołu. Wybór odbiorcy nie ogranicza wspólnej kolejki ani uprawnień innych operatorów.

Propozycja obsługi wyjątków: brak aktywnego konta lub adresu prowadzącego kieruje wiadomość na adres zespołu; brak tego adresu jest błędem konfiguracji widocznym administratorowi. Przed wysyłką kontrolujemy, czy adresat nadal ma dostęp do sprawy. Zmiana przypisania nie powinna ujawniać sprawy osobie z odebranymi uprawnieniami. Błąd poczty nie cofa operacji; powiadomienia personelu korzystają z tych samych zasad trwałego zapisu i ponowień co SU-012.

## 9. Czas obsługi i daty zdarzeń

**Ustalone: nie ma limitu dni na obsługę sprawy.** Dotyczy to pierwszej oceny i każdej ponownej oceny po uzupełnieniu. Wycofujemy wcześniejsze zobowiązanie 2 dni roboczych; nie wyliczamy terminów wymaganej odpowiedzi ani nie stosujemy kalendarza świąt do obsługi spraw.

Portal zachowuje daty zdarzeń w strefie Europe/Warsaw i pozwala sortować według czasu oczekiwania. Sam upływ czasu nie kończy opłaconej aktywnej sprawy, nie oznacza akceptacji i nie uruchamia zwrotu pieniędzy. Termin opłacenia i retencja są osobnymi regułami. Przypomnienia o uzupełnieniu po 7 i 21 dniach nie stanowią terminu wykonania usługi.

Zapisujemy osobno datę opłacenia i czas odebrania potwierdzenia dla uzgadniania płatności. Brak limitu czasu obsługi nie usuwa technicznych limitów czasu żądań, ważności sesji płatniczych ani zasad przechowywania danych.

### 9.1 Retencja i usuwanie

Zakończone sprawy, ich treść, wersje, komentarze i pliki przechowujemy przez **6 miesięcy od zakończenia**. Obejmuje to „Zaakceptowana”, „Zakończona bez akceptacji” i „Wycofana”. Klient zachowuje dostęp i możliwość pobrania do upływu okresu. Dane usuwamy bez wcześniejszego ostrzeżenia e-mail; reguły i data planowanego usunięcia są dostępne w portalu.

Nieprzekazane szkice bez zamówienia usuwamy po **30 dniach bezczynności**, liczonych od ostatniego skutecznego zapisu treści lub zmiany plików, a dla nowego szkicu od utworzenia. Sam odczyt lub logowanie nie przedłuża okresu. Usuwanie ponownie sprawdza aktualny stan i datę aktywności, chroniąc właśnie zapisany lub przekazany szkic. Sprawy oczekujące na płatność mają 30 dni na opłacenie od utworzenia zamówienia, zgodnie z SU-025. Usuwanie szkiców i zakończonych spraw również odbywa się bez ostrzeżenia.

Ponowne otwarcie sprawy przed usunięciem wstrzymuje usuwanie według poprzedniego zakończenia. Kolejny okres 6 miesięcy rozpoczyna się przy nowym zakończeniu. Nie przywracamy danych już usuniętych. Zasady te nie ustanawiają limitu obsługi aktywnych spraw.

Logi techniczne przechowujemy 90 dni, z automatycznym usuwaniem starszych wpisów. Historia obsługi sprawy podlega retencji sprawy, nie limitowi logów technicznych. Zasady kopii i retencja dokumentów rozliczeniowych pozostają odrębne i do ustalenia. Usuwanie treści sprawy obejmuje jej pliki i historyczne wersje w głównym magazynie; przy odtworzeniu kopii należy ponownie zastosować rejestr usunięć, aby treść nie wróciła do widoku klienta. Szczegóły miesięcy kalendarzowych i harmonogramu wykonania trzeba doprecyzować przy implementacji.

## 10. Model danych i spójność

### Reguły płatności i przypomnień po rundzie 5

**30 dni na opłacenie:** okres liczymy od utworzenia zamówienia, w dniach kalendarzowych, według czasu Europe/Warsaw; konkretna data graniczna jest widoczna klientowi. Ważność pojedynczej sesji P24 może być krótsza. Ponowienie płatności ani odczyt sprawy nie przedłużają okresu. Po terminie portal blokuje nowe próby i uzgadnia stan istniejących transakcji. Materiały nieopłaconej sprawy usuwamy bez ostrzeżenia po potwierdzeniu braku wpłaty. Nie stosujemy dodatkowych 6 miesięcy przechowywania materiałów takiego zamówienia.

Nieznany wynik lub oczekująca transakcja blokuje usunięcie do wyjaśnienia. Potwierdzona wpłata wykonana w terminie nie jest odrzucana z powodu późnego webhooka. Faktyczna wpłata po terminie trafia do wyjaśnienia; nie zakładamy automatycznej akceptacji ani refundacji. Minimalne metadane zamówienia i identyfikatory transakcji pozostają dostępne zgodnie z odrębną retencją rozliczeń, aby późne potwierdzenie nie zostało zgubione. Wygaśnięcie nieopłaconego zamówienia nie jest decyzją merytoryczną operatora.

**Przypomnienia:** po 7 i 21 dniach kalendarzowych od publikacji zwrotu do uzupełnienia, w każdej rundzie osobno. Zapis szkicu poprawki i samo logowanie nie zatrzymują przypomnień; zatrzymuje je ponowne przekazanie. Nie wysyłamy ich po zakończeniu, wznowieniu do weryfikacji ani gdy oczekuje prośba o wycofanie. Każde przypomnienie ma klucz sprawa–runda–próg 7/21, aby ponowienie zadania nie planowało duplikatów. Błąd poczty podlega SU-012; przed ponowieniem kontrolujemy, czy przypomnienie jest jeszcze aktualne. Nie wysyłamy przypomnień o usunięciu danych ani o opłaceniu w ramach tej funkcji.

### Obiekty biznesowe

| Obiekt | Dane i relacje |
|---|---|
| Konto | Tożsamości logowania, potwierdzony kontakt, role; wiele własnych spraw. |
| Sprawa | Numer, właściciel, status, bieżąca przekazana wersja, daty, prowadzący po podjęciu sprawy; jedno zamówienie. |
| Wersja robocza | Nazwa, opis, lista plików, numer rewizji do wykrywania równoczesnych zapisów. |
| Przekazanie | Numer kolejny w sprawie, niezmienna nazwa i opis, powiązania z konkretnymi plikami, autor i data; pierwsze lub uzupełnienie, opcjonalny komentarz klienta do danej rundy. |
| Załącznik | Prywatny klucz magazynu, nazwa oryginalna, typ, rozmiar, suma kontrolna, stan kontroli, właściciel i sprawa. |
| Runda uzupełnień | Oceniana wersja, autor, data, publiczne uwagi, stan ich rozstrzygnięcia i wersja odpowiedzi klienta. |
| Decyzja końcowa | Typ: akceptacja, zakończenie bez akceptacji albo zatwierdzone wycofanie; wersja, autor, data i komentarz. Po ponownym otwarciu poprzednia decyzja pozostaje historyczna; najwyżej jedna aktualna decyzja końcowa na cykl obsługi. |
| Notatka wewnętrzna | Sprawa, operator, treść, daty; niewidoczna klientowi i jego powiadomieniom. |
| Przypisanie prowadzącego | Sprawa, poprzedni i nowy prowadzący, autor, data i historia zmian; jedna aktualna osoba. |
| Prośba o wycofanie | Sprawa, klient, data, opcjonalne uzasadnienie, stan rozpatrzenia, operator i data zatwierdzenia; powiązanie ze statusem „Wycofana”, odrębne rozliczenie. |
| Zamówienie | Sprawa, wersja oferty, kwota w groszach, PLN, wersja materiałów przy zakupie, stan rozliczenia. |
| Próba i zdarzenie płatnicze | Unikalne identyfikatory, zamówienie, kwota, waluta, stan, wynik weryfikacji, daty i wynik przetworzenia. |
| Daty obsługi | Daty złożenia, rozpoczęcia oceny, zwrotu, ponownego przekazania i zakończenia; bez wyliczanej daty wymaganej odpowiedzi. |
| Powiadomienie | Typ, zdarzenie źródłowe, odbiorca, stan, próby, błąd i data wysłania. |
| Dziennik operacji | Kto, kiedy, jaka operacja, sprawa/wersja, wynik i uzasadnienie; bez sekretów i pełnej treści dokumentów. |

Reguły spójności:

- Jedna sprawa należy do jednego klienta. Współdzielenie i przenoszenie własności są poza MVP.
- Załącznik wskazany w przekazaniu należy do tej sprawy; identyfikator pliku z innej sprawy jest odrzucany.
- Uzupełnienie tworzy nową wersję treści, ale nie nowe zamówienie. Kolejne wersje zachowują powiązanie z pierwotnie opłaconą sprawą.
- Decyzja wskazuje numer wersji. Serwer sprawdza, czy status i wersja nie zmieniły się od otwarcia ekranu operatora.
- Zapis przekazania i przejście statusu są spójne; decyzja końcowa, blokada edycji i planowanie powiadomienia nie mogą pozostawić półwykonanej operacji.
- Pełna historia nie oznacza przechowywania bez końca: reguły usuwania danych obejmują wersje, pliki, logi i kopie zgodnie z ustaloną retencją.

## 11. Wymagania niefunkcjonalne

Wartości liczbowe poza zachowaną skalą są propozycjami do potwierdzenia, nie gwarancją obecnego wdrożenia.

| ID | Obszar | Wymaganie / sposób odbioru |
|---|---|---|
| NF-01 | Dostęp — M | Kontrola każdej operacji, pliku i wersji. Test klienta A próbującego czytać/zmieniać sprawę B i klienta próbującego wykonać akcję operatora. |
| NF-02 | Bezpieczeństwo — M | Publiczny HTTPS, bezpieczne sesje, ochrona żądań zmieniających dane, ograniczenie nadużyć, sekrety poza kodem i logami. Panel personelu przez VPN; operatorzy i administrator logują się indywidualnym loginem i hasłem. MFA nie jest wymaganiem obecnego zakresu. |
| NF-03 | Pliki — M | Prywatny magazyn, limity, kontrola typu i zagrożeń. Niedostępność kontroli pozostawia kwarantannę; brak wykonywania treści pliku. |
| NF-04 | Integralność — M | Wersjonowanie, wykrywanie konfliktów, idempotentne płatności i decyzje. Test podwójnego kliknięcia i konkurencyjnych akcji. |
| NF-05 | Użyteczność — M | Język polski; ekran telefonu 360 px bez przewijania poziomego formularza; klawiatura, etykiety, fokus, czytelne błędy niezależne od koloru. |
| NF-06 | Wydajność — M | Skala 10 nowych spraw/dzień; proponowany test 20 aktywnych sesji i 4000 spraw. 95% zwykłych odczytów/zapisów do 2 s po stronie aplikacji, bez plików i usług zewnętrznych. |
| NF-07 | Dostępność — M | Proponowany cel 99% miesięcznie poza ogłoszonymi pracami, pomiar z zewnątrz. Osobna VM nie usuwa wspólnego ryzyka hosta, zasilania i łącza. |
| NF-08 | Kopie — M; szczegóły odłożone | Cel: możliwość odtworzenia bazy, plików i konfiguracji. Miejsce, częstotliwość, retencja kopii, RPO/RTO i harmonogram testów zostaną ustalone później. Wcześniejsze propozycje nie stanowią zatwierdzonego planu. |
| NF-09 | Monitoring — M | Alarmy niedostępności, błędów kopii/poczty, niewyjaśnionych wpłat i braku miejsca na VM oraz hoście. Proponowane progi miejsca 75% i 85%. Opiekunem i odbiorcą alarmów jest właściciel projektu (użytkownik); adres kontaktowy do konfiguracji później. |
| NF-10 | Pojemność — M | Pomiar przyrostu wraz z historią wersji. Przy 10 sprawach/dzień po 30 MB samych plików przyrost to ok. 109,5 GB/rok; początkowe 40 GiB VM wymaga planu rozbudowy. |
| NF-11 | Prywatność — M | Minimalizacja danych, zatwierdzona retencja i procedura żądań dotyczących danych; osobne okresy szkiców, spraw, plików, logów i kopii. Informacja, by nie dodawać danych niezwiązanych ze sprawą. |
| NF-12 | Utrzymanie — M | Testowe środowisko i fikcyjne dane, migracje z kopią i planem wycofania, aktualizacje zależności; brak utraty wpłat, decyzji i wersji. |
| NF-13 | Diagnostyka — M | Identyfikator błędu dla obsługi; logi bez pełnych opisów, dokumentów, tokenów i sekretów; kontrolowany dostęp do logów, retencja 90 dni i automatyczne usuwanie starszych wpisów. |

RPO oznacza dopuszczany projektowo okres utraty danych, RTO — czas odtworzenia. Po odtworzeniu kopii należy uzgodnić wpłaty z operatorem płatności za późniejszy okres; brak lokalnego potwierdzenia nie uzasadnia ponownego obciążenia klienta.

## 12. Scenariusze odbioru MVP

| ID | Wymagania | Scenariusz i oczekiwany wynik |
|---|---|---|
| AT-01 | SU-001–003 | Zapis niepełnego szkicu i ponowne logowanie: dane zachowane; brak możliwości zobaczenia cudzych spraw. |
| AT-02 | SU-003–004 | Brak nazwy, pusty opis lub zero plików: złożenie zablokowane, szkic można zapisać. |
| AT-03 | SU-004 | Jedyny plik nadal sprawdzany, odrzucony lub nieprzesłany w całości: nie spełnia minimum. Po poprawnej kontroli złożenie możliwe. |
| AT-04 | SU-006,014 | Brak skonfigurowanej ceny: brak płatności i darmowego przekazania; zapis szkicu nadal możliwy. |
| AT-05 | SU-005–006 | Poprawne złożenie i potwierdzona wpłata: jedna wersja 1, jedno zamówienie, jedna pozycja w kolejce i potwierdzenie dla klienta. |
| AT-06 | SU-006 | Powrót z P24 przed potwierdzeniem lub zamknięcie przeglądarki: status wynika z weryfikacji serwera, nie z powrotu. |
| AT-07 | SU-006,013 | Podwójne kliknięcie i powtórzony webhook: jedna należność i jeden efekt złożenia. Awaria między zapisami naprawiana ponowieniem. |
| AT-08 | SU-006 | Zła kwota/waluta/powiązanie: brak opłacenia; dwie realne wpłaty: jedna sprawa i nadpłata do wyjaśnienia. |
| AT-09 | SU-008 | Zwrot bez uzasadnienia odrzucony. Zwrot z uwagami publikuje je klientowi i odblokowuje uzupełnienie; nie cofa płatności. |
| AT-10 | SU-009,011 | Zmiana opisu i zastąpienie pliku po zwrocie: wersja 2 w tej samej sprawie bez opłaty; wersja 1 i jej plik nadal czytelne. |
| AT-11 | SU-003,009 | Klient usuwa wszystkie pliki podczas uzupełnienia: zapis roboczy możliwy, ponowne przekazanie zablokowane do dodania minimum jednego pliku. |
| AT-12 | SU-010 | Akceptacja aktualnej opłaconej wersji: status końcowy, autor, data, e-mail; próba późniejszej edycji lub ponownego przekazania odrzucona. |
| AT-13 | SU-013 | Dwóch operatorów równocześnie akceptuje i zwraca tę samą wersję: jedna decyzja, drugiej akcji serwer odmawia i odświeża stan. |
| AT-14 | SU-011,013 | Operator pracuje na nieaktualnej wersji lub klient ma dwie karty: konflikt wykryty, brak cichego nadpisania. |
| AT-15 | SU-004, NF-01 | Podmiana identyfikatora sprawy, pliku lub wersji i próba akcji operatora przez klienta: odmowa, bez ujawnienia danych. |
| AT-16 | SU-012 | Awaria e-maila: status i wpłata poprawne, wiadomość do ponowienia, błąd widoczny obsłudze. Notatka wewnętrzna nie trafia do wiadomości. |
| AT-17 | SU-006,014 | Cena zmienia się po utworzeniu zamówienia: nowe zamówienia korzystają z nowej ceny, stare zachowują uzgodnioną kwotę. |
| AT-18 | SU-007 | Sprawa oczekuje dowolną liczbę dni: brak automatycznego zamknięcia, statusu przeterminowania i obietnicy terminu odpowiedzi. Zachowane daty zdarzeń i sortowanie kolejki. |
| AT-19 | NF-08 | Odtworzenie w odseparowanym środowisku: sprawa, wersje, pliki i płatność dostępne; czas zmierzony, nowsze wpłaty uzgodnione. |
| AT-20 | NF-05 | Cały cykl na telefonie i klawiaturą: utworzenie, plik, płatność, uzupełnienie i odczyt akceptacji dostępne bez blokady interfejsu. |
| AT-21 | SU-004 | Przekroczenie limitu pliku/wersji/historii: jasny komunikat bez utraty treści i bez usuwania starszych przekazań. |
| AT-22 | SU-010,013 | Próba akceptacji nieopłaconej, nieprzekazanej albo już zamkniętej sprawy: odmowa także w bezpośrednim żądaniu do serwera. |
| AT-23 | SU-019 | Operator próbuje zakończyć bez akceptacji z pustym uzasadnieniem lub samymi spacjami: odmowa bez zmiany statusu. Z uzasadnieniem: końcowy status, widoczny powód, autor, czas, wersja i e-mail; klient nie może edytować ani przekazać ponownie. |
| AT-24 | SU-006,013,019 | Równoczesna akceptacja i zakończenie bez akceptacji: tylko jedna decyzja końcowa. Zakończenie bez akceptacji nie zmienia wpłaty, nie zleca refundacji ani nie tworzy kolejnej należności. |
| AT-25 | SU-004 | Poprawne PDF, JPG/JPEG, PNG i DOCX w limicie 20 MB przechodzą kontrolę i mogą być przekazane. Plik powyżej limitu, z fałszywym rozszerzeniem lub format makrowy zamiast DOCX jest odrzucany; szkic pozostaje zapisany. |
| AT-26 | SU-009,020 | Klient odpowiada wyłącznie komentarzem, zachowując minimum jeden plik i poprawne dane: nowe przekazanie bez dopłaty, komentarz widoczny w tej rundzie; starsze komentarze nie są nadpisane. |
| AT-27 | SU-017,013 | Dwie osoby równocześnie podejmują sprawę: jeden prowadzący i konflikt dla drugiej. Administrator przepisuje prowadzenie; historia zachowana, status i opłata bez resetu. |
| AT-28 | SU-021 | Klient usuwa własny szkic bez zamówienia; próba usunięcia opłaconej sprawy odrzucona. Prośba o wycofanie aktywnej opłaconej sprawy widoczna operatorowi, duplikat nie tworzy drugiej; status, wpłata i historia zachowane. |
| AT-29 | SU-004 | 20 poprawnych plików o sumie 100 MB, każdy do 20 MB, spełnia limity. 21. plik albo suma powyżej 100 MB blokuje przekazanie bez utraty szkicu. Starsze pliki niewłączone do bieżącej wersji nie są liczone do jej limitu. |
| AT-30 | SU-022,013 | Oczekująca prośba o wycofanie blokuje akceptację, zakończenie bez akceptacji i zwrot do uzupełnienia również ze starego ekranu. Zatwierdzenie daje „Wycofana”, e-mail, blokadę edycji i nie zmienia wpłaty. |
| AT-31 | SU-023 | Operator nie może wznowić sprawy; administrator bez powodu otrzymuje odmowę. Administrator z powodem wznawia do weryfikacji, zachowuje poprzednią decyzję, wysyła e-mail, bez nowej opłaty. |
| AT-32 | SU-024 | Usunięcie po 6 miesiącach od zakończenia lub 30 dniach bezczynności szkicu. Nowy zapis lub wznowienie przed usunięciem chroni dane przed starą datą; nowe zakończenie rozpoczyna nowy okres 6 miesięcy. Usunięte dane nie są przywracane. |
| AT-33 | SU-017,013 | Operator B obsługuje sprawę przypisaną A; autor operacji to B, prowadzący pozostaje A. Sprzeczne równoczesne decyzje nadal odrzucane. |
| AT-34 | SU-022 | Operator otrzymuje prośbę o wycofanie aktywnej sprawy: dostępne zatwierdzenie i podgląd, brak odmowy; pozostałe decyzje zablokowane do zatwierdzenia. |
| AT-35 | SU-025,024 | Próba ponowienia nie wydłuża 30 dni na opłacenie. Po terminie blokada nowych prób; nieznana wpłata blokuje usunięcie, a wpłata z terminu potwierdzona później jest uznana. Potwierdzony brak wpłaty pozwala usunąć materiały bez ostrzeżenia. |
| AT-36 | SU-026,012 | Oczekiwanie na uzupełnienie: e-maile po 7 i 21 dniach, bez duplikatów. Przekazanie, zakończenie lub oczekujące wycofanie przed wysyłką zatrzymuje wiadomość; nowa runda ma własne dwa progi. |
| AT-37 | SU-027 | Ocena używa wspólnej listy kontrolnej, bez kategorii i formularzy branżowych. Po wielu rundach nadal można przekazać uzupełnienie bez dopłaty; brak automatycznego zakończenia z powodu liczby rund. |
| AT-38 | SU-028 | Tekst równy limitowi 200/10 000/5 000 znaków przechodzi; przekroczenie o znak jest odrzucane również w bezpośrednim żądaniu do serwera, bez obcinania. Obowiązkowe uzasadnienie z samych spacji nadal niepoprawne. |
| AT-39 | SU-004,028 | Ponownie użyty ten sam plik nie zwiększa magazynu historii drugi raz. Przekroczenie 500 MB blokuje dodanie nowych plików bez kasowania starych wersji; zwiększenie limitu przez administratora z historią umożliwia dalszą pracę. |
| AT-40 | SU-029,012 | Nowa opłacona sprawa daje e-mail zespołu; uzupełnienie i wycofanie prowadzącemu albo zespołowi przy braku prowadzącego. Powtórzone zdarzenie nie tworzy duplikatu; błąd wysyłki nie cofa statusu, odbiorca bez uprawnień nie dostaje wiadomości. |
| AT-41 | NF-02 | Operator i administrator logują się indywidualnym loginem i hasłem; niepoprawne dane odrzucane, konto klienta nie uzyskuje praw personelu. Odebranie uprawnień blokuje dalsze akcje. |
| AT-42 | NF-13 | Logi techniczne starsze niż 90 dni są usuwane bez naruszania historii spraw podlegającej własnej retencji; logi nie zawierają pełnych treści, dokumentów ani sekretów. |
| AT-43 | SU-030 | Administrator inicjuje reset operatora: wiadomość na adres konta, poprawny link pozwala ustawić hasło, ponowne użycie i link wygasły odrzucone. Odebrana rola nie wraca, konto klienta nie uzyskuje dostępu. |
| AT-44 | SU-031,013 | Każda z trzech decyzji końcowych pokazuje potwierdzenie z numerem, nazwą i wersją; zakończenie bez akceptacji także uzasadnienie. Anulowanie nie zmienia stanu; zmiana statusu w innej karcie blokuje nieaktualne potwierdzenie. |
| AT-45 | SU-032 | Zapis ręczny pokazuje datę; niezapisane zmiany wywołują ostrzeżenie przy opuszczeniu formularza. Po rozpoczęciu płatności bezpośrednia próba edycji odrzucona; ponowienie zachowuje wersję. Zwrot do uzupełnienia odblokowuje kopię roboczą. |
| AT-46 | SU-033 | Operator próbuje otworzyć cudzy nieprzekazany szkic lub jego plik: odmowa; właściciel nadal ma dostęp. Szkic nie trafia do kolejki przed skutecznym opłaceniem i złożeniem. |
| AT-47 | SU-034,026 | Klient odpowiada na e-mail: wiadomość trafia do skrzynki zespołu, ale nie tworzy wersji ani uzupełnienia i nie zatrzymuje przypomnień. Uzupełnienie przekazane w portalu tworzy wersję i zatrzymuje przypomnienia danej rundy. |
| AT-48 | SU-035,011 | Operator B wykonuje czynność w sprawie prowadzonej przez A: klient widzi nazwę wyświetlaną B, bez loginu i służbowego e-maila. Wewnętrzny zapis wskazuje konto B; notatki wewnętrzne pozostają ukryte. |
| AT-49 | NF-12 | Pierwszy pilotaż obejmuje fikcyjne sprawy, testowe pliki i płatności testowe P24. Oddzielne konta klienta, operatora i administratora przechodzą złożenie, uzupełnienia, decyzje, wycofanie i wznowienie; brak rzeczywistych obciążeń klienta. |

## 13. Brainstorm — decyzje i dalsze rundy

### 13.1 Rejestr aktualnych decyzji

| ID | Decyzja | Źródło |
|---|---|---|
| DEC-01 | Przedmiotem portalu jest sprawa uniwersalna. | Nowa instrukcja użytkownika. |
| DEC-02 | Formularz obejmuje nazwę wniosku, opis i załączniki. | Nowa instrukcja użytkownika. |
| DEC-03 | Operator zwraca do uzupełnienia albo akceptuje. | Nowa instrukcja użytkownika. |
| DEC-04 | Jedna opłata za sprawę; jej kwota zostanie ustalona później. | Instrukcja i odpowiedź w rundzie 1 nowego brainstormingu. |
| DEC-05 | Co najmniej jeden załącznik jest wymagany. | Odpowiedź użytkownika w rundzie 1. |
| DEC-06 | Akceptacja kończy sprawę; klient dostaje e-mail i nie może zmieniać treści. | Wybrany wariant w rundzie 1. |
| DEC-07 | Nie ma limitu dni na obsługę; dotyczy pierwszej i kolejnych ocen. | Odpowiedź użytkownika w rundzie 2; zastępuje wcześniejsze terminy. |
| DEC-08 | Dopuszczone PDF, JPG/JPEG, PNG i DOCX, maksymalnie 20 MB na plik. | Odpowiedź użytkownika w rundzie 2. |
| DEC-09 | Operator może zakończyć sprawę bez akceptacji z uzasadnieniem; rozliczenie do ustalenia później. | Odpowiedź użytkownika w rundzie 2. |
| DEC-10 | Akceptacja potwierdza poprawność i kompletność sprawy oraz kończy obsługę. | Odpowiedź użytkownika w rundzie 3. |
| DEC-11 | Opcjonalny komentarz klienta do uzupełnienia, zapisany w historii rundy. | Odpowiedź użytkownika w rundzie 3. |
| DEC-12 | Wspólna kolejka z prowadzącym; podjęcie przez operatora i możliwość przepisania przez administratora. | Zatwierdzona propozycja w rundzie 3. |
| DEC-13 | Klient może usunąć szkic, a po opłaceniu zgłosić prośbę o wycofanie do rozpatrzenia przez operatora. | Zatwierdzona propozycja w rundzie 3; rozliczenie pozostaje otwarte. |
| DEC-14 | Maksymalnie 20 plików i 100 MB łącznie na jedno przekazanie. | Odpowiedź użytkownika w rundzie 3; nadal obowiązuje 20 MB na plik. |
| DEC-15 | Zatwierdzone wycofanie daje „Wycofana”, blokadę edycji i e-mail. | Runda 4; rozliczenie nadal otwarte. |
| DEC-16 | Oczekująca prośba o wycofanie blokuje decyzje merytoryczne. | Runda 4. |
| DEC-17 | Tylko administrator może ponownie otworzyć sprawę z uzasadnieniem, historią, e-mailem i bez dopłaty. | Zatwierdzony wariant w rundzie 4. |
| DEC-18 | Zakończone sprawy: 6 miesięcy od zakończenia; szkice: 30 dni bezczynności. | Runda 4. |
| DEC-19 | Każdy operator może obsługiwać każdą sprawę niezależnie od prowadzącego. | Runda 4; przypisanie organizacyjne. |
| DEC-20 | Wycofanie aktywnej sprawy zatwierdzane bez możliwości odmowy. | Odpowiedź użytkownika w rundzie 5. |
| DEC-21 | Logowanie jednorazowym linkiem e-mail poza obecnym zakresem. | Odpowiedź użytkownika w rundzie 5. |
| DEC-22 | Usuwanie danych po retencji bez wcześniejszego ostrzeżenia. | Odpowiedź użytkownika w rundzie 5. |
| DEC-23 | 30 dni na opłacenie sprawy. | Zatwierdzony wariant w rundzie 5; uzgodnienie wpłat przed usunięciem. |
| DEC-24 | Przypomnienia o uzupełnieniu po 7 i 21 dniach. | Odpowiedź użytkownika w rundzie 5. |
| DEC-25 | Ogólna lista kontrolna poprawności i kompletności wystarczy na start, bez kategorii i osobnych formularzy. | Zatwierdzona propozycja w rundzie 6. |
| DEC-26 | Bez limitu rund uzupełnień i bez dodatkowych opłat. | Odpowiedź użytkownika w rundzie 6. |
| DEC-27 | Nazwa 200 znaków, opis 10 000, komentarz do uzupełnienia i uzasadnienia operatora 5 000; zwykły tekst, akapity i liczniki. | Zatwierdzone limity w rundzie 6. |
| DEC-28 | 500 MB historii plików sprawy, wspólny plik liczony raz, możliwość zwiększenia przez administratora. | Zatwierdzona propozycja w rundzie 6. |
| DEC-29 | Powiadomienia operatorów w MVP: nowa sprawa na adres zespołu; uzupełnienie i wycofanie do prowadzącego, a bez niego do zespołu. | Zatwierdzona propozycja w rundzie 6. |
| DEC-30 | Nazwa portalu: „Portal spraw”; domena ustalana później. | Odpowiedź użytkownika w rundzie 7. |
| DEC-31 | Operatorzy i administrator logują się loginem i hasłem. | Odpowiedź użytkownika w rundzie 7; bez wymogu MFA w obecnym zakresie. |
| DEC-32 | Jedna skrzynka portalu; adres ustalany później. | Odpowiedź użytkownika w rundzie 7. |
| DEC-33 | Szczegóły kopii zapasowych ustalimy później. | Odpowiedź użytkownika w rundzie 7; brak zatwierdzenia proponowanych 30 dni. |
| DEC-34 | Opiekunem utrzymania jest właściciel projektu (użytkownik), logi techniczne 90 dni. | Odpowiedź użytkownika w rundzie 7. |
| DEC-35 | Blokada edycji po rozpoczęciu płatności; ponowienie dla tej samej wersji, edycja po zwrocie do uzupełnienia. | Zatwierdzona propozycja w rundzie 8. |
| DEC-36 | Szkice wyłącznie dla klienta; administrator zachowuje dostęp diagnostyczny. | Zatwierdzona propozycja w rundzie 8. |
| DEC-37 | Ręczny zapis w MVP, data zapisu i ostrzeżenie o niezapisanych zmianach; autosave później. | Zatwierdzona propozycja w rundzie 8. |
| DEC-38 | Administrator inicjuje reset hasła operatora przez e-mail; odzyskanie konta administratora przez opiekuna technicznie. | Zatwierdzona propozycja w rundzie 8. |
| DEC-39 | Potwierdzenie akceptacji, zakończenia bez akceptacji i zatwierdzenia wycofania z identyfikacją sprawy oraz wersji. | Zatwierdzona propozycja w rundzie 8. |
| DEC-40 | Odpowiedzi na e-maile obsługuje zespół ręcznie; formalne uzupełnienia tylko w portalu. | Odpowiedź użytkownika w rundzie 9. |
| DEC-41 | Klient widzi nazwę wyświetlaną operatora, bez loginu i służbowego e-maila. | Zatwierdzona propozycja w rundzie 9. |
| DEC-42 | Najpierw testy na fikcyjnych sprawach i płatnościach testowych, na oddzielnych kontach ról; płatny pilotaż po domknięciu odłożonych decyzji. | Zatwierdzona kolejność w rundzie 9. |

Zachowane ustalenia z poprzedniej koncepcji: Google/Facebook, kontakt e-mail, P24 przed pierwszą oceną i uzupełnienia bez dopłaty. Dawne terminy obsługi oraz reguły dni roboczych są wycofane. Są jawnie wskazane, aby można je było zmienić bez mieszania z wycofanymi ustaleniami branżowymi.

### 13.2 Runda 2 — znaczenie akceptacji i obsługa wyjątków

| ID | Pytanie | Propozycja wyjściowa | Wpływ / stan |
|---|---|---|---|
| Q-01 | Jaka będzie końcowa kwota za sprawę? | Jedna dodatnia cena w PLN konfigurowana przez administratora, utrwalana w zamówieniu. | Użytkownik odłożył decyzję. Nie wracamy do 500 PLN; wymagane przed sprzedażą. |
| Q-02 — zamknięte w zakresie MVP | Jak operator ocenia sprawę? | Ogólna lista kontrolna poprawności i kompletności (DEC-25), bez kategorii spraw i dodatkowych formularzy. | SU-027; kryteria merytoryczne ocenia operator, walidację techniczną wykonuje system. |
| Q-03 — zamknięte | Jakie limity tekstu? | Nazwa 200, opis 10 000, komentarz do uzupełnienia i uzasadnienia operatora 5 000 znaków (DEC-27). | Zwykły tekst, akapity i liczniki; sprawdzanie również na serwerze. |
| Q-04 — zamknięte | Czy obowiązują terminy oceny? | Nie ma limitu dni na obsługę, również pierwszą ocenę i uzupełnienia (DEC-07). | Brak terminów granicznych, kalendarza dni roboczych i automatycznego zamykania z upływem czasu. |
| Q-05 — częściowo zamknięte | Jak rozliczamy zakończenie bez akceptacji; co z rozliczeniem wycofania? | Zakończenie bez akceptacji jest ustalone (DEC-09); klient może też zgłosić wycofanie (DEC-13). Zatwierdzenie prośby daje „Wycofana”, a oczekująca prośba blokuje decyzje (DEC-15–16). Wycofanie zatwierdzane bez odmowy (DEC-20); rozliczenie pozostaje otwarte. | Samo zakończenie nie uruchamia refundacji ani nie rozstrzyga zatrzymania opłaty; zasady wymagane przed płatnym startem. |
| Q-06 — zamknięte | Jak sprostować omyłkowe zakończenie? | Administrator ponownie otwiera sprawę z uzasadnieniem, historią, e-mailem i bez opłaty (DEC-17). | SU-023; operator nie może sam cofać zakończenia. |

### 13.3 Runda 3 — pliki, operatorzy i utrzymanie

| ID | Pytanie | Propozycja wyjściowa | Wpływ |
|---|---|---|---|
| Q-07 — zamknięte | Jakie pliki i limity? | Ustalono PDF, JPG/JPEG, PNG i DOCX do 20 MB/plik (DEC-08). Ustalono też maksymalnie 20 plików i 100 MB/przekazanie (DEC-14). Ustalono 500 MB historii z możliwością zwiększenia przez administratora (DEC-28). | Kontrola DOCX i rozmiaru pliku obowiązkowa; limity przekazania zatwierdzone, limit historii również zatwierdzony. |
| Q-08 — zamknięte | Jak organizujemy pracę operatorów? | Wspólna kolejka z prowadzącym informacyjnym; każdy operator może obsługiwać każdą sprawę (DEC-19). Administrator może przepisać prowadzenie. | SU-017 w MVP; liczba kont nie zmienia modelu. |
| Q-09 — zamknięte | Jak klient odpowiada na uwagi? | Lista uwag operatora, poprawki treści lub plików i opcjonalny komentarz do uzupełnienia (DEC-11). | Komentarz w historii danej rundy, bez czatu na żywo. |
| Q-10 — częściowo zamknięte | Jak długo przechowujemy dane? | Zakończone sprawy: 6 miesięcy od zakończenia; szkice: 30 dni bezczynności (DEC-18). | Logi techniczne 90 dni (DEC-34); do ustalenia zasady kopii i retencja dokumentów rozliczeniowych; usuwanie bez ostrzeżeń ustalone w DEC-22, 30 dni na płatność w DEC-23. |
| Q-11 | Osoba prywatna czy firma jako nabywca; gdzie wystawiamy dokument sprzedaży? | Rozliczenie poza portalem na start z identyfikatorem zamówienia. | Oddzielne dane rozliczeniowe, bez rozbudowy formularza sprawy. |
| Q-12 — odłożone | Czy dodajemy logowanie linkiem e-mail? | Nie, poza obecnym zakresem (DEC-21); pozostają Google/Facebook. | Nie wdrażamy teraz nowej metody ani procesu odzyskiwania dostępu opartego na linku. |
| Q-13 — częściowo zamknięte | Nazwa, domena, poczta, kopie i opiekun? | Portal spraw; domena później. Jedna skrzynka, adres później. Personel: login i hasło. Opiekun: właściciel projektu. Logi 90 dni. Szczegóły kopii odłożone (DEC-30–34). | Przed uruchomieniem skonfigurować domenę, skrzynkę, alarmy i plan odtwarzania. |
| Q-14 — zamknięte | Czy ograniczamy rundy uzupełnień? | Bez limitu rund i bez dopłat (DEC-26); przypomnienia po 7 i 21 dniach każdej rundy (DEC-24). | Brak automatycznego zamknięcia aktywnej sprawy z upływem czasu. Operator może zakończyć bez akceptacji z uzasadnieniem. |

### 13.4 Pomysły do rozważenia

| Pomysł | Korzyść | Proponowany etap |
|---|---|---|
| Przykładowy dobry opis przy formularzu | Mniej niejasnych zgłoszeń bez dodatkowych pól. | MVP. |
| Szablony uwag operatora | Szybsza i bardziej spójna komunikacja, z edycją przed wysłaniem. | Po pilotażu. |
| Porównanie wersji | Krótsza ponowna ocena. | S; po sprawdzeniu potrzeby. |
| Widoczna oś historii | Klient wie, kto ma wykonać następny krok. | MVP jako prosta lista zdarzeń. |
| Przypomnienia o uzupełnieniu | Mniej porzuconych spraw. | MVP: po 7 i 21 dniach oczekiwania w każdej rundzie, SU-026. |
| Wyszukiwanie w opisach | Łatwiejsze odnajdywanie spraw operatora. | Później, gdy wyszukiwanie po nazwie i numerze nie wystarczy. |

Po odpowiedziach aktualizujemy wymagania, model i scenariusze, a zamknięte pytanie odsyła do decyzji. Nie dopisujemy propozycji do rejestru jako zatwierdzonej bez odpowiedzi użytkownika.

## 14. Wpływ na architekturę, dane i wdrożenie

### 14.1 Co pozostaje technicznie

Jedna aplikacja Django, PostgreSQL, Caddy/Gunicorn i osobna VM pozostają wystarczającym założeniem dla planowanej skali; nie wprowadzamy nowych usług wyłącznie z powodu zmiany nazwy. Potrzebne są prywatny magazyn, integracje logowania, płatności i e-mail oraz egzekwowanie procesu opisane w wymaganiach. Aktualny stan serwera nie był ponownie weryfikowany w tej analizie.

### 14.2 Co trzeba zmienić w implementacji i dokumentacji

| Warstwa | Zmiana |
|---|---|
| Ekrany i treści | Nazwa produktu, trzy pola, statusy uniwersalne, e-maile i nowy opis usługi. |
| Model | Sprawa, wersje, uwagi, akceptacja i jedna należność; usunięcie zależności procesu od danych branżowych. |
| Reguły | Minimum jednego pliku, końcowa akceptacja, brak dokumentu wynikowego, płatność raz na sprawę. |
| Konfiguracja | Cena do ustalenia, zatwierdzone typy i limity pliku/przekazania, zatwierdzony limit historii, retencja; bez terminów oceny. |
| Testy | Zastąpić scenariusze branżowe AT-01–AT-49; zachować i dostosować testy uprawnień, konfliktów oraz płatności. |
| ARCHITEKTURA.md | Przy wdrożeniu zaktualizować cel, proces, model i backlog. Dane infrastruktury zmieniać wyłącznie po sprawdzeniu stanu. |

Przed migracją ustalamy, czy poza opisaną wcześniej wersją startową powstały modele lub rzeczywiste sprawy. Jeśli są dane: kopia i inwentaryzacja, migracja testowa, kontrola plików i wpłat, plan wycofania. Nie usuwamy pól branżowych ani nie konwertujemy opłaconych zamówień automatycznie. Dawne „Dane kompletne” i „Wniosek gotowy” nie są automatycznie równoważne nowej końcowej akceptacji. Historyczna cena pozostaje częścią starego zamówienia, a nie domyślną ceną nowego produktu.

## 15. Kolejność realizacji i kryteria gotowości

1. Domknąć kwotę przed sprzedażą, zasady rozliczenia, plan kopii i retencję dokumentów rozliczeniowych; ustalić domenę i adres jednej skrzynki, skonfigurować adresy operatorów i opiekuna. Nie obiecywać terminów obsługi.
2. Zbudować formularz nazwa–opis–załączniki, szkic i kontrolę dostępu.
3. Dodać wersje, stany, kolejkę operatora, zwrot do uzupełnienia, końcową akceptację i zakończenie bez akceptacji.
4. Dodać jedno zamówienie, P24, uzgadnianie wyjątków i e-maile z ponowieniami.
5. Sprawdzić scenariusze AT-01–AT-49, kopie, odtwarzanie, monitoring i pojemność. Brak konfiguracji ceny nie może przypadkowo otworzyć bezpłatnej ścieżki.
6. Najpierw pilotaż na fikcyjnych sprawach i płatnościach testowych P24, z właścicielem projektu korzystającym z oddzielnych kont klienta, operatora i administratora. Zakres obejmuje złożenie, uzupełnienia, akceptację, zakończenie bez akceptacji, wycofanie i ponowne otwarcie. Proponowana liczba: 5–10 spraw. Skonfigurowana testowa cena służy wyłącznie symulacji i nie ustala ceny handlowej.
7. Płatny pilotaż dopiero po ustaleniu ceny, rozliczeń i gotowości produkcyjnej, w tym domeny, poczty oraz kopii. Przed przełączeniem sprawdzić konfigurację środowiska i rozdzielenie transakcji testowych od rzeczywistych. Mierzyć liczbę rund, czas oceny, problemy z plikami i płatnościami; rozwijać funkcje na podstawie wyników.

**Gotowość płatnego MVP:** ustalona i skonfigurowana cena, zrozumiała oferta, zatwierdzone zasady obsługi wyjątków i danych, wymagane pola i pliki, uprawnienia, spójne wersje/statusy, poprawne płatności, powiadomienia, odtworzenie i zaakceptowane scenariusze odbioru. Zmiana specyfikacji nie oznacza wykonania tych prac ani uruchomienia produkcyjnego.
