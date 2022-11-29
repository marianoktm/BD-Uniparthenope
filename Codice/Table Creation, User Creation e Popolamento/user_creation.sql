-- Utente admin
CREATE USER c19v_admin IDENTIFIED BY admin;
GRANT ALL PRIVILEGES TO c19v_admin;

-- Ruolo ospite
CREATE ROLE role_ospite IDENTIFIED BY ospiterpsw;
GRANT CONNECT, CREATE SESSION to role_ospite;
GRANT EXECUTE ON CREATE_VACCINANDO TO role_ospite;

-- Ruolo medico
CREATE ROLE role_medico IDENTIFIED BY medicorpsw;
GRANT CONNECT, CREATE SESSION to role_medico;
GRANT EXECUTE ON CREATEANAMNESI TO role_medico;
GRANT EXECUTE ON CREATEVACCINAZIONE TO role_medico;
GRANT SELECT ON CONSEGNATO_A TO role_medico;
GRANT SELECT ON LOTTO_VACCINO TO role_medico;
GRANT SELECT ON VACCINANDO TO role_medico;
GRANT SELECT ON ANAMNESI TO role_medico;
GRANT SELECT ON IDONEO TO role_medico;
GRANT SELECT ON NON_IDONEO_PERMANENTE TO role_medico;
GRANT SELECT ON NON_IDONEO_TEMPORANEO TO role_medico;
GRANT SELECT ON OPERATORE_SANITARIO_RESPONSABILE TO role_medico;

-- Ruolo autorità sanitaria
CREATE ROLE role_autoritasanitaria IDENTIFIED BY autsanrpsw;
GRANT CONNECT, CREATE SESSION to role_autoritasanitaria;
GRANT EXECUTE ON CONSEGNAVACCINO TO role_autoritasanitaria;
GRANT EXECUTE ON INSERTVACCINO TO role_autoritasanitaria;
GRANT SELECT, DELETE, UPDATE ON CONSEGNATO_A TO role_autoritasanitaria;
GRANT SELECT, INSERT, DELETE, UPDATE ON LUOGO TO role_autoritasanitaria;
GRANT SELECT, DELETE, UPDATE ON LOTTO_VACCINO TO role_autoritasanitaria;
GRANT SELECT, INSERT, DELETE, UPDATE ON STABILIMENTO TO role_autoritasanitaria;
GRANT SELECT, INSERT, DELETE, UPDATE ON CASA_PRODUTTRICE TO role_autoritasanitaria;
GRANT SELECT, DELETE, UPDATE ON PRODUTTORE_DI TO role_autoritasanitaria;


-- Utente guest1, ruolo ospite
CREATE USER guest1 IDENTIFIED BY guest1psw;
GRANT role_ospite TO guest1;

-- Utente medico1, ruolo medico
CREATE USER medico1 IDENTIFIED BY medico1psw;
GRANT role_medico TO medico1;

-- Utente authsan1, ruolo autorità sanitaria
CREATE USER authsan1 IDENTIFIED BY authsan1psw;
GRANT role_autoritasanitaria TO authsan1;
