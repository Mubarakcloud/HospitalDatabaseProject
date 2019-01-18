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

