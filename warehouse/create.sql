
CREATE DATABASE hurtownia;
USE hurtownia;

DROP TABLE IF EXISTS Zdarzenie_na_trasie;
DROP TABLE IF EXISTS Odcinek_kursu;
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
    operator VARCHAR(40) NOT NULL
);

CREATE TABLE Maszynista (
    id INT IDENTITY(1,1) PRIMARY KEY,
    imie VARCHAR(30) NOT NULL,
    nazwisko VARCHAR(30) NOT NULL,
    plec VARCHAR(10) NOT NULL,
    kategoria_wiekowa VARCHAR(30) NOT NULL,
    doswiadczenie_pracy VARCHAR(30) NOT NULL,
    pesel CHAR(11) NOT NULL,
    czy_aktualne BIT NOT NULL
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
    dzien INT NOT NULL,
    pora_roku VARCHAR(20) NOT NULL,
    dzien_tygodnia VARCHAR(20) NOT NULL
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

CREATE TABLE Odcinek_kursu (
    id INT IDENTITY(1,1) PRIMARY KEY,
    id_kurs INT NOT NULL,
    id_pociag INT NOT NULL,
    id_stacja_wyjazdowa INT NOT NULL,
    id_stacja_wjazdowa INT NOT NULL,
    id_maszynista INT NOT NULL,
    id_planowa_data_przyjazdu INT NOT NULL,
    id_planowa_data_odjazdu INT NOT NULL,
    id_planowy_czas_przyjazdu INT NOT NULL,
    id_planowy_czas_odjazdu INT NOT NULL,
    id_junk INT NOT NULL,
    numer_etapu_kursu INT,
    temperatura FLOAT,
    roznica_czasu INT,
    ilosc_opadow INT,
    CONSTRAINT FK_Odc_Kurs FOREIGN KEY (id_kurs) REFERENCES Kurs(id),
    CONSTRAINT FK_Odc_Poc FOREIGN KEY (id_pociag) REFERENCES Pociag(id),
    CONSTRAINT FK_Odc_StW FOREIGN KEY (id_stacja_wyjazdowa) REFERENCES Stacja(id),
    CONSTRAINT FK_Odc_StJ FOREIGN KEY (id_stacja_wjazdowa) REFERENCES Stacja(id),
    CONSTRAINT FK_Odc_Mas FOREIGN KEY (id_maszynista) REFERENCES Maszynista(id),
    CONSTRAINT FK_Odc_DaP FOREIGN KEY (id_planowa_data_przyjazdu) REFERENCES Data(id),
    CONSTRAINT FK_Odc_DaO FOREIGN KEY (id_planowa_data_odjazdu) REFERENCES Data(id),
    CONSTRAINT FK_Odc_CzP FOREIGN KEY (id_planowy_czas_przyjazdu) REFERENCES Czas(id),
    CONSTRAINT FK_Odc_CzO FOREIGN KEY (id_planowy_czas_odjazdu) REFERENCES Czas(id),
    CONSTRAINT FK_Odc_Junk FOREIGN KEY (id_junk) REFERENCES Junk_odcinek_kursu(id)
);

CREATE TABLE Zdarzenie_na_trasie (
    id_odcinek_kursu INT NOT NULL,
    id_przejazd INT NULL,
    id_zdarzenie INT NOT NULL,
    id_junk INT NOT NULL,
    koszt_naprawy FLOAT,
    predkosc INT,
    wywolane_opoznienie INT,
    liczba_rannych INT,
    liczba_zgonow INT,
    FOREIGN KEY (id_odcinek_kursu) REFERENCES Odcinek_kursu(id),
    FOREIGN KEY (id_przejazd) REFERENCES Przejazd(id),
    FOREIGN KEY (id_zdarzenie) REFERENCES Zdarzenie(id),
    FOREIGN KEY (id_junk) REFERENCES Junk_zdarzenie(id)
);

-- Pociag data
INSERT INTO Pociag (nazwa, typ_pociagu, operator) VALUES
('Express 100', 'Elektryczny', 'PKP Intercity'),
('Regional 200', 'Spalinowy', 'PKP Przewozy Regionalne'),
('Cargo 300', 'Towarowy', 'PKP Cargo'),
('Pendolino 400', 'Wysokospeed', 'PKP Intercity'),
('Local 500', 'Lokalny', 'PKP Przewozy Regionalne');

-- Maszynista data
INSERT INTO Maszynista (imie, nazwisko, plec, kategoria_wiekowa, doswiadczenie_pracy, pesel, czy_aktualne) VALUES
('Jan', 'Kowalski', 'M', '35-45', '10-15 lat', '85010112345', 1),
('Anna', 'Nowak', 'K', '25-35', '5-10 lat', '90020223456', 1),
('Piotr', 'Wiśniewski', 'M', '45-55', '15-20 lat', '78030334567', 1),
('Maria', 'Wójcik', 'K', '35-45', '10-15 lat', '85040445678', 1),
('Tomasz', 'Kozłowski', 'M', '25-35', '5-10 lat', '92050556789', 1);

-- Stacja data
INSERT INTO Stacja (nazwa, miasto) VALUES
('Warszawa Centralna', 'Warszawa'),
('Kraków Główny', 'Kraków'),
('Gdańsk Główny', 'Gdańsk'),
('Wrocław Główny', 'Wrocław'),
('Poznań Główny', 'Poznań'),
('Łódź Fabryczna', 'Łódź'),
('Katowice', 'Katowice'),
('Szczecin Główny', 'Szczecin');

-- Kurs data
INSERT INTO Kurs (nazwa_trasy, kategoria_opoznienia) VALUES
('Warszawa-Kraków', 'Brak opóźnienia'),
('Gdańsk-Warszawa', 'Małe opóźnienie'),
('Wrocław-Poznań', 'Średnie opóźnienie'),
('Katowice-Warszawa', 'Duże opóźnienie'),
('Szczecin-Poznań', 'Brak opóźnienia');

-- Przejazd data
INSERT INTO Przejazd (czy_rogatki, czy_sygnalizacja_swietlna, czy_oswietlony, dopuszczalna_predkosc) VALUES
(1, 1, 1, '100 km/h'),
(1, 0, 1, '80 km/h'),
(0, 1, 0, '60 km/h'),
(1, 1, 0, '90 km/h'),
(0, 0, 1, '70 km/h');

-- Zdarzenie data
INSERT INTO Zdarzenie (typ_zdarzenia, kategoria, skala_niebezpieczenstwa) VALUES
('Kolizja', 'Wypadek', 'Wysoka'),
('Awaria', 'Techniczna', 'Średnia'),
('Opóźnienie', 'Organizacyjna', 'Niska'),
('Przejazd', 'Bezpieczeństwo', 'Średnia'),
('Sygnalizacja', 'Techniczna', 'Niska');

-- Data dimension
INSERT INTO Data (rok, miesiac, dzien, pora_roku, dzien_tygodnia) VALUES
(2024, 'Styczeń', 15, 'Zima', 'Poniedziałek'),
(2024, 'Luty', 20, 'Zima', 'Wtorek'),
(2024, 'Marzec', 10, 'Wiosna', 'Środa'),
(2024, 'Kwiecień', 5, 'Wiosna', 'Czwartek'),
(2024, 'Maj', 12, 'Wiosna', 'Piątek'),
(2024, 'Czerwiec', 18, 'Lato', 'Sobota'),
(2024, 'Lipiec', 25, 'Lato', 'Niedziela'),
(2024, 'Sierpień', 8, 'Lato', 'Poniedziałek');

-- Czas dimension
INSERT INTO Czas (godzina, minuta, pora_dnia) VALUES
(6, 30, 'Rano'),
(9, 15, 'Rano'),
(12, 0, 'Południe'),
(15, 45, 'Popołudnie'),
(18, 20, 'Wieczór'),
(21, 10, 'Noc'),
(3, 5, 'Noc'),
(8, 50, 'Rano');

-- Junk_odcinek_kursu data
INSERT INTO Junk_odcinek_kursu (typ_opadow) VALUES
('Brak opadów'),
('Deszcz lekki'),
('Deszcz średni'),
('Śnieg'),
('Mgła');

-- Junk_zdarzenie data
INSERT INTO Junk_zdarzenie (czy_interwencja_sluzb) VALUES
(1),
(0),
(1),
(0),
(1);

-- Odcinek_kursu fact data
INSERT INTO Odcinek_kursu (id_kurs, id_pociag, id_stacja_wyjazdowa, id_stacja_wjazdowa, id_maszynista, id_planowa_data_przyjazdu, id_planowa_data_odjazdu, id_planowy_czas_przyjazdu, id_planowy_czas_odjazdu, id_junk, numer_etapu_kursu, temperatura, roznica_czasu, ilosc_opadow) VALUES
(1, 1, 1, 2, 1, 1, 1, 1, 2, 1, 1, 5.5, 120, 0),
(1, 1, 2, 7, 1, 2, 2, 2, 3, 2, 2, 8.2, 95, 2),
(2, 2, 3, 1, 2, 3, 3, 3, 4, 3, 1, 12.8, 180, 5),
(3, 3, 4, 5, 3, 4, 4, 4, 5, 1, 1, -2.1, 75, 0),
(4, 4, 7, 1, 4, 5, 5, 5, 6, 4, 1, 15.3, 200, 8),
(5, 5, 8, 5, 5, 6, 6, 6, 7, 5, 1, 22.7, 150, 12);

-- Zdarzenie_na_trasie fact data
INSERT INTO Zdarzenie_na_trasie (id_odcinek_kursu, id_przejazd, id_zdarzenie, id_junk, koszt_naprawy, predkosc, wywolane_opoznienie, liczba_rannych, liczba_zgonow) VALUES
(1, 1, 1, 1, 15000.50, 85, 30, 2, 0),
(1, 2, 2, 2, 8500.00, 75, 15, 0, 0),
(2, 3, 3, 3, 0.00, 90, 5, 0, 0),
(3, 4, 4, 4, 2500.75, 65, 10, 1, 0),
(4, 5, 5, 5, 12000.00, 55, 45, 0, 1),
(5, 1, 1, 1, 7800.25, 70, 20, 3, 0);