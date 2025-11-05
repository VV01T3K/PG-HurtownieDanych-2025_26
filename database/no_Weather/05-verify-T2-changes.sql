-- Verification Script for T2 Merge Changes (No Weather)
-- This script shows what was updated or added after merging T2 data
-- 
-- Expected changes from T1 to T2:
-- Pociag: 1,430 -> 1,487 (57 new records)
-- Maszynista: 4,747 -> 5,095 (348 new records)
-- Przejazd: 9,937 -> 10,382 (445 new records)
-- Zdarzenie: 13 -> 13 (no change)
-- Stacja: 448 -> 448 (no change)
-- Kurs: 100,000 -> 100,000 (updates only)
-- Odcinek_kursu: 1,123,619 -> 1,125,226 (1,607 new records)
-- Zdarzenie_na_trasie: 56,073 -> 51,575 (net change, some deleted/updated)

PRINT '=== T2 MERGE VERIFICATION (No Weather) ===';
PRINT '';

-- Count records after T2 merge
PRINT 'Record counts after T2 merge:';
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

PRINT 'Pociag:              ' + CAST(@PociagCount AS VARCHAR(20)) + ' (T1: 1,430 -> T2: 1,487)';
PRINT 'Maszynista:          ' + CAST(@MaszynistaCount AS VARCHAR(20)) + ' (T1: 4,747 -> T2: 5,095)';
PRINT 'Przejazd:            ' + CAST(@PrzejazdCount AS VARCHAR(20)) + ' (T1: 9,937 -> T2: 10,382)';
PRINT 'Zdarzenie:           ' + CAST(@ZdarzenieCount AS VARCHAR(20)) + ' (T1: 13 -> T2: 13)';
PRINT 'Stacja:              ' + CAST(@StacjaCount AS VARCHAR(20)) + ' (T1: 448 -> T2: 448)';
PRINT 'Kurs:                ' + CAST(@KursCount AS VARCHAR(20)) + ' (T1: 100,000 -> T2: 100,000)';
PRINT 'Odcinek_kursu:       ' + CAST(@OdcinekCount AS VARCHAR(20)) + ' (T1: 1,123,619 -> T2: 1,125,226)';
PRINT 'Zdarzenie_na_trasie: ' + CAST(@ZdarzenieNaTrasieCount AS VARCHAR(20)) + ' (T1: 56,073 -> T2: varies)';
PRINT '';

PRINT '=== NEWLY ADDED RECORDS ===';
PRINT '';

-- Show ID ranges to identify new records
-- Note: Since we don't have a timestamp or version field, we identify new records by ID ranges

PRINT 'Pociag - New records (IDs > 1430):';
SELECT COUNT(*) AS New_Records, MIN(id) AS Min_New_ID, MAX(id) AS Max_ID
FROM Pociag
WHERE id > 1430;

SELECT TOP 10
    id, nazwa, typ_pociagu, operator
FROM Pociag
WHERE id > 1430
ORDER BY id;
PRINT '';

PRINT 'Maszynista - New records (IDs > 4747):';
SELECT COUNT(*) AS New_Records, MIN(id) AS Min_New_ID, MAX(id) AS Max_ID
FROM Maszynista
WHERE id > 4747;

SELECT TOP 10
    id, imie, nazwisko, plec, wiek, rok_zatrudnienia
FROM Maszynista
WHERE id > 4747
ORDER BY id;
PRINT '';

PRINT 'Przejazd - New records (IDs > 9937):';
SELECT COUNT(*) AS New_Records, MIN(id) AS Min_New_ID, MAX(id) AS Max_ID
FROM Przejazd
WHERE id > 9937;

SELECT TOP 10
    id, czy_rogatki, czy_sygnalizacja_swietlna, czy_oswietlony, dopuszczalna_predkosc
FROM Przejazd
WHERE id > 9937
ORDER BY id;
PRINT '';

PRINT 'Odcinek_kursu - New records (IDs > 1123619):';
SELECT COUNT(*) AS New_Records, MIN(id) AS Min_New_ID, MAX(id) AS Max_ID
FROM Odcinek_kursu
WHERE id > 1123619;

SELECT TOP 10
    id,
    kurs_id,
    numer_etapu_kursu,
    stacja_wyjazdowa_id,
    stacja_wjazdowa_id,
    planowa_data_odjazdu,
    planowa_data_przyjazdu
FROM Odcinek_kursu
WHERE id > 1123619
ORDER BY id;
PRINT '';

PRINT 'Zdarzenie_na_trasie - New records (IDs > 56073):';
SELECT COUNT(*) AS New_Records
FROM Zdarzenie_na_trasie
WHERE id > 56073;

