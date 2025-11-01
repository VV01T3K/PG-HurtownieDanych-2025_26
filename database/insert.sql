-- INSERTS
INSERT INTO Train (
        name,
        train_type,
        operator_name
    )
VALUES (
        'EIP12345',
        'passenger',
        'PKP Intercity'
    ),
    (
        'IC4302',
        'passenger',
        'PKP Intercity'
    ),
    (
        'CARGO567',
        'cargo',
        'PKP Cargo'
    ),
    (
        'POL100',
        'passenger',
        'POLREGIO'
    );
INSERT INTO Driver (
        first_name,
        last_name,
        gender,
        age,
        employment_year
    )
VALUES (
        'Jan',
        'Kowalski',
        'man',
        45,
        2005
    ),
    (
        'Anna',
        'Nowak',
        'woman',
        38,
        2010
    ),
    (
        'Marek',
        'Wiśniewski',
        'man',
        50,
        2020
    );
INSERT INTO Ride (
        route_name,
        time_difference,
        scheduled_arrival,
        scheduled_departure,
        train_id,
        driver_id
    )
VALUES (
        'Gedania',
        5,
        '2025-10-28 10:00',
        '2025-10-28 14:00',
        1,
        1
    ),
    (
        'Sudety',
        -2,
        '2025-10-29 13:30',
        '2025-10-29 18:00',
        2,
        2
    ),
    (
        'Śląsk Express',
        15,
        '2025-10-28 15:00',
        '2025-10-28 20:45',
        4,
        3
    );
INSERT INTO Station (name, city)
VALUES ('Gdansk Glowny', 'Gdansk'),
    ('Gdansk Wrzeszcz', 'Gdansk'),
    (
        'Warszawa Centralna',
        'Warszawa'
    ),
    ('Katowice', 'Katowice'),
    ('Wroclaw Glowny', 'Wroclaw');
INSERT INTO Ride_Section (
        ride_id,
        section_number,
        departure_station_id,
        arrival_station_id,
        time_difference,
        scheduled_arrival,
        scheduled_departure
    )
VALUES -- 1. Gdańsk Główny -> 2. Gdańsk Wrzeszcz -> 3. Wrocław Główny
    (
        1,
        1,
        NULL,
        1,
        3,
        '2025-10-28 9:58',
        NULL
    ),
    -- pociag mial przyjechac na Gdańsk Główny z zajezdni o 9:58 (3 minut spoznienia czyli przyjechal na stacje o 10:01)
    (
        1,
        2,
        1,
        2,
        16,
        '2025-10-28 10:05',
        '2025-10-28 10:00'
    ),
    -- pociag mial wyjechac z Gdańsk Główny o 10:00 i byc o  10:05 w Gdansk Wrzeszcz (16 spoznienia czyli przyjechal o 10:21)
    (
        1,
        3,
        2,
        5,
        10,
        '2025-10-28 14:00',
        '2025-10-28 10:07'
    ),
    --pociag mial wyjechac z Gdansk Wrzeszcz  o 10:07 i byc o 14:00 w Wroclaw Glowny (10 spoznienia czyli przyjechal o 14:10) dalej nie jedzie
    -- 2. Sudety: Gdańsk Wrzeszcz -> Warszawa Centralna
    (
        2,
        1,
        NULL,
        2,
        0,
        '2025-10-29 09:58',
        NULL
    ),
    (
        2,
        2,
        2,
        3,
        70,
        '2025-10-29 14:00',
        '2025-10-29 10:00'
    ),
    -- 3. Śląsk Express: Katowice -> Gdańsk Wrzeszcz
    (
        3,
        1,
        NULL,
        4,
        0,
        '2025-10-28 09:58',
        NULL
    ),
    (
        3,
        2,
        4,
        2,
        -1,
        '2025-10-28 18:00',
        '2025-10-28 10:00'
    );
--mozliwe przyspieszenie pociagu (roznica czasu = -1)
INSERT INTO Weather (
        ride_section_id,
        measurement_date,
        temperature,
        precipitation_amount,
        precipitation_type
    )
VALUES (
        1,
        '2025-10-28 9:59',
        12.3,
        0,
        'brak'
    ),
    -- w teorii godzina powinna byc gdzies w trakcie tego odcinka przejazdu
    (
        2,
        '2025-10-28 10:07',
        11.8,
        2.5,
        'deszcz'
    ),
    (
        3,
        '2025-10-28 12:00',
        8.5,
        0,
        'snieg'
    ),
    (
        4,
        '2025-10-29 9:58',
        10.2,
        1.1,
        'deszcz'
    ),
    (
        5,
        '2025-10-29 14:00',
        9.0,
        0,
        'brak'
    ),
    (
        6,
        '2025-10-28 9:58',
        15.1,
        3.3,
        'grad'
    ),
    (
        7,
        '2025-10-28 18:00',
        14.0,
        0,
        'brak'
    );
