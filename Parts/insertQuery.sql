SET search_path TO carsharing;

/*categoria*/
INSERT INTO Categoria VALUES('City Car');
INSERT INTO Categoria VALUES('Media');
INSERT INTO Categoria VALUES('Comfort');
INSERT INTO Categoria VALUES('Cargo');
INSERT INTO Categoria VALUES('Elettrico');

/*modelli*/
INSERT INTO Modello VALUES('Fiat 500',3545,1505,1330,4,32,150,1200,80,20,80,200,0.12,15,'City Car');
INSERT INTO Modello VALUES('Honda Civic',3705,1602,1230,5,28,180,1900,120,25,85,205,0.16,20,'Media');
INSERT INTO Modello VALUES('Fiat Panda XL',3245,1605,1328,5,30,170,1600,100,22,82,202,0.13,18,'City Car');
INSERT INTO Modello VALUES('Fiat Scudo',5248,1805,1930,3,15,180,2800,400,30,70,190,0.18,16,'Cargo');
INSERT INTO Modello VALUES('Renault Clio',4205,1495,1330,4,32,160,1200,80,20,80,200,0.12,15,'City Car');
INSERT INTO Modello VALUES('BMW Serie 3',4501,1655,1330,5,20,210,2500,98,40,100,250,0.20,25,'Comfort');
INSERT INTO Modello VALUES('Tesla Model S',4350,1725,1330,5,32,200,3500,80,40,110,250,0.20,35,'Elettrico');
INSERT INTO Modello VALUES('Porche Cayenne',3545,1505,1330,5,0,210,2300,80,20,110,250,0.18,35,'Comfort');
INSERT INTO Modello VALUES('Opel Astra',3545,1505,1330,5,32,180,1800,110,30,80,200,0.14,20,'Media');

/* parcheggi: la funzione insert parcheggio per popolare indirizzo in cascata */
SELECT insertparcheggio('Piazza Dante', 10, 'ponente',44.4052777,8.933604,'Italia','Genova',16128,1,'Piazza Dante');
SELECT insertparcheggio('Marina di Sestri', 2, 'sestri',44.4032545,8.933204,'Italia','Genova',16154,12,'Via Pionieri');
SELECT insertparcheggio('Mollassana', 15, 'bisagno',44.4052733,8.933608,'Italia','Genova',16138,1,'Via Emila');


/* categoriaParcheggi */
INSERT INTO categoriaparcheggio(nomeparcheggio,categoria) VALUES ('Piazza Dante', 'City Car');
INSERT INTO categoriaparcheggio(nomeparcheggio,categoria) VALUES ('Piazza Dante', 'Cargo');
INSERT INTO categoriaparcheggio(nomeparcheggio,categoria) VALUES ('Piazza Dante', 'Elettrico');
INSERT INTO categoriaparcheggio(nomeparcheggio,categoria) VALUES ('Mollassana', 'Cargo');
INSERT INTO categoriaparcheggio(nomeparcheggio,categoria) VALUES ('Mollassana', 'Comfort');
INSERT INTO categoriaparcheggio(nomeparcheggio,categoria) VALUES ('Mollassana', 'Media');
INSERT INTO categoriaparcheggio(nomeparcheggio,categoria) VALUES ('Marina di Sestri', 'City Car');
INSERT INTO categoriaparcheggio(nomeparcheggio,categoria) VALUES ('Marina di Sestri', 'Media');
INSERT INTO categoriaparcheggio(nomeparcheggio,categoria) VALUES ('Marina di Sestri', 'Elettrico');
INSERT INTO categoriaparcheggio(nomeparcheggio,categoria) VALUES ('Piazza Dante', 'Media');
INSERT INTO categoriaparcheggio(nomeparcheggio,categoria) VALUES ('Piazza Dante', 'Comfort');

