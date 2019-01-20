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

CREATE OR REPLACE FUNCTION dodaj_sale (
    PESEL_pacjenta pacjent.PESEL%TYPE,
    nazwa_oddzialu_pacjenta oddzial.nazwa_oddzialu%TYPE,
    numer_sali_pacjenta sala.numer_sali%TYPE
)
RETURN NUMBER
IS
    problem_sala EXCEPTION;
    id_szuk_sali NUMBER;
    tmp_pacjent pacjent%rowtype;
BEGIN
    SELECT * INTO tmp_pacjent FROM pacjent WHERE pacjent.pesel = PESEL_pacjenta;
    id_szuk_sali := szukaj_sali(nazwa_oddzialu_pacjenta, numer_sali_pacjenta);
    IF id_szuk_sali <= 0 THEN
        raise problem_sala;
    ELSE
        UPDATE karta_choroby SET sala = id_szuk_sali WHERE karta_choroby.pacjent = PESEL_pacjenta;
    END IF;

    return 0;

EXCEPTION WHEN No_data_found THEN
    return -3;
WHEN problem_sala THEN
    return id_szuk_sali - 1;
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

--wypisz pacjenta

CREATE OR REPLACE PROCEDURE wypisz_pacjenta(PESEL_pacjenta karta_choroby.pacjent%TYPE)
IS BEGIN
    IF sprawdz_karte_choroby(PESEL_pacjenta) THEN
        dbms_output.ENABLE;
        dbms_output.put_line('Pacjent nie istnieje lub zosta³ ju¿ wypisany');
    ELSE 
        UPDATE karta_choroby SET karta_choroby.data_wypisu = sysdate WHERE karta_choroby.pacjent = PESEL_pacjenta;
    END IF;
END;
/

--dodaj objawy lub diagnoze

CREATE OR REPLACE PROCEDURE dodaj_diagnoze(
    PESEL_pacjenta karta_choroby.pacjent%TYPE,
    diagnoza_dla_pacjenta karta_choroby.diagnoza%TYPE
    )
IS BEGIN
    IF sprawdz_karte_choroby(PESEL_pacjenta) THEN
        dbms_output.ENABLE;
        dbms_output.put_line('Pacjent nie istnieje lub zosta³ ju¿ wypisany');
    ELSE 
        UPDATE karta_choroby SET karta_choroby.diagnoza = diagnoza_dla_pacjenta WHERE karta_choroby.pacjent = PESEL_pacjenta;
    END IF;
END;
/

CREATE OR REPLACE PROCEDURE dodaj_objawy(
    PESEL_pacjenta karta_choroby.pacjent%TYPE,
    objawy_pacjenta karta_choroby.objawy%TYPE
    )
IS BEGIN
    IF sprawdz_karte_choroby(PESEL_pacjenta) THEN
        dbms_output.ENABLE;
        dbms_output.put_line('Pacjent nie istnieje lub zosta³ ju¿ wypisany');
    ELSE 
        UPDATE karta_choroby SET karta_choroby.objawy = objawy_pacjenta WHERE karta_choroby.pacjent = PESEL_pacjenta;
    END IF;
END;
/

--dodaj badanie
CREATE OR REPLACE FUNCTION znajdz_pracownika(
    PESEL_pracownika pracownik.PESEL%TYPE
    )
    RETURN BOOLEAN
    IS
        tmp pracownik.id_pracownika%TYPE := 0;    
    BEGIN
        SELECT p.PESEL INTO tmp FROM pracownik p WHERE p.PESEL = PESEL_pracownika;
        IF tmp = 0 THEN
            RETURN FALSE;
        ELSE 
            RETURN TRUE;
        END IF;
        EXCEPTION WHEN no_data_found THEN
            RETURN FALSE;

END;
/