INSERT INTO Crossing (
        has_barriers,
        has_light_signals,
        is_lit,
        speed_limit
    )
VALUES (1, 1, 1, 20),
    (0, 1, 0, 40),
    (1, 0, 1, 70);
INSERT INTO Event (
        event_type,
        category,
        danger_scale
    )
VALUES (
        'accident',
        'pedestrian_hit',
        9
    ),
    -- jakies chat moze dobre inne przypadki wygenerowac
    (
        'incident',
        'technical_failure',
        4
    ),
    (
        'technical',
        'power_outage',
        3
    ),
    (
        'accident',
        'collision_with_train',
        10
    );
INSERT INTO Event_On_Route (
        ride_section_id,
        crossing_id,
        event_id,
        caused_delay,
        injured_count,
        death_count,
        repair_cost,
        emergency_intervention,
        event_date,
        train_speed
    )
VALUES -- Zdarzenie 1: Potrącenie pieszego na przejeździe przy Gdańsku Wrzeszczu
    (
        2,
        1,
        1,
        12,
        1,
        0,
        50000.00,
        1,
        '2025-10-28 10:03',
        50
    ),
    -- Zdarzenie 2: Awaria techniczna na trasie do Wrocławia
    (
        3,
        NULL,
        2,
        5,
        0,
        0,
        15000.00,
        0,
        '2025-10-28 12:15',
        30
    ),
    -- Zdarzenie 3: Kolizja z innym pociągiem w Warszawie Centralnej
    (
        5,
        NULL,
        4,
        60,
        3,
        2,
        200000.00,
        1,
        '2025-10-29 13:55',
        70
    );
--SELECTS
--SELECT * FROM Train;
--SELECT * FROM Driver;
--SELECT * FROM Ride;
--SELECT * FROM Station;
--SELECT * FROM Ride_Section;
--SELECT * FROM Crossing;
--SELECT * FROM Event;
--SELECT * FROM Event_On_Route;
--wszystkie przejazdy
SELECT R.id AS Ride_ID,
    RS.section_number AS Section_Number,
    R.route_name AS Route_Name,
    T.name AS Train_Name,
    T.train_type AS Train_Type,
    T.operator_name AS Operator,
    D.first_name + ' ' + D.last_name AS Driver,
    S1.name AS Departure_Station,
    S1.city AS Departure_City,
    S2.name AS Arrival_Station,
    S2.city AS Arrival_City,
    RS.scheduled_departure AS Scheduled_Departure,
    RS.scheduled_arrival AS Scheduled_Arrival,
    RS.time_difference AS Delay_Minutes,
    W.temperature,
    W.precipitation_amount
FROM Ride R
    JOIN Train T ON R.train_id = T.id
    JOIN Driver D ON R.driver_id = D.id
    JOIN Ride_Section RS ON RS.ride_id = R.id
    LEFT JOIN Station S1 ON RS.departure_station_id = S1.id -- bo stacja  poczatkowa może być NULL (chyba ze zrobimy cos typu zajezdnia na poczatku i koncu)
    JOIN Station S2 ON RS.arrival_station_id = S2.id
    INNER JOIN Weather W ON RS.id = W.ride_section_id
WHERE 1 = 1 --AND R.id = 1 --konkretny przejazd
ORDER BY R.id,
    RS.section_number;
--zdarzenia
SELECT R.id AS Ride_ID,
    RS.section_number AS Section_Number,
    R.route_name AS Route_Name,
    T.name AS Train_Name,
    T.train_type AS Train_Type,
    D.first_name + ' ' + D.last_name AS Driver,
    S1.name AS Departure_Station,
    S2.name AS Arrival_Station,
    RS.scheduled_departure,
    RS.scheduled_arrival,
    W.temperature,
    W.precipitation_type,
    E.event_type,
    E.category,
    E.danger_scale,
    C.speed_limit,
    EOR.event_date,
    EOR.caused_delay,
    EOR.train_speed,
    EOR.injured_count,
    EOR.death_count,
    EOR.repair_cost,
    EOR.emergency_intervention
FROM Ride R
    JOIN Train T ON R.train_id = T.id
    JOIN Driver D ON R.driver_id = D.id
    JOIN Ride_Section RS ON RS.ride_id = R.id
    LEFT JOIN Station S1 ON RS.departure_station_id = S1.id
    JOIN Station S2 ON RS.arrival_station_id = S2.id
    JOIN Weather W ON RS.id = W.ride_section_id
    LEFT JOIN Event_On_Route EOR ON RS.id = EOR.ride_section_id
    JOIN Event E ON EOR.event_id = E.id
    LEFT JOIN Crossing C ON EOR.crossing_id = C.id
WHERE 1 = 1
    AND EOR.id IS NOT NULL --same incydenty
ORDER BY R.id,
    RS.section_number;