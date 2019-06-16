/* TRIGGERS! */
SET search_path TO carsharing;

-- overload timestamp
CREATE OR REPLACE 
FUNCTION cmpdates(timestamp,timestamp)
	RETURNS interval AS $BODY$
	BEGIN
		RETURN 	$2-$1::interval;
	END;		
$BODY$ LANGUAGE plpgsql;

--overload date
CREATE OR REPLACE 
FUNCTION cmpdates(date,date)
	RETURNS interval AS $BODY$
	BEGIN
		RETURN 	$1-$2::interval;
	END;		
$BODY$ LANGUAGE plpgsql;


--funzioni di supporto alle funzioni dei trigger
--
-- overload timestamp
CREATE OR REPLACE 
FUNCTION leqDay(timestamp,timestamp)
	RETURNS bool AS $BODY$
	BEGIN
		RETURN compdates($1,$2) < '1 day'::timestamp;
	END;		
$BODY$ LANGUAGE plpgsql;

-- overload date
CREATE OR REPLACE 
FUNCTION leqDay(date,date)
	RETURNS bool AS $BODY$
	BEGIN
		RETURN compdates($1,$2) < '1 day'::timestamp;
	END;		
$BODY$ LANGUAGE plpgsql;

-- overload timestamp
CREATE OR REPLACE 
FUNCTION leqWeek(timestamp,timestamp)
	RETURNS bool AS $BODY$
	BEGIN
		RETURN compdates($1,$2) < '1 day'::timestamp;
	END;		
$BODY$ LANGUAGE plpgsql;

-- overload date
CREATE OR REPLACE 
FUNCTION leqWeek(date,date)
	RETURNS bool AS $BODY$
	BEGIN
		RETURN compdates($1,$2) < '1 day'::timestamp;
	END;		
$BODY$ LANGUAGE plpgsql;

-- FINE funzioni di supporto

-- Calcola Fattura Quando viene restituita una vettura
-- Applicando la tariffa migliore

CREATE OR REPLACE FUNCTION calcFatt()
RETURNS TRIGGER AS $calcFatt$
DECLARE
 inizio timestamp;
 fine timestamp;
 modificainizio timestamp;
 modificafine timestamp;
 tariffaO numeric;
 tariffaG numeric;
 tariffaS numeric;
 TariffaC numeric;
 tariffaGA numeric;
 calc numeric;
 Rottamazione numeric;
BEGIN
	SELECT datorainizio, dataorafine, 
			toraria,tgiornaliera,tsettimanale,tchilometrica,tgiornalieraaggintiva,
			bonusrottamazione
	INTO inizio, fine, 
		tariffaO, tariffaG, tariffaS, tariffaC, tariffaGA, rottamazione
	FROM prenotazione 
	NATURAL JOIN vettura
	NATURAL JOIN modello
	NATURAL JOIN abbonamento;
	IF EXISTS (SELECT nuovadatorainizio, nuovadataorafine
			   --INTO modificainizio , modificafine
			   FROM modificaprenotazione
			   NATURAL JOIN prenotazione
			   )
		THEN SELECT nuovadatorainizio, nuovadataorafine
			   INTO modificainizio , modificafine
			   FROM modificaprenotazione
			   NATURAL JOIN prenotazione;
		inizio := modificainizio;
		fine := modificafine;
	END IF;

/*Nel caso di prenotazioni (inizio)in cui data di ritiro e data di consegna (fine) coincidono, il prezzo deve essere uguale a 
(tariffa oraria)*(ore prenotate) + (tariffa chilometrica)*(chilometri effettivamente percorsi) 
se non e` attivo il bonus di rottamazione. 
(questa operazione nel nostro schema consiste nell'emettere 
una fattura in fase di riconsegna in effettivo utilizzo )*/
	IF leqDay(new.dataOraRitiro, new.dataOrariconsegna) 
	THEN
		calc := (tariffaO) * (SELECT EXTRACT (epoch FROM ( fine-inizio )::interval )/3600) + 
				(tariffaC)*(NEW.chilometraggioriconsegna - NEW.chilometraggioritiro);
/*Nel caso di prenotazioni in cui data di ritiro e data di consegna non coincidono e la differenza tra le due e`, 
al massimo, sette giorni, il  prezzo deve essere uguale a (tariffa giornaliera)*(giorni prenotati) 
+ (tariffa chilometrica)*(chilometri effettivamente percorsi), se non e` attivo il bonus di rottamazione.*/
	ELSE IF leqWeek(new.dataOraRitiro, new.dataOrariconsegna) 
		THEN
			calc := (tariffaG)*(SELECT EXTRACT(DAY FROM (fine-inizio)::interval)) + 
					(tariffaC)*(NEW.chilometraggioriconsegna - NEW.chilometraggioritiro);
		
/*Nel caso di prenotazioni in cui data di ritiro e data di consegna non coincidono e 
la differenza tra le due e` strettamente superiore a  sette giorni, il prezzo deve essere 
uguale a (tariffa settimanale) + (tariffa giorno aggiuntivo)*((giorni prenotati) – 7 */
		ELSE 
		 calc := (tariffaS)+(tariffaGA)*(SELECT EXTRACT(DAY FROM (fine-inizio)::interval)-7);
		END IF;
	END IF;
/*Se la data di consegna dell'effettivo utilizzo e` successiva alla data di consegna della 
prenotazione al prezzo va aggiunta una penale.*/	
	IF 
	IF rottamazione != 0
	--se rottamazione la applico (percentuale)
	THEN calc:= calc - calc*rottamazione/100;
	END IF;
	--emetto fattura con la tarifazzione calcolata
	emettiFattura()
END;
$calcFatt$ LANGUAGE plpgsql;

--adattato al nostro schema
--Data e ora di ritiro in prenotazione devono essere precedenti alla data e ora di consegna in utilizzo
CREATE OR REPLACE FUNCTION checkData()
RETURNS TRIGGER AS $chkdate$
DECLARE
 ritiro timestamp;
 prenotazione timestamp;
 modifica timestamp;
BEGIN
	SELECT dataorainizio dataoraritiro
	INTO prenotazione, ritiro 
	FROM prenotazione 
	NATURAL JOIN utilizzo
	NATURAL JOIN NEW;
	IF EXISTS (SELECT nuovadatorainizio
			   INTO modifica
			   FROM modificaprenotazione
			   NATURAL JOIN prenotazione
			   )
		THEN 
		-- prenotazione modificata
			prenotazione = modifica;
	END IF;
	IF ritiro < prenotazione
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
	FROM prenotazione NATURAL JOIN New ;
	--WHERE prenotazione.numeroprenotazione = new.numeroprenotazione;
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


