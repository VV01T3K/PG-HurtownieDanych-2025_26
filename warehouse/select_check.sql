
USE hurtownia;
SELECT 
    k.id AS kurs_id,
    k.nazwa_trasy,
    d.dzien AS data_dzien,
    d.dzien_tygodnia,
    d.miesiac,
    p.nazwa AS pociag,
    m.imie + ' ' + m.nazwisko AS maszynista,
    s1.nazwa AS stacja_wyjazdowa,
    s2.nazwa AS stacja_dojazdowa,
    CAST(t_odjazdu.godzina AS VARCHAR(2)) + ':' + FORMAT(t_odjazdu.minuta, '00') AS czas_odjazdu,
    CAST(t_przyjazd.godzina AS VARCHAR(2)) + ':' + FORMAT(t_przyjazd.minuta, '00') AS czas_przyjazdu,
    ok.temperatura,
    ok.roznica_czasu AS opoznienie_min,
    ok.ilosc_opadow,
    j.typ_opadow
FROM Odcinek_kursu ok
JOIN Kurs k ON ok.id_kurs = k.id
JOIN Data d ON ok.id_planowa_data_odjazdu = d.id
JOIN Czas t_odjazdu ON ok.id_planowy_czas_odjazdu = t_odjazdu.id
JOIN Czas t_przyjazd ON ok.id_planowy_czas_przyjazdu = t_przyjazd.id
JOIN Pociag p ON ok.id_pociag = p.id
JOIN Maszynista m ON ok.id_maszynista = m.id
JOIN Stacja s1 ON ok.id_stacja_wyjazdowa = s1.id
JOIN Stacja s2 ON ok.id_stacja_wjazdowa = s2.id
JOIN Junk_odcinek_kursu j ON ok.id_junk = j.id
ORDER BY k.id, ok.id;

SELECT 
    zn.id_odcinek_kursu,
    k.id AS kurs_id,
    k.nazwa_trasy,
    d.dzien AS data_zdarzenia,
    d.dzien_tygodnia,
    d.miesiac,
    CAST(t_zdarzenia.godzina AS VARCHAR(2)) + ':' + FORMAT(t_zdarzenia.minuta, '00') AS czas_zdarzenia,
    z.typ_zdarzenia,
    z.kategoria,
    z.skala_niebezpieczenstwa,
    prz.czy_rogatki,
    prz.czy_sygnalizacja_swietlna,
    prz.czy_oswietlony,
    prz.dopuszczalna_predkosc,
    zn.koszt_naprawy,
    zn.predkosc,
    zn.wywolane_opoznienie,
    zn.liczba_rannych,
    zn.liczba_zgonow,
    ji.czy_interwencja_sluzb,
    p.nazwa AS pociag,
    m.imie + ' ' + m.nazwisko AS maszynista,
    s_wyj.nazwa AS stacja_wyjazdowa,
    s_wja.nazwa AS stacja_dojazdowa
FROM Zdarzenie_na_trasie zn
JOIN Odcinek_kursu ok ON zn.id_odcinek_kursu = ok.id
JOIN Kurs k ON ok.id_kurs = k.id
JOIN Zdarzenie z ON zn.id_zdarzenie = z.id
JOIN Przejazd prz ON zn.id_przejazd = prz.id
JOIN Data d ON zn.id_data_zdarzenia = d.id
JOIN Czas t_zdarzenia ON zn.id_czas_zdarzenia = t_zdarzenia.id
JOIN Junk_zdarzenie ji ON zn.id_junk = ji.id
JOIN Pociag p ON ok.id_pociag = p.id
JOIN Maszynista m ON ok.id_maszynista = m.id
JOIN Stacja s_wyj ON ok.id_stacja_wyjazdowa = s_wyj.id
JOIN Stacja s_wja ON ok.id_stacja_wjazdowa = s_wja.id
ORDER BY k.id, zn.id_czas_zdarzenia;