/* vetture */
INSERT INTO vettura VALUES ('Andrea','EH790CH',5000,1,'verde',true,'Fiat 500','Piazza Dante');
INSERT INTO vettura VALUES ('Anna','BX890BH',20100,2,'blu',true,'Fiat 500','Marina di Sestri');
INSERT INTO vettura VALUES ('Paola','CY790CC',10000,3,'rosso',true,'Fiat 500','Marina di Sestri');
INSERT INTO vettura VALUES ('Giuseppe','AH703EE',15000,2,'verde',false,'Fiat Panda XL','Piazza Dante');
INSERT INTO vettura VALUES ('Giovanni','AX702CD',35000,1,'blu',true,'Fiat Panda XL','Piazza Dante');
INSERT INTO vettura VALUES ('Giorgio','AY705CE',12000,3,'nero',false,'Fiat Panda XL','Marina di Sestri');
INSERT INTO vettura VALUES ('Gabriele','DZ250AA',16000,0,'bianco',false,'Honda Civic','Mollassana');
INSERT INTO vettura VALUES ('Gianna','DX277AA',18000,1,'antracite',true,'Honda Civic','Piazza Dante');
INSERT INTO vettura VALUES ('Alfonso','DZ257AA',19000,3,'blu',false,'Honda Civic','Mollassana');
INSERT INTO vettura VALUES ('Simone','BD280GB',17000,0,'giallo',true,'BMW Serie 3','Mollassana');
INSERT INTO vettura VALUES ('Maria','BC284GB',15000,3,'marrone',false,'BMW Serie 3','Marina di Sestri');
INSERT INTO vettura VALUES ('Riccardo','BZ230GB',11000,1,'giallo',false,'BMW Serie 3','Mollassana');
INSERT INTO vettura VALUES ('Veronica','CX850SZ',30000,0,'verde',false,'Tesla Model S','Piazza Dante');
INSERT INTO vettura VALUES ('Laura','CY240SZ',10000,1,'blu',true,'Tesla Model S','Mollassana');
INSERT INTO vettura VALUES ('Barbara','CZ644SZ',200,1,'rosso',false,'Tesla Model S','Marina di Sestri');
INSERT INTO vettura VALUES ('Gianni','FF426CH',30000,0,'verde',false,'Porche Cayenne','Mollassana');
INSERT INTO vettura VALUES ('Aldo','FC566CH',30000,3,'verde',false,'Porche Cayenne','Piazza Dante');
INSERT INTO vettura VALUES ('Danilo','CX662CH',30000,2,'verde',false,'Porche Cayenne','Mollassana');
INSERT INTO vettura VALUES ('Marco','EZ987EZ',15789,3,'verde',true,'Opel Astra','Mollassana');
INSERT INTO vettura VALUES ('Massimo','EX983EZ',43789,2,'verde',true,'Opel Astra','Marina di Sestri');
INSERT INTO vettura VALUES ('Lino','EY937EZ',45789,1,'verde',true,'Opel Astra','Mollassana');
INSERT INTO vettura VALUES ('Gino','AX753AD',34356,0,'verde',false,'Fiat 500','Mollassana');
INSERT INTO vettura VALUES ('John','AX723AD',33356,1,'verde',false,'Fiat 500','Marina di Sestri');
INSERT INTO vettura VALUES ('Nicola','AX754AD',34356,1,'verde',false,'Fiat 500','Mollassana');
INSERT INTO vettura VALUES ('Pino','DE659TY',20400,1,'verde',true,'Renault Clio','Mollassana');
INSERT INTO vettura VALUES ('Alvaro','DE149TY',10400,1,'verde',true,'Renault Clio','Marina di Sestri');
INSERT INTO vettura VALUES ('Luca','DE751TY',40400,1,'verde',true,'Renault Clio','Mollassana');
INSERT INTO vettura VALUES ('Poldo','ER452HH',30330,1,'verde',true,'Fiat Scudo','Mollassana');
INSERT INTO vettura VALUES ('Piero','ER451HH',20330,1,'verde',true,'Fiat Scudo','Marina di Sestri');
INSERT INTO vettura VALUES ('Mario','ER352HH',10330,1,'verde',true,'Fiat Scudo','Mollassana');

