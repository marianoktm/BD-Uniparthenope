create or replace type disArr is varray(10) of varchar2(40);
create or replace type patArr is varray(10) of varchar2(40);
create or replace type NumTelArr is varray(5) of varchar2(20);

create or replace procedure create_Vaccinando(
num_Tessera_p     vaccinando.num_tessera_sanitaria%type,
scad_Tessera_p    vaccinando.scadenza_tessera_sanitaria%type,
cod_fiscale_p     vaccinando.codice_fiscale%type,
nome_p            vaccinando.nome%type,
cognome_p         vaccinando.cognome%type,
data_nascita_p    vaccinando.data_nascita%type,
citta_natale_p    vaccinando.citta_natale%type,
citta_p           vaccinando.citta%type,
provincia_p       vaccinando.provincia%type,
cap_p             vaccinando.cap%type,
via_p             vaccinando.via%type,
civico_p          vaccinando.civico%type,
email_p           vaccinando.e_mail%type,
pos_preg_p        vaccinando.positivita_pregressa%type,

disc_Dis_p        number,
num_Attes_104_p   disabile.num_attestato_104%type,
disabilita_p      disArr,

disc_Pat_p        number,
patologia_p       patArr,

numero_telefono_p   NumTelArr
)

is
prenotazioni_esistenti      number;
vaccinando_exists           number;
vaccinando_gia_esiste       exception;

max_protocollo              PRENOTAZIONE.NUM_PROTOCOLLO%TYPE;
max_data                    DATE;
pos_preg_errata             EXCEPTION;

begin
    -- Si controlla se il vaccinando esiste
    select count(*)
        into vaccinando_exists
            from vaccinando
                where num_tessera_sanitaria = num_Tessera_p;

    if (vaccinando_exists <> 0) then
        raise vaccinando_gia_esiste;
    end if;

        -- Si estrae il numero delle prenotazioni esistenti. Servirà per creare il nuovo numero di prenotazione.
        SELECT count(*)
            into prenotazioni_esistenti
                from PRENOTAZIONE;

        -- Se non esistono prenotazioni, si crea la prima prenotazione con data una settimana successiva alla data di sistema.
        IF (prenotazioni_esistenti = 0) THEN
            max_protocollo := 0;
            max_data := sysdate + 7;

        -- Se esistono prenotazioni, si procede incrementando di 1 l'ultimo valore di prenotazione.
        ELSE
            SELECT MAX(NUM_PROTOCOLLO)
                INTO max_protocollo
                    FROM PRENOTAZIONE;

            SELECT MAX(DATA_ORA_PREVISTE)
                INTO max_data
                    FROM PRENOTAZIONE;

        end if;

        -- Se si ha positività pregressa la prenotazione è a singola dose, altrimenti, a doppia dose.
        IF (pos_preg_p = 'T') THEN
            INSERT INTO PRENOTAZIONE VALUES (max_protocollo+1, 1, max_data + (1/1440*10), 'SINGOLA');
        ELSIF (pos_preg_p = 'F') THEN
            INSERT INTO PRENOTAZIONE VALUES (max_protocollo+1, 1, max_data + (1/1440*10), 'DOPPIA');
        ELSE
            RAISE pos_preg_errata;
        end if;


   -- Si inserisce il vaccinando.
   insert into vaccinando values(
                                    num_Tessera_p,
                                    scad_Tessera_p,
                                    cod_fiscale_p,
                                    nome_p,
                                    cognome_p,
                                    data_nascita_p,
                                    citta_natale_p,
                                    citta_p,
                                    provincia_p,
                                    cap_p,
                                    via_p,
                                    civico_p,
                                    email_p,
                                    pos_preg_p,
                                    max_protocollo+1,
                                    1
                                    );

    -- Si controlla se è stato passato un vaccinando disabile come parametro della procedura. Se sì, si procede ad inserirlo in DISABILE e ad inserire tutte le sue disabilità.
    if(disc_Dis_p <> 0) then
      insert into disabile values (
                                    num_Attes_104_p,
                                    num_Tessera_p
      );

        for i in 1..disabilita_p.count loop
            insert into disabilita values (
                                          num_Tessera_p,
                                          disabilita_p(i)
            );
        end loop;
    end if;

    -- Si controlla se è stato inserito un vaccinando fragile come parametro della procedura. Se sì, si procede ad inserirlo in FRAGILE e ad inserire tutte le sue patologie.
    if(disc_Pat_p <> 0) then
          insert into fragile values (
                                    num_Tessera_p
          );


        for i in 1..patologia_p.count loop
            insert into patologia values (
                                          num_Tessera_p,
                                          patologia_p(i)
            );
        end loop;
    end if;


    -- Se sono stati passati dei numeri di telefono in input alla procedura, si procede ad inserirli nella tabella TELEFONO.
    if(numero_telefono_p is not NUll) then
        for i in 1.. numero_telefono_p.count loop
            insert into telefono values (
                                        num_Tessera_p,
                                        numero_telefono_p(i)
                                        );
        end loop;
    end if;


    commit;
    exception
    when vaccinando_gia_esiste then
        raise_application_error(-20015, 'Il vaccinando esiste già nel database!');
        rollback;

    WHEN pos_preg_errata then
        raise_application_error(-20060, 'Inserisci una positività pregressa valida!');
        rollback;

end;
