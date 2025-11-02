-- Bulk Load Script for T1 Dataset
-- This script loads all T1 data from CSV files into the database

-- Disable constraints temporarily for faster loading
ALTER TABLE Event_On_Route NOCHECK CONSTRAINT ALL;

ALTER TABLE Ride_Section NOCHECK CONSTRAINT ALL;

ALTER TABLE Ride NOCHECK CONSTRAINT ALL;

ALTER TABLE Weather NOCHECK CONSTRAINT ALL;

-- Disable identity insert to allow specific IDs from CSV
SET IDENTITY_INSERT Train ON;

BULK INSERT Train
FROM '/opt/data/T1/Train.csv'
WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        TABLOCK
    );

SET IDENTITY_INSERT Train OFF;

SET IDENTITY_INSERT Driver ON;

BULK INSERT Driver
FROM '/opt/data/T1/Driver.csv'
WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        TABLOCK
    );

SET IDENTITY_INSERT Driver OFF;

SET IDENTITY_INSERT Crossing ON;

BULK INSERT Crossing
FROM '/opt/data/T1/Crossing.csv'
WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        TABLOCK
    );

SET IDENTITY_INSERT Crossing OFF;

SET IDENTITY_INSERT Event ON;

BULK INSERT Event
FROM '/opt/data/T1/Event.csv'
WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        TABLOCK
    );

SET IDENTITY_INSERT Event OFF;

SET IDENTITY_INSERT Station ON;

BULK INSERT Station
FROM '/opt/data/T1/Station.csv'
WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        TABLOCK
    );

SET IDENTITY_INSERT Station OFF;

SET IDENTITY_INSERT Ride ON;

BULK INSERT Ride
FROM '/opt/data/T1/Ride.csv'
WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        TABLOCK
    );

SET IDENTITY_INSERT Ride OFF;

SET IDENTITY_INSERT Ride_Section ON;

BULK INSERT Ride_Section
FROM '/opt/data/T1/Ride_Section.csv'
WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        TABLOCK
    );

SET IDENTITY_INSERT Ride_Section OFF;

SET IDENTITY_INSERT Weather ON;

BULK INSERT Weather
FROM '/opt/data/T1/weather.csv'
WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        TABLOCK
    );

SET IDENTITY_INSERT Weather OFF;

SET IDENTITY_INSERT Event_On_Route ON;

BULK INSERT Event_On_Route
FROM '/opt/data/T1/Event_On_Route.csv'
WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        TABLOCK
    );

SET IDENTITY_INSERT Event_On_Route OFF;

-- Re-enable constraints
ALTER TABLE Event_On_Route CHECK CONSTRAINT ALL;

ALTER TABLE Ride_Section CHECK CONSTRAINT ALL;

ALTER TABLE Ride CHECK CONSTRAINT ALL;

ALTER TABLE Weather CHECK CONSTRAINT ALL;

-- Display summary
PRINT 'T1 Data Bulk Load Complete';

PRINT 'Train records: ' + CAST(
    (
        SELECT COUNT(*)
        FROM Train
    ) AS VARCHAR
);

PRINT 'Driver records: ' + CAST(
    (
        SELECT COUNT(*)
        FROM Driver
    ) AS VARCHAR
);

PRINT 'Station records: ' + CAST(
    (
        SELECT COUNT(*)
        FROM Station
    ) AS VARCHAR
);

PRINT 'Crossing records: ' + CAST(
    (
        SELECT COUNT(*)
        FROM Crossing
    ) AS VARCHAR
);

PRINT 'Event records: ' + CAST(
    (
        SELECT COUNT(*)
        FROM Event
    ) AS VARCHAR
);

PRINT 'Ride records: ' + CAST(
    (
        SELECT COUNT(*)
        FROM Ride
    ) AS VARCHAR
);

PRINT 'Ride_Section records: ' + CAST(
    (
        SELECT COUNT(*)
        FROM Ride_Section
    ) AS VARCHAR
);

PRINT 'Weather records: ' + CAST(
    (
        SELECT COUNT(*)
        FROM Weather
    ) AS VARCHAR
);

PRINT 'Event_On_Route records: ' + CAST(
    (
        SELECT COUNT(*)
        FROM Event_On_Route
    ) AS VARCHAR
);