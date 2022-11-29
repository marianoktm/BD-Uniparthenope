CREATE OR REPLACE PROCEDURE createAnamnesi(
cod_fisc_p                      VACCINANDO.CODICE_FISCALE%TYPE,
num_isc_medici_p                ANAMNESI.NUM_ISCRIZIONE_ORDINE_MEDICI%TYPE,
data_controllo_p                ANAMNESI.DATA_ORA_CONTROLLO%TYPE,
esito_p                         NUMBER,
idoneita_prevista_p             DATE
)
IS
    vaccinando_exists           NUMBER;
    operatore_exists            NUMBER;
    prenotazione_exists         NUMBER;
    vaccinando_non_esiste       EXCEPTION;
    operatore_non_esiste        EXCEPTION;
    prenotazione_non_esiste     EXCEPTION;
    num_protocollo_v            PRENOTAZIONE.NUM_PROTOCOLLO%TYPE;
    num_tentativi_v             PRENOTAZIONE.NUM_TENTATIVI%TYPE;
    tipo_prenotazione_v         PRENOTAZIONE.TIPO_PRENOTAZIONE%TYPE;
    data_idoneita_assente       EXCEPTION;
    esito_sconosciuto           EXCEPTION;
    data_controllo_valida       DATE;
    anamnesi_check              NUMBER;
    anamnesi_gia_esiste         EXCEPTION;

BEGIN

    -- Si controlla se esiste il vaccinando
    SELECT count(*)
        INTO vaccinando_exists
            FROM VACCINANDO
                WHERE CODICE_FISCALE = cod_fisc_p;

    IF (vaccinando_exists = 0) THEN
        raise vaccinando_non_esiste;
    end if;

    -- Si controlla se esiste l'operatore sanitario responsabile
    SELECT count(*)
        INTO operatore_exists
            FROM OPERATORE_SANITARIO_RESPONSABILE
                WHERE NUM_ISCRIZIONE_ORDINE_MEDICI = num_isc_medici_p;

    IF (operatore_exists = 0) THEN
        raise operatore_non_esiste;
    end if;


    -- Si ricavano il numero di prenotazione ed il numero di rimodulazioni massimo
    SELECT PRENOTAZIONE.NUM_PROTOCOLLO, MAX(PRENOTAZIONE.NUM_TENTATIVI), TIPO_PRENOTAZIONE
        INTO num_protocollo_v, num_tentativi_v, tipo_prenotazione_v
            FROM PRENOTAZIONE JOIN VACCINANDO
                ON PRENOTAZIONE.NUM_PROTOCOLLO = VACCINANDO.NUM_PROTOCOLLO
                    WHERE CODICE_FISCALE = cod_fisc_p
                        group by PRENOTAZIONE.NUM_PROTOCOLLO, PRENOTAZIONE.TIPO_PRENOTAZIONE;

    -- Si controlla se è stata fornita una data di anamnesi
    IF (data_controllo_p IS NULL) THEN
        data_controllo_valida := sysdate;
    ELSE
        data_controllo_valida := data_controllo_p;
    end if;

    -- Si controlla se è stata effettuata l'anamnesi per l'ultima prenotazione
    SELECT count(*)
    into anamnesi_check
        FROM ANAMNESI
            WHERE NUM_PROTOCOLLO = num_protocollo_v and NUM_TENTATIVI = num_tentativi_v;

    if (anamnesi_check <> 0) then
        raise anamnesi_gia_esiste;
    end if;

    -- Si inserisce nell'anamnesi
    INSERT INTO ANAMNESI VALUES (
                                 num_protocollo_v,
                                 num_tentativi_v,
                                 data_controllo_valida,
                                 num_isc_medici_p
                                );

    -- Si controlla l'esito
    -- Idoneo
    IF (esito_p = 0) THEN
        INSERT INTO IDONEO VALUES (
                                    num_protocollo_v,
                                    num_tentativi_v,
                                    data_controllo_valida
                                  );
    -- Non Idoneo Permamente
    ELSIF (esito_p = 2) THEN
        INSERT INTO NON_IDONEO_PERMANENTE VALUES (
                                                    num_protocollo_v,
                                                    num_tentativi_v,
                                                    data_controllo_valida
                                                 );
    -- Non Idoneo Temporaneo
    ELSIF (esito_p = 1) THEN
        IF (idoneita_prevista_p IS NULL) THEN
            raise data_idoneita_assente;
        end if;

        INSERT INTO NON_IDONEO_TEMPORANEO VALUES (
                                                    num_protocollo_v,
                                                    num_tentativi_v,
                                                    data_controllo_valida,
                                                    idoneita_prevista_p
                                                 );
        -- Si genera la nuova prenotazione
        INSERT INTO PRENOTAZIONE VALUES (
                                         num_protocollo_v,
                                         num_tentativi_v+1,
                                         idoneita_prevista_p,
                                         tipo_prenotazione_v
                                        );

    -- Se viene passato un valore errato
    ELSE
        raise esito_sconosciuto;
    end if;




    EXCEPTION
    WHEN vaccinando_non_esiste THEN
        RAISE_APPLICATION_ERROR(-20022, 'Il vaccinando non esiste!');
        rollback;

    WHEN operatore_non_esiste THEN
        RAISE_APPLICATION_ERROR(-20023, 'Operatore Sanitario non esiste!');
        rollback;

    WHEN data_idoneita_assente THEN
        RAISE_APPLICATION_ERROR(-20024, 'Devi fornire una data di idoneità!');
        rollback;

    WHEN esito_sconosciuto THEN
        RAISE_APPLICATION_ERROR(-20025, 'Esito sconosciuto! Inserisci un valore di esito valido: 0 Idoneo, 1 Non idoneo temporaneo, 2 Non idoneo permanente.');
        rollback;

    WHEN anamnesi_gia_esiste THEN
        RAISE_APPLICATION_ERROR(-20062, 'Questa anamnesi è già stata effettuata.');
        rollback;
end;