/* Documento uso insertDocumento per popolare in cascata l'indirizzo */ 
/* se stesso indirizzo, non lo reinserisce evitando errori di duplicati sulla chiave di indirizzi */
SELECT insertDocumento('CA2536AV','2017-12-29','2027-12-29','tecnico','Andres','Coronado',false,'Buenos Aires','1984-12-29',NULL,'Italia','Genova',16128,17,'Mura delle Grazie');
SELECT insertDocumento('GE2456EG','2012-04-11','2022-04-11','tecnico','Andres','Coronado',true,'Buenos Aires','1984-12-29','C','Italia','Genova',16128,17,'Mura delle Grazie');
SELECT insertDocumento('CA3476AV','2019-06-06','2029-06-06','data evangelist','Giuseppe','Carta',false,'Palermo','1992-01-01',NULL,'Italia','Genova',16138,134,'Via Emilia');
SELECT insertDocumento('GE2456EF','2019-02-14','2029-02-24','data evangelist','Giuseppe','Carta',true,'Palermo','1992-01-01','B','Italia','Genova',16138,134,'Via Emilia');
SELECT insertDocumento('CA3576AV','2019-06-06','2029-06-06','Processor Architect','Gabriele','Addari',false,'Genova','1995-01-01',NULL,'Italia','Genova',16154,12,'Via Sestri');
SELECT insertDocumento('GE2451EG','2019-12-29','2029-12-29','Processor Architect','Addari','Addari',true,'Genova','1995-01-01','B','Italia','Genova',16154,12,'Via Sestri');
SELECT insertDocumento('CB3576EV','2015-06-06','2025-06-06','Psicologo','Veronica','Colleoni',false,'Bergamo','1989-01-01',NULL,'Italia','Genova',16128,17,'Mura delle Grazie');
SELECT insertDocumento('BG2457AF','2011-10-29','2021-10-29','Psicologo','Veronica','Colleoni',true,'Bergamo','1989-01-01','B','Italia','Genova',16128,17,'Mura delle Grazie');
SELECT insertDocumento('CA3546DV','2019-06-06','2029-06-06','Idraulico','Mario','Rossi',false,'Milano','1974-01-01',NULL,'Italia','Genova',16121,1,'Piazza Caricamento');
SELECT insertDocumento('MI2226EF','2019-12-29','2029-12-29','Idraulico','Mario','Rossi',true,'Milano','1974-01-01','C','Italia','Genova',16121,1,'Piazza Caricamento');
SELECT insertDocumento('CA4576UV','2019-06-06','2029-06-06','Regista','Alice','Bianchi',false,'Rogoredo','1992-01-01',NULL,'Italia','Genova',16138,134,'Via Emilia');
SELECT insertDocumento('MI2356UF','2019-12-29','2029-12-29','Regista','Alice','Bianchi',true,'Rogoredo','1992-01-01','B','Italia','Genova',16138,134,'Via Emilia');


/* referente */
INSERT INTO Referente VALUES
('3456154789','Giovanni','Referini'),
('3386854762','Luca','Giurato'),
('3336456785','Linus','Torvalds');

/* rappresentante */
INSERT INTO Rappresentante VALUES
('Mario','Rossi','1974-01-01','Milano'),
('Fabio','Fazio','1968-01-01','Roma'),
('Donald','Knuth','1982-01-01','Venezia');

/* Azienda */
INSERT INTO AZIENDA VALUES
(00205748,'Leonardo idraulica','0106532525','3456154789','Mario','Rossi','1974-01-01'),
(00007148,'Rai','06564851','3386854762','Fabio','Fazio','1968-01-01'),
(00237148,'IBM RedHat','025582524','3336456785','Donald','Knuth','1982-01-01');

