-- wczesniej CREATE DATABASE hurtownia;
USE hurtownia;

DROP TABLE IF EXISTS Zdarzenie_na_trasie;
DROP TABLE IF EXISTS Odcinek_kursu;
DROP TABLE IF EXISTS Kolejnosc_odcinkow;
DROP TABLE IF EXISTS Junk_zdarzenie;
DROP TABLE IF EXISTS Junk_odcinek_kursu;
DROP TABLE IF EXISTS Czas;
DROP TABLE IF EXISTS Data;
DROP TABLE IF EXISTS Zdarzenie;
DROP TABLE IF EXISTS Przejazd;
DROP TABLE IF EXISTS Kurs;
DROP TABLE IF EXISTS Stacja;
DROP TABLE IF EXISTS Maszynista;
DROP TABLE IF EXISTS Pociag;

CREATE TABLE Pociag (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nazwa VARCHAR(20) NOT NULL,
    typ_pociagu VARCHAR(30) NOT NULL,
    przewoznik VARCHAR(40) NOT NULL
);

CREATE TABLE Maszynista (
    id INT IDENTITY(1,1) PRIMARY KEY,
    imie VARCHAR(30) NOT NULL,
    nazwisko VARCHAR(30) NOT NULL,
    plec VARCHAR(10) NOT NULL CHECK (plec IN ('man', 'woman')),
    kategoria_wiekowa VARCHAR(30) NOT NULL,
    doswiadczenie_pracy VARCHAR(30) NOT NULL,
    pesel CHAR(11) NOT NULL,
    czy_aktualne BIT NOT NULL,
    CONSTRAINT chk_pesel_format CHECK (pesel LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
);

CREATE TABLE Stacja (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nazwa VARCHAR(40) NOT NULL,
    miasto VARCHAR(40) NOT NULL
);

CREATE TABLE Kurs (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nazwa_trasy VARCHAR(40) NOT NULL,
    kategoria_opoznienia VARCHAR(40) NOT NULL
);

CREATE TABLE Przejazd (
    id INT IDENTITY(1,1) PRIMARY KEY,
    czy_rogatki BIT NOT NULL,
    czy_sygnalizacja_swietlna BIT NOT NULL,
    czy_oswietlony BIT NOT NULL,
    dopuszczalna_predkosc VARCHAR(30) NOT NULL
);

CREATE TABLE Zdarzenie (
    id INT IDENTITY(1,1) PRIMARY KEY,
    typ_zdarzenia VARCHAR(30) NOT NULL,
    kategoria VARCHAR(40) NOT NULL,
    skala_niebezpieczenstwa VARCHAR(40) NOT NULL
);

CREATE TABLE Data (
    id INT IDENTITY(1,1) PRIMARY KEY,
    rok INT NOT NULL,
    miesiac VARCHAR(20) NOT NULL,
    numer_miesiaca INT NOT NULL,
    pora_roku VARCHAR(20) NOT NULL,
    dzien_tygodnia VARCHAR(20) NOT NULL,
    dzien INT NOT NULL
);

CREATE TABLE Czas (
    id INT IDENTITY(1,1) PRIMARY KEY,
    godzina INT NOT NULL,
    minuta INT NOT NULL,
    pora_dnia VARCHAR(10) NOT NULL
);

CREATE TABLE Junk_odcinek_kursu (
    id INT IDENTITY(1,1) PRIMARY KEY,
    typ_opadow VARCHAR(20) NOT NULL
);

CREATE TABLE Junk_zdarzenie (
    id INT IDENTITY(1,1) PRIMARY KEY,
    czy_interwencja_sluzb BIT NOT NULL
);

CREATE TABLE Kolejnosc_odcinkow (
    id INT IDENTITY(1,1) PRIMARY KEY,
    numer_etapu INT NOT NULL UNIQUE,
);

CREATE TABLE Odcinek_kursu (
    id INT IDENTITY(1,1) PRIMARY KEY,
    id_kurs INT NOT NULL REFERENCES Kurs(id),
    id_pociag INT NOT NULL REFERENCES Pociag(id),
    id_stacja_wyjazdowa INT NOT NULL REFERENCES Stacja(id),
    id_stacja_wjazdowa INT NOT NULL REFERENCES Stacja(id),
    id_maszynista INT NOT NULL REFERENCES Maszynista(id),
    id_planowa_data_przyjazdu INT NOT NULL REFERENCES Data(id),
    id_planowa_data_odjazdu INT NOT NULL REFERENCES Data(id),
    id_planowy_czas_przyjazdu INT NOT NULL REFERENCES Czas(id),
    id_planowy_czas_odjazdu INT NOT NULL REFERENCES Czas(id),
    id_junk INT NOT NULL REFERENCES Junk_odcinek_kursu(id),
    id_kolejnosc_odcinkow INT NOT NULL REFERENCES Kolejnosc_odcinkow(id),
    temperatura FLOAT,
    roznica_czasu INT,
    ilosc_opadow INT
);

CREATE TABLE Zdarzenie_na_trasie (
    id_odcinek_kursu INT NOT NULL REFERENCES Odcinek_kursu(id),
    id_przejazd INT NOT NULL REFERENCES Przejazd(id),
    id_zdarzenie INT NOT NULL REFERENCES Zdarzenie(id),
    id_junk INT NOT NULL REFERENCES Junk_zdarzenie(id),
    id_data_zdarzenia INT NOT NULL REFERENCES Data(id),
    id_czas_zdarzenia INT NOT NULL REFERENCES Czas(id),
    koszt_naprawy FLOAT,
    predkosc INT,
    wywolane_opoznienie INT,
    liczba_rannych INT,
    liczba_zgonow INT,
    PRIMARY KEY (id_odcinek_kursu, id_przejazd, id_zdarzenie, id_junk, id_data_zdarzenia, id_czas_zdarzenia)
);

INSERT INTO Pociag (nazwa, typ_pociagu, przewoznik) VALUES
('KM 6153', 'passenger', 'Koleje Mazowieckie'),
('IC 7624', 'passenger', 'PKP Intercity'),
('KS 6176', 'passenger', 'Koleje Śląskie'),
('IC 8234', 'passenger', 'PKP Intercity'),
('KM 4536', 'passenger', 'Koleje Mazowieckie'),
('KD 6552', 'passenger', 'Koleje Dolnośląskie'),
('PR 51652', 'passenger', 'POLREGIO'),
('DB 8384', 'cargo', 'DB Cargo Polska'),
('IC 7680', 'passenger', 'PKP Intercity'),
('IC 6555', 'passenger', 'PKP Intercity'),
('KM 2624', 'passenger', 'Koleje Mazowieckie'),
('PR 60889', 'passenger', 'POLREGIO'),
('ET 2969', 'cargo', 'PKP Cargo'),
('PR 54401', 'passenger', 'POLREGIO'),
('ET 3066', 'cargo', 'PKP Cargo');

INSERT INTO Maszynista (imie, nazwisko, plec, kategoria_wiekowa, doswiadczenie_pracy, pesel, czy_aktualne) VALUES
('Wiktor', 'Kuran', 'man', '25-35', '10-15 lat', '99010112345', 1),
('Kornel', 'Buchalik', 'man', '25-35', '1-5 lat', '99010112346', 1),
('Jacek', 'Pastuszko', 'man', '25-35', '1-5 lat', '99010112347', 1),
('Adrian', 'Amanowicz', 'man', '25-35', '1-5 lat', '99010112348', 1),
('Emil', 'Szachniewicz', 'man', '25-35', '10-15 lat', '99010112349', 1),
('Dominik', 'Brojek', 'man', '25-35', '1-5 lat', '99010112350', 1),
('Albert', 'Korbut', 'man', '55-65', '30+ lat', '99010112351', 1),
('Marta', 'Skoneczna', 'woman', '60+', '30+ lat', '99010112352', 1),
('Maurycy', 'Padło', 'man', '35-45', '25-30 lat', '99010112353', 1),
('Ksawery', 'Pachnik', 'man', '35-45', '15-20 lat', '99010112354', 1);

INSERT INTO Stacja (nazwa, miasto) VALUES
('Stacja Marki', 'Marki'),
('Stacja Elbląg', 'Elbląg'),
('Stacja Szczecin', 'Szczecin'),
('Stacja Koło', 'Koło'),
('Stacja Tarnowskie Góry', 'Tarnowskie Góry'),
('Stacja Tomaszów Mazowiecki', 'Tomaszów Mazowiecki'),
('Stacja Suwałki', 'Suwałki'),
('Stacja Chorzów', 'Chorzów'),
('Stacja Świebodzice', 'Świebodzice'),
('Stacja Dąbrowa Górnicza', 'Dąbrowa Górnicza');

INSERT INTO Kurs (nazwa_trasy, kategoria_opoznienia) VALUES
('Linia 22-93', 'Brak opóźnienia'),
('Linia 48-175', 'Małe opóźnienie'),
('Linia 34-80', 'Brak opóźnienia'),
('Linia 174-93', 'Średnie opóźnienie'),
('Linia 31-62', 'Duże opóźnienie'),
('Linia 116-100', 'Średnie opóźnienie'),
('Linia 33-149', 'Średnie opóźnienie'),
('Linia 70-18', 'Małe opóźnienie'),
('Linia 1-196', 'Duże opóźnienie'),
('Linia 43-22', 'Średnie opóźnienie');

INSERT INTO Przejazd (czy_rogatki, czy_sygnalizacja_swietlna, czy_oswietlony, dopuszczalna_predkosc) VALUES
(1, 1, 1, '35'),
(0, 0, 0, '61'),
(0, 0, 0, '82'),
(0, 1, 1, '52'),
(0, 0, 0, '72'),
(0, 0, 1, '64'),
(1, 0, 1, '58'),
(1, 1, 1, '59'),
(0, 0, 0, '54'),
(0, 0, 0, '38');

INSERT INTO Zdarzenie (typ_zdarzenia, kategoria, skala_niebezpieczenstwa) VALUES
('wypadek', 'potrącenie pieszego', '9'),
('wypadek', 'zderzenie z samochodem', '8'),
('wypadek', 'wykolejenie', '10'),
('wypadek', 'zderzenie z innym pociągiem', '10'),
('incydent', 'opóźnienie organizacyjne', '4'),
('incydent', 'przekroczenie limitu prędkości', '5'),
('incydent', 'problem z pasażerem', '3'),
('awaria', 'usterka hamulców', '7'),
('awaria', 'usterka sygnalizacji', '6'),
('awaria', 'awaria lokomotywy', '7'),
('zdarzenie techniczne', 'planowy postój', '2'),
('zdarzenie techniczne', 'test systemu', '2'),
('zdarzenie techniczne', 'brak maszynisty', '3');

INSERT INTO Data (rok, miesiac, numer_miesiaca, dzien, pora_roku, dzien_tygodnia) VALUES
(2023, 'Styczeń', 1, 1, 'Zima', 'Niedziela'),
(2023, 'Styczeń', 1, 15, 'Zima', 'Niedziela'),
(2023, 'Luty', 2, 20, 'Zima', 'Poniedziałek'),
(2023, 'Marzec', 3, 10, 'Wiosna', 'Piątek'),
(2023, 'Kwiecień', 4, 5, 'Wiosna', 'Środa'),
(2023, 'Maj', 5, 12, 'Wiosna', 'Piątek'),
(2023, 'Czerwiec', 6, 18, 'Lato', 'Niedziela'),
(2023, 'Lipiec', 7, 25, 'Lato', 'Wtorek'),
(2023, 'Sierpień', 8, 8, 'Lato', 'Wtorek'),
(2023, 'Wrzesień', 9, 15, 'Jesień', 'Piątek'),
(2023, 'Październik', 10, 30, 'Jesień', 'Poniedziałek'),
(2023, 'Listopad', 11, 20, 'Jesień', 'Poniedziałek'),
(2023, 'Grudzień', 12, 25, 'Zima', 'Poniedziałek'),
(2024, 'Styczeń', 1, 10, 'Zima', 'Środa'),
(2024, 'Czerwiec', 6, 5, 'Lato', 'Środa');

INSERT INTO Czas (godzina, minuta, pora_dnia) VALUES
(6, 0, 'Rano'),
(7, 30, 'Rano'),
(9, 0, 'Rano'),
(10, 30, 'Rano'),
(12, 0, 'Południe'),
(13, 30, 'Popołudnie'),
(15, 0, 'Popołudnie'),
(16, 30, 'Popołudnie'),
(11, 15, 'Rano'),
(14, 0, 'Popołudnie'),
(15, 30, 'Popołudnie'),
(17, 0, 'Popołudnie'),
(18, 30, 'Wieczór'),
(20, 0, 'Wieczór'),
(21, 30, 'Wieczór'),
(22, 45, 'Noc'),
(22, 30, 'Noc');

INSERT INTO Junk_odcinek_kursu (typ_opadow) VALUES
('brak'),
('deszcz'),
('snieg'),
('grad'),
('deszcz');

INSERT INTO Junk_zdarzenie (czy_interwencja_sluzb) VALUES
(1),
(0);

INSERT INTO Kolejnosc_odcinkow (numer_etapu) VALUES
(1),
(2),
(3),
(4),
(5),
(6),
(7),
(8),
(9),
(10);

INSERT INTO Odcinek_kursu (id_kurs, id_pociag, id_stacja_wyjazdowa, id_stacja_wjazdowa, id_maszynista, id_planowa_data_przyjazdu, id_planowa_data_odjazdu, id_planowy_czas_przyjazdu, id_planowy_czas_odjazdu, id_junk, id_kolejnosc_odcinkow, temperatura, roznica_czasu, ilosc_opadow) VALUES
(1, 1, 1, 2, 1, 1, 1, 1, 2, 1, 1, 2.5, 0, 0),
(1, 1, 2, 3, 1, 1, 1, 2, 3, 1, 2, 2.1, 5, 0),
(1, 1, 3, 4, 1, 1, 1, 4, 5, 1, 3, 1.8, 0, 0),
(1, 1, 4, 5, 1, 1, 1, 6, 7, 1, 4, 1.5, 0, 0),
(2, 2, 1, 3, 2, 2, 2, 10, 11, 2, 1, 3.2, 0, 2),
(2, 2, 3, 5, 2, 2, 2, 11, 12, 2, 2, 2.8, 8, 2),
(2, 2, 5, 7, 2, 2, 2, 13, 14, 2, 3, 3.1, 0, 2),
(2, 2, 7, 9, 2, 2, 2, 15, 16, 2, 4, 2.9, 0, 2),
(3, 3, 2, 4, 3, 3, 3, 12, 13, 5, 1, 0.5, 0, 5),
(3, 3, 4, 6, 3, 3, 3, 13, 14, 5, 2, 0.2, 10, 5),
(3, 3, 6, 8, 3, 3, 3, 14, 15, 5, 3, -0.5, 0, 5),
(3, 3, 8, 10, 3, 3, 3, 16, 17, 5, 4, -0.8, 0, 5);

INSERT INTO Zdarzenie_na_trasie (id_odcinek_kursu, id_przejazd, id_zdarzenie, id_junk, id_data_zdarzenia, id_czas_zdarzenia, koszt_naprawy, predkosc, wywolane_opoznienie, liczba_rannych, liczba_zgonow) VALUES
(2, 1, 5, 1, 1, 9, 2500.50, 65, 5, 0, 0),
(6, 2, 6, 2, 2, 12, 3200.00, 58, 3, 0, 0),
(10, 3, 8, 1, 3, 16, 5600.75, 72, 5, 0, 0);