CREATE OR REPLACE PROCEDURE dodaj_badanie(
    data_badania badanie.data_badania%TYPE,
    PESEL_pacjenta karta_choroby.pacjent%TYPE,
    wzrost_pacjenta badanie.wzrost%TYPE,
    tetno_pacjenta badanie.tetno%TYPE,
    uwagi_pacjenta badanie.uwagi%TYPE,
    badanie_wstepne_pacjenta badanie.badanie_wstepne_flg%TYPE,
    PESEL_pracownika pracownik.PESEL%TYPE
)
IS
    id_karty_pacjenta karta_choroby.id_karty%TYPE := 0;
    czy_pracownik_istnieje BOOLEAN;
    karta_istnieje BOOLEAN;
    id_znalezionego_pracownika NUMBER;
    nie_ma_karty EXCEPTION;
    nie_ma_pracownika EXCEPTION;
BEGIN
   czy_pracownik_istnieje := znajdz_pracownika(PESEL_pracownika);
    IF czy_pracownik_istnieje = FALSE THEN
        RAISE nie_ma_pracownika;
    ELSE
        BEGIN
            karta_istnieje := sprawdz_karte_choroby(PESEL_pacjenta);
            IF karta_istnieje = TRUE THEN
                RAISE nie_ma_karty;
            ELSE
                SELECT id_karty INTO id_karty_pacjenta FROM karta_choroby WHERE karta_choroby.pacjent = PESEL_pacjenta AND karta_choroby.data_wypisu IS NULL; 
                SELECT id_pracownika INTO id_znalezionego_pracownika FROM pracownik WHERE pracownik.PESEL = PESEL_pracownika;
                INSERT INTO badanie VALUES(id_karty_pacjenta, id_znalezionego_pracownika, data_badania, wzrost_pacjenta, tetno_pacjenta, uwagi_pacjenta, badanie_wstepne_pacjenta);
            END IF;
            EXCEPTION WHEN nie_ma_karty THEN 
                dbms_output.ENABLE;
                dbms_output.put_line('Nie ma takiego pacjenta');
            WHEN no_data_found THEN
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
CREATE OR REPLACE FUNCTION znajdz_id_pracownika(
    p_pesel pracownik.PESEL%TYPE
)
RETURN pracownik.id_pracownika%TYPE
IS
    tmp pracownik.id_pracownika%TYPE;
BEGIN
    SELECT id_pracownika INTO tmp FROM pracownik WHERE PESEL=p_pesel;
    IF tmp IS NULL THEN
        tmp:=0;
    END IF;
    RETURN tmp;
END;
/
CREATE OR REPLACE FUNCTION znajdz_stanowisko(
    p_id_pracownika pracownik.id_pracownika%TYPE
)
RETURN pracownik.stanowisko%TYPE
IS
    tmp pracownik.stanowisko%TYPE;
BEGIN
    SELECT stanowisko INTO tmp FROM pracownik WHERE id_pracownika=p_id_pracownika;
    RETURN tmp;
END;
/
CREATE OR REPLACE PROCEDURE dodaj_zabieg(
    p_data_zabiegu zabiegi.data_zabiegu%TYPE,
    p_typ_zabiegu zabiegi.typ_zabiegu%TYPE,
    p_spodziewane_zakonczenie zabiegi.spodziewane_zakonczenie%TYPE,
    p_numer_sali sala.numer_sali%TYPE,
    p_pesel_lekarza pracownik.PESEL%TYPE
)
IS
    tmp_data_poczatku zabiegi.data_zabiegu%TYPE;
    tmp_koniec zabiegi.spodziewane_zakonczenie%TYPE;
    p_id_sali zabiegi.sala%TYPE;
    p_id_zabiegu zabiegi.id_zabiegu%TYPE;
    p_id_prowadzacego pracownik.id_pracownika%TYPE;
    cursor cur_data_poczatku is select data_zabiegu from zabiegi where p_id_sali=sala;
    cursor cur_koniec is select spodziewane_zakonczenie from zabiegi where p_id_sali=sala;
    sala_zajeta EXCEPTION;
    nie_ma_sali EXCEPTION;
    sala_nie_zabiegowa EXCEPTION;
    czas EXCEPTION;
    nie_lekarz EXCEPTION;
