# Dokument Projektowy Gry (GDD) – *The Last Warship*

## 1. Informacje Ogólne o Projekcie
* **Tytuł roboczy:** The Last Warship
* **Gatunek:** Rogue-like / Akcja / Przetrwanie (Survival)
* **Klimat / Stylistyka:** Wojenny, Low-Fantasy (mroczny realizm morski z elementami nadprzyrodzonymi)
* **Perspektywa:** Top-down (widok z góry), kamera zablokowana na graczu (gracz zawsze w centrum ekranu)
* **Platforma docelowa:** PC (Sterowanie: Klawiatura + Mysz)
* **Główny cel rozgrywki:** Przetrwać jak najdłużej, odpierając hordy wrogów, eliminując bossów, ulepszając okręt i zdobywając jak najwyższy wynik punktowy. Gra kończy się bezpowrotną śmiercią gracza (permadeath).

---

## 2. Rdzeń Rozgrywki (Core Gameplay Loop)
Rozgrywka opiera się na dynamicznej pętli:
1. **Nawigacja i Walka:** Gracz steruje okrętem wojenny po nieskończonym, generowanym proceduralnie oceanie usianym wyspami i portami. Odpiera nieustannie spawnujące się fale wrogów.
2. **Zbieranie Łupów:** Pokonani przeciwnicy upuszczają punkty doświadczenia (XP) oraz skrzynie ze złotem.
3. **Rozwój i Skalowanie:** Po zebraniu odpowiedniej ilości XP następuje zatrzymanie czasu i wybór nowej umiejętności lub ulepszenia.
4. **Handel w Portach:** Gracz może zadokować w bezpiecznych portach, aby wydać złoto na permanentne (w skali danego podejścia) ulepszenia kadłuba i dział.
5. **Wydarzenia Losowe:** Świat reaguje na czas rozgrywki poprzez nagłe anomalie pogodowe i środowiskowe, zmuszając do ciągłej zmiany taktyki.

---

## 3. System Walki i Mechanika Postaci (Actor System)

Każda jednostka w grze (zarówno Gracz, jak i Przeciwnik/Boss) jest traktowana jako **Actor** i posiada określony zestaw statystyk oraz zachowań.

### 3.1. Statystyki Bazowe Aktora
* **Punkty Życia (HP):** Aktualna i maksymalna wytrzymałość okrętu. Gdy spadnie do 0, jednostka zostaje zniszczona.
* **Atak (ATK):** Modyfikator bazowych obrażeń zadawanych przez pociski i umiejętności.
* **Prędkość (SPD):** Szybkość poruszania się okrętu po wodzie.
* **Prędkość obrotu (T_SPD):** Zwrotność - jak szybko okręt może zmienić kierunek.

### 3.2. Kategorie Ataków i Umiejętności
Wszystkie ataki posiadają zdefiniowane parametry: **czas odnowienia (cooldown)**, **zasięg**, **obrażenia**, **animację wystrzału** oraz **efekt wizualny/cząsteczkowy (VFX)**.

#### A. Atak Automatyczny (Auto-attack)
* **Gracz:** Działa burtowe i dziobowe strzelają automatycznie w najbliższych przeciwników w zasięgu. Szybkość ataku (częstotliwość) skaluje się bezpośrednio z czasem odnowienia (cooldown). Celowanie bazowe może być wspomagane automatycznie lub podążać za ogólnym kierunkiem poruszania się.
* **Komputer (AI):** Przeciwnicy oddają salwy automatycznie, gdy tylko gracz znajdzie się w ich zasięgu bojowym.

#### B. Atak Dodatkowy (Secondary Attack)
* **Gracz:** Wyzwalany ręcznie za pomocą **kliknięcia myszy** (domyślnie LPM lub PPM). Przykładem jest *Torpeda* – potężny pocisk podwodny poruszający się w linii prostej w kierunku kursora myszy, zadający obrażenia obszarowe.
* **Komputer (AI):** Przeciwnicy elitarni odpalają atak dodatkowy losowo lub po spełnieniu warunku odległości, z widocznym dla gracza wskaźnikiem trajektorii (telegrafowanie ataków).

#### C. Umiejętności Aktywne (Skills)
* **Gracz:** Aktywowane za pomocą przycisków myszy. Mają długie czasy odnowienia i potężny wpływ na pole bitwy (np. *Magiczny Strzał*, *Naprawa Awaryjna*).
* **Komputer (AI):** Używane głównie przez Bossów. Odpalane losowo w cyklach czasowych lub przy niskim poziomie zdrowia (np. tarcza energetyczna, wezwanie posiłków).

---

## 4. Przeciwnicy, Bossowie i Skalowanie Trudności

