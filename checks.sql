SET search_path TO carsharing;
/*commentato per test*/
--ALTER TABLE prenotazione ADD CHECK(NOW()::timestamp <= prenotazione.dataorainizio - interval '15 min'); /* trigger */
ALTER TABLE prenotazione ADD CHECK(dataOraFine >= prenotazione.dataorainizio + interval '1 day'); /* prenotazione minima un giorno*/
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
ALTER TABLE Utilizzo ADD CHECK(dataOraRitiro < dataOraRiconsegna AND dataOraRitiro < dataOraRiconsegna AND chilometraggioRitiro < chilometraggioRiconsegna);
ALTER TABLE Sinistro ADD CHECK (dataOra > now() - interval '10 day');
ALTER TABLE Testimoni ADD CHECK (dataDiNascita < now() - interval '18 year' );
ALTER TABLE Rappresentante ADD CHECK (dataDiNascita < now() - interval '18 year');
ALTER TABLE Azienda ADD CHECK (piva != 0);
ALTER TABLE Sede ADD CHECK (tiposede = 'Legale' or tiposede = 'Operativa');
ALTER TABLE Documento ADD CHECK(dataDiNascita < now() - interval '18 year');
ALTER TABLE Persona ADD CHECK (eta >= 18);
ALTER TABLE Utente ADD CHECK (email ~ '^[a-zA-Z0-9.!#$%&''*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$')
