-- Bulk Update/Insert Script for T2 Dataset
-- This script updates existing records and inserts new T2 data
-- T2 contains incremental/updated data that should merge with T1

-- Disable constraints temporarily for faster loading
ALTER TABLE Event_On_Route NOCHECK CONSTRAINT ALL;

ALTER TABLE Ride_Section NOCHECK CONSTRAINT ALL;

ALTER TABLE Ride NOCHECK CONSTRAINT ALL;

ALTER TABLE Weather NOCHECK CONSTRAINT ALL;

-- Load new Train records from T2
CREATE TABLE #Train_Temp (
    id INT,
    name VARCHAR(20),
    train_type VARCHAR(30),
    operator_name VARCHAR(40)
);

BULK INSERT #Train_Temp
FROM '/opt/data/T2/Train.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

SET IDENTITY_INSERT Train ON;

MERGE INTO Train AS target
USING #Train_Temp AS source
ON target.id = source.id
WHEN MATCHED THEN
    UPDATE SET name = source.name, train_type = source.train_type, operator_name = source.operator_name
WHEN NOT MATCHED THEN
    INSERT (id, name, train_type, operator_name) VALUES (source.id, source.name, source.train_type, source.operator_name);

SET IDENTITY_INSERT Train OFF;

DROP TABLE #Train_Temp;

-- Update Driver records from T2
CREATE TABLE #Driver_Temp (
    id INT,
    first_name VARCHAR(30),
    last_name VARCHAR(30),
    gender VARCHAR(10),
    age INT,
    employment_year INT
);

BULK INSERT #Driver_Temp
FROM '/opt/data/T2/Driver.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

SET IDENTITY_INSERT Driver ON;

MERGE INTO Driver AS target
USING #Driver_Temp AS source
ON target.id = source.id
WHEN MATCHED THEN
    UPDATE SET first_name = source.first_name, last_name = source.last_name, gender = source.gender, age = source.age, employment_year = source.employment_year
WHEN NOT MATCHED THEN
    INSERT (id, first_name, last_name, gender, age, employment_year) VALUES (source.id, source.first_name, source.last_name, source.gender, source.age, source.employment_year);

SET IDENTITY_INSERT Driver OFF;

DROP TABLE #Driver_Temp;

-- Update Crossing records from T2
CREATE TABLE #Crossing_Temp (
    id INT,
    has_barriers BIT,
    has_light_signals BIT,
    is_lit BIT,
    speed_limit INT
);

BULK INSERT #Crossing_Temp
FROM '/opt/data/T2/Crossing.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

SET IDENTITY_INSERT Crossing ON;

MERGE INTO Crossing AS target
USING #Crossing_Temp AS source
ON target.id = source.id
WHEN MATCHED THEN
    UPDATE SET has_barriers = source.has_barriers, has_light_signals = source.has_light_signals, is_lit = source.is_lit, speed_limit = source.speed_limit
WHEN NOT MATCHED THEN
    INSERT (id, has_barriers, has_light_signals, is_lit, speed_limit) VALUES (source.id, source.has_barriers, source.has_light_signals, source.is_lit, source.speed_limit);

SET IDENTITY_INSERT Crossing OFF;

DROP TABLE #Crossing_Temp;

-- Update Event records from T2
CREATE TABLE #Event_Temp (
    id INT,
    event_type VARCHAR(30),
    category VARCHAR(40),
    danger_scale INT
);

BULK INSERT #Event_Temp
FROM '/opt/data/T2/Event.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

SET IDENTITY_INSERT Event ON;

MERGE INTO Event AS target
USING #Event_Temp AS source
ON target.id = source.id
WHEN MATCHED THEN
    UPDATE SET event_type = source.event_type, category = source.category, danger_scale = source.danger_scale
WHEN NOT MATCHED THEN
    INSERT (id, event_type, category, danger_scale) VALUES (source.id, source.event_type, source.category, source.danger_scale);

SET IDENTITY_INSERT Event OFF;

DROP TABLE #Event_Temp;

-- Update Station records from T2
CREATE TABLE #Station_Temp (
    id INT,
    name VARCHAR(40),
    city VARCHAR(40)
);

BULK INSERT #Station_Temp
FROM '/opt/data/T2/Station.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

SET IDENTITY_INSERT Station ON;

MERGE INTO Station AS target
USING #Station_Temp AS source
ON target.id = source.id
WHEN MATCHED THEN
    UPDATE SET name = source.name, city = source.city
WHEN NOT MATCHED THEN
    INSERT (id, name, city) VALUES (source.id, source.name, source.city);

SET IDENTITY_INSERT Station OFF;

DROP TABLE #Station_Temp;

-- Merge Ride records from T2
CREATE TABLE #Ride_Temp (
    id INT,
    route_name VARCHAR(40),
    time_difference INT,
    scheduled_departure DATETIME,
    scheduled_arrival DATETIME,
    train_id INT,
    driver_id INT
);

BULK INSERT #Ride_Temp
FROM '/opt/data/T2/Ride.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

SET IDENTITY_INSERT Ride ON;

MERGE INTO Ride AS target
USING #Ride_Temp AS source
ON target.id = source.id
WHEN MATCHED THEN
    UPDATE SET route_name = source.route_name, time_difference = source.time_difference, scheduled_departure = source.scheduled_departure, scheduled_arrival = source.scheduled_arrival, train_id = source.train_id, driver_id = source.driver_id
WHEN NOT MATCHED THEN
    INSERT (id, route_name, time_difference, scheduled_departure, scheduled_arrival, train_id, driver_id) VALUES (source.id, source.route_name, source.time_difference, source.scheduled_departure, source.scheduled_arrival, source.train_id, source.driver_id);

