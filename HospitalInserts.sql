--Sekwencje
DROP SEQUENCE oddzial_id_seq;
DROP SEQUENCE pracownik_id_seq;
DROP SEQUENCE lekarz_id_seq;
DROP SEQUENCE sala_id_seq;
DROP SEQUENCE karta_id_seq;
DROP SEQUENCE lek_id_seq;
DROP SEQUENCE zabieg_id_seq;


CREATE SEQUENCE oddzial_id_seq;
CREATE SEQUENCE pracownik_id_seq;
CREATE SEQUENCE lekarz_id_seq;
CREATE SEQUENCE sala_id_seq;
CREATE SEQUENCE karta_id_seq;
CREATE SEQUENCE lek_id_seq;
CREATE SEQUENCE zabieg_id_seq;

 -- Oddzialy

INSERT INTO oddzial VALUES (oddzial_id_seq.NEXTVAL, 'Pediatria', 'Kielce', 'Grunwaldzka', '1', '25-736');
INSERT INTO oddzial VALUES (oddzial_id_seq.NEXTVAL, 'Chirurgia', 'Kielce', 'Grunwaldzka', '2', '25-736');
INSERT INTO oddzial VALUES (oddzial_id_seq.NEXTVAL, 'Okulistyka', 'Kielce', 'Grunwaldzka', '3', '25-736');
INSERT INTO oddzial VALUES (oddzial_id_seq.NEXTVAL, 'Kardiologia', 'Kielce', 'Grunwaldzka', '4', '25-736');
INSERT INTO oddzial VALUES (oddzial_id_seq.NEXTVAL, 'Neurologia', 'Kielce', 'Grunwaldzka', '5', '25-736');
INSERT INTO oddzial VALUES (oddzial_id_seq.NEXTVAL, 'Laryngologia', 'Kielce', 'Grunwaldzka', '6', '25-736');
INSERT INTO oddzial VALUES (oddzial_id_seq.NEXTVAL, 'Ortopedia', 'Kielce', 'Grunwaldzka', '7', '25-736');
INSERT INTO oddzial VALUES (oddzial_id_seq.NEXTVAL, 'Neonatologiczny', 'Kielce', 'Grunwaldzka', '8', '25-736');
INSERT INTO oddzial VALUES (oddzial_id_seq.NEXTVAL, 'Nefrologia', 'Kielce', 'Grunwaldzka', '9', '25-736');
INSERT INTO oddzial VALUES (oddzial_id_seq.NEXTVAL, 'Psychiatria', 'Kielce', 'Grunwaldzka', '10', '25-736');
INSERT INTO oddzial VALUES (oddzial_id_seq.NEXTVAL, 'Paliacja', 'Kielce', 'Grunwaldzka', '11', '25-736');


-- Pracownicy

