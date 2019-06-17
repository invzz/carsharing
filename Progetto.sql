-- Gruppo 22
-- Coronado Andres, Carta Giuseppe, Addari Gabriele
-- Scritto usando VIm, testato su PgAdmin4, con PostgreSQL 11.3

--tables!
DROP SCHEMA IF EXISTS carsharing CASCADE;
CREATE SCHEMA carsharing;
SET search_path TO carsharing;

CREATE TABLE Indirizzo (
	nazione varchar(20) NOT NULL,
	citta varchar(20) NOT NULL,
	cap numeric(5,0) NOT NULL,
	civico numeric(4,0) NOT NULL,
	via varchar(20) NOT NULL,
	PRIMARY KEY(nazione, citta, cap, civico,via)
);

CREATE TABLE Categoria (
	categoria varchar (20) PRIMARY KEY
);

CREATE TABLE Modello (
	NomeModello varchar(20) PRIMARY KEY,
	lunghezza numeric(6,2) NOT NULL,
	larghezza numeric(6,2) NOT NULL,
	altezza	numeric(6,2) NOT NULL,
	Nporte smallint NOT NULL,	
	consumo	numeric(4,2),
	velocita smallint NOT NULL,	
	motorizzazione smallint,
	capBagagliaio numeric(6,2) NOT NULL,	
	Toraria	numeric(5,2) NOT NULL,
	Tgiornaliera numeric(5,2) NOT NULL,	
	Tsettimanale numeric(5,2) NOT NULL,
	Tchilometrica numeric(5,2) NOT NULL,
	TgiornalieraAggiuntiva numeric(6,2) NOT NULL,
	categoria  varchar (20) NOT NULL 
	REFERENCES Categoria
	ON DELETE NO ACTION
	ON UPDATE NO ACTION,
	aria bool NULL,
	servoS bool NULL,
	airBag bool NULL
);

CREATE TABLE Fatturazione (
	numeroFattura serial PRIMARY KEY,
	penale numeric,
	totaleFatt numeric,
	chilometriPercorsi numeric, 
	TempoNonUsufruito numeric,
	TempoUsufruito numeric,
	TempoAnnullato numeric
	--CHECK(TempoUsufruito + TempoNonUsufruito > 0)
);
/* check TempoUsufruito + TempoNonUsufruito > 0 */
/* trigger TempoAnnullato > 0 ==> TempoNonUsufruito > 0*/
CREATE TABLE Tipo (
	periodo	varchar(20) PRIMARY KEY,
	ngiorni int, /* aggiunto per insertAbbonamento, numero di giorni */
	costo numeric NOT NULL,
	riduzioneEta numeric NuLL
);
/* periodo annuale, bimestrale, semestrale, mensile, settimanale...*/

CREATE TABLE Carta (
	numero numeric(16,0) NOT NULL, 
	circuito varchar(16) NOT NULL,
	intestatario varchar(30) NOT NULL,
	scadenza date NOT NULL ,
	PRIMARY KEY(numero,circuito,intestatario,scadenza)
	
);

CREATE TABLE Rid (
	codIban char(27) NOT NULL, 
	intestatario varchar(30) NOT NULL,
	PRIMARY KEY(codIban,Intestatario)
);

CREATE TABLE MetodoDiPagamento (
	numSmartCard serial PRIMARY KEY,
	versato numeric, 
	numeroCarta numeric(16,0), 
	intestatarioCarta varchar(30),		
	circuitoCarta varchar(10),
	scadenzaCarta date,
	codIban char(27), 
	intestatarioConto varchar(30),
	FOREIGN KEY(codIban,IntestatarioConto) 
	REFERENCES Rid(codIban,intestatario)
	ON UPDATE CASCADE
	ON DELETE CASCADE,	
	FOREIGN KEY (numeroCarta,circuitoCarta,IntestatarioCarta,scadenzaCarta)
	REFERENCES Carta(numero, circuito, intestatario,scadenza)
	ON UPDATE CASCADE
	ON DELETE CASCADE
	
);
/* TRIGGER se versato non e' null prepagato */

CREATE TABLE Abbonamento (
	dataInizio timestamp NOT NULL,	
	dataFine timestamp NOT NULL,
	dataBonus date,
	bonusRottamazione numeric(3,0),
	pinCarta	numeric(4,0) NOT NULL,
	numSmartCard integer NOT NULL references MetodoDiPagamento,
	tipo varchar(20) NOT NULL references Tipo,
	PRIMARY KEY (numSmartCard),
	UNIQUE (numSmartCard, dataInizio)
	
);

