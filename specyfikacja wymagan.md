# Portal spraw — specyfikacja wymagań

Wersja ujednolicona 1.4 — 14 listopada 2026 r.

## 1. Cel i przeznaczenie dokumentu

Dokument określa docelowe wymagania Portalu spraw. Został opracowany na podstawie [wymagania.md](wymagania.md), wersja 1.8, i uzupełniony o wymaganie dodatkowego zapisu spraw na dysku serwera. Stanowi jednolitą podstawę projektowania ekranów, implementacji i odbioru produktu. Opisuje wymagane zachowanie, a nie stan wykonania aplikacji.

Portal pozwala klientowi złożyć sprawę uniwersalną: podać nazwę, opis i załączniki, wnieść jedną opłatę oraz przekazywać uzupełnienia. Operator ocenia poprawność i kompletność sprawy, zwraca ją do uzupełnienia, akceptuje albo kończy bez akceptacji. Klient może zgłosić wycofanie, które operator zatwierdza bez odmowy. Zakończoną sprawę może wyjątkowo wznowić administrator z uzasadnieniem.

Identyfikatory SU, NF i AT zachowują zgodność z dokumentem źródłowym; numeracja może być nieciągła. M oznacza wymaganie pierwszej wersji, S funkcję pożądaną do późniejszego rozważenia. Szczegóły oznaczone jako propozycje lub parametry do ustalenia nie są zatwierdzonymi zobowiązaniami. Decyzje odłożone i parametry wymagające doprecyzowania zebrano w sekcji 13.

## 2. Ogólne zasady produktu

1. Konto klienta może mieć wiele niezależnych spraw. Każda ma jednoznaczny numer, właściciela, historię wersji i własne zamówienie.
2. Zapis szkicu nie jest złożeniem sprawy. Do skutecznego złożenia wymagane są poprawne pola, pliki oraz zweryfikowana wpłata.
3. Jedna opłata obejmuje obsługę sprawy i nieograniczoną liczbę rund uzupełnień. Kwota zostanie ustalona później; brak konfiguracji ceny blokuje rzeczywisty zakup. Konfiguracyjny tryb mock pozwala testować obsługę spraw bez P24 i bez realizacji płatności zgodnie z sekcją 7.4.
4. Operator ocenia konkretną niezmienną wersję. Uzupełnienie tworzy nową wersję bez nadpisania poprzedniej i bez kolejnej opłaty.
5. Akceptacja potwierdza poprawność i kompletność. Akceptacja, zakończenie bez akceptacji i wycofanie kończą zwykłą obsługę i blokują edycję klienta.
6. Ponowne otwarcie jest wyjątkiem dostępnym tylko administratorowi, z historią, uzasadnieniem, e-mailem i bez nowej opłaty.
7. Nie obowiązuje limit dni na obsługę. Termin opłacenia, przypomnienia i retencja są odrębnymi regułami.
8. Dostęp do treści, plików i czynności podlega uprawnieniom sprawdzanym na serwerze. Notatki wewnętrzne są niewidoczne klientowi.
9. Pierwszy pilotaż korzysta z fikcyjnych spraw, testowych plików i płatności testowych.
10. Wszystkie zapisane dane wprowadzone przez klienta do sprawy są dodatkowo utrwalane w JSON wraz z załącznikami w skonfigurowanej lokalizacji na dysku serwera. Każda sprawa ma osobny katalog.

## 3. Zakres MVP i słownik

### 3.1 Podstawowe wymagania

- Nazwa portalu: **Portal spraw**. Nazwa procesu/rodzaju zgłoszenia: **Sprawa uniwersalna**. Domena zostanie ustalona później. Klient tworzy i składa sprawę.
- Dane formularza: **nazwa wniosku, opis, załączniki**; co najmniej jeden załącznik obowiązkowy.
- Operator może **zwrócić do uzupełnienia**, **zaakceptować** albo **zakończyć bez akceptacji z uzasadnieniem**.
- Akceptacja kończy sprawę, blokuje dalszą edycję i powoduje powiadomienie e-mail.
- Operator może zakończyć sprawę bez akceptacji z uzasadnieniem; również ten stan kończy edycję. Zasady rozliczenia zostaną ustalone później.
- Brak limitu dni na obsługę. Dopuszczone pliki: PDF, JPG/JPEG, PNG i DOCX, do 20 MB na plik.
- Jedna opłata za sprawę, bez dopłat za kolejne uzupełnienia; kwota otwarta.
- Konto może mieć wiele spraw. Logowanie Google/Facebook, kontakt e-mail i płatność P24 przed weryfikacją.
- Akceptacja potwierdza poprawność i kompletność sprawy. Uzupełnienie może zawierać opcjonalny komentarz klienta do danej rundy.
- Operator może udostępnić klientowi własne załączniki przy publikacji rundy uzupełnień i przy akceptacji sprawy. Pliki są powiązane z konkretną rundą albo decyzją.
- Operatorzy pracują we wspólnej kolejce z prowadzącym; klient może zgłosić prośbę o wycofanie. Ustalone limity każdego przekazania: 20 plików i 100 MB łącznie, przy 20 MB na plik.
- Skala planowania: do 10 nowych spraw dziennie. Język polski, strefa Europe/Warsaw.

### 3.2 Zakres pierwszej wersji

Logowanie, zapis szkicu, formularz, prywatne pliki, podsumowanie, jedna opłata, lista i szczegóły spraw, kolejka operatora, zwrot z uzasadnieniem, ponowne przekazanie, akceptacja lub zakończenie bez akceptacji, historia, e-maile, podstawowe monitorowanie i administracja uprawnieniami.

Poza MVP: własne typy formularzy, pola dynamiczne konfigurowane przez klienta, generowanie dokumentów, podpis elektroniczny, współdzielenie sprawy między klientami, automatyczne decyzje AI, czat na żywo, integracje branżowe oraz dalszy proces realizacji po akceptacji. Zakończenie bez akceptacji jest jawną akcją operatora z uzasadnieniem. Zgłoszenie prośby o wycofanie przez klienta należy do MVP. Zatwierdzenie prośby daje status „Wycofana”. Ponowne otwarcie zastrzeżone jest dla administratora z uzasadnieniem. Wycofanie zatwierdzamy bez możliwości odmowy; rozliczenia pozostają otwarte w sekcji 13. Logowanie jednorazowym linkiem e-mail jest poza obecnym zakresem.

### 3.3 Słownik i nazwy interfejsu

| Pojęcie | Znaczenie |
|---|---|
| Sprawa uniwersalna | Zgłoszenie klienta zawierające nazwę, opis i pliki. |
| Nazwa wniosku | Edytowalny tytuł sprawy wpisany przez klienta. |
| Numer sprawy | Unikalny, niezmienny identyfikator nadawany przez system. |
| Operator | Osoba oceniająca sprawę i wykonująca działania obsługi. |
| Szkic | Dane robocze przed pierwszym przekazaniem. |
| Wersja przekazana | Utrwalona nazwa, opis i konkretne pliki przekazane do oceny. |
| Runda uzupełnień | Opublikowane uwagi operatora i powiązane ponowne przekazanie klienta. |
| Akceptacja | Potwierdzenie poprawności i kompletności konkretnej wersji sprawy po zapoznaniu się z treścią i załącznikami; kończy obsługę, z datą i autorem. |
| Zakończenie bez akceptacji | Końcowa decyzja operatora z publicznym uzasadnieniem; nie jest zwrotem do uzupełnienia ani operacją finansową. |
| Zamówienie / próba płatności | Jedna należność za sprawę / pojedyncza próba jej opłacenia. |

Proponowane etykiety: „Moje sprawy”, „Nowa sprawa”, „Nazwa wniosku”, „Opis”, „Załączniki”, „Zapłać i złóż sprawę”, „Przekaż uzupełnienia”, „Zwróć do uzupełnienia”, „Zaakceptuj sprawę”.

## 4. Role i uprawnienia

### 4.1 Publiczna strona główna (Homepage)

Portal ma stronę główną dostępną bez logowania, będącą podstawową wizytówką usługi i domyślnym punktem wejścia nowego użytkownika. Prezentuje nazwę „Portal spraw”, krótkie powitanie i ofertę: przekazanie nazwy, opisu oraz dokumentów do oceny poprawności i kompletności, uzupełnienia oraz odbiór wyniku w koncie klienta.

Strona zawiera sekcje „Oferta”, „Jak to działa” i „Kontakt” z działającymi odnośnikami oraz główne wezwanie „Zaloguj się i złóż sprawę”. Przycisk prowadzi gościa do logowania; po zalogowaniu użytkownik uzyskuje dostęp do swoich spraw i utworzenia nowej. Skrót do „Moich spraw” wymaga logowania i nigdy nie ujawnia danych klienta na stronie publicznej. Odnośnik dla personelu prowadzi do logowania personelu, którego docelowa dostępność pozostaje zgodna z ograniczeniem panelu przez VPN. Logo/nazwa portalu umożliwia powrót na stronę główną z pozostałych ekranów bez utraty zapisanych danych; przy niezapisanych zmianach obowiązuje ostrzeżenie.

