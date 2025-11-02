-- Bulk Update/Insert Script for T2 Dataset
-- This script updates existing records and inserts new T2 data
-- T2 contains incremental/updated data that should merge with T1

-- Disable constraints temporarily for faster loading
ALTER TABLE Zdarzenie_na_trasie NOCHECK CONSTRAINT ALL;

ALTER TABLE Odcinek_kursu NOCHECK CONSTRAINT ALL;

ALTER TABLE Kurs NOCHECK CONSTRAINT ALL;

ALTER TABLE Weather NOCHECK CONSTRAINT ALL;

-- Load new Pociag records from T2
CREATE TABLE #Pociag_Temp (
    id INT,
    nazwa VARCHAR(20),
    typ_pociagu VARCHAR(30),
    operator VARCHAR(40)
);

BULK INSERT #Pociag_Temp
FROM '/opt/data/T2/Pociag.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

SET IDENTITY_INSERT Pociag ON;

MERGE INTO Pociag AS target
USING #Pociag_Temp AS source
ON target.id = source.id
WHEN MATCHED THEN
    UPDATE SET nazwa = source.nazwa, typ_pociagu = source.typ_pociagu, operator = source.operator
WHEN NOT MATCHED THEN
    INSERT (id, nazwa, typ_pociagu, operator) VALUES (source.id, source.nazwa, source.typ_pociagu, source.operator);

SET IDENTITY_INSERT Pociag OFF;

DROP TABLE #Pociag_Temp;

-- Update Maszynista records from T2
CREATE TABLE #Maszynista_Temp (
    id INT,
    imie VARCHAR(30),
    nazwisko VARCHAR(30),
    plec VARCHAR(10),
    wiek INT,
    rok_zatrudnienia INT
);

BULK INSERT #Maszynista_Temp
FROM '/opt/data/T2/Maszynista.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

SET IDENTITY_INSERT Maszynista ON;

MERGE INTO Maszynista AS target
USING #Maszynista_Temp AS source
ON target.id = source.id
WHEN MATCHED THEN
    UPDATE SET imie = source.imie, nazwisko = source.nazwisko, plec = source.plec, wiek = source.wiek, rok_zatrudnienia = source.rok_zatrudnienia
WHEN NOT MATCHED THEN
    INSERT (id, imie, nazwisko, plec, wiek, rok_zatrudnienia) VALUES (source.id, source.imie, source.nazwisko, source.plec, source.wiek, source.rok_zatrudnienia);

SET IDENTITY_INSERT Maszynista OFF;

DROP TABLE #Maszynista_Temp;

-- Update Przejazd records from T2
CREATE TABLE #Przejazd_Temp (
    id INT,
    czy_rogatki BIT,
    czy_sygnalizacja_swietlna BIT,
    czy_oswietlony BIT,
    dopuszczalna_predkosc INT
);

BULK INSERT #Przejazd_Temp
FROM '/opt/data/T2/Przejazd.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

SET IDENTITY_INSERT Przejazd ON;

MERGE INTO Przejazd AS target
USING #Przejazd_Temp AS source
ON target.id = source.id
WHEN MATCHED THEN
    UPDATE SET czy_rogatki = source.czy_rogatki, czy_sygnalizacja_swietlna = source.czy_sygnalizacja_swietlna, czy_oswietlony = source.czy_oswietlony, dopuszczalna_predkosc = source.dopuszczalna_predkosc
WHEN NOT MATCHED THEN
    INSERT (id, czy_rogatki, czy_sygnalizacja_swietlna, czy_oswietlony, dopuszczalna_predkosc) VALUES (source.id, source.czy_rogatki, source.czy_sygnalizacja_swietlna, source.czy_oswietlony, source.dopuszczalna_predkosc);

SET IDENTITY_INSERT Przejazd OFF;

DROP TABLE #Przejazd_Temp;

-- Update Zdarzenie records from T2
CREATE TABLE #Zdarzenie_Temp (
    id INT,
    typ_zdarzenia VARCHAR(30),
    kategoria VARCHAR(40),
    skala_niebezpieczenstwa INT
);

BULK INSERT #Zdarzenie_Temp
FROM '/opt/data/T2/Zdarzenie.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

SET IDENTITY_INSERT Zdarzenie ON;

MERGE INTO Zdarzenie AS target
USING #Zdarzenie_Temp AS source
ON target.id = source.id
WHEN MATCHED THEN
    UPDATE SET typ_zdarzenia = source.typ_zdarzenia, kategoria = source.kategoria, skala_niebezpieczenstwa = source.skala_niebezpieczenstwa
WHEN NOT MATCHED THEN
    INSERT (id, typ_zdarzenia, kategoria, skala_niebezpieczenstwa) VALUES (source.id, source.typ_zdarzenia, source.kategoria, source.skala_niebezpieczenstwa);

