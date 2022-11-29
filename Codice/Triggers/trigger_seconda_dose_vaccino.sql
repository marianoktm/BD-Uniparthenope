CREATE OR REPLACE TRIGGER Check_Seconda_Dose_Date
    BEFORE INSERT OR UPDATE OF DATA_ORA_EFFETTIVA ON VACCINAZIONE
    FOR EACH ROW
    DECLARE
        Tempo_Prima_Seconda             LOTTO_VACCINO.TEMPO_PRIMA_SECONDA_DOSE%TYPE;
        Data_Effettiva                  DATE;
        NumCartaExists                  NUMBER;
        NumCarta                        CARD_VACCINATO.NUM_CARTA%TYPE;
        Data_non_valida_inserimento     EXCEPTION;
        Data_non_valida_aggiornamento   EXCEPTION;

    BEGIN
        -- Si controlla se esiste la card vaccinato (in caso di esistenza, il vaccinando ha fatto una dose di vaccino)
        SELECT count(*)
            INTO NumCartaExists
                FROM CARD_VACCINATO
                    WHERE :NEW.NUM_CARTA = NUM_CARTA;

        -- Se la carta esiste, la si estrae
        IF (NumCartaExists <> 0) THEN
            SELECT NUM_CARTA
                INTO NumCarta
                    FROM CARD_VACCINATO
                        WHERE :NEW.NUM_CARTA = NUM_CARTA;


            -- Si estrae il tempo che decorre tra la prima e la seconda dose
            SELECT TEMPO_PRIMA_SECONDA_DOSE, DATA_ORA_EFFETTIVA
                INTO Tempo_Prima_Seconda, Data_Effettiva
                    FROM LOTTO_VACCINO
                        JOIN VACCINAZIONE V on LOTTO_VACCINO.NUM_LOTTO = V.NUM_LOTTO and LOTTO_VACCINO.NOME_FARMACO = V.NOME_FARMACO
                            WHERE DISCRIMINATORE = 'T' AND NUM_CARTA = NumCarta;

            -- Se la data in inserimento su vaccinazione è minore del decorso prima/seconda dose, allora eccezione
            IF (:NEW.DATA_ORA_EFFETTIVA  < Tempo_Prima_Seconda + Data_Effettiva) THEN
                IF INSERTING THEN
                    RAISE Data_non_valida_inserimento;
                end if;
                IF UPDATING THEN
                    RAISE Data_non_valida_aggiornamento;
                end if;
            end if;
        end if;

        EXCEPTION
        WHEN no_data_found THEN
            DBMS_OUTPUT.PUT_LINE( 'Il vaccino non risulta essere a doppia dose.');
        WHEN Data_non_valida_inserimento THEN
            RAISE_APPLICATION_ERROR(-20005, 'Data od ora della vaccinazione invalida! (in inserimento)');
        WHEN Data_non_valida_aggiornamento THEN
            RAISE_APPLICATION_ERROR(-20006, 'Data od ora della vaccinazione invalida! (in aggiornamento)');
    end;









