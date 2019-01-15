--B A R D Z O  W A Z N E !
SET SERVEROUTPUT ON;
--Dodawanie pacjenta

CREATE OR REPLACE PROCEDURE dodaj_pacjenta (
    PESEL_pacjenta pacjent.PESEL%TYPE,
    imie_pacjenta pacjent.imie%TYPE,
    nazwisko_pacjenta pacjent.nazwisko%TYPE,
    numer_telefonu_pacjenta pacjent.numer_telefonu%TYPE
    )
IS
    szukana_osoba pacjent%ROWTYPE;
BEGIN
    SELECT * INTO szukana_osoba FROM pacjent WHERE PESEL_pacjenta = pacjent.PESEL;
    dbms_output.ENABLE;
    dbms_output.put_line('Pacjent istnieje, zamiast tego przyjmij pacjenta');
    EXCEPTION WHEN No_Data_Found THEN
        INSERT INTO pacjent VALUES (PESEL_pacjenta, imie_pacjenta, nazwisko_pacjenta, sysdate, numer_telefonu_pacjenta);
END;
/
--Przyjmowanie pacjenta
CREATE OR REPLACE FUNCTION uzyskaj_id_oddzialu (nazwa_szukanego_oddzialu oddzial.nazwa_oddzialu%TYPE)
RETURN oddzial.id_oddzialu%TYPE
IS
    tmp oddzial%ROWTYPE;
BEGIN
    SELECT * INTO tmp FROM oddzial WHERE oddzial.nazwa_oddzialu = nazwa_szukanego_oddzialu;
    RETURN tmp.id_oddzialu;
    EXCEPTION WHEN No_Data_Found THEN
        RETURN 0;
END;
/

CREATE OR REPLACE FUNCTION szukaj_sali (
    nazwa_szukanego_oddzialu oddzial.nazwa_oddzialu%TYPE,
    numer_szukanej_sali sala.numer_sali%TYPE
    )
RETURN sala.id_sali%TYPE
IS
    id_oddzialu_sali oddzial.id_oddzialu%TYPE;
    tmp sala%ROWTYPE;
    nie_ma_oddzialu EXCEPTION;
BEGIN
    id_oddzialu_sali := uzyskaj_id_oddzialu(nazwa_szukanego_oddzialu);
    IF id_oddzialu_sali != 0 THEN
        BEGIN
            SELECT * INTO tmp FROM sala 
                WHERE sala.id_oddzialu = id_oddzialu_sali AND sala.numer_sali = numer_szukanej_sali;
        EXCEPTION when No_Data_Found THEN
            RETURN 0;
        END;
    ELSE 
        RAISE nie_ma_oddzialu;
    END IF;
    RETURN tmp.id_sali;
    EXCEPTION WHEN nie_ma_oddzialu THEN
        RETURN -1;
END;
/
        
CREATE OR REPLACE FUNCTION sprawdz_karte_choroby (PESEL_pacjenta pacjent.PESEL%TYPE)
RETURN BOOLEAN
IS
    CURSOR cur IS
        SELECT * FROM karta_choroby WHERE karta_choroby.pacjent = PESEL_pacjenta AND karta_choroby.data_wypisu IS NULL;
    wynik BOOLEAN;
    it NUMBER := 0;
        
BEGIN
    FOR tmp IN cur LOOP
        it := it + 1;
    END LOOP;
    IF it = 0 THEN wynik := TRUE;
    ELSE wynik := FALSE;
    END IF;
    RETURN wynik;
END;
/

CREATE OR REPLACE PROCEDURE przyjmij_pacjenta (
    PESEL_pacjenta pacjent.PESEL%TYPE,
    nazwa_oddzialu_pacjenta oddzial.nazwa_oddzialu%TYPE,
    numer_sali_pacjenta sala.numer_sali%TYPE
)
IS
    tmp karta_choroby%ROWTYPE;
    tmp_pacjent pacjent%ROWTYPE;
    id_szukanej_sali NUMBER; 
    pacjent_przyjety EXCEPTION;
    nie_ma_oddzalu EXCEPTION;
    nie_ma_sali EXCEPTION;
