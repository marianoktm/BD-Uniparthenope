DROP TABLE CASA_PRODUTTRICE;
DROP TABLE STABILIMENTO;
DROP TABLE PRODUTTORE_DI;
DROP TABLE CARD_VACCINATO;
DROP TABLE CONSEGNATO_A;
DROP TABLE PATOLOGIA;
DROP TABLE DISABILITA;
DROP TABLE FRAGILE;
DROP TABLE DISABILE;
DROP TABLE TELEFONO;
DROP TABLE VACCINANDO;
DROP TABLE VACCINAZIONE;
DROP TABLE CONSEGNATO_A;
DROP TABLE LOTTO_VACCINO;
DROP TABLE LUOGO;
DROP TABLE PRENOTAZIONE;
DROP TABLE ANAMNESI;
DROP TABLE NON_IDONEO_TEMPORANEO;
DROP TABLE NON_IDONEO_PERMANENTE;
DROP TABLE IDONEO;



CREATE TABLE Vaccinando (
Num_Tessera_Sanitaria           CHAR(20) PRIMARY KEY,
Scadenza_Tessera_Sanitaria      DATE,
Codice_Fiscale                  CHAR(16) UNIQUE NOT NULL,
Nome                            VARCHAR2(25) NOT NULL,
Cognome                         VARCHAR2(25) NOT NULL,
Data_Nascita                    DATE NOT NULL,
Citta_Natale                    VARCHAR2(50) NOT NULL,
Citta                       	VARCHAR2(50) NOT NULL,
Provincia                       CHAR(2) NOT NULL,
CAP                             CHAR(5),
Via                             VARCHAR2(30),
Civico                          VARCHAR2(10),
e_mail                          VARCHAR2(40),
Positivita_Pregressa            CHAR(1) DEFAULT 'F' CHECK (Positivita_Pregressa IN ('T', 'F')) NOT NULL
);



CREATE TABLE Prenotazione(
Num_Protocollo                      NUMBER(8, 0),
Num_Tentativi                       NUMBER(2, 0),
Data_Ora_Previste                   DATE NOT NULL,

Tipo_Prenotazione       VARCHAR2(7) CHECK (Tipo_Prenotazione IN ('SINGOLA','DOPPIA')) NOT NULL,

PRIMARY KEY (Num_Protocollo, Num_Tentativi)
);



ALTER TABLE Vaccinando ADD (
Num_Protocollo      NUMBER(8, 0),
Num_Tentativi       NUMBER(2, 0),

CONSTRAINT Foreign_Key_Vaccinando FOREIGN KEY (Num_Protocollo, Num_Tentativi) REFERENCES Prenotazione(Num_Protocollo, Num_Tentativi)
);



CREATE TABLE Fragile (
Num_Tessera_Sanitaria           CHAR(20) PRIMARY KEY,

CONSTRAINT Foreign_Key_Fragile FOREIGN KEY (Num_Tessera_Sanitaria) REFERENCES Vaccinando(Num_Tessera_Sanitaria)
);



CREATE TABLE Disabile (
Num_Attestato_104               VARCHAR2(10) NOT NULL,
Num_Tessera_Sanitaria           CHAR(20) PRIMARY KEY,

CONSTRAINT Foreign_Key_Disabile FOREIGN KEY (Num_Tessera_Sanitaria) REFERENCES Vaccinando(Num_Tessera_Sanitaria)
);



CREATE TABLE Disabilita (
Num_Tessera_Sanitaria           CHAR(20),
Disabilita                      VARCHAR2(40),

PRIMARY KEY (Num_Tessera_Sanitaria, Disabilita),

CONSTRAINT Foreign_Key_Disabilita FOREIGN KEY (Num_Tessera_Sanitaria) REFERENCES Disabile(Num_Tessera_Sanitaria)
);



CREATE TABLE Patologia (
Num_Tessera_Sanitaria           CHAR(20),
Patologia                       VARCHAR2(40),

PRIMARY KEY (Num_Tessera_Sanitaria, Patologia),

CONSTRAINT Foreign_Key_Patologia FOREIGN KEY (Num_Tessera_Sanitaria) REFERENCES Fragile(Num_Tessera_Sanitaria)
);

/**/

CREATE TABLE Telefono (
Num_Tessera_Sanitaria           CHAR(20),
Telefono                        VARCHAR2(20),

PRIMARY KEY (Num_Tessera_Sanitaria, Telefono),

CONSTRAINT Foreign_Key_Telefono FOREIGN KEY (Num_Tessera_Sanitaria) REFERENCES Vaccinando(Num_Tessera_Sanitaria)
);


