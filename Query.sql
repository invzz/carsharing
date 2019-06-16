SELECT PA.*
FROM  parcheggio AS PA , vettura AS V ,prenotazione AS PR, modello AS Mo, Categoria AS Cat

WHERE Cat.categoria ='City Car' AND
       PA.nomeparcheggio = V.sede AND
	   V.nomevettura = PR.nomevettura AND
	   V.modello = Mo.NomeModello  AND
	   Mo.categoria = Cat.categoria AND
      EXTRACT (HOUR from current_date) + 3 = EXTRACT(HOUR from PR.dataOraInizio::Date)
////////////////////////////////////////////////////////////////////////////////////////////

SELECT U.*, V.nomevettura, V.targa, utilizzo.dataOraRiconsegna
FROM Utente AS U NATURAL JOIN metododipagamento AS MDP
	 NATURAL JOIN abbonamento AS Ab
	 NATURAL JOIN prenotazione AS PR
	 NATURAL JOIN vettura AS V, utilizzo, prenotazione
WHERE prenotazione.numsmartcard = Ab.numsmartcard AND
	  prenotazione.numeroprenotazione = utilizzo.numeroprenotazione AND
      utilizzo.dataOraRitiro::date < utilizzo.dataOraRiconsegna::date
///////////////////////////////////////////////////////////////////////////////////////////
SELECT pa.nomeparcheggio, cat.categoria
FROM parcheggio as pa, vettura as v, prenotazione as pr,
     modello as mo, categoria as cat
WHERE pa.nomeparcheggio = v.sede AND
	  v.nomevettura = pr.nomevettura AND
	  v.modello = mo.nomemodello AND
	  mo.categoria = cat.categoria AND
	  EXTRACT(hour from current_date)+1 = EXTRACT(hour from pr.dataOraInizio)
GROUP BY pa.nomeparcheggio,cat.categoria
HAVING count(*) >= 1
///////////////////////////////////////////////////////////////////////////////////////////
Select *
from prenotazione as p1
except
Select *
from prenotazione as p2
where p2.nomevettura like 'Andrea'
/////////////////////////////////////////////////////////////////////////////////////////
select v.*
from vettura as v right outer join prenotazione as pr
	 on v.nomevettura = pr.nomevettura
where v.chilometraggio > 10000 AND v.chilometraggio <=25000
////////////////////////////////////////////////////////////////////////////////////////
select *
from parcheggio as pr JOIN vettura as v on pr.nomeparcheggio = v.sede
where pr.numposti > 5 and pr.zona like 'ponente'
////////////////////////////////////////////////////////////////////////////////////////
Select V.*
from vettura AS V
WHERE V.chilometraggio >= ALL(select v2.chilometraggio
							  from vettura as v2)
////////////////////////////////////////////////////////////////////////////////////
SELECT pr.numeroprenotazione
from prenotazione as pr Natural join modificaprenotazione as mp
where mp.dataorarinuncia = NULL
group by pr.numeroprenotazione
/////////////////////////////////////////////////////////////////////////////////////

/*DIVISIONE UTILIZZANDO LE NOT EXISTS*/
SELECT pr.*
from prenotazione as pr
where not exists(select *
				 from vettura
				 where not exists(select *
								  from parcheggio as pa
								   where pa.numposti > 5 AND
								         pa.numposti < 10))
//////////////////////////////////////////////////////////////////////////////////
/*Vettura con chilometraggio più alto*/
select v.*
from vettura as v
where v.chilometraggio >= (select MAX(v2.chilometraggio)
							 from vettura as v2)
/////////////////////////////////////////////////////////////////////////////////
/*modello con tariffa oraria <= alla media delle T orarie*/
Select mo.*
from  modello as mo
where mo.toraria <= (select AVG(mo2.toraria)
					 from modello as mo2)
////////////////////////////////////////////////////////////////////////////////
/*Prenotazioni con lo stesso numero di smartcard*/
select count(*) as numDiSmartcadUguali
from prenotazione as pr1 NATURAL JOIN vettura as v
where pr1.numsmartcard = 1
