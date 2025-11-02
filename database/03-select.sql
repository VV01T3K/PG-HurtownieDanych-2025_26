--SELECTS

--SELECT * FROM Pociag;
--SELECT * FROM Maszynista;
--SELECT * FROM Kurs;
--SELECT * FROM Stacja;
--SELECT * FROM Odcinek_kursu;
--SELECT * FROM Przejazd;
--SELECT * FROM Zdarzenie;
--SELECT * FROM Zdarzenie_na_trasie;

--wszystkie przejazdy 
SELECT
    K.id AS Kurs_ID,
    OK.numer_etapu_kursu AS Numer_Etapu,
    K.nazwa_trasy AS Nazwa_Trasy,
    P.nazwa AS Nazwa_Pociagu,
    P.typ_pociagu AS Typ_Pociagu,
    P.operator AS Operator,
    M.imie + ' ' + M.nazwisko AS Maszynista,
    S1.nazwa AS Stacja_Wyjazdowa,
    S1.miasto AS Miasto_Wyjazdowe,
    S2.nazwa AS Stacja_Wjazdowa,
    S2.miasto AS Miasto_Wjazdowe,
    OK.planowa_data_odjazdu AS Planowana_Data_Odjazdu,
    OK.planowa_data_przyjazdu AS Planowana_Data_Przyjazdu,
    OK.roznica_czasu AS Roznica_Czasu_Minut,
    W.temperatura,
    W.ilosc_opadow
FROM Kurs K
    JOIN Pociag P ON K.pociag_id = P.id
    JOIN Maszynista M ON K.maszynista_id = M.id
    JOIN Odcinek_kursu OK ON OK.kurs_id = K.id
    LEFT JOIN Stacja S1 ON OK.stacja_wyjazdowa_id = S1.id -- bo stacja poczatkowa może być NULL
    JOIN Stacja S2 ON OK.stacja_wjazdowa_id = S2.id
    INNER JOIN Weather W ON OK.id = W.id_odcinka
WHERE 1=1
--AND K.id = 1 --konkretny kurs
ORDER BY K.id, OK.numer_etapu_kursu;

--zdarzenia
SELECT
    K.id AS Kurs_ID,
    OK.numer_etapu_kursu AS Numer_Etapu,
    K.nazwa_trasy AS Nazwa_Trasy,
    P.nazwa AS Nazwa_Pociagu,
    P.typ_pociagu AS Typ_Pociagu,
    M.imie + ' ' + M.nazwisko AS Maszynista,
    S1.nazwa AS Stacja_Wyjazdowa,
    S2.nazwa AS Stacja_Wjazdowa,
    OK.planowa_data_odjazdu,
    OK.planowa_data_przyjazdu,
    W.temperatura,
    W.typ_opadow,
    Z.typ_zdarzenia,
    Z.kategoria,
    Z.skala_niebezpieczenstwa,
    Prz.dopuszczalna_predkosc,
    ZNT.data,
    ZNT.wywolane_opoznienie,
    ZNT.predkosc,
    ZNT.liczba_rannych,
    ZNT.liczba_zgonow,
    ZNT.koszt_naprawy,
    ZNT.czy_interwencja_sluzb
FROM Kurs K
    JOIN Pociag P ON K.pociag_id = P.id
    JOIN Maszynista M ON K.maszynista_id = M.id
    JOIN Odcinek_kursu OK ON OK.kurs_id = K.id
    LEFT JOIN Stacja S1 ON OK.stacja_wyjazdowa_id = S1.id
    JOIN Stacja S2 ON OK.stacja_wjazdowa_id = S2.id
    JOIN Weather W ON OK.id = W.id_odcinka
    LEFT JOIN Zdarzenie_na_trasie ZNT ON OK.id = ZNT.odcinek_kursu_id
    JOIN Zdarzenie Z ON ZNT.zdarzenie_id = Z.id
    LEFT JOIN Przejazd Prz ON ZNT.przejazd_id = Prz.id
WHERE 1=1
    AND ZNT.id IS NOT NULL
--tylko zdarzenia
ORDER BY K.id, OK.numer_etapu_kursu;