CREATE TABLE Parcheggio (
	NomeParcheggio varchar(20) PRIMARY KEY,
	numPosti numeric NOT NULL,
	zona varchar(20) NOT NULL,
	longitudine numeric (14,7) NOT NULL,
	latitudine numeric(14,7) NOT NULL,
	nazione varchar(20) NOT NULL,
	citta varchar(20) NOT NULL,
	cap numeric(5,0) NOT NULL,
	civico numeric(4,0) NOT NULL,
	via varchar(20) NOT NULL,
	FOREIGN KEY(nazione,citta,cap,via,civico) 
		REFERENCES Indirizzo (nazione,citta,cap,via,civico)	
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

CREATE TABLE CategoriaParcheggio(
	id serial primary key,
	NomeParcheggio varchar(20) references Parcheggio,
	categoria varchar(20) References Categoria
);

CREATE TABLE Vettura (
	NomeVettura	varchar(10) PRIMARY KEY,
	targa varchar(7) UNIQUE NOT NULL,
	chilometraggio numeric NOT NULL,
	seggiolini numeric NuLL,
	colore varchar(20) NOT NULL,
	animali bool NOT NULL,
	modello varchar(20) REFERENCES Modello,
	sede varchar(20) REFERENCES Parcheggio
);


CREATE TABLE Prenotazione (
	NumeroPrenotazione serial PRIMARY KEY, -- GENERATED ALWAYS AS IDENTITY (START WITH 1),
	numSmartCard int NOT NULL, 
	NomeVettura varchar(10) REFERENCES Vettura,
	dataOraInizio timestamp NOT NULL,
	dataOraFine timestamp NOT NULL,
	numeroFattura int
		REFERENCES Fatturazione
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
	FOREIGN KEY(numSmartCard)
		REFERENCES Abbonamento(numSmartCard)
	
);

CREATE TABLE ModificaPrenotazione(
	NumeroPrenotazione int REFERENCES Prenotazione,
	dataOraRinuncia timestamp,
	nuovaDataOraInizio timestamp,
	nuovaDataOraRest timestamp,
	PRIMARY KEY(NumeroPrenotazione)
);

CREATE TABLE Rifornimenti (
	targa varchar(7) references Vettura(targa),
	chilometraggio numeric,	
	data date NOT NULL,
	litri numeric NOT NULL,
	PRIMARY KEY (chilometraggio,targa)
	
);

CREATE TABLE Utilizzo (
	NumeroPrenotazione int NOT NULL 
		REFERENCES Prenotazione 
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,	
	chilometraggioRitiro numeric(6,0) NOT NULL,
	dataOraRitiro timestamp NOT NULL,
	dataOraRiconsegna timestamp NULL,
	chilometraggioRiconsegna numeric(6,0),
	PRIMARY KEY (NumeroPrenotazione,dataOraRitiro)
	
);



CREATE TABLE Sinistro (
	NumeroPrenotazione int REFERENCES Prenotazione(NumeroPrenotazione), 
	dataOra timestamp,	
	danni varchar NOT NULL,
	dinamica varchar NOT NULL,	
	conducente varchar (40) NOT NULL,
	luogo varchar (100) NOT NULL,
	PRIMARY KEY (numeroPrenotazione, dataOra)
	
);
/*sinistro notificato entro tot giorni ?*/

CREATE TABLE Testimoni (
	contatto varchar(30) PRIMARY KEY,	
	nome varchar(10) NOT NULL,
	cognome varchar(15) NOT NULL,
	dataDiNascita date NOT NULL,
	luogoDiNascita varchar(20) NOT NULL
	
);


CREATE TABLE Terzi (
	targa char(7) PRIMARY KEY,
	conducente varchar(25) NOT NULL
);


CREATE TABLE SinistroTestimoni (
	NumeroPrenotazione int NOT NULL,
	dataOra timestamp NOT NULL,
	contatto varchar(20) NOT NULL REFERENCES Testimoni,
	FOREIGN KEY(numeroPrenotazione, dataOra) references Sinistro (numeroPrenotazione, dataOra)
);


CREATE TABLE SinistroTerzi (
	NumeroPrenotazione serial NOT NULL,
	dataOra timestamp NOT NULL,
	targa char(7) NOT NULL REFERENCES terzi,
	FOREIGN KEY(numeroPrenotazione, dataOra) references Sinistro(numeroPrenotazione, dataOra)
);


CREATE TABLE Referente (
	telefono varchar(10) PRIMARY KEY,	
	nome varchar(10) NOT NULL,
	cognome varchar(15) NOT NULL
);


CREATE TABLE Rappresentante (
	nome varchar(10),	
	cognome	varchar(15),
	dataDiNascita date,
	luogoDiNascita	varchar(20) NOT NULL,
	PRIMARY KEY(nome,cognome, dataDiNascita)
	
);

CREATE TABLE Azienda (
	piva numeric(11) PRIMARY KEY,
	ragSociale varchar(30) NOT NULL,
	telefono varchar(10) NOT NULL,	
	telefonoReferente varchar(10) REFERENCES Referente NOT NULL,
	nomeRappresentante varchar(10) NOT NULL,
	cognomeRappresentante varchar(15) NOT NULL,
	dataDiNascitaRappresentante date NOT NULL,
	FOREIGN KEY (nomerappresentante,cognomerappresentante,datadinascitarappresentante) 
	REFERENCES rappresentante
);

CREATE TABLE Sede(
	idsede serial PRIMARY KEY,
	piva numeric(11) REFERENCES azienda,
	nazione varchar(20) NOT NULL,
	citta varchar(20) NOT NULL,
	cap numeric(5,0) NOT NULL,
	civico numeric(4,0) NOT NULL,
	via varchar(20) NOT NULL,
	tipoSede varchar(9) NOT NULL,
	FOREIGN KEY(nazione,citta,cap,via,civico) 
		REFERENCES Indirizzo (nazione,citta,cap,via,civico)	
		ON DELETE CASCADE
		ON UPDATE CASCADE
	
);
/* trigger una azienda non puo avere piu di 1 sede di tipo legale */

CREATE TABLE Documento (
	nrDocumento varchar(10) PRIMARY KEY,
	rilascio date NOT NULL,
	scadenza date NOT NULL,
	professione varchar(30) NOT NULL,
	nome varchar(10) NOT NULL,
	cognome varchar (15) NOT NULL,
	isPatente bool NOT NULL,
	luogoDiNascita varchar(20) NOT NULL,
	dataDiNascita date NOT NULL,
	CategoriaPatente char(1) NULL,
	nazione varchar(20) NOT NULL,
	citta varchar(20) NOT NULL,
	cap numeric(5,0) NOT NULL,
	civico numeric(4,0) NOT NULL,
	via varchar(20) NOT NULL,
	FOREIGN KEY (nazione,citta,	cap, civico, via) 
	REFERENCES 	Indirizzo (nazione,citta, cap, civico, via)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

CREATE TABLE Conducente (
	id_conducente serial PRIMARY KEY,
	piva numeric(11) NULL REFERENCES Azienda, 
	nrDocumento varchar(10) REFERENCES Documento 
	ON DELETE CASCADE 
	ON UPDATE CASCADE,
	nrPatente varchar (10) NOT NULL REFERENCES Documento 
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	UNIQUE (id_conducente,piva,nrDocumento,nrPatente)
);

CREATE TABLE Persona (
	codFisc char(16) NOT NULL PRIMARY KEY,
	id_conducente int references Conducente 
	ON DELETE CASCADE,	
	telefono varchar(11) NOT NULL,
	eta numeric, /* calcolato automaticamente */
	nrDocumento varchar(10) NOT NULL references Documento,
	nrPatente varchar(10) NOT NULL references Documento
	
);
/* numeri italiani 10 cifre nb */

CREATE TABLE Utente (
	email varchar(30) PRIMARY KEY, 
	piva integer REFERENCES Azienda 
	ON UPDATE CASCADE	
	ON DELETE CASCADE,
	codfisc char(16) REFERENCES Persona 
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	numSmartCard int REFERENCES MetodoDiPagamento
);

/** Funzioni utili per l'inserimento **/

SET search_path TO carsharing;

--insertParcheggio: 
CREATE OR REPLACE 
FUNCTION insertParcheggio(varchar(20),numeric,varchar(20),numeric(14,7),numeric(14,7),
		   /* indirizzo */varchar(20),varchar(20),numeric(5,0),numeric(4,0),varchar(20)) 
RETURNS VOID AS $$
DECLARE 
	BEGIN
		IF EXISTS( SELECT * FROM Indirizzo 
				  AS i 
				  WHERE i.nazione = $6 
				  AND i.citta = $7
				  AND i.cap = $8
				  AND i.civico = $9
				  AND i.via= $10)
		THEN
		INSERT INTO Parcheggio VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10);
		ELSE
			INSERT INTO Indirizzo VALUES ($6,$7,$8,$9,$10) ON CONFLICT DO NOTHING;
			INSERT INTO Parcheggio VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10);
		END IF;
	END;
