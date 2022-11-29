CREATE OR REPLACE TRIGGER Check_Vaccinazione_Anamnesi_Date
    BEFORE INSERT OR UPDATE OF DATA_ORA_EFFETTIVA ON VACCINAZIONE
    FOR EACH ROW
    DECLARE
        data_controllo                  IDONEO.DATA_ORA_CONTROLLO%TYPE;
        vaccinando_idoneo               NUMBER;
        vaccinando_non_e_idoneo         EXCEPTION;
        data_non_valida                 EXCEPTION;

    BEGIN

    -- Si controlla se esiste l'anamnesi con risultato idoneo prima dell'inserimento in vaccinazione
    SELECT count(*)
        INTO vaccinando_idoneo
            FROM IDONEO
                 WHERE IDONEO.NUM_PROTOCOLLO = :NEW.NUM_PROTOCOLLO AND IDONEO.NUM_TENTATIVI = :NEW.NUM_TENTATIVI;

    -- Se non esiste, eccezione
    IF (vaccinando_idoneo = 0) THEN
        raise vaccinando_non_e_idoneo;
    end if;


    -- Si estrae la data dell'anamnesi
        SELECT DATA_ORA_CONTROLLO
            INTO data_controllo
                FROM IDONEO
                    WHERE IDONEO.NUM_PROTOCOLLO = :NEW.NUM_PROTOCOLLO AND IDONEO.NUM_TENTATIVI = :NEW.NUM_TENTATIVI;

    -- Si controlla che la vaccinazione avvenga dopo l'anamnesi
    IF (data_controllo > :NEW.DATA_ORA_EFFETTIVA) THEN
        RAISE data_non_valida;
    end if;


EXCEPTION
        WHEN vaccinando_non_e_idoneo THEN
            RAISE_APPLICATION_ERROR(-20050, 'Il vaccinando non risulta idoneo.');

        WHEN data_non_valida THEN
            RAISE_APPLICATION_ERROR(-20051, 'La data che hai inserito non è valida.');
    end;