Poziom trudności rośnie nieliniowo wraz z upływem czasu gry. Zwiększa się częstotliwość spawnu, liczebność hord oraz statystyki bazowe wrogów.

### 4.1. Typy Przeciwników (Hordy)
1. **Szybki Kuter:** Podstawowy przeciwnik - mało HP, bardzo wysoka prędkość. Atak podstawowymi strzałami.
2. **Korweta Rakietowa:** Średnie statystyki, wyposażona w wyrzutnie rakiet.
3. **Poduszkowiec tarannujący:** Próbuje taranować gracza. Dużo HP, wolny, ale z umiejętnością Charge - szarży z gwałtownym przyspieszeniem.
3. **Pancernik Liniowy:** Boss - Dużo HP i wysoka obrona, powolny, strzela rzadko, ale potężnymi salwami dalekiego zasięgu.

### 4.2. System Bossów
Co określony interwał czasowy (np. co 5 minut) na mapie pojawia się unikalny **Boss** – gigantyczny okręt flagowy o stylistyce low-fantasy.
* **Cechy Bossa:** Ogromna pula HP, potężny atak, mała prędkość. Stara się ustawić bokiem do gracza by strzelać salwą ze wszystkich dział.
* **Nagroda za pokonanie:** Bardzo duży zastrzyk punktów doświadczenia, ogromna ilość złota.

---

## 5. Progresja, Poziomowanie i Porty

### 5.1. System Awansu (Leveling) i Umiejętności
Gdy wrogi okręt zostaje zniszczony, gracz otrzymuje XP (punkty doświadczenia)
* **Ekran Awansu:** Po zapełnieniu paska doświadczenia następuje **całkowite zatrzymanie czasu gry**.
* Na ekranie pojawia się losowy wybór 3 lub 4 kart umiejętności/modyfikatorów.
* Gracz może wydać zdobyte Punkty Umiejętności (Skill Points) na odblokowanie nowej zdolności aktywnej lub ulepszenie już istniejącej (np. *Zwiększenie zasięgu torped o 15%*, *Dodatkowy pocisk w salwie automatycznej*).

### 5.2. Porty i Panel Ulepszeń (Sklep)
Na mapie świata generują się neutralne wyspy z Portami. Gracz może do nich podpłynąć, aby wejść w bezpieczną strefę.
* Interakcja z portem **zatrzymuje czas rozgrywki** i otwiera interfejs sklepu.
* Walutą jest **Złoto** wypadające z przeciwników.
* **Skalowanie cen:** Każdy kolejny zakup tego samego ulepszenia (np. +10% Max HP, +5% Prędkości) zwiększa koszt następnego poziomu.
* W porcie można również zakupić przedmioty jednorazowe (Consumables), takie jak *Zestawy Naprawcze* czy *Miny Morskie*.

---

## 6. Zdarzenia Losowe i Środowiskowe (Environmental Hazards)

Świat gry nie jest statyczny. W losowych odstępach czasu system gry (Director AI) wywołuje zdarzenia losowe, które trwają przez określony czas i są sygnalizowane alertem na ekranie.

| Nazwa Zdarzenia | Typ | Opis Mechaniczny | Wpływ na rozgrywkę |
| :--- | :--- | :--- | :--- |
| **Morskie Tornado** | Pogodowe | Na mapie pojawiają się ruchome trąby powietrzne. | Wciągają okręty (gracza i wrogów), zadają ciągłe obrażenia i drastycznie zmieniają kurs statku. |
| **Pole minowe** | Ofensywne | Wokół gracza pojawiają się miny morskie, które eksplodują przy wpłynęciu na nie | Przeciwnicy nie aktywują min. |
---

## 7. Interfejs Użytkownika (UI / HUD)
* **Główny ekran:**
  * Górna część: Pasek postępu poziomu (XP) oraz Duży wskaźnik HP okrętu.
  * Lewy dolny róg: Ikony umiejętności aktywnych wraz z graficznym zegarem odliczającym cooldown.
  * Lewy górny róg: Licznik posiadanego złota.
* **Minimapa: (Opcjonalnie)** Uproszczony radar w rogu ekranu, wskazujący kierunek do najbliższego Portu oraz pozycję nadciągającego Bossa.

## 8. Warunki Końca Gry i Punktacja
Gra nie ma z góry zdefiniowanego końca (endless mode). Kończy się w momencie utraty wszystkich punktów HP przez gracza. 
* **Wynik końcowy (Score)** obliczany jest na podstawie czasu przeżycia i ilości zabitych przeciwników
* Po śmierci wyświetla się ekran podsumowania z listą zdobytych osiągnięć i statystykami z danej rundy.