$$ LANGUAGE plpgsql ;


--insertDocumento
CREATE OR REPLACE 
FUNCTION insertDocumento(
	nrDocumento varchar(10),rilascio date,scadenza date,professione varchar(30),nome varchar(10),
	cognome varchar (15),isPatente bool ,luogoDiNascita varchar(20), dataDiNascita date,
	CategoriaPatente char(1),nazione1 varchar(20), citta1 varchar(20), cap1 numeric(5,0),
	civico1 numeric(4,0), via1 varchar(20))
	
	RETURNS VOID AS $$ 
	BEGIN
		IF EXISTS( SELECT * FROM Indirizzo 
				  AS i 
				  WHERE i.nazione = nazione1 
				  AND i.citta = citta1
				  AND i.cap = cap1
				  AND i.civico = civico1
				  AND i.via= via1)
		THEN
   		INSERT INTO Documento VALUES (nrDocumento,rilascio,scadenza,professione,nome,cognome,
								 isPatente,luogoDiNascita,dataDiNascita,CategoriaPatente,
								 nazione1,citta1,cap1,civico1,via1);
		ELSE
		INSERT INTO Indirizzo VALUES (nazione1,citta1,cap1,civico1,via1) ON CONFLICT DO NOTHING;
		INSERT INTO Documento VALUES (nrDocumento,rilascio,scadenza,professione,nome,cognome,
								 isPatente,luogoDiNascita,dataDiNascita,CategoriaPatente,
								 nazione1,citta1,cap1,civico1,via1);
		END IF;
	END;