/* conducente */
INSERT INTO Conducente(piva,nrDocumento,nrPatente) VALUES (NULL,'CB3576EV','BG2457AF');
INSERT INTO Conducente(piva,nrDocumento,nrPatente) VALUES (00007148,'CA4576UV','MI2356UF');
INSERT INTO Conducente(piva,nrDocumento,nrPatente) VALUES (00205748,'CA3546DV','MI2226EF');
INSERT INTO Conducente(piva,nrDocumento,nrPatente) VALUES (00237148,'CA2536AV','GE2456EG');

/* persona (inserisce solo se conducente e persona sono coinquilini ), getid fornisce l'id del conducente*/
SELECT insertPersona('CRNNRS84T29Z600A',getIdConducente('CB3576EV'), '3483794192','CA2536AV','GE2456EG');
SELECT insertPersona('CRTGPP92A01G273F',getIdConducente('CA4576UV'), '3389565645','CA3476AV','GE2456EF');
SELECT insertPersona('RSSMRA74A01F205Z',0, '3349585645','CA3546DV','MI2226EF');
SELECT insertPersona('BNCLCA93A41F205I',0, '3329465645','CA4576UV','MI2356UF');

/* sede : se l'indirizzo e` mancante lo registra nella tabella indirizzi */
SELECT insertSede(00205748,'Italia','Milano',20100,12,'Via Trento','Legale');
SELECT insertSede(00205748,'Italia','Genova',16162,1,'Via Bolzaneto','Operativa');
SELECT insertSede(00205748,'Italia','Genova',16142,1,'Via Sampierdarena','Legale');
SELECT insertSede(00205748,'Italia','Genova',16122,1,'Via Erzelli','Legale');

/*tipo abb.*/
INSERT INTO Tipo VALUES('Annuale',365,150,15);
INSERT INTO Tipo VALUES('Semestrale',182,90,10);
INSERT INTO Tipo VALUES('Mensile',30,60,5);

/* MetodoDiPAgamento ed overload carta ban prepagato*/
SELECT insertMetodo(1,'IT83X0200801452000101755018','Andres Coronado');
SELECT insertMetodo(2,1234123412341234,'Giuseppe Carta','VISA','2021-01-01');
SELECT insertMetodo(3,1234123412341234,'Red Hat Inc','Mastercard','2020-01-01');
SELECT insertMetodo(4,'IT01Y0304801452000101755018','Rai Cinema');
SELECT insertMetodo(5,200);
SELECT insertMetodo(6,50);

/* Utente */
INSERT INTO utente VALUES 
('info@leonardo.com',00205748,NULL,5),
('info@rai.it',00007148,NULL,4),
('info@redhat.org',00237148,NULL,3),
('invizuz@gmail.com',NULL,'CRNNRS84T29Z600A',1),
('mariorossi@libero.it',NULL,'RSSMRA74A01F205Z',6),
('cartagiuseppe@gmail.com',NULL,'CRTGPP92A01G273F',2);

/* Abbonamento insertAbbonamento(dataInizio timestamp,databonus date,bonus numeric, pin numeric, card numeric, tipo varchar) */
SELECT insertAbbonamento(now()::timestamp,now()::date,10,1234,1,'Annuale');
SELECT insertAbbonamento(now()::timestamp,NULL,0,1432,2,'Annuale');
SELECT insertAbbonamento(now()::timestamp,NULL,0,1324,3,'Annuale');
SELECT insertAbbonamento(now()::timestamp,NULL,0,4123,4,'Annuale');
SELECT insertAbbonamento(now()::timestamp,now()::date,15,2341,5,'Annuale');
SELECT insertAbbonamento(now()::timestamp,now()::date,15,3412,6,'Annuale');