SET IDENTITY_INSERT Zdarzenie OFF;

DROP TABLE #Zdarzenie_Temp;

-- Update Stacja records from T2
CREATE TABLE #Stacja_Temp (
    id INT,
    nazwa VARCHAR(40),
    miasto VARCHAR(40)
);

BULK INSERT #Stacja_Temp
FROM '/opt/data/T2/Stacja.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

SET IDENTITY_INSERT Stacja ON;

MERGE INTO Stacja AS target
USING #Stacja_Temp AS source
ON target.id = source.id
WHEN MATCHED THEN
    UPDATE SET nazwa = source.nazwa, miasto = source.miasto
WHEN NOT MATCHED THEN
    INSERT (id, nazwa, miasto) VALUES (source.id, source.nazwa, source.miasto);

SET IDENTITY_INSERT Stacja OFF;

DROP TABLE #Stacja_Temp;

-- Merge Kurs records from T2
CREATE TABLE #Kurs_Temp (
    id INT,
    nazwa_trasy VARCHAR(40),
    roznica_czasu INT,
    planowa_data_odjazdu DATETIME,
    planowa_data_przyjazdu DATETIME,
    pociag_id INT,
    maszynista_id INT
);

BULK INSERT #Kurs_Temp
FROM '/opt/data/T2/Kurs.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

SET IDENTITY_INSERT Kurs ON;

MERGE INTO Kurs AS target
USING #Kurs_Temp AS source
ON target.id = source.id
WHEN MATCHED THEN
    UPDATE SET nazwa_trasy = source.nazwa_trasy, roznica_czasu = source.roznica_czasu, planowa_data_odjazdu = source.planowa_data_odjazdu, planowa_data_przyjazdu = source.planowa_data_przyjazdu, pociag_id = source.pociag_id, maszynista_id = source.maszynista_id
WHEN NOT MATCHED THEN
    INSERT (id, nazwa_trasy, roznica_czasu, planowa_data_odjazdu, planowa_data_przyjazdu, pociag_id, maszynista_id) VALUES (source.id, source.nazwa_trasy, source.roznica_czasu, source.planowa_data_odjazdu, source.planowa_data_przyjazdu, source.pociag_id, source.maszynista_id);

SET IDENTITY_INSERT Kurs OFF;

DROP TABLE #Kurs_Temp;

-- Merge Odcinek_kursu records from T2
CREATE TABLE #Odcinek_kursu_Temp (
    id BIGINT,
    kurs_id INT,
    numer_etapu_kursu INT,
    stacja_wyjazdowa_id INT,
    stacja_wjazdowa_id INT,
    roznica_czasu INT,
    planowa_data_przyjazdu DATETIME,
    planowa_data_odjazdu DATETIME
);

BULK INSERT #Odcinek_kursu_Temp
FROM '/opt/data/T2/Odcinek_kursu.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

SET IDENTITY_INSERT Odcinek_kursu ON;

MERGE INTO Odcinek_kursu AS target
USING #Odcinek_kursu_Temp AS source
ON target.id = source.id
WHEN MATCHED THEN
    UPDATE SET kurs_id = source.kurs_id, numer_etapu_kursu = source.numer_etapu_kursu, stacja_wyjazdowa_id = source.stacja_wyjazdowa_id, stacja_wjazdowa_id = source.stacja_wjazdowa_id, roznica_czasu = source.roznica_czasu, planowa_data_przyjazdu = source.planowa_data_przyjazdu, planowa_data_odjazdu = source.planowa_data_odjazdu
WHEN NOT MATCHED THEN
    INSERT (id, kurs_id, numer_etapu_kursu, stacja_wyjazdowa_id, stacja_wjazdowa_id, roznica_czasu, planowa_data_przyjazdu, planowa_data_odjazdu) VALUES (source.id, source.kurs_id, source.numer_etapu_kursu, source.stacja_wyjazdowa_id, source.stacja_wjazdowa_id, source.roznica_czasu, source.planowa_data_przyjazdu, source.planowa_data_odjazdu);

SET IDENTITY_INSERT Odcinek_kursu OFF;

DROP TABLE #Odcinek_kursu_Temp;

-- Merge Weather records from T2
CREATE TABLE #Weather_Temp (
    id BIGINT,
    id_odcinka BIGINT,
    data_pomiaru DATETIME,
    temperatura DECIMAL(4, 1),
    ilosc_opadow DECIMAL(4, 1),
    typ_opadow VARCHAR(10)
);

BULK INSERT #Weather_Temp
FROM '/opt/data/T2/Weather.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

SET IDENTITY_INSERT Weather ON;

