-- Verification Script for T1 Data Load (No Weather)
-- This script verifies that the correct amount of data was loaded from T1 CSV files
-- Expected counts (CSV lines - 1 for header):
-- Pociag: 1,430 records
-- Maszynista: 4,747 records
-- Przejazd: 9,937 records
-- Zdarzenie: 13 records
-- Stacja: 448 records
-- Kurs: 100,000 records
-- Odcinek_kursu: 1,123,619 records
-- Zdarzenie_na_trasie: 56,073 records

PRINT '=== T1 DATA LOAD VERIFICATION (No Weather) ===';
PRINT '';

-- Count records in each table
PRINT 'Record counts after T1 load:';
PRINT '';

DECLARE @PociagCount INT, @MaszynistaCount INT, @PrzejazdCount INT, @ZdarzenieCount INT,
        @StacjaCount INT, @KursCount INT, @OdcinekCount BIGINT,
        @ZdarzenieNaTrasieCount BIGINT;

SELECT @PociagCount = COUNT(*)
FROM Pociag;
SELECT @MaszynistaCount = COUNT(*)
FROM Maszynista;
SELECT @PrzejazdCount = COUNT(*)
FROM Przejazd;
SELECT @ZdarzenieCount = COUNT(*)
FROM Zdarzenie;
SELECT @StacjaCount = COUNT(*)
FROM Stacja;
SELECT @KursCount = COUNT(*)
FROM Kurs;
SELECT @OdcinekCount = COUNT(*)
FROM Odcinek_kursu;
SELECT @ZdarzenieNaTrasieCount = COUNT(*)
FROM Zdarzenie_na_trasie;

PRINT 'Pociag:              ' + CAST(@PociagCount AS VARCHAR(20)) + ' (Expected: 1,430)';
PRINT 'Maszynista:          ' + CAST(@MaszynistaCount AS VARCHAR(20)) + ' (Expected: 4,747)';
PRINT 'Przejazd:            ' + CAST(@PrzejazdCount AS VARCHAR(20)) + ' (Expected: 9,937)';
PRINT 'Zdarzenie:           ' + CAST(@ZdarzenieCount AS VARCHAR(20)) + ' (Expected: 13)';
PRINT 'Stacja:              ' + CAST(@StacjaCount AS VARCHAR(20)) + ' (Expected: 448)';
PRINT 'Kurs:                ' + CAST(@KursCount AS VARCHAR(20)) + ' (Expected: 100,000)';
PRINT 'Odcinek_kursu:       ' + CAST(@OdcinekCount AS VARCHAR(20)) + ' (Expected: 1,123,619)';
PRINT 'Zdarzenie_na_trasie: ' + CAST(@ZdarzenieNaTrasieCount AS VARCHAR(20)) + ' (Expected: 56,073)';
PRINT '';

-- Verify data integrity
PRINT '=== DATA INTEGRITY CHECKS ===';
PRINT '';

-- Check for NULL foreign keys where they shouldn't be
PRINT 'Checking foreign key integrity:';
PRINT '';

DECLARE @InvalidKurs INT, @InvalidOdcinek INT, @InvalidZdarzenie INT;

SELECT @InvalidKurs = COUNT(*)
FROM Kurs
WHERE pociag_id IS NULL OR maszynista_id IS NULL;
SELECT @InvalidOdcinek = COUNT(*)
FROM Odcinek_kursu
WHERE kurs_id IS NULL OR stacja_wjazdowa_id IS NULL;
SELECT @InvalidZdarzenie = COUNT(*)
FROM Zdarzenie_na_trasie
WHERE odcinek_kursu_id IS NULL OR zdarzenie_id IS NULL;

PRINT 'Kurs with NULL pociag_id or maszynista_id:     ' + CAST(@InvalidKurs AS VARCHAR(20));
PRINT 'Odcinek_kursu with NULL required FKs:          ' + CAST(@InvalidOdcinek AS VARCHAR(20));
PRINT 'Zdarzenie_na_trasie with NULL required FKs:    ' + CAST(@InvalidZdarzenie AS VARCHAR(20));
PRINT '';

-- Sample data from each table
PRINT '=== SAMPLE DATA (First 5 Records) ===';
PRINT '';

PRINT 'Pociag:';
SELECT TOP 5
    id, nazwa, typ_pociagu, operator
FROM Pociag
ORDER BY id;
PRINT '';

PRINT 'Maszynista:';
SELECT TOP 5
    id, imie, nazwisko, plec, wiek, rok_zatrudnienia
FROM Maszynista
ORDER BY id;
PRINT '';

PRINT 'Stacja:';
SELECT TOP 5
    id, nazwa, miasto
FROM Stacja
ORDER BY id;
PRINT '';

PRINT 'Zdarzenie:';
SELECT id, typ_zdarzenia, kategoria, skala_niebezpieczenstwa
FROM Zdarzenie
ORDER BY id;
PRINT '';

PRINT 'Kurs (sample):';
SELECT TOP 5
    id,
    nazwa_trasy,
    planowa_data_odjazdu,
    planowa_data_przyjazdu,
    pociag_id,
    maszynista_id
FROM Kurs
ORDER BY id;
PRINT '';

-- Date range analysis
PRINT '=== DATE RANGE ANALYSIS ===';
PRINT '';

SELECT
    'Kurs' AS Tabela,
    MIN(planowa_data_odjazdu) AS Najwczesniejsza_Data,
    MAX(planowa_data_przyjazdu) AS Najpozniejsza_Data,
    DATEDIFF(DAY, MIN(planowa_data_odjazdu), MAX(planowa_data_przyjazdu)) AS Rozpietosc_Dni
FROM Kurs;

SELECT
    'Zdarzenie_na_trasie' AS Tabela,
    MIN(data) AS Najwczesniejsza_Data,
    MAX(data) AS Najpozniejsza_Data,
    DATEDIFF(DAY, MIN(data), MAX(data)) AS Rozpietosc_Dni
FROM Zdarzenie_na_trasie;

PRINT '';

-- Statistics
PRINT '=== STATISTICAL SUMMARY ===';
PRINT '';

PRINT 'Zdarzenia by type:';
SELECT
    Z.typ_zdarzenia,
    Z.kategoria,
    COUNT(*) AS Liczba_Zdarzen,
    SUM(ZNT.liczba_rannych) AS Suma_Rannych,
    SUM(ZNT.liczba_zgonow) AS Suma_Zgonow,
    SUM(ZNT.koszt_naprawy) AS Suma_Kosztow
FROM Zdarzenie Z
    JOIN Zdarzenie_na_trasie ZNT ON Z.id = ZNT.zdarzenie_id
GROUP BY Z.typ_zdarzenia, Z.kategoria
ORDER BY Liczba_Zdarzen DESC;
PRINT '';

PRINT 'Pociag types:';
SELECT
    typ_pociagu,
    operator,
    COUNT(*) AS Liczba_Pociagow
FROM Pociag
GROUP BY typ_pociagu, operator
ORDER BY Liczba_Pociagow DESC;

PRINT '';
PRINT '=== T1 VERIFICATION COMPLETE ===';
