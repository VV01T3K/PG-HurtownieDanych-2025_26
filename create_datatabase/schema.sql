-- DROPS
DROP TABLE IF EXISTS Event_On_Route;
DROP TABLE IF EXISTS Weather;
DROP TABLE IF EXISTS Ride_Section;
DROP TABLE IF EXISTS Ride;
DROP TABLE IF EXISTS Train;
DROP TABLE IF EXISTS Driver;
DROP TABLE IF EXISTS Station;
DROP TABLE IF EXISTS Crossing;
DROP TABLE IF EXISTS Event;
GO -- CREATES
    CREATE TABLE Train (
        id INT IDENTITY(1, 1) PRIMARY KEY,
        name VARCHAR(20) NOT NULL,
        train_type VARCHAR(30) NOT NULL,
        operator_name VARCHAR(40) NOT NULL
    );
CREATE TABLE Driver (
    id INT IDENTITY(1, 1) PRIMARY KEY,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL CHECK (gender IN ('man', 'woman')),
    age INT NOT NULL CHECK (
        age BETWEEN 18 AND 80
    ),
    employment_year INT NOT NULL CHECK (
        employment_year BETWEEN 1900 AND YEAR(GETDATE())
    )
);
CREATE TABLE Crossing (
    id INT IDENTITY(1, 1) PRIMARY KEY,
    has_barriers BIT NOT NULL,
    has_light_signals BIT NOT NULL,
    is_lit BIT NOT NULL,
    speed_limit INT NOT NULL CHECK (
        speed_limit BETWEEN 20 AND 100
    )
);
CREATE TABLE Event (
    id INT IDENTITY(1, 1) PRIMARY KEY,
    event_type VARCHAR(30) NOT NULL,
    category VARCHAR(40) NOT NULL,
    danger_scale INT NOT NULL CHECK (
        danger_scale BETWEEN 1 AND 10
    )
);
CREATE TABLE Ride (
    id INT IDENTITY(1, 1) PRIMARY KEY,
    route_name VARCHAR(40) NOT NULL,
    time_difference INT NOT NULL,
    scheduled_departure DATETIME NOT NULL,
    scheduled_arrival DATETIME,
    --MOZNA BY POZWOLIC NA NULLA JAKO ZE WCALE NIE DOJECHAL 
    train_id INT NOT NULL REFERENCES Train (id),
    driver_id INT NOT NULL REFERENCES Driver (id)
);
CREATE TABLE Station (
    id INT IDENTITY(1, 1) PRIMARY KEY,
    name VARCHAR(40) NOT NULL,
    city VARCHAR(40) NOT NULL
);
CREATE TABLE Ride_Section (
    id BIGINT IDENTITY(1, 1) PRIMARY KEY,
    ride_id INT NOT NULL REFERENCES Ride (id),
    section_number INT NOT NULL,
    departure_station_id INT REFERENCES Station (id),
    arrival_station_id INT NOT NULL REFERENCES Station (id),
    time_difference INT NOT NULL,
    scheduled_arrival DATETIME NOT NULL,
    scheduled_departure DATETIME,
    CONSTRAINT chk_arrival_after_departure CHECK (
        scheduled_departure IS NULL
        OR scheduled_arrival > scheduled_departure
    )
);
CREATE TABLE Weather (
    --pogladowo chociaz to bedzie w tym .CSV (w teorii mozna by sie pozbyc tych NOT NULLI ale moze niech beda dla wszystkich)
    id BIGINT IDENTITY(1, 1) PRIMARY KEY,
    ride_section_id BIGINT NOT NULL REFERENCES Ride_Section (id),
    -- w hurtowni to raczej ten klucz obcy bedzie po stronie przejazdu
    measurement_date DATETIME NOT NULL,
    temperature DECIMAL(4, 1) NOT NULL CHECK (
        temperature BETWEEN -30 AND 50
    ),
    precipitation_amount DECIMAL(4, 1) NOT NULL CHECK (
        precipitation_amount BETWEEN 0 AND 30
    ),
    -- [mm/h]
    precipitation_type VARCHAR(10) NOT NULL CHECK (
        precipitation_type IN (
            'deszcz',
            'snieg',
            'grad',
            'brak'
        )
    )
);
CREATE TABLE Event_On_Route (
    id BIGINT IDENTITY(1, 1) PRIMARY KEY,
    ride_section_id BIGINT NOT NULL REFERENCES Ride_Section (id),
    crossing_id INT REFERENCES Crossing (id),
    --niektore zdarzenia moga nie byc na przejezdzie 
    event_id INT NOT NULL REFERENCES Event (id),
    caused_delay INT NOT NULL,
    injured_count INT NOT NULL,
    death_count INT NOT NULL,
    repair_cost DECIMAL(10, 2) NOT NULL,
    emergency_intervention BIT NOT NULL,
    event_date DATETIME NOT NULL,
    train_speed INT NOT NULL
);