$$ LANGUAGE plpgsql; 

--insertSede
CREATE OR REPLACE 
FUNCTION insertSede(piva numeric(11),nazione1 varchar(20) ,
					citta1 varchar(20),cap1 numeric(5,0),civico1 numeric(4,0) ,
					via1 varchar(20),tipoSede1 varchar(9))

	RETURNS VOID AS $$ 
	BEGIN
		IF EXISTS( SELECT * FROM Indirizzo 
				  AS i 
				  WHERE i.nazione = nazione1 
				  AND i.citta = citta1
				  AND i.cap = cap1
				  AND i.civico = civico1
				  AND i.via= via1)
		THEN
   		INSERT INTO Sede(piva,nazione,citta,cap,civico,via,tipoSede) VALUES (piva,nazione1,citta1,cap1,civico1,via1,tipoSede1);
		ELSE
		INSERT INTO Indirizzo VALUES (nazione1,citta1,cap1,civico1,via1) ON CONFLICT DO NOTHING;
		INSERT INTO Sede(piva,nazione,citta,cap,civico,via,tipoSede) VALUES (piva,nazione1,citta1,cap1,civico1,via1,tipoSede1);
		END IF;
	END;
$$ LANGUAGE plpgsql;


--isSameAddres controlla se due persone Vivono insieme
CREATE OR REPLACE 
FUNCTION isSameAddress(nrPatCond varchar(10), nrDocPer varchar(10))
	RETURNS bool AS $$
	DECLARE
		ind1 record; /* record e` un rowtype assegnato dalla SELECT INTO -- */
		ind2 record;

	BEGIN
		SELECT nazione,citta,cap,civico,via FROM Documento
		natural join indirizzo 
		INTO ind1
		WHERE Documento.nrDocumento = nrPatCond;
		
		SELECT nazione,citta,cap,civico,via FROM Documento
		natural join indirizzo 
		INTO ind2
		WHERE Documento.nrDocumento = nrDocPer;
		
		IF 		ind1.nazione = ind2.nazione 
		AND		ind1.citta = ind2.citta
		AND		ind1.cap = ind2.cap
		AND		ind1.civico = ind2.civico
		AND		ind1.via = ind2.via
			
		THEN
			RAISE NOTICE 'Same addres...ok (%),(%)',ind1,ind2;
			RETURN true;
		ELSE 
			RAISE NOTICE 'Same addres...false (%),(%)',ind1,ind2;
			RETURN false;
		END IF;
	END;
$$ LANGUAGE plpgsql;

--getIdConducente 
CREATE OR REPLACE
FUNCTION getIdConducente(_param_id varchar(10))
RETURNS int AS $$
DECLARE
BEGIN
	RETURN (SELECT id_conducente FROM conducente WHERE nrDocumento = _param_id);
END;
$$ LANGUAGE plpgsql;

--CalcolaEta
CREATE OR REPLACE 
FUNCTION calcolaEta(date)
RETURNS int as $$
DECLARE

BEGIN

	RETURN (SELECT EXTRACT(YEAR FROM age($1)));
END;
$$ LANGUAGE plpgsql;


-- InsertPersona Controlla che un conducente che non sia conducente per una azienda abiti insieme alla persona
CREATE OR REPLACE 
FUNCTION insertPersona(codFisc char(16) ,id_conducente1 int, telefono varchar(11), nrDocumento1 varchar(10),nrPatente varchar(10))
RETURNS VOID AS $$
	DECLARE
		docConduc varchar(10);
		datanascita date;
	BEGIN
		
		SELECT nrDocumento
		INTO docConduc
		FROM conducente 
		WHERE id_conducente = id_conducente1;
		
		SELECT documento.datadinascita 
		INTO datanascita
		FROM Documento
		WHERE documento.nrdocumento = nrDocumento1;
		
		IF id_conducente1 = 0 
		THEN 
			RAISE NOTICE 'nessun conducente aggiuntivo per (%)',codFisc;
			INSERT INTO Persona VALUES (codFisc, NULL, telefono ,calcolaEta(datanascita) , nrDocumento1 , nrPatente); 
		RETURN;
		END IF;
		
		IF docConduc = NULL
			THEN
				INSERT INTO Persona VALUES (codFisc, id_conducente1, telefono ,calcolaEta(datanascita) , nrDocumento1 , nrPatente); 
			ELSE IF isSameAddress(nrPatente,docConduc)
			THEN 
				INSERT INTO Persona VALUES (codFisc, id_conducente1, telefono ,calcolaEta(datanascita) , nrDocumento1 , nrPatente);  
			ELSE
				RAISE EXCEPTION 'Inserimento abortito '
				USING HINT = 'Il conducente scelto non Abita insieme o non esistente';
			END IF;
		END IF;
	END;
$$
LANGUAGE plpgsql;