/* prenotazione */
INSERT INTO prenotazione VALUES (nextval('prenotazione_numeroprenotazione_seq'::regclass),'1','Andrea','2019-07-01','2019-07-03',NULL);
INSERT INTO prenotazione VALUES (nextval('prenotazione_numeroprenotazione_seq'::regclass),'1','Danilo','2019-07-11','2019-07-13',NULL);
INSERT INTO prenotazione VALUES (nextval('prenotazione_numeroprenotazione_seq'::regclass),'2','Gabriele','2019-07-04','2019-07-20',NULL);
INSERT INTO prenotazione VALUES (nextval('prenotazione_numeroprenotazione_seq'::regclass),'2','Gino','2019-08-01','2019-08-08',NULL);
INSERT INTO prenotazione VALUES (nextval('prenotazione_numeroprenotazione_seq'::regclass),'3','Laura','2019-07-03','2019-07-05',NULL);
INSERT INTO prenotazione VALUES (nextval('prenotazione_numeroprenotazione_seq'::regclass),'3','Luca','2019-07-06','2019-08-07',NULL);
INSERT INTO prenotazione VALUES (nextval('prenotazione_numeroprenotazione_seq'::regclass),'4','Marco','2019-07-01','2019-08-01',NULL);
INSERT INTO prenotazione VALUES (nextval('prenotazione_numeroprenotazione_seq'::regclass),'4','Mario','2019-07-05','2019-07-22',NULL);
INSERT INTO prenotazione VALUES (nextval('prenotazione_numeroprenotazione_seq'::regclass),'5','Andrea','2019-08-01','2019-08-02',NULL);
INSERT INTO prenotazione VALUES (nextval('prenotazione_numeroprenotazione_seq'::regclass),'5','Massimo','2019-08-01','2019-08-28',NULL);
INSERT INTO prenotazione VALUES (nextval('prenotazione_numeroprenotazione_seq'::regclass),'6','Piero','2019-07-20','2019-08-22',NULL);
INSERT INTO prenotazione VALUES (nextval('prenotazione_numeroprenotazione_seq'::regclass),'6','Paola','2019-08-18','2019-08-25',NULL);
/*nr 13* modificaprenotazione */
INSERT INTO prenotazione VALUES (nextval('prenotazione_numeroprenotazione_seq'::regclass),'1','Andrea','2018-07-01','2018-07-03',NULL);
/*nr 14* modificaprenotazione */
INSERT INTO prenotazione VALUES (nextval('prenotazione_numeroprenotazione_seq'::regclass),'1','Danilo','2018-07-11','2018-07-13',NULL);
/*nr 15* modificaprenotazione */
INSERT INTO prenotazione VALUES (nextval('prenotazione_numeroprenotazione_seq'::regclass),'2','Gabriele','2018-07-04','2018-07-20',NULL);
/* ritiro e riconsegna in giornata */
INSERT INTO prenotazione VALUES (nextval('prenotazione_numeroprenotazione_seq'::regclass),'2','Gino','2018-08-01','2018-08-01',NULL);
/*ritiro e consegna 2 settimane */
INSERT INTO prenotazione VALUES (nextval('prenotazione_numeroprenotazione_seq'::regclass),'3','Laura','2018-07-03','2018-07-17',NULL);
INSERT INTO prenotazione VALUES (nextval('prenotazione_numeroprenotazione_seq'::regclass),'3','Luca','2018-07-06','2018-08-07',NULL);
INSERT INTO prenotazione VALUES (nextval('prenotazione_numeroprenotazione_seq'::regclass),'4','Marco','2018-07-01','2018-08-01',NULL);
INSERT INTO prenotazione VALUES (nextval('prenotazione_numeroprenotazione_seq'::regclass),'4','Mario','2018-07-05','2018-07-22',NULL);
INSERT INTO prenotazione VALUES (nextval('prenotazione_numeroprenotazione_seq'::regclass),'5','Andrea','2018-08-01','2018-08-02',NULL);
INSERT INTO prenotazione VALUES (nextval('prenotazione_numeroprenotazione_seq'::regclass),'5','Massimo','2018-08-01','2018-08-28',NULL);
INSERT INTO prenotazione VALUES (nextval('prenotazione_numeroprenotazione_seq'::regclass),'6','Piero','2018-07-20','2018-08-22',NULL);
INSERT INTO prenotazione VALUES (nextval('prenotazione_numeroprenotazione_seq'::regclass),'6','Paola','2018-08-18','2018-08-25',NULL);
INSERT INTO prenotazione VALUES (nextval('prenotazione_numeroprenotazione_seq'::regclass),'1','Andrea','2017-07-01','2017-07-03',NULL);
INSERT INTO prenotazione VALUES (nextval('prenotazione_numeroprenotazione_seq'::regclass),'1','Danilo','2017-07-11','2017-07-13',NULL);
INSERT INTO prenotazione VALUES (nextval('prenotazione_numeroprenotazione_seq'::regclass),'2','Gabriele','2017-07-04','2017-07-20',NULL);
INSERT INTO prenotazione VALUES (nextval('prenotazione_numeroprenotazione_seq'::regclass),'2','Gino','2017-08-01','2017-08-08',NULL);
INSERT INTO prenotazione VALUES (nextval('prenotazione_numeroprenotazione_seq'::regclass),'3','Laura','2017-07-03','2017-07-05',NULL);
INSERT INTO prenotazione VALUES (nextval('prenotazione_numeroprenotazione_seq'::regclass),'3','Luca','2017-07-06','2017-08-07',NULL);
INSERT INTO prenotazione VALUES (nextval('prenotazione_numeroprenotazione_seq'::regclass),'4','Marco','2017-07-01','2017-08-01',NULL);
INSERT INTO prenotazione VALUES (nextval('prenotazione_numeroprenotazione_seq'::regclass),'4','Mario','2017-07-05','2017-07-22',NULL);
INSERT INTO prenotazione VALUES (nextval('prenotazione_numeroprenotazione_seq'::regclass),'5','Andrea','2017-08-01','2017-08-02',NULL);
INSERT INTO prenotazione VALUES (nextval('prenotazione_numeroprenotazione_seq'::regclass),'5','Massimo','2017-08-01','2017-08-28',NULL);
INSERT INTO prenotazione VALUES (nextval('prenotazione_numeroprenotazione_seq'::regclass),'6','Piero','2017-07-20','2017-08-22',NULL);
INSERT INTO prenotazione VALUES (nextval('prenotazione_numeroprenotazione_seq'::regclass),'6','Paola','2017-08-18','2017-08-25',NULL);

