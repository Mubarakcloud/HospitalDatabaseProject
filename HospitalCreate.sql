--drop
DROP TABLE zab_prac CASCADE CONSTRAINTS;
DROP TABLE zabiegi CASCADE CONSTRAINTS;
DROP TABLE kart_lek CASCADE CONSTRAINTS;
DROP TABLE leki CASCADE CONSTRAINTS;
DROP TABLE badanie CASCADE CONSTRAINTS;
DROP TABLE karta_choroby CASCADE CONSTRAINTS;
DROP TABLE pacjent CASCADE CONSTRAINTS;
DROP TABLE sala CASCADE CONSTRAINTS;
DROP TABLE dyzur CASCADE CONSTRAINTS;
DROP TABLE lekarz CASCADE CONSTRAINTS;
DROP TABLE pracownik CASCADE CONSTRAINTS;
DROP TABLE oddzial CASCADE CONSTRAINTS;
--create

CREATE TABLE oddzial (
    id_oddzialu NUMBER CONSTRAINT oddzial_pk PRIMARY KEY,
    nazwa_oddzialu VARCHAR2(100) NOT NULL CONSTRAINT nazwa_oddzialu_unique UNIQUE,
    miasto VARCHAR2(50) NOT NULL,
    ulica VARCHAR2(50) NOT NULL,
    number_budynku NUMBER(3) NOT NULL,
    kod_pocztowy VARCHAR2(6) NOT NULL
);

CREATE TABLE pracownik (
    id_pracownika NUMBER CONSTRAINT pracownik_pk PRIMARY KEY,
    id_oddzialu NUMBER NOT NULL CONSTRAINT oddzial_pracownik_fk REFERENCES oddzial(id_oddzialu),
    imie VARCHAR2(20) NOT NULL,
    nazwisko VARCHAR2(50) NOT NULL,
    stanowisko VARCHAR2(20) NOT NULL,
    wynagrodzenie NUMBER NOT NULL CONSTRAINT wynagrodzenie_check CHECK(wynagrodzenie > 0 AND wynagrodzenie < 99999),
    numer_telefonu VARCHAR2(9)
);


CREATE TABLE lekarz (
    id_lekarza NUMBER CONSTRAINT lekarz_pk PRIMARY KEY,
    id_pracownika NUMBER NOT NULL CONSTRAINT lekarz_pracownik_fk REFERENCES pracownik(id_pracownika),
    specializacja VARCHAR2(20) NOT NULL,
    gabinet VARCHAR2(4) NOT NULL, --LUB NUMBER SAM NIE WIEM BO MOzE BYc POKoJ 120c
    miejsce_parkingowe VARCHAR2(4) --TO CO WYzEJ
);

CREATE TABLE dyzur (
    id_lekarza NUMBER NOT NULL CONSTRAINT lekarz_dyzur_fk REFERENCES lekarz(id_lekarza),
    data_rozpoczecia DATE DEFAULT SYSDATE NOT NULL,
    data_zakonczenia DATE,
    uwagi VARCHAR2(300)
);

CREATE TABLE sala (
    id_sali NUMBER CONSTRAINT sala_pk PRIMARY KEY,
    id_oddzialu NUMBER NOT NULL CONSTRAINT sala_oddzial_fk REFERENCES oddzial(id_oddzialu),
    numer_sali VARCHAR2(4) NOT NULL, --LUB NUMBER
    rodzaj_sali VARCHAR2(20) NOT NULL,
    liczba_lozek NUMBER,
    opiekun NUMBER CONSTRAINT  opiekun_fk REFERENCES lekarz(id_lekarza)
);

CREATE TABLE pacjent (
    PESEL NUMBER(11) CONSTRAINT pacjent_pk PRIMARY KEY,
    imie VARCHAR2(20) NOT NULL,
    nazwisko VARCHAR2(50) NOT NULL,
    data_rejestracji DATE DEFAULT SYSDATE  NOT NULL,
    numer_telefonu VARCHAR(9)
);

CREATE TABLE karta_choroby (
    id_karty NUMBER CONSTRAINT karta_chorby_pk PRIMARY KEY,
    pacjent NUMBER(11) NOT NULL CONSTRAINT karta_chorby_fk REFERENCES pacjent(PESEL),
    lekarz_prowadzacy NUMBER CONSTRAINT lekarz_prowadzacy_fk REFERENCES lekarz(id_lekarza),
    sala NUMBER NOT NULL CONSTRAINT karta_chory_sala_fk REFERENCES sala(id_sali),
    data_przyjecia DATE  DEFAULT SYSDATE NOT NULL,
    data_wypisu DATE DEFAULT SYSDATE,
    diagnoza VARCHAR2(100),
    objawy VARCHAR(500)
);

CREATE TABLE badanie (
    id_karty NOT NULL CONSTRAINT badanie_karta_fk REFERENCES karta_choroby(id_karty),
    id_pracownika NOT NULL CONSTRAINT badanie_pracownik_fk REFERENCES pracownik(id_pracownika),
    data_badania DATE DEFAULT SYSDATE NOT NULL,
    wzrost NUMBER(3) NOT NULL,
    tetno VARCHAR2(10) NOT NULL,
    uwagi VARCHAR2(300),
    badanie_wstepne_flg NUMBER(1) DEFAULT 0
);

CREATE TABLE leki (
    id_leku NUMBER CONSTRAINT lek_pk PRIMARY KEY,
    nazwa_leku VARCHAR2(30) NOT NULL,
    zalecanie_dawkowanie VARCHAR(20) NOT NULL,
    dostepnosc NUMBER NOT NULL CONSTRAINT dostepnosc_check CHECK(dostepnosc >=0),
    uwagi VARCHAR2(300)
);

CREATE TABLE kart_lek (
    id_karty NUMBER NOT NULL CONSTRAINT lek_id_karty_fk REFERENCES karta_choroby(id_karty),
    podany_lek NUMBER NOT NULL CONSTRAINT podany_lek_fk REFERENCES leki(id_leku),
    podana_dawnka VARCHAR2(10) NOT NULL
);

CREATE TABLE zabiegi (
    id_zabiegu NUMBER CONSTRAINT zabiegi_pk PRIMARY KEY,
    data_zabiegu DATE DEFAULT SYSDATE NOT NULL,
    typ_zabiegu VARCHAR2(20) NOT NULL,
    spodziewany_czas_trwania DATE NOT NULL,
    sala NUMBER NOT NULL CONSTRAINT zabieg_sala_fk REFERENCES sala(id_sali)
);

CREATE TABLE zab_prac (
    id_zabiegu NUMBER NOT NULL CONSTRAINT zabieg_fk REFERENCES zabiegi(id_zabiegu),
    id_pracownika NUMBER NOT NULL CONSTRAINT zabieg_pracownik_fk REFERENCES pracownik(id_pracownika)
);