SELECT TOP 10
    id,
    odcinek_kursu_id,
    przejazd_id,
    zdarzenie_id,
    data,
    wywolane_opoznienie,
    liczba_rannych,
    liczba_zgonow,
    koszt_naprawy
FROM Zdarzenie_na_trasie
WHERE id > 56073
ORDER BY id;
PRINT '';

PRINT '=== COMPARISON: BEFORE AND AFTER T2 ===';
PRINT '';

-- Since this is meant to be run AFTER T2 merge, we can't directly compare
-- But we can show distribution changes that would indicate updates

PRINT 'Zdarzenia statistics (after T2):';
SELECT
    Z.typ_zdarzenia,
    Z.kategoria,
    COUNT(*) AS Liczba_Zdarzen,
    SUM(ZNT.liczba_rannych) AS Suma_Rannych,
    SUM(ZNT.liczba_zgonow) AS Suma_Zgonow,
    CAST(SUM(ZNT.koszt_naprawy) AS DECIMAL(15,2)) AS Suma_Kosztow
FROM Zdarzenie Z
    JOIN Zdarzenie_na_trasie ZNT ON Z.id = ZNT.zdarzenie_id
GROUP BY Z.typ_zdarzenia, Z.kategoria
ORDER BY Liczba_Zdarzen DESC;
PRINT '';

PRINT 'Train operators distribution (after T2):';
SELECT
    operator,
    COUNT(*) AS Liczba_Pociagow
FROM Pociag
GROUP BY operator
ORDER BY Liczba_Pociagow DESC;
PRINT '';

PRINT 'Maszynista age distribution (after T2):';
SELECT
    CASE 
        WHEN wiek < 30 THEN '< 30'
        WHEN wiek BETWEEN 30 AND 39 THEN '30-39'
        WHEN wiek BETWEEN 40 AND 49 THEN '40-49'
        WHEN wiek BETWEEN 50 AND 59 THEN '50-59'
        ELSE '60+'
    END AS Grupa_Wiekowa,
    COUNT(*) AS Liczba_Maszynistow,
    CAST(AVG(rok_zatrudnienia) AS DECIMAL(10,2)) AS Sredni_Rok_Zatrudnienia
FROM Maszynista
GROUP BY 
    CASE 
        WHEN wiek < 30 THEN '< 30'
        WHEN wiek BETWEEN 30 AND 39 THEN '30-39'
        WHEN wiek BETWEEN 40 AND 49 THEN '40-49'
        WHEN wiek BETWEEN 50 AND 59 THEN '50-59'
        ELSE '60+'
    END
ORDER BY Grupa_Wiekowa;
PRINT '';

PRINT '=== DATE RANGE ANALYSIS (After T2) ===';
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

PRINT '=== DETAILED CHANGE SUMMARY ===';
PRINT '';

-- Show sample of courses with most recent dates (likely updated in T2)
PRINT 'Courses with most recent dates (likely from T2 updates):';
SELECT TOP 20
    K.id,
    K.nazwa_trasy,
    K.planowa_data_odjazdu,
    K.planowa_data_przyjazdu,
    P.nazwa AS Pociag,
    M.imie + ' ' + M.nazwisko AS Maszynista
FROM Kurs K
    JOIN Pociag P ON K.pociag_id = P.id
    JOIN Maszynista M ON K.maszynista_id = M.id
ORDER BY K.planowa_data_odjazdu DESC;
PRINT '';

-- Show crossings with highest speed limits (possibly new/updated)
PRINT 'Przejazd with highest speed limits:';
SELECT TOP 20
    id,
    czy_rogatki,
    czy_sygnalizacja_swietlna,
    czy_oswietlony,
    dopuszczalna_predkosc
FROM Przejazd
ORDER BY dopuszczalna_predkosc DESC, id DESC;
PRINT '';

-- Show recent incidents
PRINT 'Most recent Zdarzenia_na_trasie:';
SELECT TOP 20
    ZNT.id,
    ZNT.data,
    Z.typ_zdarzenia,
    Z.kategoria,
    ZNT.wywolane_opoznienie,
    ZNT.liczba_rannych,
    ZNT.liczba_zgonow,
    ZNT.koszt_naprawy,
    ZNT.predkosc
FROM Zdarzenie_na_trasie ZNT
    JOIN Zdarzenie Z ON ZNT.zdarzenie_id = Z.id
ORDER BY ZNT.data DESC;

PRINT '';
PRINT '=== T2 MERGE VERIFICATION COMPLETE ===';
PRINT '';
PRINT 'Summary:';
PRINT '- New Pociag records added from T2';
PRINT '- New Maszynista records added from T2';
PRINT '- New Przejazd records added from T2';
PRINT '- New Odcinek_kursu records added';
PRINT '- Zdarzenie_na_trasie records merged/updated';
PRINT '- Existing records updated with T2 values where applicable';
