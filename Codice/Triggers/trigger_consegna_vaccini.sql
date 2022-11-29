CREATE OR REPLACE TRIGGER Check_Consegna_Vaccini
    BEFORE INSERT OR UPDATE OF NOME_FARMACO, NUM_LOTTO ON VACCINAZIONE
    FOR EACH ROW
    DECLARE
        farmaco_exists          NUMBER;
        farmaco_nonesiste       EXCEPTION;
    BEGIN
        -- Si controlla se il farmaco è stato consegnato in un dato luogo
        SELECT count(*)
            INTO farmaco_exists
                FROM CONSEGNATO_A CONS
                    WHERE :NEW.NOME_LUOGO = CONS.NOME_LUOGO AND :NEW.DISTRETTO_LUOGO = CONS.DISTRETTO_LUOGO AND :NEW.NOME_FARMACO = CONS.NOME_FARMACO AND :NEW.NUM_LOTTO = CONS.NUM_LOTTO;

        -- Se non esiste, errore
        IF (farmaco_exists = 0) THEN
            raise farmaco_nonesiste;
        end if;


        EXCEPTION
        WHEN farmaco_nonesiste THEN
        RAISE_APPLICATION_ERROR(-20008, 'Il lotto di vaccino che si sta cercando di usare non esiste nel luogo desiderato.');
    end;
