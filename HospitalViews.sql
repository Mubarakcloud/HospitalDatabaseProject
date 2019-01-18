CREATE OR REPLACE VIEW dyzury_w_okresie
AS
SELECT p.imie, p.nazwisko, p.pesel,d.data_rozpoczecia, d.data_zakonczenia FROM dyzur d
    JOIN Lekarz l ON l.id_lekarza = d.id_lekarza
    JOIN Pracownik p ON p.id_pracownika = l.id_pracownika;

CREATE OR REPLACE VIEW Pracownicy_oddzialu
AS
SELECT p.imie, p.nazwisko, p.pesel, p.stanowisko, o.nazwa_oddzialu FROM Pracownik p
    JOIN oddzial o ON o.id_oddzialu = p.id_oddzialu;

CREATE OR REPLACE VIEW zabiegi_dzisiaj 
AS 
SELECT p.imie, p.nazwisko, p.numer_telefonu, o.nazwa_oddzialu FROM Zabiegi z 
    JOIN zab_prac zp ON z.id_zabiegu = zp.id_zabiegu 
    JOIN pracownik p ON p.id_pracownika = zp.id_pracownika
    JOIN oddzial o ON o.id_oddzialu = p.id_oddzialu
    WHERE TO_CHAR(z.data_zabiegu, 'yyyy/mm/dd') = TO_CHAR(SYSDATE, 'yyyy/mm/dd')
    AND p.stanowisko = 'Lekarz';

CREATE OR REPLACE VIEW Zaplanowane_zabiegi
AS
SELECT z.data_zabiegu, z.typ_zabiegu, z.spodziewane_zakonczenie, o.nazwa_oddzialu, s.numer_sali FROM Zabiegi z
    JOIN sala s ON s.id_sali = z.sala
    JOIN oddzial o ON o.id_oddzialu = s.id_oddzialu 
    WHERE z.data_zabiegu > SYSDATE;

CREATE OR REPLACE VIEW Podane_leki_przez_lekarza 
AS
SELECT l.nazwa_leku, l.dostepnosc, l.uwagi, p.imie, p.nazwisko, p.pesel, lk.specjalizacja, lk.gabinet FROM Leki l
    JOIN kart_lek kl ON l.id_leku = kl.podany_lek
    JOIN karta_choroby kch ON kch.id_karty = kl.id_karty
    JOIN Lekarz lk ON lk.id_lekarza = kch.lekarz_prowadzacy
    JOIN Pracownik p ON p.id_pracownika = lk.id_pracownika;

CREATE OR REPLACE VIEW Pacjenci_na_miejscu
AS
SELECT p.imie, p.nazwisko, p.pesel, o.nazwa_oddzialu, s.numer_sali FROM Pacjent p
    JOIN karta_choroby kch ON kch.pacjent = p.pesel
    JOIN sala s ON s.id_sali = kch.sala
    JOIN oddzial o ON o.id_oddzialu = s.id_oddzialu
    WHERE kch.data_wypisu IS NULL;