INSERT INTO pracownik VALUES (pracownik_id_seq.NEXTVAL, 1, 'Marian', 'Konewka', 'Konserwator', 2500, '111222333');
INSERT INTO pracownik VALUES (pracownik_id_seq.NEXTVAL, 1, 'Marianna', 'Konewka', 'Sprz�taczka', 2500, '111222334');
INSERT INTO pracownik VALUES (pracownik_id_seq.NEXTVAL, 2, 'Zdzis�aw', 'Nowak', 'Konserwator', 2600, '543222333');
INSERT INTO pracownik VALUES (pracownik_id_seq.NEXTVAL, 2, 'Kornel', 'Tutaj', 'Piel�gniarz', 2800, '111753333');
INSERT INTO pracownik VALUES (pracownik_id_seq.NEXTVAL, 3, 'Joanna', 'Papaj', 'Piel�gniarka', 2800, '111222412');
INSERT INTO pracownik VALUES (pracownik_id_seq.NEXTVAL, 4, 'Kamil', 'Wakszmucki', 'Piel�gniarz', 2800, '111983333');
INSERT INTO pracownik VALUES (pracownik_id_seq.NEXTVAL, 10, 'Andrzej', 'Kolejarz', 'Ochroniacz', 2300, '532222333');
INSERT INTO pracownik VALUES (pracownik_id_seq.NEXTVAL, 10, 'Wac�aw', 'Tam', 'Ochroniarz', 2300, '111981333');
INSERT INTO pracownik VALUES (pracownik_id_seq.NEXTVAL, 5, 'Dawid', 'Szynka', 'Informatyk', 9999, '111324333');
INSERT INTO pracownik VALUES (pracownik_id_seq.NEXTVAL, 6, 'Karolina', 'Strata', 'Sekretarka', 2900, '991222333');
INSERT INTO pracownik VALUES (pracownik_id_seq.NEXTVAL, 3, 'Wasilij', 'Papataj', 'Piel�gniarz', 2800, '854222412');
INSERT INTO pracownik VALUES (pracownik_id_seq.NEXTVAL, 4, 'Antonina', 'Michalczyk', 'Piel�gniarka', 2800, '643983333');
INSERT INTO pracownik VALUES (pracownik_id_seq.NEXTVAL, 1, 'Dawid', 'Szynka', 'Ochroniacz', 2300, '532532333');
INSERT INTO pracownik VALUES (pracownik_id_seq.NEXTVAL, 10, 'Tomasz', 'Dobrych�op', 'Bazodanowiec', 9999, '765981976');
INSERT INTO pracownik VALUES (pracownik_id_seq.NEXTVAL, 3, 'Karol', 'Marcinkowski', 'Technik', 3000, '331676333');
INSERT INTO pracownik VALUES (pracownik_id_seq.NEXTVAL, 7, 'Magda', 'Pionel', 'Sekretarka', 2900, '991222999');


INSERT INTO pracownik VALUES (pracownik_id_seq.NEXTVAL, 1, 'Wies�aw', 'M�czka', 'Lekarz', 6800, '987983333');
INSERT INTO pracownik VALUES (pracownik_id_seq.NEXTVAL, 2, 'Andrzej', 'Martyniuk', 'Lekarz', 6800, '532222333');
INSERT INTO pracownik VALUES (pracownik_id_seq.NEXTVAL, 3, 'Karmil', 'Czekaj', 'Lekarz', 6800, '987981333');
INSERT INTO pracownik VALUES (pracownik_id_seq.NEXTVAL, 4, 'Teresa', 'Witam', 'Lekarz', 6800, '111324999');
INSERT INTO pracownik VALUES (pracownik_id_seq.NEXTVAL, 5, 'Micha�', 'Rze�nik', 'Lekarz', 6800, '991786333');
INSERT INTO pracownik VALUES (pracownik_id_seq.NEXTVAL, 6, 'Pawe�', 'Tombreno', 'Lekarz', 6800, '854563412');
INSERT INTO pracownik VALUES (pracownik_id_seq.NEXTVAL, 7, 'Paulina', 'Stonoga', 'Lekarz', 6800, '643983757');
INSERT INTO pracownik VALUES (pracownik_id_seq.NEXTVAL, 8, 'Joanna', 'Kaszanka', 'Lekarz', 6800, '532532999');
INSERT INTO pracownik VALUES (pracownik_id_seq.NEXTVAL, 9, 'Diego', 'Manino', 'Lekarz', 6800, '974981976');
INSERT INTO pracownik VALUES (pracownik_id_seq.NEXTVAL, 10, 'Marian', 'Pazera', 'Lekarz', 6800, '331676395');
INSERT INTO pracownik VALUES (pracownik_id_seq.NEXTVAL, 11, 'Dorbromi�a', 'Ogie�', 'Lekarz', 6800, '991864999');

--lekarze

