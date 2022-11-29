CREATE OR REPLACE TRIGGER Check_Prenotazione_Anamnesi_Date
    BEFORE INSERT OR UPDATE OF DATA_ORA_CONTROLLO ON ANAMNESI
    FOR EACH ROW
    DECLARE
        Data_Prenotazione               DATE;
        Data_Controllo                  DATE;
        Data_non_valida_inserimento     EXCEPTION;
        Data_non_valida_aggiornamento   EXCEPTION;

    BEGIN
        -- Si estrae (se esiste) la prenotazione
        SELECT DATA_ORA_PREVISTE
            INTO Data_Prenotazione
                FROM PRENOTAZIONE
                    WHERE NUM_PROTOCOLLO = :NEW.NUM_PROTOCOLLO AND NUM_TENTATIVI = :NEW.NUM_TENTATIVI;

        -- Si controlla che la data dell'anamnesi sia dopo la data della prenotazione
        IF (:NEW.DATA_ORA_CONTROLLO < Data_Prenotazione ) THEN
            IF INSERTING THEN
                RAISE Data_non_valida_inserimento;
            end if;
            IF UPDATING THEN
                RAISE Data_non_valida_aggiornamento;
            end if;
        END IF;

        EXCEPTION
        WHEN no_data_found THEN
            RAISE_APPLICATION_ERROR(-20021 ,'La prenotazione non esiste!');

        WHEN Data_non_valida_inserimento THEN
            RAISE_APPLICATION_ERROR(-20001, 'Data od ora del controllo invalida! (in inserimento)');

        WHEN Data_non_valida_aggiornamento THEN
            RAISE_APPLICATION_ERROR(-20002, 'Data od ora del controllo invalida! (in aggiornamento)');
    end;