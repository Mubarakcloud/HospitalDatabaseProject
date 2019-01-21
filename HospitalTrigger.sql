CREATE OR REPLACE TRIGGER przy_usuwaniu_pacjenta
BEFORE DELETE ON pacjent
FOR EACH ROW
DECLARE
BEGIN
    UPDATE karta_choroby SET karta_choroby.pacjent = 00000000000 WHERE karta_choroby.pacjent = :old.PESEL;
END;
/

CREATE OR REPLACE TRIGGER przy_dodawaniu_pacjenta
AFTER INSERT ON pacjent
FOR EACH ROW
DECLARE
BEGIN
    INSERT INTO karta_choroby VALUES (karta_id_seq.NEXTVAL, :new.PESEL, NULL, NULL, SYSDATE, NULL, NULL, NULL);
END;
/
CREATE OR REPLACE TRIGGER przy_podaniu_leku
BEFORE INSERT ON KART_LEK
FOR EACH ROW
DECLARE
    aktualna_ilosc leki.dostepnosc%TYPE;
BEGIN
    SELECT l.dostepnosc INTO aktualna_ilosc FROM LEKI l WHERE l.id_leku = :new.podany_lek; 
    IF aktualna_ilosc>0 THEN
        UPDATE LEKI SET DOSTEPNOSC =  DOSTEPNOSC - 1 WHERE id_leku = :new.podany_lek;
    END IF;
END;
/