/*overload carta shorcut */
CREATE OR REPLACE FUNCTION insertMetodo(card int, num numeric,inte varchar,circ varchar,scad date)
RETURNS VOID AS $$
BEGIN
	INSERT INTO carta(numero,circuito,intestatario,scadenza) VALUES (num, circ, inte, scad);
	INSERT INTO MetodoDiPagamento(numsmartcard,numeroCarta,IntestatarioCarta,circuitoCarta,scadenzaCarta) VALUES (card,num,inte,circ,scad);
END;
$$ LANGUAGE plpgsql;

/*overload rid shorcut */
CREATE OR REPLACE FUNCTION insertMetodo(card int,iban varchar,inte varchar)
RETURNS VOID AS $$
BEGIN
	INSERT INTO rid(codIban, Intestatario) VALUES (iban, inte);
	INSERT INTO MetodoDiPagamento(numSmartCard,codIban,intestatarioConto)
			VALUES (card,iban, inte);
END;
$$ LANGUAGE plpgsql;


/* overload prepagato shortcut per inserimento metodo prepagato */
CREATE OR REPLACE FUNCTION insertMetodo(card int,versato numeric)
RETURNS VOID AS $$
BEGIN
	INSERT INTO MetodoDiPagamento(numSmartCard,versato)
			VALUES (card,versato);
END;
$$ LANGUAGE plpgsql;

--InsertAbbonamento
CREATE OR REPLACE FUNCTION insertAbbonamento(dataInizio timestamp,databonus date,bonus numeric, pin numeric, card numeric, tipo1 varchar)
RETURNS VOID AS $$
DECLARE
	days int;
	etaU int;
	
BEGIN
	SELECT ngiorni INTO days FROM tipo WHERE periodo = tipo1;
	SELECT eta INTO etaU FROM utente NATURAL JOIN persona WHERE numSmartCard = card; 
	INSERT INTO Abbonamento(datainizio,datafine,dataBonus,bonusRottamazione,pincarta,numsmartcard,tipo) 
	VALUES (datainizio,datainizio + days * INTERVAL '1 day',databonus,bonus,pin,card,tipo1);
END;
$$ LANGUAGE plpgsql;

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
--INSERT INTO carsharing.utilizzo VALUES (13, 2000, '2019-07-01 00:00:00', '2019-07-05 00:00:00', 2750);
--INSERT INTO carsharing.utilizzo VALUES (14, 7500, '2017-07-16 00:00:00', '2017-07-18 00:00:00', 7750);
--INSERT INTO carsharing.utilizzo VALUES (15, 2000, '2018-07-01 00:00:00', '2018-07-21 00:00:00', 3500);
--INSERT INTO carsharing.utilizzo VALUES (16, 1500, '2018-08-01 00:00:00', '2018-08-01 00:00:00', 1680);
--INSERT INTO carsharing.utilizzo VALUES (17, 5450, '2018-07-03 00:00:00', '2018-07-17 00:00:00', 6850);

--funzioni di supporto alle funzioni dei trigger

-- overload timestamp
CREATE OR REPLACE 
FUNCTION leqDay(timestamp, timestamp)
	RETURNS bool AS $BODY$
	BEGIN
		RETURN ($2::date-$1::date) <= 1;
	END;		
$BODY$ LANGUAGE plpgsql;

-- overload date
CREATE OR REPLACE 
FUNCTION leqDay(date,date)
	RETURNS bool AS $BODY$
	BEGIN
		RETURN ($2::date-$1::date) <= 7;
	END;		
$BODY$ LANGUAGE plpgsql;

-- overload timestamp
CREATE OR REPLACE 
FUNCTION leqWeek(timestamp,timestamp)
	RETURNS bool AS $BODY$
	BEGIN
		RETURN ($2::date-$1::date) <= 7;
	END;		
$BODY$ LANGUAGE plpgsql;

-- overload date
CREATE OR REPLACE 
FUNCTION leqWeek(date,date)
	RETURNS bool AS $BODY$
	BEGIN
		RETURN ($2::date-$1::date) <= 7;
	END;		
$BODY$ LANGUAGE plpgsql;

--tariffazione oraria
CREATE OR REPLACE FUNCTION tOraria(intervallo numeric,tariffaO numeric,tariffaC numeric,chilometri numeric)
RETURNS Numeric AS $$
	BEGIN
		RETURN (tariffaO)*(intervallo) + (tariffaC)*(chilometri);
	END;
$$ LANGUAGE plpgsql;

--tariffazione giornaliera
CREATE OR REPLACE FUNCTION tGiornaliera(intervallo numeric,tariffaG numeric, tariffaC numeric,chilometri numeric)
RETURNS Numeric AS $$
	BEGIN
		RETURN (tariffaG)*(SELECT EXTRACT(DAY FROM (intervallo)::interval)) + (tariffaC)*(cconsegna - critiro);
	END;
$$ LANGUAGE plpgsql;

--tariffazione settimanale + giorliera aggiuntiva
CREATE OR REPLACE FUNCTION tSettimanale(intervallo numeric, tariffaS numeric,tariffaGA numeric, tariffaC numeric,chilometri numeric)
RETURNS Numeric AS $$
	BEGIN
		RETURN (tariffaS)+(tariffaGA)*(intervallo-7);
	END;
