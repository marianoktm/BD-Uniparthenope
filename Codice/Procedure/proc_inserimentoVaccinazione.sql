CREATE OR REPLACE PROCEDURE createVaccinazione(
cod_fisc_p                      VACCINANDO.CODICE_FISCALE%TYPE,

data_vaccinazione_p             VACCINAZIONE.DATA_ORA_EFFETTIVA%TYPE,
braccio_p                       VACCINAZIONE.BRACCIO_INOCULAZIONE%TYPE,

luogo_p                         VACCINAZIONE.NOME_LUOGO%TYPE,
distretto_p                     VACCINAZIONE.DISTRETTO_LUOGO%TYPE,

lotto_p                         VACCINAZIONE.NUM_LOTTO%TYPE,
farmaco_p                       VACCINAZIONE.NOME_FARMACO%TYPE
)
IS
    vaccinando_exists           NUMBER;
    num_prot_vaccinando         VACCINANDO.NUM_PROTOCOLLO%TYPE;
    vaccinando_non_esiste       EXCEPTION;
    luogo_exists                NUMBER;
    luogo_non_esiste            EXCEPTION;
    data_usata                  DATE;
    max_carta                   CARD_VACCINATO.NUM_CARTA%TYPE;
    card_exists                 NUMBER;
    num_idoneita                NUMBER;
    data_ora_controllo_v        IDONEO.DATA_ORA_CONTROLLO%TYPE;
    num_tentativi_v             PRENOTAZIONE.NUM_TENTATIVI%TYPE;
    non_idoneo                  EXCEPTION;
    tipo_p_v                    PRENOTAZIONE.TIPO_PRENOTAZIONE%TYPE;
    check_doppia_dose           NUMBER;
    tempo_prima_seconda         LOTTO_VACCINO.TEMPO_PRIMA_SECONDA_DOSE%TYPE;
    vaccino_one_shot            LOTTO_VACCINO.DISCRIMINATORE%TYPE;
    vaccinazione_check          NUMBER;
    vaccinazione_gia_esiste     EXCEPTION;