SET IDENTITY_INSERT Ride OFF;

DROP TABLE #Ride_Temp;

-- Merge Ride_Section records from T2
CREATE TABLE #Ride_Section_Temp (
    id BIGINT,
    ride_id INT,
    section_number INT,
    departure_station_id INT,
    arrival_station_id INT,
    time_difference INT,
    scheduled_arrival DATETIME,
    scheduled_departure DATETIME
);

BULK INSERT #Ride_Section_Temp
FROM '/opt/data/T2/Ride_Section.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

SET IDENTITY_INSERT Ride_Section ON;

MERGE INTO Ride_Section AS target
USING #Ride_Section_Temp AS source
ON target.id = source.id
WHEN MATCHED THEN
    UPDATE SET ride_id = source.ride_id, section_number = source.section_number, departure_station_id = source.departure_station_id, arrival_station_id = source.arrival_station_id, time_difference = source.time_difference, scheduled_arrival = source.scheduled_arrival, scheduled_departure = source.scheduled_departure
WHEN NOT MATCHED THEN
    INSERT (id, ride_id, section_number, departure_station_id, arrival_station_id, time_difference, scheduled_arrival, scheduled_departure) VALUES (source.id, source.ride_id, source.section_number, source.departure_station_id, source.arrival_station_id, source.time_difference, source.scheduled_arrival, source.scheduled_departure);

SET IDENTITY_INSERT Ride_Section OFF;

DROP TABLE #Ride_Section_Temp;

-- Merge Weather records from T2
CREATE TABLE #Weather_Temp (
    id BIGINT,
    ride_section_id BIGINT,
    measurement_date DATETIME,
    temperature DECIMAL(4, 1),
    precipitation_amount DECIMAL(4, 1)
);

BULK INSERT #Weather_Temp
FROM '/opt/data/T2/weather.csv'
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
    UPDATE SET ride_section_id = source.ride_section_id, measurement_date = source.measurement_date, temperature = source.temperature, precipitation_amount = source.precipitation_amount
WHEN NOT MATCHED THEN
    INSERT (id, ride_section_id, measurement_date, temperature, precipitation_amount) VALUES (source.id, source.ride_section_id, source.measurement_date, source.temperature, source.precipitation_amount);

SET IDENTITY_INSERT Weather OFF;

DROP TABLE #Weather_Temp;

-- Merge Event_On_Route records from T2
CREATE TABLE #Event_On_Route_Temp (
    id BIGINT,
    ride_section_id BIGINT,
    crossing_id INT,
    event_id INT,
    caused_delay DECIMAL(10, 2),
    injured_count INT,
    death_count INT,
    repair_cost DECIMAL(10, 2),
    emergency_intervention BIT,
    event_date DATETIME,
    train_speed INT
);

BULK INSERT #Event_On_Route_Temp
FROM '/opt/data/T2/Event_On_Route.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

SET IDENTITY_INSERT Event_On_Route ON;

MERGE INTO Event_On_Route AS target
USING #Event_On_Route_Temp AS source
ON target.id = source.id
WHEN MATCHED THEN
    UPDATE SET ride_section_id = source.ride_section_id, crossing_id = source.crossing_id, event_id = source.event_id, caused_delay = source.caused_delay, injured_count = source.injured_count, death_count = source.death_count, repair_cost = source.repair_cost, emergency_intervention = source.emergency_intervention, event_date = source.event_date, train_speed = source.train_speed
WHEN NOT MATCHED THEN
    INSERT (id, ride_section_id, crossing_id, event_id, caused_delay, injured_count, death_count, repair_cost, emergency_intervention, event_date, train_speed) VALUES (source.id, source.ride_section_id, source.crossing_id, source.event_id, source.caused_delay, source.injured_count, source.death_count, source.repair_cost, source.emergency_intervention, source.event_date, source.train_speed);

SET IDENTITY_INSERT Event_On_Route OFF;

DROP TABLE #Event_On_Route_Temp;

-- Re-enable constraints
ALTER TABLE Event_On_Route CHECK CONSTRAINT ALL;

ALTER TABLE Ride_Section CHECK CONSTRAINT ALL;

ALTER TABLE Ride CHECK CONSTRAINT ALL;

ALTER TABLE Weather CHECK CONSTRAINT ALL;

-- Display summary
PRINT 'T2 Data Merge Complete';

PRINT 'Total Train records: ' + CAST(
    (
        SELECT COUNT(*)
        FROM Train
    ) AS VARCHAR
);

PRINT 'Total Driver records: ' + CAST(
    (
        SELECT COUNT(*)
        FROM Driver
    ) AS VARCHAR
);

PRINT 'Total Station records: ' + CAST(
    (
        SELECT COUNT(*)
        FROM Station
    ) AS VARCHAR
);

PRINT 'Total Crossing records: ' + CAST(
    (
        SELECT COUNT(*)
        FROM Crossing
    ) AS VARCHAR
);

PRINT 'Total Event records: ' + CAST(
    (
        SELECT COUNT(*)
        FROM Event
    ) AS VARCHAR
);

PRINT 'Total Ride records: ' + CAST(
    (
        SELECT COUNT(*)
        FROM Ride
    ) AS VARCHAR
);

PRINT 'Total Ride_Section records: ' + CAST(
    (
        SELECT COUNT(*)
        FROM Ride_Section
    ) AS VARCHAR
);

PRINT 'Total Weather records: ' + CAST(
    (
        SELECT COUNT(*)
        FROM Weather
    ) AS VARCHAR
);

PRINT 'Total Event_On_Route records: ' + CAST(
    (
        SELECT COUNT(*)
        FROM Event_On_Route
    ) AS VARCHAR
);