$$ LANGUAGE plpgsql;

--emetti fattura abbiamo scelto di fissare penale al 10% non c'era tempo di aggiungere un campo/entita apposta sul db
CREATE OR REPLACE FUNCTION emettiFattura(penale numeric,totale numeric,chilometripercorsi numeric,
										tempoNonUsufruito interval, tempoUsufruito interval, 
										tempoAnnullato interval)
RETURNS VOID AS $$
	DECLARE 
	tn int;
	tu int;
	ta int;
	BEGIN
		tn := EXTRACT (HOUR FROM tempononusufruito);
		tu := EXTRACT (HOUR FROM tempousufruito);
		ta := EXTRACT (HOUR FROM tempoannullato);
		INSERT INTO fatturazione(penale,totalefatt,chilometripercorsi,tempononusufruito,tempousufruito,tempoannullato)
		VALUES(penale,totale,chilometripercorsi,tn,tu,ta);
	END;
$$ LANGUAGE plpgsql;
--versione senza logica per penali utile per riduzioni
CREATE OR REPLACE FUNCTION MinorCosto(intervallo numeric,tariffaO numeric, 
										tariffaG numeric, tariffaS numeric,
	 									TariffaC numeric, tariffaGA numeric,
										critiro numeric, cconsegna numeric)
RETURNS numeric AS $$
DECLARE 
calc numeric;
BEGIN
		IF intervallo <= 1
		THEN calc := tOraria(intervallo,tariffaO,tariffaC,cconsegna-critiro);
		END IF;
		IF intervallo <= 7
		THEN calc := tGiornaliera(intervallo,tariffaG,tariffaC,cconsegna-critiro);
		END IF;
		IF intervallo > 7
		THEN calc := tSettimanale(intervallo,tariffaS,tariffaGA,tariffaC,cconsegna-critiro);
		END IF;
	RETURN calc;
END;
$$ LANGUAGE plpgsql;

--Minor Costo
CREATE OR REPLACE FUNCTION MinorCosto(
	inizio timestamp, fine timestamp, modificainizio timestamp,	 modificafine timestamp,
	 rinuncia timestamp, tariffaO numeric, tariffaG numeric, tariffaS numeric,
	 TariffaC numeric, tariffaGA numeric, annullato bool, ritiro timestamp,
	 consegna timestamp, critiro numeric, cconsegna numeric)
	 
