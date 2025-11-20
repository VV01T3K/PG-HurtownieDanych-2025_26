-- DROPS
DROP TABLE IF EXISTS Zdarzenie_na_trasie;

DROP TABLE IF EXISTS Odcinek_kursu;

DROP TABLE IF EXISTS Kurs;

DROP TABLE IF EXISTS Pociag;

DROP TABLE IF EXISTS Maszynista;

DROP TABLE IF EXISTS Stacja;

DROP TABLE IF EXISTS Przejazd;

DROP TABLE IF EXISTS Zdarzenie;
GO
-- CREATES
CREATE TABLE Pociag
(
    id INT IDENTITY(1, 1) PRIMARY KEY,
    nazwa VARCHAR(20) NOT NULL,
    typ_pociagu VARCHAR(30) NOT NULL,
    operator VARCHAR(40) NOT NULL
);

CREATE TABLE Maszynista
(
    id INT IDENTITY(1, 1) PRIMARY KEY,
    imie VARCHAR(30) NOT NULL,
    nazwisko VARCHAR(30) NOT NULL,
    pesel CHAR(11) NOT NULL UNIQUE,
    plec VARCHAR(10) NOT NULL CHECK (plec IN ('man', 'woman')),
    wiek INT NOT NULL CHECK (wiek BETWEEN 18 AND 80),
    rok_zatrudnienia INT NOT NULL CHECK (
        rok_zatrudnienia BETWEEN 1900 AND YEAR(GETDATE())
    ),
    CONSTRAINT chk_pesel_format CHECK (pesel LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
);

CREATE TABLE Przejazd
(
    id INT IDENTITY(1, 1) PRIMARY KEY,
    czy_rogatki BIT NOT NULL,
    czy_sygnalizacja_swietlna BIT NOT NULL,
    czy_oswietlony BIT NOT NULL,
    dopuszczalna_predkosc INT NOT NULL CHECK (
        dopuszczalna_predkosc BETWEEN 20 AND 100
    )
);

CREATE TABLE Zdarzenie
(
    id INT IDENTITY(1, 1) PRIMARY KEY,
    typ_zdarzenia VARCHAR(30) NOT NULL,
    kategoria VARCHAR(40) NOT NULL,
    skala_niebezpieczenstwa INT NOT NULL CHECK (
        skala_niebezpieczenstwa BETWEEN 1 AND 10
    )
);

CREATE TABLE Kurs
(
    id INT IDENTITY(1, 1) PRIMARY KEY,
    nazwa_trasy VARCHAR(40) NOT NULL,
    roznica_czasu INT NOT NULL,
    planowa_data_odjazdu DATETIME NOT NULL,
    planowa_data_przyjazdu DATETIME,
    --MOZNA BY POZWOLIC NA NULLA JAKO ZE WCALE NIE DOJECHAL 
    pociag_id INT NOT NULL REFERENCES Pociag (id),
    maszynista_id INT NOT NULL REFERENCES Maszynista (id)
);

CREATE TABLE Stacja
(
    id INT IDENTITY(1, 1) PRIMARY KEY,
    nazwa VARCHAR(40) NOT NULL,
    miasto VARCHAR(40) NOT NULL
);

CREATE TABLE Odcinek_kursu
(
    id BIGINT IDENTITY(1, 1) PRIMARY KEY,
    kurs_id INT NOT NULL REFERENCES Kurs (id),
    numer_etapu_kursu INT NOT NULL,
    stacja_wyjazdowa_id INT REFERENCES Stacja (id),
    stacja_wjazdowa_id INT NOT NULL REFERENCES Stacja (id),
    roznica_czasu INT NOT NULL,
    planowa_data_przyjazdu DATETIME NOT NULL,
    planowa_data_odjazdu DATETIME,
    CONSTRAINT chk_arrival_after_departure CHECK (
        planowa_data_odjazdu IS NULL
        OR planowa_data_przyjazdu > planowa_data_odjazdu
    )
);

CREATE TABLE Zdarzenie_na_trasie
(
    id BIGINT IDENTITY(1, 1) PRIMARY KEY,
    odcinek_kursu_id BIGINT NOT NULL REFERENCES Odcinek_kursu (id),
    przejazd_id INT REFERENCES Przejazd (id),
    --niektore zdarzenia moga nie byc na przejezdzie 
    zdarzenie_id INT NOT NULL REFERENCES Zdarzenie (id),
    wywolane_opoznienie INT NOT NULL,
    liczba_rannych INT NOT NULL,
    liczba_zgonow INT NOT NULL,
    koszt_naprawy DECIMAL(10, 2) NOT NULL,
    czy_interwencja_sluzb BIT NOT NULL,
    data DATETIME NOT NULL,
    predkosc INT NOT NULL
);
