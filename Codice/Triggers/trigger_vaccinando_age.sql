CREATE OR REPLACE TRIGGER Check_Age_over18
    BEFORE INSERT OR UPDATE OF DATA_NASCITA ON VACCINANDO
    FOR EACH ROW

    BEGIN
        -- Se il vaccinando ha meno di 18 anni al giorno di inserimento, errore.
        IF trunc(months_between(sysdate,:NEW.DATA_NASCITA) / 12) < 18 THEN
            RAISE_APPLICATION_ERROR(-20000, 'Vaccinando troppo giovane!');
        end if;
    end;