RETURNS numeric AS $fun$
declare 
penale numeric;
calc numeric;
intervallo interval;
BEGIN
	penale:=0;
	--tariffazione oraria
	IF leqDay(ritiro::date, consegna::date)    
	THEN
		calc := tOraria(extract(hour from fine)::int - extract(hour from inizio)::int,tariffaO,tariffaC,cconsegna-critiro);
	
	--tariffazione giornaliera	
	ELSE IF leqWeek(ritiro::timestamp, consegna::timestamp)
		THEN
			calc := tGiornaliera(extract(DAY from fine)::int - extract(DAY from inizio)::int,tariffaG,tariffaC,cconsegna-critiro);
	
	--tariffazione settimanale + giornaliera aggiuntiva
		ELSE 
			calc := tSettimanale(extract(DAY from fine)::int - extract(DAY from inizio)::int,tariffaS,tariffaGA,tariffaC,cconsegna-critiro);
		END IF;
	END IF;
	--applicazione penale nel caso di consegna ritardata
	IF consegna > fine
	THEN 
		penale := 0.1;
		calc := calc * penale;
	END IF;
	--annullamento della prenotazione con "sconto" preavviso
	IF ritiro >= rinuncia + '1 day'::interval AND annullato  
	THEN
		calc:=0.5*calc;
	END IF;
	
	--riduzione di prenotazione entro 24 ore precedenti con 50% di sconto sul tempo non goduto
	IF ritiro < rinuncia + '1 day'::interval AND (modificafine < fine OR modificainizio > inizio) 
	THEN
		
		--chiamata ricorsiva calcolo il nuovo tempo prenotato 
		calc:=MinorCosto( modificainizio, modificafine, NULL,NULL,NULL,	
					tariffaO,tariffaG,tariffaS,TariffaC,tariffaGA,
					FALSE,NULL, consegna,critiro,cconsegna);
	
		--calcolo intervallo 'rimandato'					
		intervallo := ((fine-inizio)-(modificafine-modificainizio))::interval;
		
		--applico minorcosto(semplificato, non c'e` bisogno di logica per penali) a intervallo e applico sconto
		calc:=calc+0.5*MinorCosto(intervallo,tariffaO,tariffaG,tariffaS,TariffaC,tariffaGA,critiro,cconsegna);
	END IF;
	IF consegna < fine
	THEN
		--chiamata ricorsiva calcolo il tempo di effettivo utilizzo 
		calc := MinorCosto( ritiro, consegna, NULL,NULL,NULL,	
					tariffaO,tariffaG,tariffaS,TariffaC,tariffaGA,
					FALSE,ritiro, consegna,critiro,cconsegna);
		--intervallo non utilizzato
	 	intervallo := ((fine-inizio)-(consegna-ritiro))::interval;
		--applico minorcosto a intervallo e applico 0.5 sul minorcosto dell'intervallo non goduto
		calc := calc + 0.5*MinorCosto(intervallo,tariffaO,tariffaG,tariffaS,TariffaC,tariffaGA,critiro,cconsegna);
	END IF;
	return calc;
END;
$fun$ LANGUAGE plpgsql; 
-- FINE funzioni di supporto

--trigger calcola fattura quando viene riconsegnato una vettura (inserimento in utilizzo)
CREATE OR REPLACE FUNCTION calcFatt()
RETURNS TRIGGER AS $calcFatt$
DECLARE
 inizio timestamp; fine timestamp;  modificainizio timestamp;
 modificafine timestamp; rinuncia timestamp; tariffaO numeric;
 tariffaG numeric; tariffaS numeric; TariffaC numeric;
 tariffaGA numeric; Rottamazione numeric; calc numeric;
 penale numeric; annullato bool; tempoAnnullato interval; 	
BEGIN

--cerco i dati necessari...
	SELECT prenotazione.dataorainizio, prenotazione.dataorafine, 
			modello.toraria,modello.tgiornaliera,modello.tsettimanale,
			modello.tchilometrica,modello.tgiornalieraaggiuntiva,
			abbonamento.bonusrottamazione
	INTO inizio, fine, 
		tariffaO, tariffaG, tariffaS, tariffaC, tariffaGA, rottamazione
	FROM prenotazione 
	NATURAL JOIN vettura
	NATURAL JOIN modello
	NATURAL JOIN abbonamento
	WHERE prenotazione.numeroprenotazione = new.numeroprenotazione;
	
	IF EXISTS (SELECT modificaprenotazione.nuovadataorainizio, 
			   		  modificaprenotazione.nuovadataorarest
			   FROM   modificaprenotazione
			   NATURAL JOIN prenotazione
               WHERE prenotazione.numeroprenotazione = new.numeroprenotazione
			   )
		THEN 
			SELECT modificaprenotazione.nuovadataorainizio,	
				   modificaprenotazione.nuovadataorarest, 
				   modificaprenotazione.dataorarinuncia
				INTO modificainizio , modificafine, rinuncia
			   	FROM modificaprenotazione
			   	WHERE modificaprenotazione.numeroprenotazione = new.numeroprenotazione;
	
	--se la modificaprenotazione non ha data e` un annullamento
		ELSE
		modificainizio := NULL;
		modificafine := NULL;
		rinuncia := NULL;
	END IF;
	--se c'e` stato un annulmento setto flag
	annullato := (rinuncia != NULL) AND (modificainizio = NULL) AND modificafine = NULL;
	
	IF annullato 
		THEN TempoAnnullato := EXTRACT(HOUR FROM(fine-inizio))::int;
		ELSE TempoAnnullato=0;
	END IF;

	calc := MinorCosto(inizio,fine,modificainizio,modificafine,
					   rinuncia,tariffaO,tariffaG,tariffaS,TariffaC,
					   tariffaGA,annullato,new.dataoraritiro,new.dataorariconsegna,
					   new.chilometraggioritiro,new.chilometraggioriconsegna);
					   
	--se rottamazione la applico (percentuale)
	IF rottamazione != 0
		THEN calc:= calc - calc*rottamazione/100;
	END IF;
	IF new.dataorariconsegna > fine
	THEN
		penale=0.1;
	ELSE 
		penale=0;
	END IF;
	--emetto fattura con la tariffazzione calcolata
	perform emettiFattura(penale,calc, new.chilometraggioriconsegna-new.chilometraggioritiro,
				 ((fine-inizio)-(new.dataorariconsegna-new.dataoraritiro)),
				 new.dataorariconsegna-new.dataoraritiro, tempoAnnullato);
				 
	RETURN NEW;
	END;
$calcFatt$ LANGUAGE plpgsql;

--adattato al nostro schema
--Data e ora di ritiro in prenotazione devono essere precedenti alla data e ora di consegna in utilizzo
CREATE OR REPLACE FUNCTION checkData()
RETURNS TRIGGER AS $chkdate$
DECLARE
 prenotazione timestamp;
 modifica timestamp;
BEGIN
	SELECT dataorainizio 
	INTO prenotazione  
	FROM prenotazione 
	WHERE new.numeroprenotazione = prenotazione.numeroprenotazione;
	IF EXISTS (SELECT modificaprenotazione.nuovadataorainizio
			   FROM modificaprenotazione
			   NATURAL JOIN prenotazione
			   WHERE new.numeroprenotazione = prenotazione.numeroprenotazione 	
			  )
		THEN
		SELECT modificaprenotazione.nuovadataorainizio
			   INTO modifica
			   FROM modificaprenotazione
			   NATURAL JOIN prenotazione
			   WHERE new.numeroprenotazione = prenotazione.numeroprenotazione; 	
	
		    -- prenotazione modificata
			prenotazione = modifica;
	END IF;
	IF new.dataoraritiro < prenotazione
	THEN
		RAISE EXCEPTION 'Inserimento abortito: la data di ritiro=(%) < prenotazione (o modificaPrenotazione)=(%)',  prenotazione,ritiro
      	USING HINT = 'prova a cambiare la data di ritiro o prenotazione o rischedulare la prenotazione.. ';
	ELSE
		RETURN NEW;
	END IF;
END;
$chkdate$ LANGUAGE plpgsql;


--UPDATE INSERT Prenotazione
CREATE OR REPLACE FUNCTION pren_trig()
RETURNS TRIGGER AS $Prenotazione$
DECLARE
 Data timestamp;
BEGIN
	Data := now()::timestamp;
	--una prenotazione puo essere fatta solo entro 15 minuti dal ritiro
	IF Data <= new.dataorainizio - 15*'1 min'::interval
	THEN
		RAISE EXCEPTION 'Non si puo inserire la prenotazione :  % e` a meno di 15 minuti da adesso ',  new.dataorainizio
      	USING HINT = 'prova a cambiare la data di partenza prenotazione.. ';
		RETURN NEW;
	END IF;
END;
$Prenotazione$ LANGUAGE plpgsql;


--UPDATE INSERT ModificaPrenotazione
CREATE OR REPLACE FUNCTION ModPren_trig()
RETURNS TRIGGER AS $ModPren$
DECLARE
	aData timestamp;
	bData timestamp;
BEGIN
	aData := now()::timestamp;
	SELECT dataorainizio
	INTO bData
	FROM prenotazione
	WHERE prenotazione.numeroprenotazione = new.numeroprenotazione;
	IF bData > aData AND new.nuovaoradatainizio < new.nuovaoradatafine
	THEN new.dataorarinuncia = aData;
	RETURN NEW;
	ELSE
	RAISE EXCEPTION 'Non si puo inserire la prenotazione :  date non consistenti '  
      	USING HINT = 'prova a verificare la data di prenotazione.. ';
	END IF;
END;
$ModPren$ LANGUAGE plpgsql;

--trigger inserimento o update prenotazione
CREATE  TRIGGER pren_trig BEFORE INSERT OR UPDATE ON prenotazione
FOR EACH ROW
EXECUTE PROCEDURE pren_trig();

--trigger inserimento o update ModificaPrenotazione
CREATE TRIGGER ModPren_trig BEFORE INSERT OR UPDATE ON Modificaprenotazione
FOR EACH ROW
EXECUTE PROCEDURE ModPren_trig();

--trigger controlla le date in prenotazione,modificaprenotazione ed utilizzo vedere checkdata
CREATE TRIGGER checkData BEFORE INSERT OR UPDATE ON Utilizzo
FOR EACH ROW
EXECUTE PROCEDURE checkData();

--trigger consegna macchina, emette fattura applicando la migliore tariffazione 
CREATE TRIGGER calcFatt AFTER INSERT OR UPDATE ON Utilizzo
FOR EACH ROW EXECUTE PROCEDURE calcFatt();

/* UTILIZZO CON CASI DI TEST*/
TRUNCATE utilizzo;
INSERT INTO carsharing.utilizzo VALUES (13, 2000, '2019-07-05 00:00:00', '2019-07-15 00:00:00', 2750);

--Some Checks!
ALTER TABLE Modello ADD CHECK(lunghezza > 1000);
ALTER TABLE Modello ADD CHECK(larghezza > 1000);
ALTER TABLE Modello ADD CHECK(Nporte > 2 AND Nporte <= 5);
ALTER TABLE Modello ADD CHECK(velocita BETWEEN 50 AND 230 );
ALTER TABLE Carta ADD CHECK(scadenza>NOW() + interval '1 month');
ALTER TABLE Carta ADD CHECK(numero > 0);
ALTER TABLE Abbonamento ADD CHECK( datafine > datainizio);
ALTER TABLE Abbonamento ADD CHECK(BonusRottamazione <= 100);
ALTER TABLE Vettura ADD CHECK (targa ~ $$[A-Za-z]{2}[0-9]{3}[A-Za-z]{2}$$);
ALTER TABLE Rifornimenti ADD CHECK(litri < 100);
ALTER TABLE Sinistro ADD CHECK (dataOra > now() - interval '10 day');
ALTER TABLE Testimoni ADD CHECK (dataDiNascita < now() - interval '18 year' );
ALTER TABLE Rappresentante ADD CHECK(dataDiNascita < now() - interval '18 year');
ALTER TABLE Azienda ADD CHECK (piva != 0);
ALTER TABLE Sede ADD CHECK (tiposede = 'Legale' or tiposede = 'Operativa');
ALTER TABLE Documento ADD CHECK(dataDiNascita < now() - interval '18 year');
ALTER TABLE Persona ADD CHECK (eta >= 18);
ALTER TABLE Utente ADD CHECK (email ~ '^[a-zA-Z0-9.!#$%&''*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$')