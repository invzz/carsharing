/** Funzioni utili per l'inserimento **/
/*	DROP FUNCTION insertParcheggio;
	DROP FUNCTION insertDocumento;
	DROP FUNCTION insertSede;
*/


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
--Compare address

--isSameAddres controlla se due persone Vivono insieme
CREATE OR REPLACE 
FUNCTION isSameAddress(nrPatCond varchar(10), nrDocPer varchar(10))
	RETURNS bool AS $$
	DECLARE
		ind1 record; /* record e` un rowtype assegnato dalla SELECT INTO -- */
		ind2 record;

	BEGIN
		SELECT * FROM Documento
		natural join indirizzo 
		INTO ind1
		WHERE Documento.nrDocuemento = nrPatCond;
		
		SELECT * FROM Documento
		natural join indirizzo 
		INTO ind2
		WHERE Documento.nrDocuemento = nrDocPer;
		
		IF ind1 = ind2
		THEN
			RETURN true;
		ELSE 
			RETURN false;
		END IF;
	END;
$$ LANGUAGE plpgsql;

--getIdConducente 

-- InsertPersona Controlla che un conducente che non sia conducente per una azienda abiti insieme alla persona
CREATE OR REPLACE 
FUNCTION insertPersona(id_conducente1 int,piva numeric(11), nrDocumento1 varchar(10),nrPatente varchar (10))
RETURNS VOID AS $$
	DECLARE
		idDocCon int;
	BEGIN
		SELECT id_conducente
		FROM conducente
		INTO idDocCon
		WHERE nrDocumento = nrDocumento1;
		IF piva = NULL
		THEN
			IF isSameAddress(nrPatente,DocConduc)
			THEN 
			INSERT INTO Persona (id_conducente ,piva , nrDocumento ,nrPatente)  VALUES (piva , nrDocumento1 ,nrPatente  );  
			ELSE
			RAISE EXCEPTION 'Inserimento abortito '
      		USING HINT = 'Il conducente scelto non Abita insieme alla Persona !';
			END IF;
		ELSE
		INSERT INTO Persona (id_conducente ,piva , nrDocumento ,nrPatente)  VALUES (piva , nrDocumento1 ,nrPatente  );  
		END IF;
	END;
$$
LANGUAGE plpgsql