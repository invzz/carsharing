/* TRIGGERS! */
SET search_path TO carsharing;

--funzioni di supporto alle funzioni dei trigger

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

-- overload timestamp
CREATE OR REPLACE 
FUNCTION leqDay(timestamp,timestamp)
	RETURNS bool AS $BODY$
	BEGIN
		RETURN compdates($1,$2) <= '1 day'::timestamp;
	END;		
$BODY$ LANGUAGE plpgsql;

-- overload date
CREATE OR REPLACE 
FUNCTION leqDay(date,date)
	RETURNS bool AS $BODY$
	BEGIN
		RETURN compdates($1,$2) <= '1 day'::timestamp;
	END;		
$BODY$ LANGUAGE plpgsql;

-- overload timestamp
CREATE OR REPLACE 
FUNCTION leqWeek(timestamp,timestamp)
	RETURNS bool AS $BODY$
	BEGIN
		RETURN compdates($1,$2) <= '7 day'::timestamp;
	END;		
$BODY$ LANGUAGE plpgsql;

-- overload date
CREATE OR REPLACE 
FUNCTION leqWeek(date,date)
	RETURNS bool AS $BODY$
	BEGIN
		RETURN compdates($1,$2) <= '7 day'::timestamp;
	END;		
$BODY$ LANGUAGE plpgsql;

--tariffazione oraria
CREATE OR REPLACE FUNCTION tOraria(intervallo interval,tariffaO numeric,tariffaC numeric,chilometri numeric)
RETURNS Numeric AS $$
	BEGIN
		RETURN (tariffaO)*(SELECT EXTRACT (epoch FROM ( intervallo )::interval )/3600) + (tariffaC)*(chilometri);
	END;
$$ LANGUAGE plpgsql;

--tariffazione giornaliera
CREATE OR REPLACE FUNCTION tGiornaliera(intervallo interval,tariffaG numeric, tariffaC numeric,chilometri numeric)
RETURNS Numeric AS $$
	BEGIN
		RETURN (tariffaG)*(SELECT EXTRACT(DAY FROM (intervallo)::interval)) + (tariffaC)*(cconsegna - critiro);
	END;
$$ LANGUAGE plpgsql;

--tariffazione settimanale + giorliera aggiuntiva
CREATE OR REPLACE FUNCTION tSettimanale(intervallo interval, tariffaS numeric,tariffaGA numeric, tariffaC numeric,chilometri numeric)
RETURNS Numeric AS $$
	BEGIN
		RETURN (tariffaS)+(tariffaGA)*(SELECT EXTRACT(DAY FROM (intervallo)-7));
	END;
$$ LANGUAGE plpgsql;

--emetti fattura abbiamo scelto di fissare penale al 10% non c'era tempo di aggiungere un campo/entita apposta sul db
CREATE OR REPLACE FUNCTION emettiFattura(totale numeric,chilometripercorsi numeric,
										tempoNonUsufruito interval, tempoUsufruito interval, 
										tempoAnnullato interval)
RETURNS VOID AS $$
	BEGIN
		INSERT INTO fatturazione(penale,totale,chilometripercorsi,tempononusufruito,tempousufruito,tempoannullato)
		VALUES(0.1,totale,chilometripercorsi,tempononusufruito,tempousufruito,tempoannullato);
	END;
$$ LANGUAGE plpgsql;
--versione senza logica per penali utile per riduzioni
CREATE OR REPLACE FUNCTION MinorCosto(intervallo interval,tariffaO numeric, 
										tariffaG numeric, tariffaS numeric,
	 									TariffaC numeric, tariffaGA numeric,
										critiro numeric, cconsegna numeric)
RETURNS numeric AS $$
DECLARE 
calc numeric;
BEGIN
		IF intervallo <= '1 day'::interval
		THEN calc := tOraria(intervallo,tariffaO,tariffaC,cconsegna-critiro);
		END IF;
		IF intervallo <= '7 day'::interval
		THEN calc := tGiornaliera(intervallo,tariffaG,tariffaC,cconsegna-critiro);
		END IF;
		IF intervallo <= '7 day'::interval
		THEN calc := tSettimanale(fine-inizio::interval,tariffaS,tariffaGA,tariffaC,cconsegna-critiro);
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
	IF leqDay(ritiro, consegna)    
	THEN
		calc := tOraria(fine-inizio::interval,tariffaO,tariffaC,cconsegna-critiro);
	--tariffazione giornaliera	
	ELSE IF leqWeek(ritiro, consegna)
		THEN
			calc := tGiornaliera(fine-inizio::interval,tariffaG,tariffaC,cconsegna-critiro);
	--tariffazione settimanale + giornaliera aggiuntiva
		ELSE 
			calc := tSettimanale(fine-inizio::interval,tariffaS,tariffaGA,tariffaC,cconsegna-critiro);
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
			   FROM modificaprenotazione
			   NATURAL JOIN prenotazione
			   )
		THEN SELECT nuovadatorainizio, nuovadataorafine, dataorarinuncia
			   INTO modificainizio , modificafine, rinuncia
			   FROM modificaprenotazione
			   NATURAL JOIN prenotazione;
	--se la modificaprenotazione non ha data e` un annullamento
	END IF;
	annullato = rinuncia != NULL AND modificainzio = NULL AND modificafine = NULL;
	
	IF annullato 
		THEN TempoAnnullato := EXTRACT(HOUR FROM(fine-inizio))::int;
		ELSE TempoAnnullato=0;
	END IF;
	calc := MinorCosto(inizio,fine,modificainizio,modificafine,
					   rinuncia,tariffaO,tariffaG,tariffaS,TariffaC,
					   tariffaGA,Rottamazione,calc,penale,annullato,
					   new.dataoraritiro,new.datorariconsegna,
					   new.chilometraggioritiro,new.chilometraggioriconsegna);
					   
	--se rottamazione la applico (percentuale)
	IF rottamazione != 0
		THEN calc:= calc - calc*rottamazione/100;
	END IF;
	
	--emetto fattura con la tariffazzione calcolata
	SELECT emettiFattura(penale,calc, new.chilometraggioriconsegna-new.chilometraggioritiro,
				 EXTRACT(HOUR FROM((fine-inizio)-(consegna-ritiro))::int),
				 EXTRACT(HOUR FROM consegna-ritiro)::int, tempoAnnullato);
	
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