INSERT INTO lekarz VALUES (lekarz_id_seq.NEXTVAL, 1, 'Pediatria', '150c', '142b');
INSERT INTO lekarz VALUES (lekarz_id_seq.NEXTVAL, 2, 'Chirurgia', '150c', '142b');
INSERT INTO lekarz VALUES (lekarz_id_seq.NEXTVAL, 3, 'Okulistyka', '150c', '142b');
INSERT INTO lekarz VALUES (lekarz_id_seq.NEXTVAL, 4, 'Kardiologia', '150c', '142b');
INSERT INTO lekarz VALUES (lekarz_id_seq.NEXTVAL, 5, 'Neurologia', '150c', '142b');
INSERT INTO lekarz VALUES (lekarz_id_seq.NEXTVAL, 6, 'Laryngologia', '150c', '142b');
INSERT INTO lekarz VALUES (lekarz_id_seq.NEXTVAL, 7, 'Ortopedia', '150c', '142b');
INSERT INTO lekarz VALUES (lekarz_id_seq.NEXTVAL, 8, 'Neonatologiczny', '150c', '142b');
INSERT INTO lekarz VALUES (lekarz_id_seq.NEXTVAL, 9, 'Nefrologia', '150c', '142b');
INSERT INTO lekarz VALUES (lekarz_id_seq.NEXTVAL, 10, 'Psychiatria', '150c', '142b');
INSERT INTO lekarz VALUES (lekarz_id_seq.NEXTVAL, 11, 'Paliacja', '150c', '142b');

--sale
INSERT INTO sala VALUES (sala_id_seq.NEXTVAL, 1, '1a', 'Zabiegowe', 10, 1);
INSERT INTO sala VALUES (sala_id_seq.NEXTVAL, 2, '2a', 'Zabiegowe', 10, 2);
INSERT INTO sala VALUES (sala_id_seq.NEXTVAL, 3, '3a', 'Zabiegowe', 10, 3);
INSERT INTO sala VALUES (sala_id_seq.NEXTVAL, 3, '3b', 'Operacyjne', 10, 3);
INSERT INTO sala VALUES (sala_id_seq.NEXTVAL, 3, '3c', 'Pooperacyjne', 10, 3);
INSERT INTO sala VALUES (sala_id_seq.NEXTVAL, 4, '4a', 'Zabiegowe', 10, 4);
INSERT INTO sala VALUES (sala_id_seq.NEXTVAL, 5, '5a', 'Zabiegowe', 10, 5);
INSERT INTO sala VALUES (sala_id_seq.NEXTVAL, 6, '6a', 'Zabiegowe', 10, 6);
INSERT INTO sala VALUES (sala_id_seq.NEXTVAL, 6, '6b', 'Operacyjne', 10, 6);
INSERT INTO sala VALUES (sala_id_seq.NEXTVAL, 6, '6c', 'Pooperacyjne', 10, 6);
INSERT INTO sala VALUES (sala_id_seq.NEXTVAL, 7, '7a', 'Zabiegowe', 10, 7);
INSERT INTO sala VALUES (sala_id_seq.NEXTVAL, 8, '8a', 'Zabiegowe', 10, 8);
INSERT INTO sala VALUES (sala_id_seq.NEXTVAL, 9, '9a', 'Zabiegowe', 10, 9);
INSERT INTO sala VALUES (sala_id_seq.NEXTVAL, 10, '10a', 'Izolatka', 1, 10);
INSERT INTO sala VALUES (sala_id_seq.NEXTVAL, 10, '10b', 'Izolatka', 1, 10);
INSERT INTO sala VALUES (sala_id_seq.NEXTVAL, 10, '10c', 'Izolatka', 1, 10);
INSERT INTO sala VALUES (sala_id_seq.NEXTVAL, 10, '10d', 'Izolatka', 1, 10);
INSERT INTO sala VALUES (sala_id_seq.NEXTVAL, 10, '10e', 'Izolatka', 1, 10);
INSERT INTO sala VALUES (sala_id_seq.NEXTVAL, 11, '11a', 'Zabiegowe', 10, 11);
