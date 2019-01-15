CREATE OR REPLACE VIEW Dzisiejsze_badania 
AS 
SELECT * FROM Badanie 
    WHERE Badanie.data_badania = SYSDATE;

CREATE OR REPLACE VIEW Dzisejsze_dyzury 
AS 
SELECT * FROM Dyzur
    WHERE Dyzur.data_rozpoczecia = SYSDATE;

CREATE OR REPLACE VIEW Lekarze_z_zabiegami_dzisiaj 
AS 
SELECT p.imie, p.nazwisko, p.numer_telefonu, o.nazwa_oddzialu FROM Zabiegi z 
    JOIN zab_prac zp ON z.id_zabiegu = zp.id_zabiegu 
    JOIN pracownik p ON p.id_pracownika = zp.id_pracownika
    JOIN oddzial o ON o.id_oddzialu = z.id_oddzialu
    WHERE z.data_zabiegu = SYSDATE AND p.stanowisko = 'Lekarz';

CREATE OR REPLACE VIEW Zaplanowane_zabiegi
AS
SELECT z.data_zabiegu, z.typ_zabiegu, z.spodziewany_czas_trwania, o.nazwa_oddzialu, s.numer_sali FROM Zabiegi z
    JOIN sala s ON s.id_sali = z.sala
    JOIN oddzial o ON o.id_oddzialu = s.id_oddzialu 
    WHERE z.data_zabiegu > SYSDATE;

CREATE OR REPLACE VIEW Podane_leki_przez_lekarza
AS
SELECT l.nazwa_leku, l.dostepnosc, l.uwagi, p.imie, p.nazwisko, lk.specjalizacja, lk.gabinet FROM Leki l
    JOIN kart_lek kl ON l.id_leku = kl.podany_lek
    JOIN karta_choroby kch ON kch.id_karty = kl.id_karty
    JOIN Lekarz lk ON lk.id_lekarza = kch.lekarz_prowadzacy
    JOIN Pracownik p ON p.id_pracownika = lk.id_pracownika

CREATE OR REPLACE VIEW Pacjenci_na_miejscu
AS
SELECT p.imie, p.nazwisko, o.nazwa_oddzialu, s.numer_sali FROM Pacjent p
    JOIN karta_choroby kch ON kch.pacjent = p.pesel
    JOIN sala s ON s.id_sali = kch.sala
    JOIN oddzial o ON o.id_oddzialu = s.id_oddzialu