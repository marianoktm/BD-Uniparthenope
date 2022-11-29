CREATE OR REPLACE TRIGGER Check_NonIdoneoTemp_Cant_Be_Vaccinated
    BEFORE INSERT OR UPDATE ON VACCINAZIONE
    FOR EACH ROW
    DECLARE
        exists_in_nit               NUMBER;
        Numero_Protocollo           NUMBER(8, 0);
        Numero_Tentativi            NUMBER(2, 0);
        Vaccinazione_Non_Valida     EXCEPTION;

    BEGIN
        -- Si controlla se esiste il vaccinando in inserimento nella tabella NON_IDONEO_TEMPORANEO.
        SELECT count(*)
            INTO exists_in_nit
                FROM NON_IDONEO_TEMPORANEO
                    WHERE :NEW.NUM_PROTOCOLLO = NUM_PROTOCOLLO AND :NEW.NUM_TENTATIVI = NUM_TENTATIVI;

        -- Se non esiste, errore.
        IF (exists_in_nit <> 0) THEN
            RAISE Vaccinazione_Non_Valida;
        end if;


        EXCEPTION
        WHEN Vaccinazione_Non_Valida THEN
            RAISE_APPLICATION_ERROR(-20007, 'Un non idoneo temporaneo non deve essere vaccinato!');
    end;