BEGIN
    SELECT * INTO tmp_pacjent FROM pacjent WHERE pacjent.PESEL = PESEL_pacjenta;
    
    IF sprawdz_karte_choroby(PESEL_pacjenta) THEN
        BEGIN
            id_szukanej_sali := szukaj_sali( nazwa_oddzialu_pacjenta, numer_sali_pacjenta);
            IF id_szukanej_sali = 0 THEN
                RAISE nie_ma_sali;
            ELSIF id_szukanej_sali = -1 THEN
                RAISE nie_ma_oddzalu;
            ELSE 
                INSERT INTO karta_choroby VALUES (karta_id_seq.NEXTVAL, PESEL_pacjenta, NULL, id_szukanej_sali, sysdate, NULL, NULL, NULL);
            END IF;
            
            EXCEPTION WHEN nie_ma_sali THEN
                dbms_output.ENABLE;
                dbms_output.put_line('Nie ma takiej sali');
            WHEN nie_ma_oddzalu THEN 
                dbms_output.ENABLE;
                dbms_output.put_line('Nie ma takiego oddzalu!');
        END;
    ELSE 
        RAISE pacjent_przyjety;
    END IF;
    
    EXCEPTION WHEN pacjent_przyjety THEN
        dbms_output.ENABLE;
        dbms_output.put_line('Taki pacient zostal przyjety!');
    WHEN No_Data_Found THEN
        dbms_output.ENABLE;
        dbms_output.put_line('Taki pacient nie istnieje!');
END;
/
--dodaj badanie
CREATE OR REPLACE FUNCTION znajdz_pracownika(
    imie_pracownika pracownik.imie%TYPE,
    nazwisko_pracownika pracownik.nazwisko%TYPE
    )
    RETURN NUMBER
    IS
        tmp pracownik.id_pracownika%TYPE;    
    BEGIN
        SELECT p.id_pracownika INTO tmp FROM pracownik p WHERE p.imie = imie_pracownika AND p.nazwisko = nazwisko_pracownika;
        IF tmp = 0 THEN
            RAISE no_data_found;
        ELSE RETURN tmp;
        END IF;
        EXCEPTION WHEN No_data_found THEN
            RETURN 0;
END;
/

CREATE OR REPLACE PROCEDURE dodaj_badanie(
    PESEL_pacjenta badanie.id_karty%TYPE,
    wzrost_pacjenta badanie.wzrost%TYPE,
    tetno_pacjenta badanie.tetno%TYPE,
    uwagi_pacjenta badanie.uwagi%TYPE,
    badanie_wstepne_pacjenta badanie.badanie_wstepne_flg%TYPE,
    imie_pracownika pracownik.imie%TYPE,
    nazwisko_pracownika pracownik.nazwisko%TYPE
)
IS
    id_karty_pacjenta karta_choroby.id_karty%TYPE;
    id_szukanego_pracownika pracownik.id_pracownika%TYPE;
    karta_istnieje BOOLEAN;
    nie_ma_karty EXCEPTION;
    nie_ma_pracownika EXCEPTION;
BEGIN
    id_szukanego_pracownika := znajdz_pracownika(imie_pracownika,nazwisko_pracownika);
    IF id_szukanego_pracownika = 0 THEN
        RAISE nie_ma_pracownika;
    ELSE
        BEGIN
        karta_istnieje := sprawdz_karte_choroby(PESEL_pacjenta);
        IF karta_istnieje = TRUE THEN
            RAISE nie_ma_karty;
        ELSE
            SELECT id_karty INTO id_karty_pacjenta FROM karta_choroby WHERE karta_choroby.pacjent = PESEL_pacjenta; 
            INSERT INTO badanie VALUES(id_karty_pacjenta, id_szukanego_pracownika, sysdate, wzrost_pacjenta, tetno_pacjenta, uwagi_pacjenta, badanie_wstepne_pacjenta);
        END IF;
        EXCEPTION WHEN nie_ma_karty THEN 
        dbms_output.ENABLE;
        dbms_output.put_line('Nie ma takiego pacjenta');
        END;
    END IF; 
    EXCEPTION WHEN nie_ma_pracownika THEN
        dbms_output.ENABLE;
        dbms_output.put_line('Nie ma takiego pracownika');
END;
/
--dodaj zabieg
CREATE OR REPLACE FUNCTION znajdz_sale(
    p_numer_sali sala.numer_sali%TYPE
)
RETURN NUMBER
IS
    tmp sala.id_sali%TYPE;
BEGIN
    BEGIN
        SELECT id_sali INTO tmp FROM sala WHERE p_numer_sali=sala.numer_sali;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            tmp:=NULL;
    END;
    RETURN tmp;
END;
/

CREATE OR REPLACE FUNCTION znajdz_rodzaj_sali(
    p_id_sali sala.id_sali%TYPE
)
RETURN sala.rodzaj_sali%TYPE
IS
    tmp sala.rodzaj_sali%TYPE;
BEGIN
    SELECT rodzaj_sali INTO tmp FROM sala WHERE id_sali=p_id_sali;
    RETURN tmp;
END;
/
CREATE OR REPLACE FUNCTION znajdz_najwieksze_id_zabiegu
RETURN zabiegi.id_zabiegu%TYPE
IS 
    tmp zabiegi.id_zabiegu%TYPE;
BEGIN
    SELECT MAX(id_zabiegu) INTO tmp FROM zabiegi;
    IF tmp IS NULL THEN
        tmp:=0;
    END IF;
    RETURN tmp;