/
CREATE TABLE Operatore_Sanitario_Responsabile (
Num_Iscrizione_Ordine_Medici            NUMBER(10, 0) PRIMARY KEY,
Nome                                    VARCHAR2(25) NOT NULL,
Cognome                                 VARCHAR2(25) NOT NULL
);



CREATE TABLE Anamnesi (
Num_Protocollo                          NUMBER(8, 0) NOT NULL,
Num_Tentativi                           NUMBER(2, 0) NOT NULL,
Data_Ora_Controllo                      DATE NOT NULL,
Num_Iscrizione_Ordine_Medici            NUMBER(10, 0) NOT NULL,

PRIMARY KEY (Num_Protocollo, Num_Tentativi, Data_Ora_Controllo),

CONSTRAINT Foreign_Key_Anamnesi1 FOREIGN KEY (Num_Protocollo, Num_Tentativi) REFERENCES Prenotazione(Num_Protocollo, Num_Tentativi),
CONSTRAINT Foreign_Key_Anamnesi2 FOREIGN KEY (Num_Iscrizione_Ordine_Medici) REFERENCES Operatore_Sanitario_Responsabile(Num_Iscrizione_Ordine_Medici)
);



CREATE TABLE Non_Idoneo_Temporaneo(
Num_Protocollo                          NUMBER(8, 0),
Num_Tentativi                           NUMBER(2, 0),
Data_Ora_Controllo                      DATE,
Data_Idoneita_Prevista                  DATE NOT NULL,

PRIMARY KEY (Num_Protocollo, Num_Tentativi, Data_Ora_Controllo),

CONSTRAINT Foreign_Key_Non_Idoneo_Temporaneo1 FOREIGN KEY (Num_Protocollo, Num_Tentativi, Data_Ora_Controllo) REFERENCES Anamnesi(Num_Protocollo, Num_Tentativi, Data_Ora_Controllo)
);



CREATE TABLE Idoneo(
Num_Protocollo                          NUMBER(8, 0),
Num_Tentativi                           NUMBER(2, 0),
Data_Ora_Controllo                      DATE,

PRIMARY KEY (Num_Protocollo, Num_Tentativi, Data_Ora_Controllo),

CONSTRAINT Foreign_Key_Idoneo FOREIGN KEY (Num_Protocollo, Num_Tentativi, Data_Ora_Controllo) REFERENCES Anamnesi(Num_Protocollo, Num_Tentativi, Data_Ora_Controllo)
);



CREATE TABLE Non_Idoneo_Permanente (
Num_Protocollo                          NUMBER(8, 0),
Num_Tentativi                           NUMBER(2, 0),
Data_Ora_Controllo                      DATE,

PRIMARY KEY (Num_Protocollo, Num_Tentativi, Data_Ora_Controllo),

CONSTRAINT Foreign_Key_Non_Idoneo_Permanente FOREIGN KEY (Num_Protocollo, Num_Tentativi, Data_Ora_Controllo) REFERENCES Anamnesi(Num_Protocollo, Num_Tentativi, Data_Ora_Controllo)
);

/**/

CREATE TABLE Card_Vaccinato (
Num_Carta           NUMBER(8, 0) PRIMARY KEY,
Data_Attivazione    DATE NOT NULL,
Data_Scadenza       DATE NOT NULL
);



CREATE TABLE Stabilimento (
Nome        VARCHAR2(30) PRIMARY KEY,
Nazione     VARCHAR2(20),
Citta       VARCHAR2(50),
Via         VARCHAR2(50),
Civico      VARCHAR2(10)
);



CREATE TABLE Casa_Produttrice (
Nome        VARCHAR2(30) PRIMARY KEY,
Nazione     VARCHAR2(20),
Sito_Web    VARCHAR2(30)
);



CREATE TABLE Luogo (
Nome                                VARCHAR2(30),
Distretto                           VARCHAR2(20),
ASL_Appartenenza                    VARCHAR2(20) NOT NULL,
Provincia                           CHAR(2) NOT NULL,
Citta                               VARCHAR2(50) NOT NULL,
CAP                                 CHAR(5) NOT NULL,
Via                                 VARCHAR2(30) NOT NULL,
Civico                              VARCHAR2(10),


Discriminatore_PVO                  CHAR(1) DEFAULT '1' CHECK (Discriminatore_PVO IN ('1', '0')) NOT NULL,
Codice_Presidio_Ospedaliero         VARCHAR2(20) UNIQUE,

PRIMARY KEY (Nome, Distretto)
);