Opis procesu obejmuje logowanie, wypełnienie formularza z co najmniej jednym plikiem, podsumowanie i płatność oraz ocenę operatora z ewentualnymi uzupełnieniami. Akceptacja jest potwierdzeniem poprawności i kompletności, nie gwarancją dodatkowej realizacji. Strona nie obiecuje terminu obsługi. W trybie rzeczywistym pokazuje wyłącznie skonfigurowaną cenę końcową; brak ceny nie jest prezentowany jako cena zerowa. W mocku wyraźnie informuje o symulacji bez pobierania pieniędzy.

Sekcja kontaktowa korzysta z jednej skonfigurowanej skrzynki portalu. W makietach przed ustaleniem adresu widnieje informacja o jego braku, bez fikcyjnego adresu. Strona nie wyświetla danych spraw, prywatnych załączników ani statystyk klientów. Ilustracje procesu są oznaczone jako przykładowe. Układ działa na komputerze i telefonie, z czytelną hierarchią, obsługą klawiaturą i dostępnymi etykietami linków.

### 4.2 Konta i dostęp do funkcji

Operatorzy i administrator korzystają z indywidualnych kont personelu z loginem i hasłem, zakładanych przez administratora. Samodzielna rejestracja nie nadaje uprawnień personelu. Hasła są przechowywane w postaci bezpiecznych skrótów; obowiązują ograniczenie prób logowania i możliwość odebrania dostępu. Administrator uruchamia reset hasła operatora: jednorazowy link do ustawienia nowego hasła jest wysyłany na adres przypisany do konta operatora. Odzyskanie konta administratora jest procedurą techniczną opiekuna. Reset nie dodaje logowania klienta linkiem e-mail.

| Rola | Dozwolone działania |
|---|---|
| Gość | Informacje o usłudze, cenie i logowanie. |
| Klient | Własne szkice, składanie i opłacanie spraw, uzupełnienia, historia i własne pliki. |
| Operator | Wspólna kolejka opłaconych spraw z przypisanym prowadzącym; odczyt wersji, notatki wewnętrzne, publikacja uwag, akceptacja i zakończenie bez akceptacji z uzasadnieniem. |
| Administrator | Konta personelu, uprawnienia, ustawienia ceny i plików, diagnostyka; bez dowolnego nadpisywania decyzji i wpłat. |
| Operator płatności | Wyłącznie integracja finansowa; bez treści spraw i dokumentów. |

Autoryzacja obowiązuje na serwerze dla odczytu, zapisu, pobrania pliku i każdej akcji. Operator nie edytuje w imieniu klienta nazwy, opisu ani jego plików. Może dodawać własne załączniki do rund uzupełnień i akceptacji zgodnie z sekcją 5.4. Klient nie ustawia statusu ani ceny. Notatki wewnętrzne nie trafiają do klienta i e-maili. Ustalone: nieprzekazane szkice są widoczne wyłącznie właścicielowi; operator nie ma dostępu także przez bezpośredni adres lub pobranie pliku. Do kolejki trafiają dopiero opłacone sprawy. Administrator zachowuje dostęp techniczny do diagnostyki, nie używa go do zwykłej obsługi szkiców.

**Prowadzenie sprawy:** wszyscy operatorzy widzą wspólną kolejkę i każdy może obsługiwać każdą sprawę, niezależnie od przypisania. Prowadzący służy organizacji pracy, nie jest blokadą uprawnień. „Podejmij sprawę” przypisuje jednego prowadzącego; administrator może go zmienić z historią. Inny operator może publikować uwagi, podejmować decyzje i rozpatrywać wycofanie bez przepisywania prowadzącego. Każda operacja zapisuje rzeczywistego autora i nie zmienia automatycznie przypisania. Powrót po uzupełnieniu zachowuje prowadzącego. Nadal obowiązują kontrola aktualnej wersji i ochrona przed równoczesnymi sprzecznymi decyzjami.

## 5. Formularz, pliki i walidacja

### 5.1 Pola klienta

| Pole | Reguła | Status szczegółu |
|---|---|---|
| Nazwa wniosku | Wymagana przy przekazaniu; tekst po usunięciu skrajnych spacji nie może być pusty. Limit 200 znaków. | Ustalone. |
| Opis | Wymagany; zwykły tekst, wielowierszowy, nie tylko białe znaki. Limit 10 000 znaków. | Ustalone. |
| Załączniki | Co najmniej jeden przy każdym przekazaniu; stary plik może pozostać w nowej wersji. | Obowiązkowość ustalona. |

Numer, właściciel, daty, status, wersja i płatność są metadanymi systemowymi, a nie dodatkowymi polami formularza. Adres kontaktowy pochodzi z konta; ewentualne dane rozliczeniowe zbierane są oddzielnie przy zakupie. Nie dokładamy kategorii, priorytetu ani dodatkowych ankiet do MVP.

### 5.2 Limity i obsługa plików

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

### 5.4 Załączniki operatora udostępniane klientowi

Operator może dodać jeden lub kilka plików do przygotowywanej rundy uzupełnień oraz do akceptacji sprawy. Załączniki operatora są opcjonalne; brak pliku nie blokuje tych działań. Nie zmieniają ani nie zastępują załączników przekazanych przez klienta. Nadal obowiązuje minimum jednego pliku klienta przy jego przekazaniu.

Przy zwrocie do uzupełnienia pliki operatora są publikowane razem z uwagami i przypisane do danej rundy oraz ocenianej wersji klienta. Przy akceptacji pliki są publikowane razem z decyzją i przypisane do zaakceptowanej wersji. Klient widzi sekcję „Załączniki operatora”, autora w postaci nazwy wyświetlanej, datę publikacji i powiązanie z rundą lub akceptacją. Może pobrać pliki po zalogowaniu przez cały okres dostępności sprawy.

Dodanie pliku do wersji roboczej operatora nie udostępnia go klientowi. Operator przed publikacją może go usunąć lub zastąpić. Publikowane są wyłącznie pliki z zakończoną kontrolą bezpieczeństwa i kompletnym dodatkowym zapisem katalogowym. Anulowanie potwierdzenia decyzji nie publikuje przygotowanych plików. Okno potwierdzenia akceptacji pokazuje również listę załączników operatora; przy zwrocie operator widzi listę plików wybranych do publikacji z uwagami.

Publikacja uwag lub akceptacji i udostępnienie przypisanych plików są jedną spójną operacją. Klient nie może zobaczyć pliku z niezatwierdzonej lub nieudanej operacji. Jeżeli w międzyczasie zmienił się status sprawy, wersja albo pojawiła się prośba o wycofanie, serwer odrzuca nieaktualną publikację wraz z jej plikami.

Opublikowane załączniki pozostają niezmienne w historii. Klient nie może ich edytować ani usuwać. Zmiana dokumentu wymaga nowej publikacji w kolejnej rundzie lub przy kolejnej akceptacji po ponownym otwarciu sprawy przez administratora. Po akceptacji operator nie dopisuje plików do starej decyzji bez wznowienia procesu. Funkcja obejmuje przekazanie plików dostarczonych przez operatora; nie wprowadza automatycznego generowania dokumentów.

Stosujemy te same formaty i kontrolę co dla plików klienta: PDF, JPG/JPEG, PNG i DOCX, do 20 MB na plik. W jednej publikacji operatora obowiązuje maksymalnie 20 plików i 100 MB łącznie. Zestaw operatora i zestaw klienta są liczone oddzielnie dla przekazania/publikacji, natomiast wszystkie ich unikalne pliki i historia korzystają ze wspólnego limitu 500 MB sprawy, z możliwością zwiększenia przez administratora. Fizyczna dodatkowa kopia na serwerze nie jest liczona drugi raz do limitu sprawy.

E-mail o zwrocie do uzupełnienia lub akceptacji informuje o dostępnych plikach i prowadzi do sprawy. Samych plików nie dołączamy do wiadomości. Obowiązują autoryzacja pobierania, prywatny magazyn, kwarantanna, historia i retencja sprawy.

## 6. Proces i maszyna stanów

### 6.1 Ścieżka podstawowa

1. Klient loguje się, wybiera „Nowa sprawa” i zapisuje nazwę, opis oraz pliki.
2. Portal sprawdza wymagane pola, kontrolę plików i limity. Pokazuje podsumowanie i jedną cenę końcową.
3. W trybie P24 „Zapłać i złóż sprawę” utrwala wersję 1, warunki zakupu i zamówienie, następnie przekierowuje do Przelewy24. W trybie mock akcja „Złóż sprawę — płatność symulowana” realizuje ścieżkę z sekcji 7.4 bez P24.
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
| Szkic | Do weryfikacji | System w trybie mock; walidacja, utrwalona wersja i zamówienie mock, symulacja i kompletny dodatkowy zapis, bez przekierowania P24. |
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

