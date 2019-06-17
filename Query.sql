SELECT PA.*
FROM  parcheggio AS PA , vettura AS V ,prenotazione AS PR, modello AS Mo, Categoria AS Cat
WHERE Cat.categoria ='City Car' AND
       PA.nomeparcheggio = V.sede AND
	   V.nomevettura = PR.nomevettura AND
	   V.modello = Mo.NomeModello  AND
	   Mo.categoria = Cat.categoria AND
      EXTRACT (HOUR FROM current_date) + 3 = EXTRACT(HOUR FROM PR.dataOraInizio::Date)
--
SELECT U.*, V.nomevettura, V.targa, utilizzo.dataOraRiconsegna
FROM Utente AS U NATURAL JOIN metododipagamento AS MDP
	 NATURAL JOIN abbonamento AS Ab
	 NATURAL JOIN prenotazione AS PR
	 NATURAL JOIN vettura AS V, utilizzo, prenotazione
WHERE prenotazione.numsmartcard = Ab.numsmartcard AND
	  prenotazione.numeroprenotazione = utilizzo.numeroprenotazione AND
      utilizzo.dataOraRitiro::date < utilizzo.dataOraRiconsegna::date
--
SELECT pa.nomeparcheggio, cat.categoria
FROM parcheggio AS pa, vettura AS v, prenotazione AS pr,
     modello AS mo, categoria AS cat
WHERE pa.nomeparcheggio = v.sede AND
	  v.nomevettura = pr.nomevettura AND
	  v.modello = mo.nomemodello AND
	  mo.categoria = cat.categoria AND
	  EXTRACT(hour FROM current_date)+1 = EXTRACT(hour FROM pr.dataOraInizio)
GROUP BY pa.nomeparcheggio,cat.categoria
HAVING count(*) >= 1
--
SELECT *
FROM prenotazione AS p1
except
SELECT *
FROM prenotazione AS p2
WHERE p2.nomevettura LIKE 'Andrea'
--
SELECT v.*
FROM vettura AS v RIGHT OUTER JOIN prenotazione AS pr
	 on v.nomevettura = pr.nomevettura
WHERE v.chilometraggio > 10000 AND v.chilometraggio <=25000
--
SELECT *
FROM parcheggio AS pr JOIN vettura AS v on pr.nomeparcheggio = v.sede
WHERE pr.numposti > 5 and pr.zona LIKE 'ponente'
--
SELECT V.*
FROM vettura AS V
WHERE V.chilometraggio >= ALL(SELECT v2.chilometraggio
							  FROM vettura AS v2)
--
SELECT pr.numeroprenotazione
FROM prenotazione AS pr NATURAL JOIN modificaprenotazione AS mp
WHERE mp.dataorarinuncia = NULL
group by pr.numeroprenotazione
--divisione
SELECT pr.*
FROM prenotazione AS pr
WHERE not exists(SELECT *
				 FROM vettura
				 WHERE not exists(SELECT *
								  FROM parcheggio AS pa
								   WHERE pa.numposti > 5 AND
								         pa.numposti < 10))
--Vettura con chilometraggio più alto
SELECT v.*
FROM vettura AS v
WHERE v.chilometraggio >= (SELECT MAX(v2.chilometraggio)
							 FROM vettura AS v2)
--modello con tariffa oraria <= alla media delle T orarie
SELECT mo.*
FROM  modello AS mo
WHERE mo.toraria <= (SELECT AVG(mo2.toraria)
					 FROM modello AS mo2)
--Prenotazioni con lo stesso numero di smartcard
SELECT count(*) AS numDiSmartcadUguali
FROM prenotazione AS pr1 NATURAL JOIN vettura AS v
WHERE pr1.numsmartcard = 1