END;
/
CREATE OR REPLACE PROCEDURE dodaj_zabieg(
    p_data_zabiegu zabiegi.data_zabiegu%TYPE,
    p_typ_zabiegu zabiegi.typ_zabiegu%TYPE,
    p_spodziewany_czas_trwania zabiegi.typ_zabiegu%TYPE,
    p_numer_sali sala.numer_sali%TYPE
)
IS
    tmp_data_poczatku zabiegi.data_zabiegu%TYPE;
    tmp_data_konca zabiegi.spodziewany_czas_trwania%TYPE;
    p_id_sali zabiegi.sala%TYPE;
    p_id_zabiegu zabiegi.id_zabiegu%TYPE;
    sala_zajeta EXCEPTION;
    nie_ma_sali EXCEPTION;
    sala_nie_zabiegowa EXCEPTION;
    czas EXCEPTION;
BEGIN
    p_id_zabiegu:=znajdz_najwieksze_id_zabiegu();
    p_id_zabiegu:=p_id_zabiegu+1;
    p_id_sali:=znajdz_sale(p_numer_sali);
    BEGIN
        SELECT data_zabiegu INTO tmp_data_poczatku FROM zabiegi WHERE p_id_sali=sala;
        SELECT spodziewany_czas_trwania INTO tmp_data_konca FROM zabiegi WHERE p_id_sali=sala;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            tmp_data_poczatku:=NULL;
            tmp_data_konca:=NULL;
    END;
    IF p_id_sali IS NULL THEN
        RAISE nie_ma_sali;
    ELSIF p_data_zabiegu>p_spodziewany_czas_trwania THEN
        RAISE czas;
    ELSIF znajdz_rodzaj_sali(p_id_sali) NOT LIKE 'Zabiegowe' AND znajdz_rodzaj_sali(p_id_sali) NOT LIKE 'Operacyjne' THEN
        RAISE sala_nie_zabiegowa;
    ELSIF (tmp_data_poczatku IS NOT NULL AND tmp_data_konca IS NOT NULL) OR (p_data_zabiegu>=tmp_data_poczatku AND p_data_zabiegu<=tmp_data_konca) OR p_spodziewany_czas_trwania>=tmp_data_poczatku THEN
        RAISE sala_zajeta;
    ELSE 
        INSERT INTO zabiegi VALUES(p_id_zabiegu, p_data_zabiegu, p_typ_zabiegu, p_spodziewany_czas_trwania, p_id_sali);
    END IF;
    EXCEPTION WHEN sala_zajeta THEN
        dbms_output.ENABLE;
        dbms_output.put_line('Ta sala jest juz zarezerwowana!');
    WHEN nie_ma_sali THEN
        dbms_output.ENABLE;
        dbms_output.put_line('Taka sala nie istnieje');
    WHEN sala_nie_zabiegowa THEN
        dbms_output.ENABLE;
        dbms_output.put_line('Wybrana sala nie jest zabiegowa!');
    WHEN czas THEN
        dbms_output.ENABLE;
        dbms_output.put_line('Data konca zabiegu nie moze byc mniejsza nic data poczatku');
END;
/
EXEC dodaj_zabieg(TO_DATE('2019/01/14', 'YYYY/MM/DD'), 'leczenie', TO_DATE('2019/01/16', 'YYYY/MM/DD'), '2a');
select * from zabiegi;

-- Wypisujemy pacjentów z diagnozą - zgon. 

CREATE OR REPLACE PROCEDURE wypisz_martwych
IS 
    CURSOR martwi_pacjenci IS SELECT * FROM karta_choroby WHERE karta_choroby.diagnoza = 'Zgon' FOR UPDATE;
BEGIN
    FOR tmp IN martwi_pacjenci LOOP
        UPDATE karta_choroby SET data_wypisu = SYSDATE WHERE CURRENT OF martwi_pacjenci;
    END LOOP;
END;
/

CREATE OR REPLACE PROCEDURE karty_bez_badania_wstepnego
IS
    CURSOR karta_choroby_cur IS SELECT * FROM karta_choroby;
    pacjent_bez_badania_wstepnego karta_choroby%ROWTYPE;
    row_badanie badanie%ROWTYPE;
BEGIN
    FOR tmp IN karta_choroby_cur LOOP
        pacjent_bez_badania_wstepnego := tmp;
        SELECT * INTO row_badanie FROM badanie WHERE tmp.id_karty = badanie.id_karty;
    END LOOP;
EXCEPTION WHEN No_Data_Found THEN
        dbms_output.ENABLE;
        dbms_output.put_line('Pacjent o id karty ' || pacjent_bez_badania_wstepnego.id_karty || ' nie ma  badania wstępnego.');    
END;
/

CREATE 