Zatwierdzenie prośby przez dowolnego operatora kończy sprawę statusem **„Wycofana”**, blokuje edycję i ponowne przekazanie oraz planuje e-mail. Zapisujemy operatora, datę i powiązaną prośbę, zachowując historię i pliki przez okres retencji. Nie utożsamiamy wycofania z zakończeniem bez akceptacji. Nie uruchamiamy automatycznej refundacji ani nie zakładamy bezzwrotności opłaty. Operator zatwierdza każdą prawidłową prośbę dotyczącą aktywnej sprawy; nie ma akcji odmowy wycofania. Operator nadal rejestruje zatwierdzenie, a oczekująca prośba blokuje decyzje do tego momentu. Zasady finansowe pozostają do ustalenia w sekcji 13.

### 6.6 Ponowne otwarcie przez administratora

Wyłącznie administrator może ponownie otworzyć zakończoną sprawę, podając niepuste uzasadnienie. Dotyczy statusów „Zaakceptowana”, „Zakończona bez akceptacji” i „Wycofana”, dopóki dane nie zostały usunięte w ramach retencji. Sprawa wraca do „Do weryfikacji”, bez nowego zamówienia i bez ponownej opłaty. Nie przywracamy danych, które zostały już usunięte.

Zapisujemy poprzedni status i decyzję, administratora, datę, powód oraz nowy cykl obsługi. Poprzednia decyzja nie jest usuwana ani nadpisywana; pozostaje historyczna. Klient otrzymuje e-mail i widzi wznowienie, ale nie edytuje treści do czasu zwrotu do uzupełnienia. Ponowne zamknięcie tworzy nową decyzję w historii. Przy wznowieniu sprawy wycofanej poprzednia prośba pozostaje rozpatrzona i nie blokuje nowego cyklu.

## 7. Jedna opłata i wyjątki płatnicze

Zakończenie bez akceptacji nie uruchamia automatycznego zwrotu środków, dodatkowej opłaty ani zmiany potwierdzonej wpłaty. Nie oznacza też ustalenia, że opłata jest bezzwrotna. Zasady rozliczenia wymagają ustalenia zgodnie z sekcją 13. Interfejs rozdziela wynik sprawy od stanu wpłaty i nie pokazuje nieuzgodnionej obietnicy refundacji.

### 7.1 Reguły biznesowe

- **Kwota nie jest ustalona.** Administrator musi skonfigurować dodatnią końcową cenę przed uruchomieniem płatnych zgłoszeń. W trybie P24 brak konfiguracji blokuje rozpoczęcie płatności z czytelną informacją; nie oznacza darmowego złożenia. Wyjątkiem testowym jest jawny mock z sekcji 7.4. Szkice mogą działać niezależnie.
- Waluta PLN i integracja Przelewy24. Docelowe BLIK, Google Pay i Apple Pay wymagają uruchomienia na koncie operatora i sprawdzenia przy wdrożeniu.
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

### 7.3 Okres na opłacenie i uzgodnienie transakcji

**30 dni na opłacenie:** okres liczymy od utworzenia zamówienia, w dniach kalendarzowych, według czasu Europe/Warsaw; konkretna data graniczna jest widoczna klientowi. Ważność pojedynczej sesji P24 może być krótsza. Ponowienie płatności ani odczyt sprawy nie przedłużają okresu. Po terminie portal blokuje nowe próby i uzgadnia stan istniejących transakcji. Materiały nieopłaconej sprawy usuwamy bez ostrzeżenia po potwierdzeniu braku wpłaty. Nie stosujemy dodatkowych 6 miesięcy przechowywania materiałów takiego zamówienia.

Nieznany wynik lub oczekująca transakcja blokuje usunięcie do wyjaśnienia. Potwierdzona wpłata wykonana w terminie nie jest odrzucana z powodu późnego webhooka. Faktyczna wpłata po terminie trafia do wyjaśnienia; nie zakładamy automatycznej akceptacji ani refundacji. Minimalne metadane zamówienia i identyfikatory transakcji pozostają dostępne zgodnie z odrębną retencją rozliczeń, aby późne potwierdzenie nie zostało zgubione. Wygaśnięcie nieopłaconego zamówienia nie jest decyzją merytoryczną operatora.

### 7.4 Przełącznik mockowania płatności

System udostępnia parametr konfiguracyjny typu boolean **`PAYMENTS_MOCK_ENABLED`**, domyślnie **`false`**. Ustawienie `true` włącza lokalną symulację spełnienia warunku płatności, umożliwiając przetestowanie pełnego procesu sprawy bez przekierowania do Przelewy24, wywoływania API P24, wymagania kluczy P24 ani fizycznej realizacji płatności. Jest to tryb niezależny od sandboxa P24: mock testuje proces aplikacji, a sandbox służy testom rzeczywistej integracji z operatorem.

Parametr jest ustawieniem serwera zarządzanym przez uprawnioną administrację, np. w konfiguracji środowiska aplikacji. Nie jest przełącznikiem klienta ani parametrem żądania HTTP. Brak wartości oznacza wyłączenie; nieprawidłowa wartość konfiguracji nie może niejawnie włączyć mocka. Zmiana ustawienia wymaga jego kontrolowanego zastosowania przez aplikację i zapisu w dzienniku konfiguracji, bez ujawniania sekretów.

#### Przebieg w trybie mock

1. Klient zapisuje i sprawdza nazwę, opis oraz pliki. Nadal obowiązują walidacja, limity, kontrola bezpieczeństwa i dodatkowy zapis katalogowy.
2. Zamiast akcji sugerującej rzeczywiste pobranie opłaty widzi **„Złóż sprawę — płatność symulowana”** i informację, że pieniądze nie zostaną pobrane.
3. Serwer utrwala wersję, zamówienie z trybem `mock` oraz zdarzenie symulacji. Nadaje stan **„Płatność symulowana”**, datę symulacji i unikalny lokalny identyfikator. Nie zapisuje fikcyjnego potwierdzenia P24 ani rzeczywistej wpłaty.
4. Po kompletnym zapisie materiałów sprawa trafia bezpośrednio ze szkicu do „Do weryfikacji”, bez oczekiwania na webhook i bez widocznego etapu oczekiwania na płatność. Przekazana wersja zostaje zablokowana do edycji.
5. Operator obsługuje ją tak samo jak sprawę z rzeczywistą płatnością: uwagi, uzupełnienia, własne pliki, akceptacja, zakończenie bez akceptacji, wycofanie i ponowne otwarcie. Kolejne rundy nie tworzą nowych symulowanych opłat.

Podwójne kliknięcie, ponowienie żądania i ponowne przetworzenie zdarzenia dają jedną symulację i jedno przekazanie. Błąd dysku lub zapisu nie powoduje automatycznej akceptacji ani utraty materiałów; obowiązują zasady odtwarzania spójności SU-036. Symulacja zastępuje wyłącznie warunek płatniczy, a nie walidację, uprawnienia, decyzję operatora czy kontrolę plików.

#### Oznaczenie i konfiguracja ceny testowej

Klient i personel widzą oznaczenie „Tryb testowy — płatności symulowane”. Konkretna sprawa, historia, zamówienie, powiadomienia i dodatkowy JSON zawierają trwałe oznaczenie trybu `mock`. Nie przedstawiamy klientowi symulacji jako otrzymanej wpłaty. Kwota symulacji nie jest przychodem, nie podlega zwrotowi finansowemu i nie stanowi należności wymagającej późniejszego opłacenia tej samej sprawy.

Mock może działać przed ustaleniem ceny handlowej. Dopuszczalna jest opcjonalna cena testowa; przy jej braku zapisujemy brak kwoty testowej, a nie bezpłatną ofertę handlową. W trybie rzeczywistym nadal wymagana jest dodatnia skonfigurowana cena i pełna konfiguracja P24. Włączenie mocka nie wyłącza innych integracji: e-maile, pliki, retencja i przypomnienia działają zgodnie ze specyfikacją. Pilotaż mocka korzysta z fikcyjnych danych i kontrolowanych adresów testowych.

#### Zmiana trybu i zgodność z istniejącymi sprawami

Tryb `mock` albo `p24` utrwalamy przy utworzeniu zamówienia i zachowujemy dla jego prób. Przełączenie parametru dotyczy nowych zamówień; szkic bez zamówienia korzysta z konfiguracji obowiązującej przy złożeniu. Istniejące zamówienie P24 nie staje się symulowane po włączeniu mocka. Jego opóźnione potwierdzenia nadal są weryfikowane i rozliczane właściwą ścieżką. Zasada braku wywołań P24 w mocku dotyczy zamówień `mock`, a nie uzgadniania istniejących rzeczywistych transakcji.

