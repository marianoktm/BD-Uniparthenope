/**
  - Numero di lott
  - Nome farmaco
  - data scadenza
  - numero di dosi del lotto
  - discriminatore
  - tempo prima/seconda dose

  - nome stabilimento produttore
  - nazione
  - citta
  - via
  - civico

  - nome azienda/e produttrice/i
  **/



CREATE OR REPLACE TYPE caseprodarr IS VARRAY(5) OF VARCHAR(30);

CREATE OR REPLACE PROCEDURE insertVaccino(
-- Parametri per l'inserimento su Lotto_Vaccino
nome_farmaco_p LOTTO_VACCINO.NOME_FARMACO%TYPE,
num_lotto_p LOTTO_VACCINO.NUM_LOTTO%TYPE,
scadenza_p LOTTO_VACCINO.SCADENZA%TYPE,
num_dosi_p LOTTO_VACCINO.NUM_DOSI_LOTTO%TYPE,

discriminatore_p LOTTO_VACCINO.DISCRIMINATORE%TYPE,
tempo_prima_sec_p LOTTO_VACCINO.TEMPO_PRIMA_SECONDA_DOSE%TYPE default 0,

-- Parametri per l'inserimento dello stabilimento produttore
nome_stab_p STABILIMENTO.NOME%TYPE,
nazione_stab_p STABILIMENTO.NAZIONE%TYPE,
citta_stab_p STABILIMENTO.CITTA%TYPE,
via_stab_p STABILIMENTO.VIA%TYPE,
civico_stab_p STABILIMENTO.CIVICO%TYPE,

-- Parametri per l'inserimento della casa produttrice
nome_casa_prod_p caseprodarr
)
IS
    nome_casa_prod_i CASA_PRODUTTRICE.NOME%TYPE;
    stab_exists number;
BEGIN

    -- Si controlla se lo stabilimento passato in input alla procedura esiste già a database. Se non esiste, lo si inserisce.
    SELECT COUNT(*)
        INTO stab_exists
            FROM STABILIMENTO
                WHERE NOME = nome_stab_p;

    IF (stab_exists = 0) THEN
            INSERT INTO STABILIMENTO VALUES (
                                         nome_stab_p,
                                         nazione_stab_p,
                                         citta_stab_p,
                                         via_stab_p,
                                         civico_stab_p
                                        );
    end if;

    -- Si inserisce il lotto di vaccino nella tabella dedicata.
    INSERT INTO LOTTO_VACCINO VALUES (num_lotto_p,
                                      nome_farmaco_p,
                                      scadenza_p,
                                      num_dosi_p,
                                      nome_stab_p,
                                      discriminatore_p,
                                      tempo_prima_sec_p);

    -- Se vengono passate delle case produttrici in input, si controlla se esistono effettuando la select sottostante. Se non esistono, errore.
    IF (nome_casa_prod_p IS NOT NULL) THEN
            for i in 1 .. nome_casa_prod_p.count loop
                SELECT NOME
                    INTO nome_casa_prod_i
                        FROM CASA_PRODUTTRICE
                            WHERE NOME = nome_casa_prod_p(i);

                -- Se la select non alza no_data_found, allora si associa il vacicno con le case produttrici.
                INSERT INTO PRODUTTORE_DI VALUES (
                                                  nome_casa_prod_p(i),
                                                  nome_farmaco_p,
                                                  num_lotto_p
                                                 );
            end loop;
    end if;
 COMMIT;

    EXCEPTION
    WHEN no_data_found THEN
        RAISE_APPLICATION_ERROR(-20009, 'Una o più case produttrici scelte non sono presenti nel database.');
        rollback;

end;
