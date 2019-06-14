DROP SCHEMA carsharing CASCADE;
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
	ON UPDATE NO ACTION
	CHECK(lunghezza > 1000),
	CHECK(larghezza > 1000),
	CHECK(Nporte > 2 AND Nporte <= 5),
	CHECK(velocita BETWEEN 50 AND 230 ),
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
	TempoAnnullato numeric,
	CHECK(TempoUsufruito + TempoNonUsufruito > 0)
);
/* check TempoUsufruito + TempoNonUsufruito > 0 */
/* trigger TempoAnnullato > 0 ==> TempoNonUsufruito > 0*/
CREATE TABLE Tipo (
	periodo	varchar(20) PRIMARY KEY,
	costo numeric NOT NULL,
	riduzione numeric NuLL
);
/* periodo annuale, bimestrale, semestrale, mensile, settimanale...*/

CREATE TABLE Carta (
	numero numeric(10,0) NOT NULL, 
	circuito varchar(10) NOT NULL,
	intestatario varchar(30) NOT NULL,
	scadenza date NOT NULL ,
	PRIMARY KEY(numero,circuito,intestatario,scadenza),
	CHECK(scadenza>NOW() + interval '1 month'),
	CHECK(numero > 0)
);

CREATE TABLE Rid (
	codIban char(27) NOT NULL, 
	intestatario varchar(30) NOT NULL,
	PRIMARY KEY(codIban,Intestatario)
);

CREATE TABLE MetodoDiPagamento (
	numSmartCard numeric PRIMARY KEY,
	versato numeric, 
	numeroCarta numeric(10), 
	intestatarioCarta varchar(30),		
	circuitoCarta varchar(10),
	scadenzaCarta date NOT NULL,
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
	bonusRiduzione numeric,
	pinCarta	numeric(4,0) NOT NULL,
	numSmartCard numeric NOT NULL references MetodoDiPagamento,
	tipo varchar(20) NOT NULL references Tipo,
	PRIMARY KEY (dataInizio,numSmartCard)
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
	sede varchar(20) references Parcheggio
	CHECK (targa ~ $$[A-Za-z]{2}[0-9]{3}[A-Za-z]{2}$$)
);


CREATE TABLE Prenotazione (
	NumeroPrenotazione serial PRIMARY KEY,
	dataOraRinuncia timestamp,
	nuovaDataOraRest timestamp,
	dataOraInizio timestamp NOT NULL,
	dataOraFine timestamp NOT NULL,
	dataInizio date NOT NULL,
	numSmartCard int, 
	NomeVettura varchar(10) REFERENCES Vettura,
	numeroFattura int
		REFERENCES Fatturazione
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
	FOREIGN KEY(numSmartCard, dataInizio)
		REFERENCES Abbonamento(numSmartCard, dataInizio)
);


CREATE TABLE Rifornimenti (
	targa varchar(7) references Vettura(targa),
	chilometraggio numeric,	
	data date NOT NULL,
	litri numeric NOT NULL,
	PRIMARY KEY (chilometraggio,targa),
	CHECK(litri < 100)
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
	PRIMARY KEY (NumeroPrenotazione,dataOraRitiro),
	CHECK(dataOraRitiro < dataOraRiconsegna 
			AND dataOraRitiro < dataOraRiconsegna 
			AND chilometraggioRitiro < chilometraggioRiconsegna)
);



CREATE TABLE Sinistro (
	NumeroPrenotazione int REFERENCES Prenotazione(NumeroPrenotazione), 
	dataOra timestamp,	
	danni varchar NOT NULL,
	dinamica varchar NOT NULL,	
	conducente varchar (40) NOT NULL,
	luogo varchar (100) NOT NULL,
	PRIMARY KEY (numeroPrenotazione, dataOra),
	CHECK (dataOra > now() - interval '10 day')
);
/*sinistro notificato entro 10 giorni*/

CREATE TABLE Testimoni (
	contatto varchar(30) PRIMARY KEY,	
	nome varchar(10) NOT NULL,
	cognome varchar(15) NOT NULL,
	dataDiNascita date NOT NULL,
	luogoDiNascita varchar(20) NOT NULL,
	CHECK (dataDiNascita < now() - interval '18 year' )	
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
	PRIMARY KEY(nome,cognome, dataDiNascita),
	CHECK (dataDiNascita < now() - interval '18 year') 
);

CREATE TABLE Azienda (
	piva numeric(11) PRIMARY KEY,
	ragSociale varchar(30) NOT NULL,
	telefono varchar(10) NOT NULL,	
	telefonoReferente varchar(10) REFERENCES Referente NOT NULL,
	nomeRappresentante varchar(10) NOT NULL,
	cognomeRappresentante varchar(15) NOT NULL,
	dataDiNascitaRappresentante date NOT NULL,
	FOREIGN KEY (nomeRappresentante, cognomeRappresentante, dataDiNascitaRappresentante) 
	REFERENCES Rappresentante
	ON DELETE CASCADE 
	ON UPDATE CASCADE,
	CHECK (piva != 0)
);

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
	CategoriaPatente char(1) NOT NULL,
	nazione varchar(20) NOT NULL,
	citta varchar(20) NOT NULL,
	cap numeric(5,0) NOT NULL,
	civico numeric(4,0) NOT NULL,
	via varchar(20) NOT NULL,
	FOREIGN KEY (nazione,citta,	cap, civico, via) 
	REFERENCES 	Indirizzo (nazione,citta, cap, civico, via)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CHECK (dataDiNascita < now() - interval '18 year') 
);

CREATE TABLE Conducente (
	id_conducente serial PRIMARY KEY,
	piva numeric(11) NOT NULL REFERENCES Azienda, 
	nrDocumento varchar(10) NOT NULL REFERENCES Documento 
	ON DELETE CASCADE 
	ON UPDATE CASCADE,
	nrPatente varchar (10) NOT NULL REFERENCES Documento 
	ON DELETE CASCADE
	ON UPDATE CASCADE
);



CREATE TABLE Persona (
	id_conducente int references Conducente
	ON DELETE CASCADE,	
	telefono varchar(10) NOT NULL,
	eta numeric, /* calcolato automaticamente */
	codFisc char(11) NOT NULL PRIMARY KEY,
	nrDocumento varchar(10) NOT NULL references Documento,
	nrPatente varchar(10) NOT NULL references Documento,
	CHECK (eta >= 18)
);
/* numeri italiani 10 cifre nb */

CREATE TABLE Utente (
	email varchar(30) PRIMARY KEY, 
	piva numeric(11) REFERENCES Azienda 
	ON UPDATE CASCADE	
	ON DELETE CASCADE,
	codfisc char(11) REFERENCES Persona 
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

/** Funzioni utili per l'inserimento **/
CREATE FUNCTION insertParcheggio(varchar(20),numeric,varchar(20),
								numeric(14,7),numeric(14,7),
								/* indirizzo */
								varchar(20),varchar(20),numeric(5,0),
								numeric(4,0),varchar(20)) 
  RETURNS VOID AS 
$$ 
   INSERT INTO Indirizzo VALUES ($6,$7,$8,$9,$10);
   INSERT INTO Parcheggio VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10) 
   
$$ 
LANGUAGE sql STRICT;