MERGE INTO Weather AS target
USING #Weather_Temp AS source
ON target.id = source.id
WHEN MATCHED THEN
    UPDATE SET id_odcinka = source.id_odcinka, data_pomiaru = source.data_pomiaru, temperatura = source.temperatura, ilosc_opadow = source.ilosc_opadow, typ_opadow = source.typ_opadow
WHEN NOT MATCHED THEN
    INSERT (id, id_odcinka, data_pomiaru, temperatura, ilosc_opadow, typ_opadow) VALUES (source.id, source.id_odcinka, source.data_pomiaru, source.temperatura, source.ilosc_opadow, source.typ_opadow);

SET IDENTITY_INSERT Weather OFF;

DROP TABLE #Weather_Temp;

-- Merge Zdarzenie_na_trasie records from T2
CREATE TABLE #Zdarzenie_na_trasie_Temp (
    id BIGINT,
    odcinek_kursu_id BIGINT,
    przejazd_id INT,
    zdarzenie_id INT,
    wywolane_opoznienie INT,
    liczba_rannych INT,
    liczba_zgonow INT,
    koszt_naprawy DECIMAL(10, 2),
    czy_interwencja_sluzb BIT,
    data DATETIME,
    predkosc INT
);

BULK INSERT #Zdarzenie_na_trasie_Temp
FROM '/opt/data/T2/Zdarzenie_na_trasie.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

SET IDENTITY_INSERT Zdarzenie_na_trasie ON;

MERGE INTO Zdarzenie_na_trasie AS target
USING #Zdarzenie_na_trasie_Temp AS source
ON target.id = source.id
WHEN MATCHED THEN
    UPDATE SET odcinek_kursu_id = source.odcinek_kursu_id, przejazd_id = source.przejazd_id, zdarzenie_id = source.zdarzenie_id, wywolane_opoznienie = source.wywolane_opoznienie, liczba_rannych = source.liczba_rannych, liczba_zgonow = source.liczba_zgonow, koszt_naprawy = source.koszt_naprawy, czy_interwencja_sluzb = source.czy_interwencja_sluzb, data = source.data, predkosc = source.predkosc
WHEN NOT MATCHED THEN
    INSERT (id, odcinek_kursu_id, przejazd_id, zdarzenie_id, wywolane_opoznienie, liczba_rannych, liczba_zgonow, koszt_naprawy, czy_interwencja_sluzb, data, predkosc) VALUES (source.id, source.odcinek_kursu_id, source.przejazd_id, source.zdarzenie_id, source.wywolane_opoznienie, source.liczba_rannych, source.liczba_zgonow, source.koszt_naprawy, source.czy_interwencja_sluzb, source.data, source.predkosc);

SET IDENTITY_INSERT Zdarzenie_na_trasie OFF;

DROP TABLE #Zdarzenie_na_trasie_Temp;

-- Re-enable constraints
ALTER TABLE Zdarzenie_na_trasie CHECK CONSTRAINT ALL;

ALTER TABLE Odcinek_kursu CHECK CONSTRAINT ALL;

ALTER TABLE Kurs CHECK CONSTRAINT ALL;

ALTER TABLE Weather CHECK CONSTRAINT ALL;

-- Display summary
PRINT 'T2 Data Merge Complete';

PRINT 'Total Pociag records: ' + CAST(
    (
        SELECT COUNT(*)
        FROM Pociag
    ) AS VARCHAR
);

PRINT 'Total Maszynista records: ' + CAST(
    (
        SELECT COUNT(*)
        FROM Maszynista
    ) AS VARCHAR
);

PRINT 'Total Stacja records: ' + CAST(
    (
        SELECT COUNT(*)
        FROM Stacja
    ) AS VARCHAR
);

PRINT 'Total Przejazd records: ' + CAST(
    (
        SELECT COUNT(*)
        FROM Przejazd
    ) AS VARCHAR
);

PRINT 'Total Zdarzenie records: ' + CAST(
    (
        SELECT COUNT(*)
        FROM Zdarzenie
    ) AS VARCHAR
);

PRINT 'Total Kurs records: ' + CAST(
    (
        SELECT COUNT(*)
        FROM Kurs
    ) AS VARCHAR
);

PRINT 'Total Odcinek_kursu records: ' + CAST(
    (
        SELECT COUNT(*)
        FROM Odcinek_kursu
    ) AS VARCHAR
);

PRINT 'Total Weather records: ' + CAST(
    (
        SELECT COUNT(*)
        FROM Weather
    ) AS VARCHAR
);

PRINT 'Total Zdarzenie_na_trasie records: ' + CAST(
    (
        SELECT COUNT(*)
        FROM Zdarzenie_na_trasie
    ) AS VARCHAR
);