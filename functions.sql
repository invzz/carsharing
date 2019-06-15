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

--insertMetodo
CREATE OR REPLACE FUNCTION insertMetodo(numeric,numeric,varchar,varchar,date,char(27),varchar)
RETURNS VOID AS $$
DECLARE
BEGIN
	IF $1 = NULL OR $1 = 0
	THEN
		IF EXISTS (SELECT * from Carta,rid WHERE carta.numero = $2 OR rid.codiban = $6)
		THEN 
			INSERT INTO MetodoDiPagaento(versato,numeroCarta,intestatarioCarta,circuitoCarta,scadenzaCarta,codIban,intestatarioConto)
			VALUES ($1,$2,$3,$4,$5,$6,$7);
		END IF; 
		IF $2 != NULL AND $6 = NULL
		THEN
			INSERT INTO carta 
			VALUES ($2,$3,$4,$5); 
			INSERT INTO MetodoDiPagamento(versato,numeroCarta,intestatarioCarta,circuitoCarta,scadenzaCarta,codIban,intestatarioConto)
			VALUES ($1,$2,$3,$4,$5,$6,$7);
		END IF;
		IF  $2 = NULL AND $6 != NULL
		THEN
			INSERT INTO rid
			VALUES ($6,$7);
			INSERT INTO MetodoDiPagamento(versato,numeroCarta,intestatarioCarta,circuitoCarta,scadenzaCarta,codIban,intestatarioConto)
			VALUES ($1,$2,$3,$4,$5,$6,$7);
		END IF;
	END IF;
END;
$$ LANGUAGE plpgsql;

/*overload carta shorcut */
CREATE OR REPLACE FUNCTION insertMetodo(num numeric,inte varchar,circ varchar,scad date)
RETURNS VOID AS $$
BEGIN
	INSERT INTO carta(numero,circuito,intestatario,scadenza) VALUES (num, circ, inte, scad);
	INSERT INTO MetodoDiPagamento(numeroCarta,IntestatarioCarta,circuitoCarta,scadenzaCarta) VALUES (num,inte,circ,scad);
END;
$$ LANGUAGE plpgsql;

/*overload rid shorcut */
CREATE OR REPLACE FUNCTION insertMetodo(iban varchar,inte varchar)
RETURNS VOID AS $$
BEGIN
	INSERT INTO rid(codIban, Intestatario) VALUES (iban, inte);
	INSERT INTO MetodoDiPagamento(codIban,intestatarioConto)
			VALUES (iban, inte);
END;
$$ LANGUAGE plpgsql;


/* overload prepagato shortcut per inserimento metodo prepagato */
CREATE OR REPLACE FUNCTION insertMetodo(versato numeric)
RETURNS VOID AS $$
BEGIN
	INSERT INTO MetodoDiPagamento(versato)
			VALUES (versato);
END;
$$ LANGUAGE plpgsql