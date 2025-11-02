-- Bulk Load Script for T1 Dataset
-- This script loads all T1 data from CSV files into the database

-- Disable constraints temporarily for faster loading
ALTER TABLE Zdarzenie_na_trasie NOCHECK CONSTRAINT ALL;

ALTER TABLE Odcinek_kursu NOCHECK CONSTRAINT ALL;

ALTER TABLE Kurs NOCHECK CONSTRAINT ALL;

-- Disable identity insert to allow specific IDs from CSV
SET IDENTITY_INSERT Pociag ON;

BULK INSERT Pociag
FROM '/opt/data/T1/Pociag.csv'
WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        TABLOCK
    );

SET IDENTITY_INSERT Pociag OFF;

SET IDENTITY_INSERT Maszynista ON;

BULK INSERT Maszynista
FROM '/opt/data/T1/Maszynista.csv'
WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        TABLOCK
    );

SET IDENTITY_INSERT Maszynista OFF;

SET IDENTITY_INSERT Przejazd ON;

BULK INSERT Przejazd
FROM '/opt/data/T1/Przejazd.csv'
WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        TABLOCK
    );

SET IDENTITY_INSERT Przejazd OFF;

SET IDENTITY_INSERT Zdarzenie ON;

BULK INSERT Zdarzenie
FROM '/opt/data/T1/Zdarzenie.csv'
WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        TABLOCK
    );

SET IDENTITY_INSERT Zdarzenie OFF;

SET IDENTITY_INSERT Stacja ON;

BULK INSERT Stacja
FROM '/opt/data/T1/Stacja.csv'
WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        TABLOCK
    );

SET IDENTITY_INSERT Stacja OFF;

SET IDENTITY_INSERT Kurs ON;

BULK INSERT Kurs
FROM '/opt/data/T1/Kurs.csv'
WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        TABLOCK
    );

SET IDENTITY_INSERT Kurs OFF;

SET IDENTITY_INSERT Odcinek_kursu ON;

BULK INSERT Odcinek_kursu
FROM '/opt/data/T1/Odcinek_kursu.csv'
WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        TABLOCK
    );

SET IDENTITY_INSERT Odcinek_kursu OFF;

-- SET IDENTITY_INSERT Zdarzenie_na_trasie ON;

-- BULK INSERT Zdarzenie_na_trasie
-- FROM '/opt/data/T1/Zdarzenie_na_trasie.csv'
-- WITH (
--         FORMAT = 'CSV',
--         FIRSTROW = 2,
--         FIELDTERMINATOR = ',',
--         ROWTERMINATOR = '\n',
--         TABLOCK
--     );

-- SET IDENTITY_INSERT Zdarzenie_na_trasie OFF;

-- Re-enable constraints
ALTER TABLE Zdarzenie_na_trasie CHECK CONSTRAINT ALL;

ALTER TABLE Odcinek_kursu CHECK CONSTRAINT ALL;

ALTER TABLE Kurs CHECK CONSTRAINT ALL;

BULK INSERT Weather
FROM '/opt/data/T1/Weather.csv'
WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        TABLOCK
    );