Wyłączenie mocka nie zmienia historycznej symulacji w rzeczywistą wpłatę, nie kieruje ponownie testowej sprawy do P24 i nie żąda od klienta opłaty. Oznaczenie testowe pozostaje przez cały cykl życia sprawy. Zdarzenie P24 nie może oznaczyć zamówienia `mock` jako rzeczywiście opłaconego ani uruchomić jego drugiego przekazania. Reguła 30 dni na opłacenie dotyczy zamówień wymagających P24; poprawnie złożona sprawa mock nie jest nieopłaconą sprawą przeznaczoną do usunięcia po tym okresie.

Na potrzeby autoryzacji procesu warunek „sprawa opłacona” w pozostałych wymaganiach oznacza **zweryfikowaną rzeczywistą wpłatę albo trwale zapisaną symulację dla zamówienia `mock`**. Rozróżnienie finansowe i oznaczenie interfejsu zawsze pozostają zachowane. Tryb rzeczywisty nie przełącza się automatycznie na mock po błędzie P24.

## 8. Wymagania funkcjonalne i kryteria odbioru

Poniższe szczegóły stanowią proponowaną realizację ustalonego zakresu.

| ID | Priorytet | Wymaganie | Kryterium odbioru |
|---|---|---|---|
| SU-001 | M | Logowanie Google/Facebook i kontakt e-mail. | Klient wraca do swoich spraw; brak e-maila od dostawcy wymaga zebrania i potwierdzenia kontaktu. Kont nie łączymy tylko po zgodności e-maila. |
| SU-002 | M | Lista „Moje sprawy”: numer, nazwa, status sprawy i płatności, data aktualizacji, następne działanie. | Filtry, sortowanie i stronicowanie; klient widzi tylko własne rekordy. |
| SU-003 | M | Formularz nazwa–opis–załączniki, zapis szkicu. | Zapis niepełnych danych możliwy; do przekazania oba teksty i minimum jeden gotowy plik. |
| SU-004 | M | Prywatne załączniki i kontrola bezpieczeństwa. | Brak publicznego pobrania, kontrola uprawnień, typów i limitów; plik oczekujący na kontrolę nie spełnia minimum. |
| SU-005 | M | Podsumowanie i niezmienne przekazania. | Klient widzi treść i cenę przed zakupem; każda wersja ma numer, autora, datę oraz konkretne pliki. |
| SU-006 | M | Jedno zamówienie i obsługa prób płatności. | Opłata potwierdzana serwerowo, cena utrwalona, duplikaty bez drugiego przekazania; brak ceny blokuje rzeczywisty zakup. Mock spełnia warunek procesu zgodnie z SU-038 i pozostaje odrębny od wpłaty. |
| SU-007 | M | Kolejka operatora. | Filtrowanie statusu i daty, wyszukiwanie numeru/nazwy/klienta, sortowanie od najstarszych; widoczne sprawy po uzupełnieniu oraz daty oczekiwania, bez terminów granicznych. |
| SU-008 | M | Zwrot do uzupełnienia. | Wymagane opublikowane uzasadnienie; klient widzi uwagi i może edytować kopię. Zwrot nie oznacza refundacji. |
| SU-009 | M | Ponowne przekazanie. | Nowa wersja w tej samej sprawie, zachowana historia, żadnej ponownej opłaty. |
| SU-010 | M | Akceptacja potwierdzająca poprawność i kompletność, kończąca obsługę. | Tylko operator, aktualna wersja, opłacona sprawa i rozstrzygnięte uwagi; zapis autora/czasu i blokada edycji. |
| SU-011 | M | Historia i wersje. | Odczyt każdej przekazanej wersji, powiązanych uwag i decyzji; notatki wewnętrzne ukryte dla klienta. |
| SU-012 | M | Powiadomienia e-mail. | Po skutecznym złożeniu, zwrocie, ponownym przekazaniu, akceptacji i zakończeniu bez akceptacji; numer i link po zalogowaniu, bez plików i pełnej treści. |
| SU-013 | M | Kontrola statusów i konfliktów. | Niedozwolone przejścia odrzucane serwerowo; dwie karty lub dwóch operatorów nie nadpisują wzajemnie decyzji. |
| SU-014 | M | Administracja ceną, uprawnieniami i limitami. | Historia zmian konfiguracji; cena nie zmienia opłaconej sprawy, odebranie roli blokuje kolejną akcję. |
| SU-016 | M | Opis usługi i warunków zakupu. | Jasne minimum pól, jedna cena, znaczenie akceptacji, zasady uzupełnień i rezygnacji. Opis zgodny z zakresem niniejszej specyfikacji. |
| SU-017 | M | Wspólna kolejka z prowadzącym. | Operator wybiera „Podejmij sprawę”; jedna osoba zostaje prowadzącym organizacyjnie, każdy operator może nadal obsługiwać sprawę. Administrator może przepisać sprawę innemu operatorowi. Zmiany przypisania zapisane w historii; klient nadal widzi wyłącznie własne sprawy. |
| SU-018 | S | Porównanie dwóch wersji. | Pokazane zmiany nazwy, opisu i listy plików; w MVP bez tej funkcji wystarczy odczyt obu wersji. |
| SU-019 | M | Zakończenie sprawy bez akceptacji z uzasadnieniem. | Operator ocenia aktualną wersję opłaconej sprawy; niepuste uzasadnienie jest obowiązkowe i widoczne klientowi. Zapis decyzji, autora, czasu i wersji, status końcowy, blokada edycji i e-mail. Brak automatycznej operacji finansowej. |
| SU-020 | M | Opcjonalny komentarz do uzupełnienia. | Komentarz utrwalony z daną wersją/rundą, widoczny obu stronom; klient może wyjaśnić brak zmian bez dopisywania do opisu. Nie zastępuje wymaganego pliku. |
| SU-021 | M | Usunięcie szkicu i zgłoszenie wycofania. | Klient usuwa własny nieprzekazany szkic bez zamówienia; po opłaceniu aktywnej sprawy składa prośbę widoczną operatorowi. Samo zgłoszenie nie usuwa danych, nie kończy sprawy ani nie zmienia płatności. Zatwierdzenie bez odmowy według SU-022; rozliczenie do ustalenia w sekcji 13. |
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
| SU-036 | M | Dodatkowy zapis sprawy na dysku serwera: JSON i załączniki, osobny katalog każdej sprawy. | Konfigurowalny katalog główny; komplet danych klienta dla szkicu i kolejnych wersji, pliki z jednoznacznym powiązaniem, aktualizacja po zapisie, wykrywanie błędów i ponowienie, ochrona dostępu oraz usuwanie zgodne z retencją. Szczegóły w sekcji 10.2. |
| SU-037 | M | Załączniki operatora dla klienta przy rundzie uzupełnień i akceptacji. | Opcjonalne pliki przygotowane przez operatora, niewidoczne do publikacji. Udostępnienie wraz z uwagami lub akceptacją, kontrola plików, przypisanie do rundy/decyzji i wersji, prywatne pobranie, e-mail z informacją, niezmienna historia oraz dodatkowy zapis na dysku. Szczegóły w sekcji 5.4. |
| SU-038 | M | Mockowanie płatności przełącznikiem `PAYMENTS_MOCK_ENABLED`. | Domyślnie wyłączone. Po włączeniu lokalna symulacja bez P24 i obciążenia klienta, przekazanie do obsługi bez webhooka, trwałe oznaczenie testowe i pełny cykl sprawy. Cena handlowa nie jest wymagana do mocka; przełączenie nie zmienia istniejących zamówień ani historii. Szczegóły w sekcji 7.4. |
| SU-039 | M | Publiczna strona główna — wizytówka i nawigacja. | Powitanie, ogólny opis oferty, etapy, sekcje Oferta/Jak to działa/Kontakt, przejście do logowania i spraw oraz powrót przez logo. Bez ujawnienia danych prywatnych, nieustalonej ceny lub obietnicy terminu; czytelne oznaczenie mocka i układ mobilny. Szczegóły w sekcji 4.1. |

Propozycja techniczna resetu: token ważny 60 minut, jednokrotny, unieważniany po ustawieniu hasła i ponownym wydaniu. Czas ważności jest parametrem implementacji do doprecyzowania; nie zmienia zatwierdzonej metody resetu. Reset nie nadaje ani nie przywraca odebranej roli. Błąd poczty jest widoczny administratorowi i nie zmienia hasła do czasu poprawnego użycia linku. Opiekun odzyskuje konto administratora procedurą techniczną z rejestracją operacji.