/*
/*nr 13* modificaprenotazione in tempo*/
/*nr 14* modificaprenotazione in tempo*/
/*nr 15* modificaprenotazione non in tempo */
*/

/* modifica prenotazione */
INSERT INTO carsharing.modificaprenotazione VALUES (13, '2018-06-28', '2018-07-01', '2019-07-05');
INSERT INTO carsharing.modificaprenotazione VALUES (14, '2018-06-28', '2018-07-16', '2019-07-18');
INSERT INTO carsharing.modificaprenotazione VALUES (15, '2018-07-01', '2018-07-01', '2019-07-21');

/* UTILIZZO CON CASI DI TEST*/
INSERT INTO carsharing.utilizzo VALUES (13, 2000, '2019-07-01 00:00:00', '2019-07-05 00:00:00', 2750);
INSERT INTO carsharing.utilizzo VALUES (14, 7500, '2017-07-16 00:00:00', '2017-07-18 00:00:00', 7750);
INSERT INTO carsharing.utilizzo VALUES (15, 2000, '2018-07-01 00:00:00', '2018-07-21 00:00:00', 3500);
INSERT INTO carsharing.utilizzo VALUES (16, 1500, '2018-08-01 00:00:00', '2018-08-01 00:00:00', 1680);
INSERT INTO carsharing.utilizzo VALUES (17, 5450, '2018-07-03 00:00:00', '2018-07-17 00:00:00', 6850);