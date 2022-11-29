CREATE OR REPLACE TRIGGER vaccinoScaduto
    BEFORE INSERT OR UPDATE OF DATA_ORA_EFFETTIVA ON VACCINAZIONE
    FOR EACH ROW
    DECLARE

    check_data          LOTTO_VACCINO.SCADENZA%TYPE;

    BEGIN
        -- Si estrae la scadenza del lotto di vaccino che si sta utilizzando
        SELECT SCADENZA
            INTO CHECK_DATA
                FROM LOTTO_VACCINO LV
                    WHERE :NEW.NOME_FARMACO = LV.NOME_FARMACO AND :NEW.NUM_LOTTO = LV.NUM_LOTTO;

        -- Se il vaccino è scaduto, errore
        IF (:NEW.DATA_ORA_EFFETTIVA > check_data) then
            RAISE_APPLICATION_ERROR(-20080, 'Non puoi usare un vaccino scaduto!!!');
        end if;

    end;