Powiadomienia są zapisywane trwale i ponawiane po błędzie. Awaria poczty nie cofa wpłaty, przekazania ani akceptacji. Zdarzenie biznesowe nie tworzy duplikatów zleceń wysyłki; zewnętrzna poczta może mimo to doręczyć wiadomość ponownie. Operator widzi błędy dostarczania i może ponowić wysyłkę.

### 8.1 Powiadomienia zespołu

**Odpowiedzi klientów:** zespół obsługuje je ręcznie we wspólnej skrzynce. Portal nie importuje wiadomości ani załączników z poczty do sprawy. Odpowiedź e-mail nie zmienia treści, wersji, statusu ani harmonogramu przypomnień. Powiadomienia dotyczące uzupełnień zawierają informację „Uzupełnienia przekaż w portalu” i odsyłacz do sprawy. Kontakt mailowy może wyjaśniać obsługę, ale formalne przekazanie pozostaje akcją zalogowanego klienta w portalu.

**Tożsamość operatora:** klient widzi nazwę wyświetlaną autora publicznej czynności, bez loginu i służbowego adresu. Nazwa jest polem profilu personelu wymaganym przed wykonywaniem publicznych czynności. Nie musi być unikalna; wewnętrzna identyfikacja opiera się na koncie. Propozycja zachowania historii: przy zdarzeniu zapisujemy nazwę wyświetlaną z chwili czynności, aby późniejsza edycja profilu nie zmieniała wcześniejszych wpisów. Notatki wewnętrzne nadal są niewidoczne klientowi.

**Jedna skrzynka portalu:** wspólna skrzynka służy do wysyłania wiadomości, odbierania powiadomień zespołu i kontaktu klientów z obsługą. Jej adres i parametry pocztowe zostaną ustalone później. Nie wymagamy teraz osobnych skrzynek ani aliasów dla tych funkcji. Zachowujemy indywidualne adresy operatorów jako odbiorców wiadomości dotyczących prowadzonych spraw — nie oznacza to dodatkowych skrzynek technicznych portalu. Skrzynka zespołu jest dostępna wyłącznie uprawnionemu personelowi.

Adres zespołu jest konfigurowany przez administratora, a każdy operator ma adres służbowy do powiadomień. Pierwsze opłacone przekazanie planuje jedną wiadomość na adres zespołu. Każde ponowne przekazanie i zgłoszenie wycofania planuje wiadomość do prowadzącego; jeśli go nie przypisano, na adres zespołu. Wybór odbiorcy nie ogranicza wspólnej kolejki ani uprawnień innych operatorów.

Propozycja obsługi wyjątków: brak aktywnego konta lub adresu prowadzącego kieruje wiadomość na adres zespołu; brak tego adresu jest błędem konfiguracji widocznym administratorowi. Przed wysyłką kontrolujemy, czy adresat nadal ma dostęp do sprawy. Zmiana przypisania nie powinna ujawniać sprawy osobie z odebranymi uprawnieniami. Błąd poczty nie cofa operacji; powiadomienia personelu korzystają z tych samych zasad trwałego zapisu i ponowień co SU-012.

### 8.2 Przypomnienia o uzupełnieniu

**Przypomnienia:** po 7 i 21 dniach kalendarzowych od publikacji zwrotu do uzupełnienia, w każdej rundzie osobno. Zapis szkicu poprawki i samo logowanie nie zatrzymują przypomnień; zatrzymuje je ponowne przekazanie. Nie wysyłamy ich po zakończeniu, wznowieniu do weryfikacji ani gdy oczekuje prośba o wycofanie. Każde przypomnienie ma klucz sprawa–runda–próg 7/21, aby ponowienie zadania nie planowało duplikatów. Błąd poczty podlega SU-012; przed ponowieniem kontrolujemy, czy przypomnienie jest jeszcze aktualne. Nie wysyłamy przypomnień o usunięciu danych ani o opłaceniu w ramach tej funkcji.

## 9. Czas obsługi i daty zdarzeń

**Ustalone: nie ma limitu dni na obsługę sprawy.** Dotyczy to pierwszej oceny i każdej ponownej oceny po uzupełnieniu. Nie wyliczamy terminów wymaganej odpowiedzi ani nie stosujemy kalendarza świąt do obsługi spraw.

Portal zachowuje daty zdarzeń w strefie Europe/Warsaw i pozwala sortować według czasu oczekiwania. Sam upływ czasu nie kończy opłaconej aktywnej sprawy, nie oznacza akceptacji i nie uruchamia zwrotu pieniędzy. Termin opłacenia i retencja są osobnymi regułami. Przypomnienia o uzupełnieniu po 7 i 21 dniach nie stanowią terminu wykonania usługi.

Zapisujemy osobno datę opłacenia i czas odebrania potwierdzenia dla uzgadniania płatności. Brak limitu czasu obsługi nie usuwa technicznych limitów czasu żądań, ważności sesji płatniczych ani zasad przechowywania danych.

### 9.1 Retencja i usuwanie

Zakończone sprawy, ich treść, wersje, komentarze i pliki przechowujemy przez **6 miesięcy od zakończenia**. Obejmuje to „Zaakceptowana”, „Zakończona bez akceptacji” i „Wycofana”. Klient zachowuje dostęp i możliwość pobrania do upływu okresu. Dane usuwamy bez wcześniejszego ostrzeżenia e-mail; reguły i data planowanego usunięcia są dostępne w portalu.

Nieprzekazane szkice bez zamówienia usuwamy po **30 dniach bezczynności**, liczonych od ostatniego skutecznego zapisu treści lub zmiany plików, a dla nowego szkicu od utworzenia. Sam odczyt lub logowanie nie przedłuża okresu. Usuwanie ponownie sprawdza aktualny stan i datę aktywności, chroniąc właśnie zapisany lub przekazany szkic. Sprawy oczekujące na płatność mają 30 dni na opłacenie od utworzenia zamówienia, zgodnie z SU-025. Usuwanie szkiców i zakończonych spraw również odbywa się bez ostrzeżenia.

Ponowne otwarcie sprawy przed usunięciem wstrzymuje usuwanie według poprzedniego zakończenia. Kolejny okres 6 miesięcy rozpoczyna się przy nowym zakończeniu. Nie przywracamy danych już usuniętych. Zasady te nie ustanawiają limitu obsługi aktywnych spraw.

Logi techniczne przechowujemy 90 dni, z automatycznym usuwaniem starszych wpisów. Historia obsługi sprawy podlega retencji sprawy, nie limitowi logów technicznych. Zasady kopii i retencja dokumentów rozliczeniowych pozostają odrębne i do ustalenia. Usuwanie treści sprawy obejmuje pliki klienta i operatora oraz historyczne wersje w głównym magazynie; przy odtworzeniu kopii należy ponownie zastosować rejestr usunięć, aby treść nie wróciła do widoku klienta. Szczegóły miesięcy kalendarzowych i harmonogramu wykonania trzeba doprecyzować przy implementacji.

## 10. Model danych i spójność

### 10.1 Obiekty biznesowe

| Obiekt | Dane i relacje |
|---|---|
| Konto | Tożsamości logowania, potwierdzony kontakt, role; wiele własnych spraw. |
| Sprawa | Numer, właściciel, status, bieżąca przekazana wersja, daty, prowadzący po podjęciu sprawy; jedno zamówienie. |
| Wersja robocza | Nazwa, opis, lista plików, numer rewizji do wykrywania równoczesnych zapisów. |
| Przekazanie | Numer kolejny w sprawie, niezmienna nazwa i opis, powiązania z konkretnymi plikami, autor i data; pierwsze lub uzupełnienie, opcjonalny komentarz klienta do danej rundy. |
| Załącznik | Prywatny klucz magazynu, nazwa oryginalna, typ, rozmiar, suma kontrolna, stan kontroli, właściciel i sprawa. |
| Publikacja załączników operatora | Sprawa, autor, rodzaj publikacji: runda uzupełnień lub akceptacja, oceniana wersja klienta, lista konkretnych plików, stan roboczy/opublikowany i data publikacji. |
| Runda uzupełnień | Oceniana wersja, autor, data, publiczne uwagi, stan ich rozstrzygnięcia i wersja odpowiedzi klienta. |
| Decyzja końcowa | Typ: akceptacja, zakończenie bez akceptacji albo zatwierdzone wycofanie; wersja, autor, data i komentarz. Po ponownym otwarciu poprzednia decyzja pozostaje historyczna; najwyżej jedna aktualna decyzja końcowa na cykl obsługi. |
| Notatka wewnętrzna | Sprawa, operator, treść, daty; niewidoczna klientowi i jego powiadomieniom. |
| Przypisanie prowadzącego | Sprawa, poprzedni i nowy prowadzący, autor, data i historia zmian; jedna aktualna osoba. |
| Prośba o wycofanie | Sprawa, klient, data, opcjonalne uzasadnienie, stan rozpatrzenia, operator i data zatwierdzenia; powiązanie ze statusem „Wycofana”, odrębne rozliczenie. |
| Zamówienie | Sprawa, tryb p24/mock, wersja oferty, kwota w groszach (testowa opcjonalna w mocku), PLN, wersja materiałów przy zakupie, stan rozliczenia lub lokalnej symulacji. |
| Próba i zdarzenie płatnicze | Unikalne identyfikatory, zamówienie, kwota, waluta, stan, wynik weryfikacji, daty i wynik przetworzenia. |
| Daty obsługi | Daty złożenia, rozpoczęcia oceny, zwrotu, ponownego przekazania i zakończenia; bez wyliczanej daty wymaganej odpowiedzi. |
| Powiadomienie | Typ, zdarzenie źródłowe, odbiorca, stan, próby, błąd i data wysłania. |
| Synchronizacja katalogowa | Sprawa, względna ścieżka katalogu, numer ostatniej kompletnej rewizji, rewizja oczekująca, stan i czas zapisu oraz ostatni błąd. |
| Dziennik operacji | Kto, kiedy, jaka operacja, sprawa/wersja, wynik i uzasadnienie; bez sekretów i pełnej treści dokumentów. |

