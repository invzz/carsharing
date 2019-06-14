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

/* parcheggi usa la funzione insert parcheggio per popolare indirizzo in cascata */
SELECT insertparcheggio('Piazza Dante', 10, 'ponente',44.4052777,8.933604,'Italia','Genova',16128,1,'Piazza Dante');
SELECT insertparcheggio('Marina di Sestri', 2, 'sestri',44.4032545,8.933204,'Italia','Genova',16154,12,'Via Pionieri');
SELECT insertparcheggio('Mollassana', 15, 'bisagno',44.4052733,8.933608,'Italia','Genova',16138,1,'Via Emila');

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
SELECT insertDocumento('CA2536AV','2017-12-29','2027-12-29','tecnico','Andres','Coronado',false,'Buenos Aires','1984-12-29',NULL,'Italia','Genova',16128,17,'Mura delle Grazie');
SELECT insertDocumento('GE2456EG','2012-04-11','2022-04-11','tecnico','Andres','Coronado',true,'Buenos Aires','1984-12-29','C','Italia','Genova',16128,17,'Mura delle Grazie');
SELECT insertDocumento('CA3476AV','2019-06-06','2029-06-06','data evangelist','Giuseppe','Carta',false,'Palermo','1992-01-01',NULL,'Italia','Genova',16138,134,'Via Emilia');
SELECT insertDocumento('GE2456EF','2019-02-14','2029-02-24','data evangelist','Giuseppe','Carta',true,'Palermo','1992-01-01','B','Italia','Genova',16138,134,'Via Emilia');
SELECT insertDocumento('CA3576AV','2019-06-06','2029-06-06','Processor Architect','Gabriele','Addari',false,'Genova','1995-01-01',NULL,'Italia','Genova',16154,12,'Via Sestri');
SELECT insertDocumento('GE2451EG','2019-12-29','2029-12-29','Processor Architect','Addari','Addari',true,'Genova','1995-01-01','B','Italia','Genova',16154,12,'Via Sestri');

/* se stesso indirizzo, non lo reinserisce evitando errori di duplicati sulla chiave di indirizzi */
SELECT insertDocumento('CB3576EV','2015-06-06','2025-06-06','Psicologo','Veronica','Colleoni',false,'Bergamo','1989-01-01',NULL,'Italia','Genova',16128,17,'Mura Delle Grazie');
SELECT insertDocumento('BS2457AF','2011-10-29','2021-10-29','Psicologo','Veronica','Colleoni',true,'Bergamo','1989-01-01','B','Italia','Genova',16128,17,'Mura Delle Grazie');
SELECT insertDocumento('CA3546DV','2019-06-06','2029-06-06','Idraulico','Mario','Rossi',false,'Milano','1974-01-01',NULL,'Italia','Genova',16121,1,'Piazza Caricamento');
SELECT insertDocumento('MI2226EF','2019-12-29','2029-12-29','Idraulico','Mario','Rossi',true,'Milano','1974-01-01','C','Italia','Genova',16121,1,'Piazza Caricamento');
SELECT insertDocumento('CA4576UV','2019-06-06','2029-06-06','Regista','Alice','Bianchi',false,'Rogoredo','1992-01-01',NULL,'Italia','Genova',16138,17,'Via Emilia');
SELECT insertDocumento('MI2356UF','2019-12-29','2029-12-29','Regista','Alice','Bianchi',true,'Rogoredo','1992-01-01','B','Italia','Genova',16138,17,'Via Emilia');

/* conducente */
/* Persona */
/* referente */
/* rappresentante */
/* Azienda */
/* Utente */
/* Abbonamento */
/*tipo abb.*/
INSERT INTO Tipo VALUES('Annuale',150,130);
INSERT INTO Tipo VALUES('Semestrale',90,80);
INSERT INTO Tipo VALUES('Mensile',60,55);