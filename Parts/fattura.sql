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