BEGIN
    p_id_zabiegu:=znajdz_najwieksze_id_zabiegu();
    p_id_zabiegu:=p_id_zabiegu+1;
    p_id_sali:=znajdz_sale(p_numer_sali);
    p_id_prowadzacego:=znajdz_id_pracownika(p_pesel_lekarza);
    IF p_id_sali IS NULL THEN
        RAISE nie_ma_sali;
    ELSIF p_data_zabiegu>p_spodziewane_zakonczenie THEN
        RAISE czas;
    ELSIF znajdz_rodzaj_sali(p_id_sali) NOT LIKE 'Zabiegowe' AND znajdz_rodzaj_sali(p_id_sali) NOT LIKE 'Operacyjne' THEN
        RAISE sala_nie_zabiegowa;
    ELSIF p_id_prowadzacego IS NULL THEN
        RAISE nie_lekarz;
    ELSIF znajdz_stanowisko(p_id_prowadzacego) NOT LIKE 'Lekarz' THEN
        RAISE nie_lekarz;
    END IF;
    OPEN cur_data_poczatku;
    OPEN cur_koniec;
    LOOP
    FETCH cur_data_poczatku INTO tmp_data_poczatku;
    FETCH cur_koniec INTO tmp_koniec;
    EXIT WHEN cur_data_poczatku%NOTFOUND;
    EXIT WHEN cur_koniec%NOTFOUND;
    IF (tmp_data_poczatku IS NOT NULL AND tmp_koniec IS NOT NULL) AND ((p_data_zabiegu>=tmp_data_poczatku AND p_spodziewane_zakonczenie<=tmp_koniec)) THEN
        RAISE sala_zajeta;
    END IF;
    END LOOP;
    INSERT INTO zabiegi VALUES(p_id_zabiegu, p_data_zabiegu, p_typ_zabiegu, p_spodziewane_zakonczenie, p_id_sali);
    INSERT INTO zab_prac VALUES(p_id_zabiegu, p_id_prowadzacego);
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
    WHEN nie_lekarz THEN
        dbms_output.ENABLE;
        dbms_output.put_line('Prowadzacy zabieg musi istniec i byc lekarzem');
END;
/

EXEC dodaj_zabieg(to_timestamp('20/01/2019 16:30', 'dd-mm-yyyy hh24:mi:ss'), 'leczenie', to_timestamp('20/01/2019 17:30', 'dd-mm-yyyy hh24:mi:ss'), '4a', 84070986833);

-- Wypisujemy pacjentów z diagnoz¹ - zgon. 
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
        dbms_output.put_line('Pacjent o id karty ' || pacjent_bez_badania_wstepnego.id_karty || ' nie ma  badania wstêpnego.');    
END;
/

CREATE OR REPLACE PROCEDURE dodatek_dyzurowy
IS
    CURSOR dyz_cur (id_szuk_lekarza NUMBER) IS 
    SELECT EXTRACT(hour FROM (data_zakonczenia - data_rozpoczecia)) godziny, id_lekarza FROM dyzur
    WHERE dyzur.id_lekarza = id_szuk_lekarza AND
    EXTRACT(month from dyzur.data_zakonczenia) = EXTRACT(month FROM SYSDATE);
    CURSOR lek_cur IS SELECT * FROM lekarz l;
    liczba_godzin NUMBER := 0;
BEGIN
    FOR tmp_lek IN lek_cur LOOP
        liczba_godzin := 0;
        FOR tmp_dyz IN dyz_cur(tmp_lek.id_lekarza) LOOP
            liczba_godzin := liczba_godzin + tmp_dyz.godziny;
        END LOOP;
        IF liczba_godzin > 22 THEN
            UPDATE pracownik SET premia = 200 WHERE tmp_lek.id_pracownika = id_pracownika;
        END IF;
    END LOOP;
END;
/
