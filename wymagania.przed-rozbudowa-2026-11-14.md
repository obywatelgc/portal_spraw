# 1. Cel dokumentu
Celem dokumentu jest opisanie wymagań funkcjonalnych i niefunkcjonalnych dla systemu przyjmowania wniosków dotyczących warunków zabudowy.


# 2. Słownik pojęć


# 3. Wizja rozwiązania

Portal (strona www) ma zbierać od klientów dane i dokumenty potrzebne pracownikowi do przygotowania wniosku o warunki zabudowy. **Sprawę inicjuje klient**. Planowana skala to maksymalnie 10 nowych wniosków dziennie. Końcowym rezultatem procesu w portalu jest potwierdzenie kompletności materiałów. Przygotowanie dokumentu urzędowego i jego złożenie pozostają po stronie pracownika.

Przy tej skali przyjęto jedną aplikację Django i jedną relacyjną bazę danych. Formularze klienta i funkcje pracownika mogą korzystać z tego samego modelu sprawy, zasad walidacji i historii zmian. Osobna maszyna wirtualna pozwala aktualizować i restartować portal niezależnie od działającej na tym samym Dellu maszyny Home Assistant. Obie VM współdzielą jednak fizyczny dysk, pamięć, zasilanie i dostęp do sieci.

## 3.1 Docelowy proces obsługa sprawy

| Etap | Użytkownik i czynność | Wynik |
|---|---|---|
| Wejście do portalu | Klient loguje się przez Google lub Facebook i otwiera „Moje wnioski”. | Widzi sprawy przypisane do swojego konta. |
| Rozpoczęcie | Klient wybiera „Nowy wniosek o warunki zabudowy”. | Powstaje szkic z przypisanym właścicielem. |
| Zebranie danych | Klient podaje dane wnioskodawców, działki, opis inwestycji, dostęp do drogi i mediów oraz dodaje załączniki. | Zapis poszczególnych kroków pozwala wznowić pracę po ponownym logowaniu. |
| Przekazanie | Klient sprawdza podsumowanie. Aplikacja waliduje wymagane pola i zapisuje przekazaną wersję. | Klient otrzymuje potwierdzenie z numerem sprawy. Status przechodzi na „Do weryfikacji”. |
| Uzupełnienie | Pracownik wskazuje pola lub dokumenty do poprawy. Klient otrzymuje e-mail, poprawia dane i ponownie je przekazuje. | „Do uzupełnienia” → „Do weryfikacji”. Wcześniejsza wersja pozostaje w historii. |
| Zamknięcie weryfikacji | Pracownik potwierdza kompletność materiałów. | Klient widzi status „Dane kompletne”. |

**Model danych do wdrożenia.** Konto klienta może mieć wiele spraw. Sprawa łączy wnioskodawców, działki, dane inwestycji, metadane załączników, przekazane wersje odpowiedzi i historię statusu. Dane wnioskodawcy są osobnymi polami formularza, ponieważ właściciel konta może przygotowywać materiały dla innej osoby. Każdy odczyt, zapis i pobranie załącznika wymaga sprawdzenia uprawnienia do danej sprawy.



# 4. Wymagania funckjonalne
## 4.1 Portal Klienta 
RQ-001 Strona logowania


RQ-002 Dashboard

RQ-003 Lista wniosków

RQ-004 Nowy wniosek



RQ-005 Płatność za usługę
Przebieg procesu:
1. Klient uzupełnia wniosek i widzi podsumowanie oraz cenę.
2. Klika „Zapłać i przekaż do weryfikacji”.
3. Portal zapisuje wersję wniosku oraz próbę płatności i przekierowuje do Przelewy24.
4. Klient płaci wybraną metodą.
5. Po potwierdzeniu przez P24 portal oznacza opłatę jako uregulowaną i przekazuje sprawę pracownikowi.
6. Jeśli klient przerwie płatność, wniosek pozostaje zapisany i można ponowić próbę.
Przyjmujemy integrację z Przelewy24.

## 4.2 Panel administracyjny pracownika
lista wniosków z możliwością filtrowania i sortowania 
obsługa wniosku - zmiana statusu

# Wymagania niefunkcjonlane