CREATE OR REPLACE TRIGGER Check_NonIdoneoPerm_Cant_Be_Vaccinated
    BEFORE INSERT OR UPDATE ON VACCINAZIONE
    FOR EACH ROW
    DECLARE
        Numero_Protocollo           NUMBER(8, 0);
        Vaccinazione_Non_Valida     EXCEPTION;

    BEGIN
        -- Si estrae (se esiste) un non idoneo permanente
        SELECT NUM_PROTOCOLLO
            INTO Numero_Protocollo
                FROM NON_IDONEO_PERMANENTE
                    where :NEW.NUM_PROTOCOLLO = NUM_PROTOCOLLO;

        -- Se il numero protocollo in inserimento su vaccinazione è uguale al numero protocollo del non idoneo permanente, allora eccezione
        IF (:NEW.NUM_PROTOCOLLO = Numero_Protocollo) THEN
            RAISE Vaccinazione_Non_Valida;
        end if;


        EXCEPTION
        WHEN no_data_found THEN
            DBMS_OUTPUT.PUT_LINE('no_data_found. Il vaccinando non fa parte di Non Idoneo Permanente.');

        WHEN Vaccinazione_Non_Valida THEN
            RAISE_APPLICATION_ERROR(-20007, 'Un non idoneo permanente non deve essere vaccinato!');
    end;