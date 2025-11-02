CSV File Format: weather.csv

Column Headers:
id_odcinka,data_pomiaru,temperatura,ilosc_opadow,typ_opadow

Data Types:
- id_odcinka: integer (foreign key to Odcinek_kursu)
- data_pomiaru: timestamp (ISO 8601 format: YYYY-MM-DD HH:MM:SS)
- temperatura: double (one decimal place, Celsius)
- ilosc_opadow: integer (mm/h)
- typ_opadow: string (deszcz, snieg, grad, brak)

Example Rows:
id_odcinka,data_pomiaru,temperatura,ilosc_opadow,typ_opadow
1,2025-01-15 08:30:00,5.2,0,brak
2,2025-01-15 08:35:00,4.8,2,deszcz
3,2025-01-15 08:40:00,2.1,8,snieg
4,2025-01-15 08:45:00,-1.5,5,grad