Reguły spójności:

- Jedna sprawa należy do jednego klienta. Współdzielenie i przenoszenie własności są poza MVP.
- Załącznik wskazany w przekazaniu należy do tej sprawy; identyfikator pliku z innej sprawy jest odrzucany.
- Uzupełnienie tworzy nową wersję treści, ale nie nowe zamówienie. Kolejne wersje zachowują powiązanie z pierwotnie opłaconą sprawą.
- Decyzja wskazuje numer wersji. Serwer sprawdza, czy status i wersja nie zmieniły się od otwarcia ekranu operatora.
- Zapis przekazania i przejście statusu są spójne; decyzja końcowa, blokada edycji i planowanie powiadomienia nie mogą pozostawić półwykonanej operacji.
- Pełna historia nie oznacza przechowywania bez końca: reguły usuwania danych obejmują wersje, pliki, logi i kopie zgodnie z ustaloną retencją.

### 10.2 Dodatkowy zapis katalogowy na dysku serwera

#### Lokalizacja i identyfikacja

Oprócz danych przechowywanych przez aplikację w bazie i prywatnym magazynie system utrwala dodatkowy, samodzielnie czytelny zapis każdej sprawy na dysku serwera: dane klienta jako JSON oraz kopie jej załączników. Funkcja należy do MVP i obejmuje także zapisane szkice oraz robocze uzupełnienia.

Przyjęta 14 listopada 2026 r. lokalizacja katalogu głównego to `/srv/wz-portal/sprawy` na VM `101 (wz-portal)`, pod adresem `192.168.3.123`, zgodnie z `ARCHITEKTURA.md`. Konfiguracja aplikacji ma określać `CASE_DATA_ROOT=/srv/wz-portal/sprawy`. Katalog hosta należy trwale podłączyć przez bind mount do tej samej ścieżki w kontenerze `web`; dane muszą przetrwać wymianę kontenera. Katalog pozostaje prywatny, bez montowania do Caddy i bez publicznej trasy WWW. Konto aplikacji musi mieć prawo odczytu i zapisu, a dostęp administracyjny przysługuje wyłącznie upoważnionym osobom. Lokalizacja została ustalona; utworzenie katalogu, nadanie uprawnień, montowanie i obsługa zapisu pozostają do wdrożenia.

Każda sprawa ma jeden własny katalog nazwany niezmiennym identyfikatorem systemowym. Zmiana nazwy wniosku nie zmienia ścieżki. Nazwy i ścieżki nie są budowane z tekstu podanego przez klienta. Wszystkie ścieżki muszą pozostać wewnątrz skonfigurowanej lokalizacji; odwołania do cudzych katalogów i wyjście poza katalog główny są niedozwolone.

Proponowany układ, do uszczegółowienia w implementacji:

```text
/srv/wz-portal/sprawy/  # CASE_DATA_ROOT
  <id-sprawy>/
    sprawa.json
    wersje/
      <id-zapisanej-rewizji>.json
    zalaczniki/
      <id-pliku>.<rozszerzenie>
```

#### Zakres JSON i załączników

JSON zawiera także tryb zamówienia p24/mock, stan symulacji i jej identyfikator, aby zapis na dysku nie sugerował rzeczywistej wpłaty dla mocka.

JSON jest zapisywany w UTF-8 i zawiera wersję schematu, identyfikator i numer sprawy, identyfikator rewizji, daty zapisu, status oraz **wszystkie dane wprowadzone przez klienta w ramach sprawy**: nazwę, opis, komentarze do uzupełnień i ewentualny powód wycofania. Zachowuje powiązanie z właścicielem, rundami uzupełnień oraz przekazanymi wersjami. Jeżeli zakres pól klienta zostanie rozszerzony, zapis katalogowy musi objąć również nowe pola. Nie obejmuje niezapisanych znaków pozostających wyłącznie w przeglądarce.

JSON zawiera manifest plików: identyfikator, oryginalną nazwę, względną ścieżkę w katalogu sprawy, typ, rozmiar, sumę kontrolną, datę dodania, wynik kontroli bezpieczeństwa i powiązania z rewizjami. Pliki są kopiowane w oryginalnej postaci, bez konwersji. Dwa pliki o tej samej nazwie klienta nie nadpisują się; oryginalną nazwę zachowuje manifest. Ponownie użyty ten sam obiekt załącznika może być przechowywany raz i wskazywany przez kilka wersji.

Dodatkowy zapis obejmuje również załączniki operatora, robocze i opublikowane, wraz z metadanymi autora, źródłem pliku (klient/operator), stanem publikacji oraz identyfikatorem rundy lub decyzji akceptacji. JSON rozróżnia wersję danych klienta od rewizji publikacji operatora. Dodanie, zastąpienie, usunięcie roboczego pliku operatora i jego publikacja wyzwalają aktualizację zapisu katalogowego. Prywatny zapis roboczy na dysku nie oznacza udostępnienia klientowi. Pliki obu stron trafiają do katalogu tej samej sprawy bez kolizji nazw; usuwanie zgodne z retencją obejmuje również pliki operatora.

`sprawa.json` opisuje aktualny zapisany stan. Niezmienne pliki rewizji pozwalają odczytać wcześniejsze zapisane dane, w tym przekazania i komentarze klienta. Roboczy zapis nie jest mylony z formalnym przekazaniem: JSON rozróżnia rodzaj zapisu i numer przekazania, jeśli istnieje. Usunięcie pliku z aktualnej wersji zmienia manifest, lecz nie usuwa kopii użytej w zachowanej wersji historycznej przed upływem retencji.

Kopia obejmuje zakończone przesłania plików i odnotowuje ich stan kontroli. Plik oczekujący na kontrolę albo odrzucony pozostaje izolowany zgodnie z zasadami kwarantanny; zapis katalogowy nie daje możliwości pobrania go z pominięciem kontroli. Nie kopiujemy haseł, tokenów sesji ani sekretów integracji; zapis danych sprawy nie jest eksportem całego konta klienta.

#### Aktualizacja, spójność i obsługa awarii

Utworzenie sprawy, każdy ręczny zapis, zakończone przesłanie lub zmiana listy plików, przekazanie uzupełnienia i zgłoszenie wycofania wyzwalają aktualizację zapisu katalogowego. Zmiany statusu i usuwanie w ramach retencji również są odzwierciedlane. Nie jest to jednorazowy eksport dopiero przy akceptacji.

Każda aktualizacja ma numer rewizji, a baza przechowuje stan synchronizacji: oczekuje, zakończona albo błąd, ostatnią kompletnie zapisaną rewizję i czas zapisu. Nowsza rewizja nie może zostać zastąpiona starszym zadaniem. Publikacja kompletnej rewizji następuje po zapisaniu wymaganych plików i sprawdzeniu ich zgodności z manifestem. Częściowy zapis lub awaria w trakcie wymiany JSON nie może uszkodzić poprzedniego kompletnego zapisu.

Jeżeli zapis w bazie powiódł się, a dodatkowy zapis na dysku nie, system zachowuje dane i trwale rejestruje konieczność ponowienia. Nie przedstawia takiej operacji jako zakończonej w obu lokalizacjach. Klient widzi stan trwającego lub nieudanego dodatkowego zapisu, a opiekun otrzymuje alarm. Przekazanie do oceny i decyzja końcowa wymagają kompletnego zapisu ocenianej wersji; potwierdzona wpłata nie jest cofana ani pobierana drugi raz wskutek błędu dysku.