BEGIN

    -- Si controlla se esiste il vaccinando
    SELECT count(*)
        into vaccinando_exists
            FROM VACCINANDO
                WHERE CODICE_FISCALE = cod_fisc_p;


    -- Se non esiste, errore
    IF (vaccinando_exists = 0) THEN
        raise vaccinando_non_esiste;
    end if;


    -- Si controlla se esiste il luogo
    SELECT count(*)
        into luogo_exists
            from LUOGO
                where DISTRETTO = distretto_p and NOME = luogo_p;


    -- Se non esiste, errore
    IF (luogo_exists = 0) THEN
        raise luogo_non_esiste;
    end if;


    -- Se non viene passato un parametro per la data, si usa la data attuale.
    IF (data_vaccinazione_p IS NULL) THEN
        data_usata := sysdate;
        ELSE
        data_usata := data_vaccinazione_p;
    end if;


    -- Si ottiene il numero protocollo del vaccinando
    SELECT NUM_PROTOCOLLO
        INTO num_prot_vaccinando
            FROM VACCINANDO
                WHERE cod_fisc_p = CODICE_FISCALE;

    -- Si controlla se il vaccinando è risultato idoneo
    SELECT count(*)
        INTO num_idoneita
            FROM IDONEO
                WHERE num_prot_vaccinando = NUM_PROTOCOLLO;

    -- Se il vaccinando è idoneo, si seleziona l'ultima idoneità.
    IF (num_idoneita <> 0) THEN
        SELECT MAX(NUM_TENTATIVI), MAX(DATA_ORA_CONTROLLO)
            INTO num_tentativi_v, data_ora_controllo_v
                FROM IDONEO
                    WHERE NUM_PROTOCOLLO = num_prot_vaccinando;
        ELSE
        raise non_idoneo;
    end if;


    -- Si controlla se è stata già inserita la vaccinazione che si sta provando ad inserire
    SELECT count(*)
    into vaccinazione_check
        FROM VACCINAZIONE
            WHERE NUM_PROTOCOLLO = num_prot_vaccinando and NUM_TENTATIVI = num_tentativi_v;

    if (vaccinazione_check <> 0) then
        raise vaccinazione_gia_esiste;
    end if;



    -- Se c'è una sola idoneita, si deve generare il numero di carta
    IF (num_idoneita > 0 and num_idoneita < 2) then
        -- Si controlla se esistono tuple in card_vaccinato per generare il numero carta
        SELECT count(*)
            into card_exists
                FROM CARD_VACCINATO;


        IF (card_exists = 0) then
            max_carta := 0;
        ELSE
            SELECT MAX(NUM_CARTA)
                INTO max_carta
                    FROM CARD_VACCINATO;

        end if;

        -- Creazione della card vaccinato
        INSERT INTO CARD_VACCINATO VALUES (
                                           max_carta+1,
                                           data_usata + 15,
                                           data_usata + 15 + 365
                                          );
    end if;



   SELECT MAX(NUM_CARTA)
                INTO max_carta
                    FROM CARD_VACCINATO;



    -- Inserimento in vaccinazione
    INSERT INTO VACCINAZIONE VALUES (
                                     data_usata,
                                     braccio_p,
                                     max_carta,
                                     luogo_p,
                                     distretto_p,
                                     lotto_p,
                                     farmaco_p,
                                     num_prot_vaccinando,
                                     num_tentativi_v,
                                     data_ora_controllo_v
                                     );

    -- Si controlla se la vaccinazione è a singola o doppia dose, e si crea la prenotazione nuova nel secondo caso
    select TIPO_PRENOTAZIONE
        into tipo_p_v
           from PRENOTAZIONE
                where NUM_PROTOCOLLO = num_prot_vaccinando AND NUM_TENTATIVI = num_tentativi_v;

    select DISCRIMINATORE
        into vaccino_one_shot
            FROM LOTTO_VACCINO
                WHERE NUM_LOTTO = lotto_p AND NOME_FARMACO = farmaco_p;

    if (tipo_p_v = 'DOPPIA' AND vaccino_one_shot = 'T') then
        -- Si controlla che effettivamente si inserisca solo una seconda dose, e non una terza, quarta...
        -- si conta quante vaccinazioni sono state effettuate su quel vaccinando
        SELECT count(*)
            into check_doppia_dose
                from VACCINAZIONE
                    where NUM_PROTOCOLLO = num_prot_vaccinando;

        -- Se esiste effettivamente solo una vaccinazione
        if (check_doppia_dose = 1) then
            -- Si controlla quale vaccino è stato usato e si controlla dopo quanto deve essere effettuata la seconda dose
            SELECT TEMPO_PRIMA_SECONDA_DOSE
            into tempo_prima_seconda
                FROM LOTTO_VACCINO
                    WHERE NOME_FARMACO = farmaco_p and NUM_LOTTO = lotto_p;

            -- Si crea la nuova prenotazione
            INSERT INTO PRENOTAZIONE VALUES (
                                         num_prot_vaccinando,
                                         num_tentativi_v+1,
                                         data_usata + tempo_prima_seconda,
                                         tipo_p_v
                                        );
        end if;
    end if;



    COMMIT;
    EXCEPTION
    WHEN vaccinando_non_esiste then
        raise_application_error(-20030, 'Il vaccinando non esiste!');
        rollback;

    when luogo_non_esiste then
        raise_application_error(-20031, 'Il luogo scelto non esiste!');
        rollback;

    when non_idoneo then
        raise_application_error(-20032, 'Il vaccinando non appare nella tabella idoneo!');
        rollback;

    when vaccinazione_gia_esiste then
        raise_application_error(-20077, 'La vaccinazione in inserimento esiste già.');
        rollback;
end;
