CREATE OR REPLACE PROCEDURE consegnaVaccino(
nome_luogo_p                LUOGO.NOME%TYPE,
distretto_p                 LUOGO.DISTRETTO%TYPE,
farmaco_p                   LOTTO_VACCINO.NOME_FARMACO%TYPE,
lotto_p                     LOTTO_VACCINO.NUM_LOTTO%TYPE,
data_consegna_p             DATE,
num_dosi_da_consegnare_p    NUMBER
)
IS
    negative_doses                  EXCEPTION;
    vaccino_exists                  NUMBER;
    vaccino_non_esiste              EXCEPTION;
    luogo_exists                    NUMBER;
    luogo_non_esiste                EXCEPTION;
    dosi_exists                     NUMBER;
    dosi_gia_consegnate             NUMBER;
    dosi_consegnabili               NUMBER;
    dosi_consegnabili_real          NUMBER;
    lotto_consegnato                EXCEPTION;
    dosi_eccessive                  EXCEPTION;
    data_consegna_real              DATE;
    consegna_exists                 NUMBER;
    num_dosi_esistenti_specifiche   NUMBER;

BEGIN
    -- Se si provano a consegnare 0 o meno dosi, errore.
    IF (num_dosi_da_consegnare_p < 1) THEN
        RAISE negative_doses;
    end if;

    -- Si controlla se il lotto di vaccino esiste nel database
    SELECT count(*)
        INTO vaccino_exists
            FROM LOTTO_VACCINO
                WHERE NOME_FARMACO = farmaco_p AND NUM_LOTTO = lotto_p;

    if (vaccino_exists = 0) THEN
        RAISE vaccino_non_esiste;
    end if;


    -- Si controlla se il luogo esiste nel database
    SELECT count(*)
        INTO luogo_exists
            FROM LUOGO
                WHERE NOME = nome_luogo_p AND DISTRETTO = distretto_p;

    IF (luogo_exists = 0) THEN
        raise luogo_non_esiste;
    end if;


    -- Si controlla il numero di dosi del lotto
    SELECT NUM_DOSI_LOTTO
            INTO dosi_consegnabili
                FROM LOTTO_VACCINO
                    WHERE NOME_FARMACO = farmaco_p AND NUM_LOTTO = lotto_p;

    -- Si controlla quale data di consegna usare
    IF (data_consegna_p IS NULL) THEN
        data_consegna_real := sysdate;
    ELSE
        data_consegna_real := data_consegna_p;
    end if;


    -- Si controlla se sono già state consegnate delle dosi di vaccino e si agisce di conseguenza.
    SELECT count(*)
        INTO dosi_exists
            FROM CONSEGNATO_A
                WHERE NUM_LOTTO = lotto_p AND NOME_FARMACO = farmaco_p;

    -- Se sono state già consegnate delle dosi in database:
    IF (dosi_exists <> 0) THEN
        SELECT sum(ALL NUM_DOSI_CONSEGNATE)
            INTO dosi_gia_consegnate
                FROM CONSEGNATO_A
                    WHERE NOME_FARMACO = farmaco_p AND NUM_LOTTO = lotto_p;

        -- Se il lotto è stato già consegnato completamente
        IF (dosi_consegnabili = dosi_gia_consegnate) THEN
            RAISE lotto_consegnato;
        end if;

        -- Si definisce il numero di dosi effettivamente consegnabili
        dosi_consegnabili_real := dosi_consegnabili - dosi_gia_consegnate;

        -- Se si provano a consegnare troppe dosi
        IF (dosi_consegnabili_real < num_dosi_da_consegnare_p) THEN
             RAISE dosi_eccessive;
        end if;

    -- Se non sono state già consegnate delle dosi
    ELSE
        -- Se si provano a consegnare troppe dosi
        IF (dosi_consegnabili < num_dosi_da_consegnare_p) THEN
            RAISE dosi_eccessive;
        end if;
    end if;

    -- Controlla se esiste già una consegna di quel lotto specifico
    SELECT count(*)
        INTO consegna_exists
            FROM CONSEGNATO_A
                WHERE nome_luogo_p = NOME_LUOGO AND distretto_p = DISTRETTO_LUOGO AND farmaco_p = NOME_FARMACO AND lotto_p = NUM_LOTTO AND data_consegna_p = DATA_CONSEGNA;

    -- Se esiste la consegna va incrementato il numero di dosi della consegna già esistente
    IF (consegna_exists = 1) THEN
        SELECT NUM_DOSI_CONSEGNATE
            INTO num_dosi_esistenti_specifiche
                FROM CONSEGNATO_A
                    WHERE nome_luogo_p = NOME_LUOGO AND distretto_p = DISTRETTO_LUOGO AND farmaco_p = NOME_FARMACO AND lotto_p = NUM_LOTTO AND data_consegna_p = DATA_CONSEGNA;

        UPDATE CONSEGNATO_A
            SET NUM_DOSI_CONSEGNATE = num_dosi_esistenti_specifiche + num_dosi_da_consegnare_p
                WHERE nome_luogo_p = NOME_LUOGO AND distretto_p = DISTRETTO_LUOGO AND farmaco_p = NOME_FARMACO AND lotto_p = NUM_LOTTO AND data_consegna_p = DATA_CONSEGNA;

    ELSE
    -- Consegna effettiva nel caso le dosi esistono ma non esiste la stessa consegna
    INSERT INTO CONSEGNATO_A VALUES (
                                         nome_luogo_p,
                                         distretto_p,
                                         farmaco_p,
                                         lotto_p,
                                         data_consegna_real,
                                         num_dosi_da_consegnare_p
                                        );
    end if;

    COMMIT;

    -- Gestione delle eccezzioni
    EXCEPTION
    WHEN negative_doses THEN
        RAISE_APPLICATION_ERROR(-20014, 'Devi consegnare almeno una dose!.');
        rollback;

    WHEN vaccino_non_esiste THEN
        RAISE_APPLICATION_ERROR(-20010, 'Il vaccino che hai selezionato non esiste nel database.');
        rollback;

    WHEN luogo_non_esiste THEN
        RAISE_APPLICATION_ERROR(-20011, 'Il luogo che hai selezionato non esiste nel database.');
        rollback;

    WHEN lotto_consegnato THEN
        RAISE_APPLICATION_ERROR(-20012, 'Il lotto è stato già consegnato completamente.');
        rollback;

    WHEN dosi_eccessive THEN
        RAISE_APPLICATION_ERROR(-20013, 'Il numero di dosi che stai provando a consegnare è troppo alto.');
        rollback;
end;