Brak miejsca, brak uprawnień, niedostępna lokalizacja i niezgodność sumy kontrolnej są błędami wymagającymi ponowienia lub interwencji. Ponowienie tej samej rewizji nie tworzy kolejnej sprawy ani duplikatów plików. Po awarii lub odtworzeniu system może uzgodnić stan zapisu katalogowego z bazą i ponowić brakujące zapisy; nie nadpisuje danych bazy ręcznymi zmianami plików. Automatyczny import z katalogu nie należy do tego wymagania.

#### Dostęp, retencja i pojemność

Katalog główny jest prywatny, poza katalogiem publicznie serwowanym przez WWW. Dostęp na dysku mają wyłącznie uprawnione konto aplikacji i upoważniona administracja serwera. Uprawnienia do plików sprawdzane w portalu nie są zastępowane przez publiczne linki do kopii katalogowej.

Usuwanie danych obejmuje również cały katalog danej sprawy, jego JSON, historyczne rewizje i kopie załączników, według tych samych zasad co dane główne: 30 dni bezczynności szkicu, 6 miesięcy od zakończenia oraz odrębna reguła nieopłaconych spraw. Nie pozostawiamy kopii po usunięciu danych z aplikacji. Ponowne otwarcie przed usunięciem wstrzymuje usuwanie obu zapisów. Rejestr usunięć zapobiega odtworzeniu katalogu przez opóźnione zadanie synchronizacji lub po odtworzeniu kopii.

Fizyczne powielenie załącznika na potrzeby dodatkowego zapisu nie podwaja limitu sprawy 500 MB; ten limit dotyczy wszystkich unikalnych plików klienta i operatora w sprawie. Plan pojemności serwera i monitoring muszą natomiast uwzględniać obie fizyczne kopie, rewizje JSON i przestrzeń tymczasową. Kopia katalogowa na tym samym serwerze nie zastępuje odrębnego planu kopii zapasowych i odtwarzania.

## 11. Wymagania niefunkcjonalne

Parametry oznaczone jako proponowane wymagają potwierdzenia zgodnie z sekcją 13. Ustalone limity, okresy retencji i metody dostępu obowiązują zgodnie z opisem. Wymagania nie stanowią potwierdzenia aktualnego wdrożenia.

| ID | Obszar | Wymaganie / sposób odbioru |
|---|---|---|
| NF-01 | Dostęp — M | Kontrola każdej operacji, pliku i wersji. Test klienta A próbującego czytać/zmieniać sprawę B i klienta próbującego wykonać akcję operatora. |
| NF-02 | Bezpieczeństwo — M | Publiczny HTTPS, bezpieczne sesje, ochrona żądań zmieniających dane, ograniczenie nadużyć, sekrety poza kodem i logami. Panel personelu przez VPN; operatorzy i administrator logują się indywidualnym loginem i hasłem. MFA nie jest wymaganiem obecnego zakresu. |
| NF-03 | Pliki — M | Prywatny magazyn, limity, kontrola typu i zagrożeń. Niedostępność kontroli pozostawia kwarantannę; brak wykonywania treści pliku. |
| NF-04 | Integralność — M | Wersjonowanie, wykrywanie konfliktów, idempotentne płatności i decyzje. Test podwójnego kliknięcia i konkurencyjnych akcji. |
| NF-05 | Użyteczność — M | Język polski; ekran telefonu 360 px bez przewijania poziomego formularza; klawiatura, etykiety, fokus, czytelne błędy niezależne od koloru. |
| NF-06 | Wydajność — M | Skala 10 nowych spraw/dzień; proponowany test 20 aktywnych sesji i 4000 spraw. 95% zwykłych odczytów/zapisów do 2 s po stronie aplikacji, bez plików i usług zewnętrznych. |
| NF-07 | Dostępność — M | Proponowany cel 99% miesięcznie poza ogłoszonymi pracami, pomiar z zewnątrz. Osobna VM nie usuwa wspólnego ryzyka hosta, zasilania i łącza. |
| NF-08 | Kopie — M; szczegóły odłożone | Cel: możliwość odtworzenia bazy, plików i konfiguracji. Miejsce, częstotliwość, retencja kopii, RPO/RTO i harmonogram testów zostaną ustalone później. Plan odtwarzania wymaga zatwierdzenia przed uruchomieniem produkcyjnym. |
| NF-09 | Monitoring — M | Alarmy niedostępności, błędów kopii/poczty i dodatkowego zapisu katalogowego, niewyjaśnionych wpłat i braku miejsca na VM oraz hoście. Proponowane progi miejsca 75% i 85%. Opiekunem i odbiorcą alarmów jest właściciel projektu (użytkownik); adres kontaktowy do konfiguracji później. |
| NF-10 | Pojemność — M | Pomiar przyrostu wraz z historią wersji. Przy 10 sprawach/dzień po 30 MB samych plików przyrost to ok. 109,5 GB/rok; początkowe 40 GiB VM wymaga planu rozbudowy. Dodatkowy zapis katalogowy powiela fizyczne załączniki i wymaga osobnego uwzględnienia w kalkulacji wraz z rewizjami JSON. |
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
| AT-04 | SU-006,014 | Tryb P24 i brak skonfigurowanej ceny: brak płatności i darmowego przekazania; szkic nadal możliwy. Wyjątek mock testowany w AT-59. |
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
| AT-49 | NF-12 | Pierwszy pilotaż obejmuje fikcyjne sprawy, testowe pliki i płatności mock; odrębne testy integracji korzystają z sandboxa P24. Oddzielne konta klienta, operatora i administratora przechodzą złożenie, uzupełnienia, decyzje, wycofanie i wznowienie; brak rzeczywistych obciążeń klienta. |
| AT-50 | SU-036,003 | Utworzenie i ręczny zapis szkicu tworzą jeden katalog sprawy, poprawny JSON UTF-8 i zapis plików. Zmiana nazwy nie zmienia katalogu; manifest wskazuje właściwe pliki i sumy kontrolne. |
| AT-51 | SU-036,009 | Uzupełnienie, komentarz, zastąpienie pliku i prośba o wycofanie aktualizują zapis. Pliki o tej samej nazwie nie nadpisują się; stare przekazania i ich pliki pozostają czytelne. |
| AT-52 | SU-036 | Brak miejsca, uprawnień lub przerwanie zapisu: brak fałszywego potwierdzenia kompletnego zapisu, zachowane dane i poprzednia kompletna rewizja, widoczny błąd i alarm. Ponowienie uzupełnia zapis bez duplikatów, starsze zadanie nie cofa nowszej rewizji. |
| AT-53 | SU-036,024 | Retencja lub usunięcie szkicu usuwa także katalog z JSON i plikami. Opóźniona synchronizacja nie odtwarza usuniętych danych; ponowne otwarcie przed usunięciem chroni oba zapisy. |
| AT-54 | SU-036, NF-01 | Kopia katalogowa nie jest dostępna publicznie, nazwa klienta nie pozwala wyjść poza katalog sprawy, kwarantanna nadal obowiązuje. Wymiana kontenera zachowuje pliki na dysku serwera. |
| AT-55 | SU-037,008 | Operator dodaje plik do rundy uzupełnień: przed publikacją klient go nie widzi. Publikacja uwag udostępnia plik przy właściwej rundzie, pokazuje autora i datę; e-mail informuje o pliku, bez załączania go do wiadomości. |
| AT-56 | SU-037,010,031 | Operator przygotowuje pliki do akceptacji: anulowanie potwierdzenia pozostawia je nieopublikowane. Potwierdzona akceptacja publikuje decyzję i pliki razem; klient pobiera je mimo blokady edycji zakończonej sprawy. |
| AT-57 | SU-037,004,013 | Plik nieprzeskanowany, przekroczony limit lub nieaktualny status blokuje publikację. Klient innej sprawy nie może pobrać dokumentu; klient właściwy nie może go zastąpić ani usunąć. |
| AT-58 | SU-037,036,024 | Plik operatora i manifest JSON trafiają do katalogu tej samej sprawy z autorem, stanem i powiązaniem do publikacji. Ponowna publikacja zachowuje stare pliki; dodatkowa kopia nie podwaja limitu, retencja usuwa również pliki operatora. |
| AT-59 | SU-038 | Mock włączony, brak kluczy P24 i ceny handlowej: poprawna sprawa otrzymuje lokalną symulację i trafia do weryfikacji. Brak przekierowania, żądań P24 i pobrania pieniędzy; dwukrotne kliknięcie daje jedno przekazanie. |
| AT-60 | SU-038,027,037 | W mocku przechodzimy uzupełnienia, publikację plików operatora, akceptację, zakończenie bez akceptacji, wycofanie i wznowienie. Wszystkie reguły uprawnień i zapisu pozostają aktywne, brak ponownej opłaty; UI, e-maile, historia i JSON wskazują symulację. |
| AT-61 | SU-038,006 | Mock wyłączony lub nieustawiony: działa ścieżka P24, brak ceny lub błąd operatora nie uruchamia symulacji. Klient nie może włączyć mocka przez pole formularza ani parametr żądania. |
| AT-62 | SU-038 | Zmiana konfiguracji w obie strony nie zmienia trybu istniejących zamówień. Późne potwierdzenie rzeczywistej wpłaty jest obsługiwane; testowa sprawa nie staje się przychodem, nie wymaga opłaty po wyłączeniu mocka ani nie wygasa jako nieopłacona po 30 dniach. |
| AT-63 | SU-039,001, NF-01 | Gość otwiera główny adres portalu: widzi wizytówkę i nawigację, nie widzi spraw ani plików. Wezwanie do złożenia i skrót do własnych spraw prowadzą do logowania; sekcje oferty, procesu i kontaktu są osiągalne. |
| AT-64 | SU-039,032 | Logo z pozostałych ekranów prowadzi do Homepage; zapisane dane pozostają. Przy niezapisanej edycji działa ostrzeżenie. Na ekranie 360 px i klawiaturą dostępne są nawigacja i główne przyciski bez poziomego przewijania. |
| AT-65 | SU-039,038,016 | Strona główna w mocku wskazuje symulację, bez kwoty handlowej zmyślonej na potrzeby makiety. W trybie rzeczywistym cena pochodzi z konfiguracji; brak adresu kontaktowego nie tworzy fikcyjnego mailto ani wysyłki. |