CREATE TABLE Lotto_Vaccino (
Num_Lotto                       VARCHAR2(10),
Nome_Farmaco                    VARCHAR2(30),
Scadenza                        DATE NOT NULL,
Num_Dosi_Lotto                  NUMBER(6, 0) NOT NULL,

Nome_Stabilimento               VARCHAR2(30) NOT NULL,

Discriminatore                  CHAR(1) CHECK (Discriminatore IN ('T', 'F')) NOT NULL,
Tempo_Prima_Seconda_Dose        NUMBER(3, 0),

PRIMARY KEY (Num_Lotto, Nome_Farmaco),

CONSTRAINT Foreign_Key_Lotto_Vaccino FOREIGN KEY (Nome_Stabilimento) REFERENCES Stabilimento(Nome) ON DELETE CASCADE
);



CREATE TABLE Produttore_Di (
Nome_Produttore         VARCHAR2(30),

Nome_Farmaco            VARCHAR2(30),
Num_Lotto               VARCHAR2(10),

PRIMARY KEY (Nome_Produttore, Nome_Farmaco, Num_Lotto),

CONSTRAINT Foreign_Key_Produttore_Di1 FOREIGN KEY (Nome_Produttore) REFERENCES Casa_Produttrice(Nome),
CONSTRAINT Foreign_Key_Produttore_Di2 FOREIGN KEY (Nome_Farmaco, Num_Lotto) REFERENCES Lotto_Vaccino(Nome_Farmaco, Num_Lotto) ON DELETE CASCADE
);



CREATE TABLE Vaccinazione (
Data_Ora_Effettiva          DATE,
Braccio_Inoculazione        CHAR(1) CHECK (Braccio_Inoculazione IN ('L', 'R')) NOT NULL,
Num_Carta                   NUMBER(8, 0),
Nome_Luogo                  VARCHAR2(30) NOT NULL,
Distretto_Luogo             VARCHAR2(20) NOT NULL,
Num_Lotto                   VARCHAR2(10) NOT NULL,
Nome_Farmaco                VARCHAR2(30) NOT NULL,

Num_Protocollo              NUMBER(8, 0) NOT NULL,
Num_Tentativi               NUMBER(2, 0) NOT NULL,
Data_Ora_Controllo          DATE NOT NULL,

PRIMARY KEY (Num_Carta, Data_Ora_Effettiva),

CONSTRAINT Foreign_Key_Vaccinazione1 FOREIGN KEY (Num_Protocollo, Num_Tentativi, Data_Ora_Controllo) REFERENCES Idoneo(Num_Protocollo, Num_Tentativi, Data_Ora_Controllo),
CONSTRAINT Foreign_Key_Vaccinazione2 FOREIGN KEY (Num_Carta) REFERENCES Card_Vaccinato(Num_Carta),
CONSTRAINT Foreign_Key_Vaccinazione3 FOREIGN KEY (Nome_Luogo, Distretto_Luogo) REFERENCES Luogo(Nome, Distretto),
CONSTRAINT Foreign_Key_Vaccinazione4 FOREIGN KEY (Num_Lotto, Nome_Farmaco) REFERENCES Lotto_Vaccino(Num_Lotto, Nome_Farmaco)
);



CREATE TABLE Consegnato_a(
Nome_Luogo                      VARCHAR2(30),
Distretto_Luogo                 VARCHAR2(20),
Nome_Farmaco                    VARCHAR2(30),
Num_Lotto                       VARCHAR2(10),
Data_Consegna                   DATE NOT NULL,
Num_Dosi_Consegnate             NUMBER(6, 0) NOT NULL,

PRIMARY KEY (Nome_Luogo, Distretto_Luogo, Nome_Farmaco, Num_Lotto, Data_Consegna),

CONSTRAINT Foreing_Key_Consegnato1 FOREIGN KEY (Nome_Luogo, Distretto_Luogo) REFERENCES Luogo(Nome, Distretto),
CONSTRAINT Foreign_Key_Consegnato2 FOREIGN KEY (Nome_Farmaco, Num_Lotto) REFERENCES Lotto_Vaccino(Nome_Farmaco, Num_Lotto)
);