## 13. Decyzje odłożone i parametry do doprecyzowania

### 13.1 Decyzje biznesowe i wdrożeniowe

| Obszar | Stan i wymagane rozstrzygnięcie |
|---|---|
| Cena | Kwota końcowa za sprawę zostanie ustalona później. Wymagana konfiguracja dodatniej ceny przed sprzedażą; cena testowa nie ustala ceny handlowej. |
| Rozliczenia | Do ustalenia zasady rozliczenia zakończenia bez akceptacji, wycofania, nadpłat i wyjątków płatniczych. Sam status sprawy nie zleca zwrotu ani nie oznacza bezzwrotności opłaty. |
| Dokument sprzedaży | Do ustalenia obsługa nabywców prywatnych i firm, zakres danych rozliczeniowych, sposób wystawienia dokumentu i jego retencja. Rozliczanie poza portalem z powiązaniem do zamówienia pozostaje propozycją. |
| Domena | Nazwa produktu to Portal spraw; domena zostanie ustalona później. |
| Lokalizacja danych spraw | Ustalona: `/srv/wz-portal/sprawy` na VM `101 (wz-portal)`, z `CASE_DATA_ROOT=/srv/wz-portal/sprawy` i trwałym bind mount do tej samej ścieżki w `web`. Utworzenie katalogu, uprawnienia, montowanie i obowiązkowy dodatkowy zapis JSON oraz załączników SU-036 pozostają do wdrożenia zgodnie z sekcją 10.2. |
| Skrzynka | Jedna skrzynka do wysyłki, powiadomień zespołu i kontaktu; adres i konfiguracja do ustalenia. Osobno skonfigurować adresy odbiorców personelu i opiekuna. |
| Kopie i odtwarzanie | Miejsce, częstotliwość, szyfrowanie, retencja kopii, RPO/RTO i harmonogram testów wymagają ustalenia przed produkcją. |
| Treści oferty | Przed sprzedażą zatwierdzić opis usługi, zasady przetwarzania danych i warunki zakupu spójne z ogólną listą kontrolną oceny. |

### 13.2 Szczegóły projektowe i techniczne

Do doprecyzowania przy projektowaniu lub implementacji pozostają: czas ważności tokenu resetu hasła (proponowane 60 minut), sposób utrwalania nazwy wyświetlanej operatora w historii, potwierdzanie listy kontrolnej, reakcja na brak adresu lub aktywnego konta prowadzącego oraz szczegóły walidacji ponownego przekazania bez zmian poza komentarzem.

Wartości niefunkcjonalne opisane jako propozycje obejmują test 20 aktywnych sesji i 4000 spraw, czas odpowiedzi do 2 s dla 95% zwykłych operacji, dostępność 99% oraz progi alarmowe miejsca 75% i 85%. Wymagają potwierdzenia przed przedstawieniem ich jako parametrów gwarantowanych.

Przy implementacji trzeba określić techniczną jednostkę limitów MB, spójny sposób liczenia znaków, zasady dodawania miesięcy kalendarzowych i harmonogram zadań retencji. Nie zmienia to ustalonych limitów: 20 MB/plik, 20 plików i 100 MB/przekazanie, 500 MB historii, 6 miesięcy spraw zakończonych, 30 dni bezczynności szkiców i 90 dni logów.

### 13.3 Funkcje poza pierwszą wersją

Porównanie wersji ze wskazywaniem różnic (SU-018), automatyczny zapis, szablony uwag i wyszukiwanie w całych opisach można rozważyć po pilotażu. W pierwszej wersji wystarcza odczyt obu wersji, zapis ręczny oraz wyszukiwanie według parametrów kolejki. Logowanie klienta jednorazowym linkiem e-mail pozostaje poza zakresem.

## 14. Założenia techniczne i przygotowanie wdrożenia

Jedna aplikacja Django, baza PostgreSQL, Caddy/Gunicorn oraz osobna maszyna wirtualna stanowią założenie techniczne dla skali do 10 nowych spraw dziennie. Wymagane są prywatny magazyn plików, dodatkowy zapis katalogowy JSON i załączników na dysku serwera z trwałym montowaniem oraz integracje logowania, płatności i poczty, zadania przypomnień i retencji oraz kontrola uprawnień i spójności procesu.

Publiczny portal i endpoint potwierdzeń płatności działają przez HTTPS. Panel personelu jest dostępny przez VPN, który nie może blokować endpointu operatora płatności. Opiekunem utrzymania i odbiorcą alarmów jest właściciel projektu.

[ARCHITEKTURA.md](ARCHITEKTURA.md) jest materiałem odniesienia dla istniejącej infrastruktury. Jego opis biznesowy wymaga dostosowania do niniejszej specyfikacji; aktualność konfiguracji i zasobów trzeba sprawdzić przed wdrożeniem.

Przed migracją należy zinwentaryzować istniejące modele, sprawy, pliki i wpłaty. Jeśli są dane: wykonać kopię, migrację testową, kontrolę powiązań i plan wycofania. Nie wolno automatycznie nadpisywać historycznych cen ani utożsamiać dawnych statusów z nowymi decyzjami końcowymi.

## 15. Kolejność realizacji i kryteria gotowości

1. Domknąć kwotę przed sprzedażą, zasady rozliczenia, plan kopii i retencję dokumentów rozliczeniowych; ustalić domenę i adres jednej skrzynki, skonfigurować adresy operatorów i opiekuna. Nie obiecywać terminów obsługi.
2. Zbudować formularz nazwa–opis–załączniki, szkic i kontrolę dostępu.
3. Dodać wersje, stany, kolejkę operatora, zwrot do uzupełnienia, końcową akceptację i zakończenie bez akceptacji oraz publikację załączników operatora dla klienta. Wdrożyć dodatkowy zapis JSON i załączników w katalogach spraw oraz obsługę błędów synchronizacji.
4. Dodać jedno zamówienie, P24, uzgadnianie wyjątków i e-maile z ponowieniami.
5. Sprawdzić scenariusze AT-01–AT-65, kopie, odtwarzanie, monitoring i pojemność. Brak konfiguracji ceny w trybie P24 nie może otworzyć bezpłatnej ścieżki; świadomie włączony mock ma być oznaczony jako testowy.
6. Najpierw pilotaż na fikcyjnych sprawach i lokalnym mocku płatności; testy integracji P24 osobno w sandboxie, z właścicielem projektu korzystającym z oddzielnych kont klienta, operatora i administratora. Zakres obejmuje złożenie, uzupełnienia, akceptację, zakończenie bez akceptacji, wycofanie i ponowne otwarcie. Proponowana liczba: 5–10 spraw. Skonfigurowana testowa cena służy wyłącznie symulacji i nie ustala ceny handlowej.
7. Płatny pilotaż dopiero po ustaleniu ceny, rozliczeń i gotowości produkcyjnej, w tym domeny, poczty oraz kopii. Przed przełączeniem sprawdzić konfigurację środowiska i rozdzielenie transakcji testowych od rzeczywistych. Mierzyć liczbę rund, czas oceny, problemy z plikami i płatnościami; rozwijać funkcje na podstawie wyników.

**Gotowość płatnego MVP:** ustalona i skonfigurowana cena, zrozumiała oferta, zatwierdzone zasady obsługi wyjątków i danych, wymagane pola i pliki, uprawnienia, spójne wersje/statusy, poprawne płatności, powiadomienia, odtworzenie i zaakceptowane scenariusze odbioru. Zmiana specyfikacji nie oznacza wykonania tych prac ani uruchomienia produkcyjnego.
