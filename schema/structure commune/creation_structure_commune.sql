/*
La table TA_FAMILLE rassemble toutes les familles de libellés.
*/
-- 1. Création de la table
CREATE TABLE G_GEO.TA_FAMILLE(
	objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
	valeur VARCHAR2(255)
);

-- 2. Création des commentaires
COMMENT ON TABLE G_GEO.TA_FAMILLE IS 'Table contenant les familles de libellés.';
COMMENT ON COLUMN G_GEO.TA_FAMILLE.objectid IS 'Identifiant de chaque famille de libellés.';
COMMENT ON COLUMN G_GEO.TA_FAMILLE.valeur IS 'Valeur de chaque famille de libellés.';

-- 3. Création de la clé primaire
ALTER TABLE G_GEO.TA_FAMILLE
ADD CONSTRAINT TA_FAMILLE_PK 
PRIMARY KEY("OBJECTID")
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_GEO.TA_FAMILLE TO G_ADMIN_SIG;

/*
La table TA_LIBELLE_LONG regroupe les libelles long pouvant être pris par les objets de la base.

*/
-- 1. Création de la table
CREATE TABLE G_GEO.TA_LIBELLE_LONG(
	objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
	valeur VARCHAR2(255)
);

-- 2. Création des commentaires
COMMENT ON TABLE G_GEO.TA_LIBELLE_LONG IS 'Table regroupant les libelles long pouvant être pris par les objets, états ou actions présents dans le schéma.';
COMMENT ON COLUMN G_GEO.TA_LIBELLE_LONG.objectid IS 'Clé primaire de la table TA_LIBELLE_LONG.';
COMMENT ON COLUMN G_GEO.TA_LIBELLE_LONG.valeur IS 'Valeur pouvant être prises par les objets, états ou actions présents dans le schéma.';

-- 3. Création de la clé primaire
ALTER TABLE G_GEO.TA_LIBELLE_LONG
ADD CONSTRAINT TA_LIBELLE_LONG_PK 
PRIMARY KEY("OBJECTID")
USING INDEX TABLESPACE "G_ADT_INDX";

-- 5. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_GEO.TA_LIBELLE_LONG TO G_ADMIN_SIG;

/*
La table TA_LIBELLE regroupe tous les états ou actions regroupés dans une famille elle-même située dans la tabe ta_famille.

*/
-- 1. Création de la table
CREATE TABLE G_GEO.TA_LIBELLE(
	objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
	fid_libelle_long NUMBER(38,0)
);

-- 2. Création des commentaires
COMMENT ON TABLE G_GEO.TA_LIBELLE IS 'Table listant les libelles utilisé afin d''établir une hiérarchie.';
COMMENT ON COLUMN G_GEO.TA_LIBELLE.objectid IS 'Identifiant de chaque libellé.';
COMMENT ON COLUMN G_GEO.TA_LIBELLE.fid_libelle_long IS 'Clé étrangère vers la table TA_LIBELLE_LONG';

-- 3. Création de la clé primaire
ALTER TABLE G_GEO.TA_LIBELLE
ADD CONSTRAINT TA_LIBELLE_PK 
PRIMARY KEY("OBJECTID")
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création de l'index de la clé étrangère
CREATE INDEX TA_LIBELLE_FID_LIBELLE_LONG_IDX ON TA_LIBELLE(fid_libelle_long)
TABLESPACE G_ADT_INDX;

-- 5. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_GEO.TA_LIBELLE TO G_ADMIN_SIG;

/*
La table TA_LIBELLE_COURT regroupant les libelles court pouvant être prise par les objets de la base.
*/
-- 1. Création de la table
CREATE TABLE ta_libelle_court(
	objectid NUMBER(38,0) GENERATED ALWAYS AS IDENTITY START WITH 1 INCREMENT BY 1,
	valeur VARCHAR2(255)
);

-- 2. Création des commentaires
COMMENT ON TABLE g_geo.ta_libelle_court IS 'Table regroupant les libelles court pouvant être prise par les objets de la base.';
COMMENT ON COLUMN g_geo.ta_libelle_court.objectid IS 'Clef primaire de la table TA_LIBELLE_COURT.';
COMMENT ON COLUMN g_geo.ta_libelle_court.valeur IS 'Valeur pouvant être prises par les variables exemple A101 ou 1 ou 0 ou x.';

-- 3. Création de la clé primaire
ALTER TABLE ta_libelle_court
ADD CONSTRAINT ta_libelle_court 
PRIMARY KEY("OBJECTID")
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création de l'index
CREATE INDEX ta_libelle_court_libelle_court_IDX ON ta_libelle_court(valeur)
TABLESPACE G_ADT_INDX;

-- 5. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON g_geo.ta_libelle_court TO G_ADMIN_SIG;

/*
La table TA_LIBELLE_CORRESPONDANCE sert à faire la correspondance entre les libelles longs(par l'intermédiaire de TA_LIBELLE) et les libelles courts.
*/

-- 1. Création de la table
CREATE TABLE ta_libelle_correspondance(
	objectid NUMBER(38,0) GENERATED ALWAYS AS IDENTITY START WITH 1 INCREMENT BY 1,
	fid_libelle NUMBER(38,0), 
	fid_libelle_court NUMBER(38,0)
);

-- 2. Création des commentaires
COMMENT ON TABLE g_geo.ta_libelle_correspondance  IS 'Table indiquant les correspondances entre les libelles et les libelles court issus de la Base Permanente des Equipements. Exemple Police = A10 ou Sans objet = x';
COMMENT ON COLUMN g_geo.ta_libelle_correspondance.objectid IS 'Clef primaire de la table ta_libelle_correspondance.';
COMMENT ON COLUMN g_geo.ta_libelle_correspondance.fid_libelle IS 'Clef etrangere vers la table TA_LIBELLE';
COMMENT ON COLUMN g_geo.ta_libelle_correspondance.fid_libelle_court IS 'Clef etrangere vers la table TA_LIBELLE_COURT pour connaitre les libelles courts des libelles. Exemple Police = A10 ou Sans objet  = x';

-- 3. Création de la clé primaire
ALTER TABLE ta_libelle_correspondance
ADD CONSTRAINT ta_libelle_correspondance_PK 
PRIMARY KEY("OBJECTID")
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères

-- clé étrangère vers la table TA_LIBELLE pour connaitre le libelle
ALTER TABLE ta_libelle_correspondance
ADD CONSTRAINT  "TA_CORRESPONDANCE_FID_LIBELLE_FK"
FOREIGN KEY ("FID_LIBELLE")
REFERENCES  "TA_LIBELLE" ("OBJECTID");

-- clé étrangère vers la table TA_LIBELLE_COURT pour connaitre le libelle court
ALTER TABLE ta_libelle_correspondance
ADD CONSTRAINT "TA_CORRESPONDANCE_FID_LIBELLE_COURT_FK"
FOREIGN KEY ("FID_LIBELLE_COURT")
REFERENCES "TA_LIBELLE_COURT" ("OBJECTID");

--5. Creation des indexes sur les clés étrangères
CREATE INDEX ta_libelle_correspondance_fid_libelle_IDX ON ta_libelle_correspondance(fid_libelle)
TABLESPACE G_ADT_INDX;

CREATE INDEX ta_libelle_correspondance_fid_libelle_court_IDX ON ta_libelle_correspondance(fid_libelle_court)
TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON g_geo.ta_libelle_correspondance TO G_ADMIN_SIG;

/*
La table TA_LIBELLE_RELATION sert à définir les relations entre les différents libelles si elles existent. Exemple A101/Police est un sous élément du libelle A1/Services Publics.x/Sans Object peut être un sous élément de COUVERT/Equipement couvert ou non mais aussi de ECLAIRE/Equipement éclairé ou non.
*/
-- 1. Création de la table
CREATE TABLE ta_libelle_relation(
	fid_libelle_fils NUMBER(38,0),
	fid_libelle_parent NUMBER(38,0)
);

-- 2. Création des commentaires
COMMENT ON TABLE g_geo.ta_libelle_relation IS 'Table qui sert à définir les relations entre les différents libelle de la nomenclature de la base permanente des equipements. Exemple A101/Police est un sous élément du libelle A1/Services Publics.x/Sans Object peut être un sous élément de COUVERT/Equipement couvert ou non mais aussi de ECLAIRE/Equipement éclairé ou non.';
COMMENT ON COLUMN g_geo.ta_libelle_relation.fid_libelle_fils IS 'Composante de la clé primaire. Clef étrangère vers la table TA_LIBELLE pour connaitre le libelle fils.';
COMMENT ON COLUMN g_geo.ta_libelle_relation.fid_libelle_parent IS 'Composante de la clé primaire. Clef étrangère vers la table TA__LIBELLE pour connaitre le libelle parent.';

-- 3. Création de la clé primaire composée.
ALTER TABLE ta_libelle_relation
	ADD CONSTRAINT ta_libelle_relation_PK 
	PRIMARY KEY("FID_LIBELLE_FILS","FID_LIBELLE_PARENT")
	USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Clé étrangère
-- 4.1. Clé étrangère vers la table TA_LIBELLE
ALTER TABLE ta_libelle_relation
	ADD CONSTRAINT  "TA_LIBELLE_OBJECTID_FID_LIBELLE_FILS_FK"
	FOREIGN KEY ("FID_LIBELLE_FILS")
	REFERENCES  "G_GEO"."TA_LIBELLE" ("OBJECTID");

-- 4.2. Clé étrangère vers la table TA_LIBELLE
ALTER TABLE ta_libelle_relation
	ADD CONSTRAINT  "TA_LIBELLE_OBJECTID_FID_LIBELLE_PARENT_FK"
	FOREIGN KEY ("FID_LIBELLE_PARENT")
	REFERENCES  "G_GEO"."TA_LIBELLE" ("OBJECTID");

-- 5. Création des indexes sur les cléfs étrangères.
CREATE INDEX ta_relation_libelle_fid_relation_fils_IDX ON ta_libelle_relation(fid_libelle_fils)
TABLESPACE G_ADT_INDX;

CREATE INDEX ta_relation_libelle_fid_relation_parent_IDX ON ta_libelle_relation(fid_libelle_parent)
TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON g_geo.ta_libelle_relation TO G_ADMIN_SIG;

/*
La table TA_FAMILLE_LIBELLE sert à faire la liaison entre les tables ta_libelle et ta_famille.
*/
-- 1. Création de la table
CREATE TABLE ta_famille_libelle(
	objectid NUMBER(38,0) GENERATED ALWAYS AS IDENTITY,
	fid_famille NUMBER(38,0),
	fid_libelle_long NUMBER(38,0)
);

-- 2. Création des commentaires
COMMENT ON TABLE g_geo.ta_famille_libelle IS 'Table contenant les identifiant des tables ta_libelle et ta_famille, permettant de joindre le libellé à sa famille de libellés.';
COMMENT ON COLUMN g_geo.ta_famille_libelle.objectid IS 'Identifiant de chaque ligne.';
COMMENT ON COLUMN g_geo.ta_famille_libelle.fid_famille IS 'Identifiant de chaque famille de libellés - FK de la table ta_famille.';
COMMENT ON COLUMN g_geo.ta_famille_libelle.fid_libelle_long IS 'Identifiant de chaque libellés - FK de la table ta_libelle_long.';

-- 3. Création de la clé primaire
ALTER TABLE ta_famille_libelle
ADD CONSTRAINT ta_famille_libelle_PK 
PRIMARY KEY("OBJECTID")
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
-- 4.1. Clé étrangère vers la table TA_FAMILLE
ALTER TABLE ta_famille_libelle
ADD CONSTRAINT ta_famille_libelle_fid_famille_FK
FOREIGN KEY(fid_famille)
REFERENCES ta_famille(objectid);

-- 4.2. Clé étrangère vers la table TA_LIBELLE_LONG
ALTER TABLE	ta_famille_libelle
ADD CONSTRAINT	ta_famille_libelle_fid_libelle_long_FK
FOREIGN KEY(fid_libelle_long)
REFERENCES ta_libelle_long(objectid);

-- 5. Création des indexes sur les clés étrangères
CREATE INDEX ta_famille_libelle_fid_famille_IDX ON ta_famille_libelle(fid_famille)
TABLESPACE G_ADT_INDX;

CREATE INDEX ta_famille_libelle_fid_libelle_long_IDX ON ta_famille_libelle(fid_libelle_long)
TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON g_geo.ta_famille_libelle TO G_ADMIN_SIG;

/*
La table TA_CODE regroupe tous les codes du schéma. 
*/

-- 1. Création de la table
CREATE TABLE ta_code(
	objectid NUMBER(38,0) GENERATED ALWAYS AS IDENTITY,
	valeur VARCHAR2(50),
	fid_libelle NUMBER(38,0)
);

-- 2. Création des commentaires
COMMENT ON TABLE g_geo.ta_code IS 'La table regroupe tous les codes du schéma G_GEO.';
COMMENT ON COLUMN g_geo.ta_code.objectid IS 'Clé primaire de la table.';
COMMENT ON COLUMN g_geo.ta_code.valeur IS 'Codes de chaque donnée du schéma.';
COMMENT ON COLUMN g_geo.ta_code.fid_libelle IS 'Clé étrangère de ta_libelle permettant de connaître la signification de chaque code.';

-- 3. Création de la clé primaire
ALTER TABLE ta_code
ADD CONSTRAINT ta_code_PK 
PRIMARY KEY("OBJECTID")
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangère
-- 4.1. Clé étrangère vers la table TA_LIBELLE
ALTER TABLE ta_code
ADD CONSTRAINT ta_code_fid_libelle_FK
FOREIGN KEY (fid_libelle)
REFERENCES ta_libelle(objectid);

-- 5. Création de l'index de la clé étrangère
CREATE INDEX ta_code_fid_libelle_IDX ON ta_code(fid_libelle)
TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON g_geo.ta_code TO G_ADMIN_SIG;

/*
La table TA_ORGANISME recense tous les organismes créateurs de données desquels proviennent les données source de la table ta_source.
*/

-- 1. Création de la table ta_organisme
CREATE TABLE ta_organisme(
    objectid NUMBER(38,0) GENERATED ALWAYS AS IDENTITY,
    acronyme VARCHAR2(50),
    nom_organisme VARCHAR2(2000)
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE g_geo.ta_organisme IS 'Table rassemblant tous les organismes créateurs des données source utilisées par la MEL.';
COMMENT ON COLUMN g_geo.ta_organisme.objectid IS 'Identifiant de chaque objet de la table.';
COMMENT ON COLUMN g_geo.ta_organisme.nom_organisme IS 'Nom de l''organisme créateur des données sources utilisées par la MEL';

-- 3. Création de la clé primaire
ALTER TABLE ta_organisme 
ADD CONSTRAINT ta_organisme_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON g_geo.ta_organisme TO G_ADMIN_SIG;

/*
La table TA_SOURCE permet de rassembler toutes les données sources provenant d'une source extérieure à la MEL.
*/

-- 1. Création de la table ta_date_acquisition
CREATE TABLE ta_date_acquisition(
    objectid NUMBER(38,0) GENERATED ALWAYS AS IDENTITY,
    date_acquisition DATE,
    millesime DATE,
    nom_obtenteur VARCHAR2(200)
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE g_geo.ta_date_acquisition IS 'Table recensant les dates d''acquisition, de millésime et du nom de l''obtenteur de chaque donnée source extérieure à la MEL.';
COMMENT ON COLUMN g_geo.ta_date_acquisition.objectid IS 'Identifiant de chaque objet de la table.';
COMMENT ON COLUMN g_geo.ta_date_acquisition.date_acquisition IS 'Date d''importation de la donnée dans la table - DD/MM/AAAA.';
COMMENT ON COLUMN g_geo.ta_date_acquisition.millesime IS 'Date de création de la donnée - MM/AAAA.';
COMMENT ON COLUMN g_geo.ta_date_acquisition.nom_obtenteur IS 'Nom de la personne ayant inséré la donnée source dans la base.';

-- 3. Création de la clé primaire
ALTER TABLE ta_date_acquisition 
ADD CONSTRAINT ta_date_acquisition_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

/*-- 4. Création du déclencheur d'enregistrement de la date d'insertion de la donnée et du nom de la personne ayant fait cet import, dans la table ta_date_acquisition.

CREATE OR REPLACE TRIGGER ta_date_acquisition
BEFORE INSERT ON ta_source
FOR EACH ROW
DECLARE
	username VARCHAR2(200)

BEGIN
	select sys_context('USERENV','OS_USER') into username from dual;
	IF INSERTING THEN
		ta_date_acquisition.date_acquisition := sysdate;
		ta_date_acquisition.nom_obtenteur := username; 
	END IF;

END;*/
-- 5. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON g_geo.ta_date_acquisition TO G_ADMIN_SIG;

/*
La table TA_SOURCE permet de rassembler toutes les données sources provenant d'une source extérieure à la MEL.
*/

-- 1. Création de la table ta_source
CREATE TABLE ta_source(
    objectid NUMBER(38,0) GENERATED ALWAYS AS IDENTITY,
    nom_source VARCHAR2(4000),
    description VARCHAR2(4000)
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE g_geo.ta_source IS 'Table rassemblant toutes les sources des données utilisées par la MEL.';
COMMENT ON COLUMN g_geo.ta_source.objectid IS 'Identifiant de chaque objet de la table.';
COMMENT ON COLUMN g_geo.ta_source.nom_source IS 'Nom de la source des données.';
COMMENT ON COLUMN g_geo.ta_source.description IS 'Description de la source de données.';

-- 3. Création de la clé primaire
ALTER TABLE ta_source 
ADD CONSTRAINT ta_source_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON g_geo.ta_source TO G_ADMIN_SIG;

/*
La table TA_PROVENANCE regroupe tous les processus d'acquisition des donnees du referentiel (équivalent de TA_PROVENANCE)
*/

-- 1. Création de la table ta_provenance
CREATE TABLE ta_provenance(
    objectid NUMBER(38,0)GENERATED ALWAYS AS IDENTITY,
    url VARCHAR2(4000),
    methode_acquisition VARCHAR2(4000)
);
   
-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE g_geo.ta_provenance IS 'Table rassemblant tous les processus d''acquisition des donnees du referentiel.';
COMMENT ON COLUMN g_geo.ta_provenance.objectid IS 'Identifiant de chaque objet de la table.';
COMMENT ON COLUMN g_geo.ta_provenance.url IS 'URL à partir de laquelle les données source ont été téléchargées, si c''est le cas.';
COMMENT ON COLUMN g_geo.ta_provenance.methode_acquisition IS 'Méthode d''acquisition des données.';

-- 3. Création de la clé primaire
ALTER TABLE ta_provenance 
ADD CONSTRAINT ta_provenance_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON g_geo.ta_provenance TO G_ADMIN_SIG;

/*
La table TA_ECHELLE regroupe toutes les échelles d'affichage des données source.
*/

-- 1. Création de la table ta_echelle
CREATE TABLE ta_echelle(
    objectid NUMBER(38,0)GENERATED ALWAYS AS IDENTITY,
    valeur NUMBER(38,0)
);
  
-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE g_geo.ta_echelle IS 'Table rassemblant toutes les échelles d''affichage des données source';
COMMENT ON COLUMN g_geo.ta_echelle.objectid IS 'Identifiant de chaque objet de la table.';
COMMENT ON COLUMN g_geo.ta_echelle.valeur IS 'Echelle de chaque donnée source.';

-- 3. Création de la clé primaire
ALTER TABLE ta_echelle 
ADD CONSTRAINT ta_echelle_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON g_geo.ta_echelle TO G_ADMIN_SIG;

/*
La table TA_METADONNEE regroupe toutes les informations relatives aux différentes donnees du schemas.
*/
-- 1. Création de la table
CREATE TABLE ta_metadonnee(
	objectid NUMBER(38,0) GENERATED ALWAYS AS IDENTITY,
	fid_source NUMBER(38,0),
	fid_acquisition NUMBER(38,0),
	fid_provenance NUMBER(38,0),
	fid_echelle NUMBER(38,0)
);

-- 2. Création des commentaires
COMMENT ON TABLE g_geo.ta_metadonnee IS 'Table qui regroupe toutes les informations relatives aux différentes donnees du schema.';
COMMENT ON COLUMN g_geo.ta_metadonnee.objectid IS 'clé primaire de la table.';
COMMENT ON COLUMN g_geo.ta_metadonnee.fid_source IS 'clé étrangère vers la table TA_SOURCE pour connaitre la source de la donnée.';
COMMENT ON COLUMN g_geo.ta_metadonnee.fid_acquisition IS 'clé étrangère vers la table ta_date_acquisition pour connaitre la date d''acquisition de la donnée.';
COMMENT ON COLUMN g_geo.ta_metadonnee.fid_provenance IS 'clé étrangère vers la table TA_PROVENANCE pour connaitre la provenance de la donnée.';
COMMENT ON COLUMN g_geo.ta_metadonnee.fid_echelle IS 'clé étrangère vers la table TA_ECHELLE pour connaitre l''echelle de la donnee.';

-- 3. Création de la clé primaire
ALTER TABLE ta_metadonnee
ADD CONSTRAINT	ta_metadonnee_PK 
PRIMARY KEY("OBJECTID")
USING INDEX TABLESPACE "G_ADT_INDX";


-- 4. Création des clés étrangère
-- 4.1. clé étrangère vers la table TA_SOURCE
ALTER TABLE ta_metadonnee
ADD CONSTRAINT ta_metadonnee_fid_source_FK
FOREIGN KEY (fid_source)
REFERENCES ta_source(objectid);

-- 4.2. clé étrangère vers la table TA_DATE_ACQUISITION
ALTER TABLE ta_metadonnee
ADD CONSTRAINT ta_metadonnee_fid_acquisition_FK
FOREIGN KEY (fid_acquisition)
REFERENCES ta_date_acquisition(objectid);

-- 4.3. clé étrangère vers la table TA_PROVENANCE
ALTER TABLE ta_metadonnee
ADD CONSTRAINT ta_metadonnee_fid_provenance_FK
FOREIGN KEY (fid_provenance)
REFERENCES ta_provenance(objectid);

-- 4.. clé étrangère vers la table TA_ECHELLE
ALTER TABLE ta_metadonnee
ADD CONSTRAINT ta_metadonnee_fid_echelle_FK
FOREIGN KEY (fid_echelle)
REFERENCES ta_echelle(objectid);

-- 7. Création des indexes sur les clés étrangères
CREATE INDEX ta_metadonnee_fid_source_IDX ON ta_metadonnee(fid_source)
TABLESPACE G_ADT_INDX;

CREATE INDEX ta_metadonnee_fid_acquisition_IDX ON ta_metadonnee(fid_acquisition)
TABLESPACE G_ADT_INDX;

CREATE INDEX ta_metadonnee_fid_provenance_IDX ON ta_metadonnee(fid_provenance)
TABLESPACE G_ADT_INDX;

CREATE INDEX ta_metadonnee_fid_echelle_IDX ON ta_metadonnee(fid_echelle)
TABLESPACE G_ADT_INDX;


-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON g_geo.ta_metadonnee TO G_ADMIN_SIG;

/*
La table TA_METADONNEE_RELATION_ORGANISME met en relation les métadonnées des données avec leurs organismes producteurs
*/
CREATE TABLE ta_metadonnee_relation_organisme(
    fid_metadonnee NUMBER(38,0),
    fid_organisme NUMBER(38,0)
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE g_geo.ta_metadonnee_relation_organisme IS 'Table de relation entre les table TA_METADONNE et TA_ORGANISME pour pouvoir dans le cas ou une donnée a plusieurs organismes producteurs tous les connaitre.';
COMMENT ON COLUMN g_geo.ta_metadonnee_relation_organisme.fid_metadonnee IS 'Clé étrangère vers la table TA_METADONNEE pour connaitre la donnée produite par un producteur.';
COMMENT ON COLUMN g_geo.ta_metadonnee_relation_organisme.fid_organisme IS 'Clé étrangère vers la table TA_ORGANISME pour connaitre les producteur de la donnée.';

-- 3. Création de la clé primaire
ALTER TABLE ta_metadonnee_relation_organisme
ADD CONSTRAINT	ta_metadonnee_relation_organisme_PK 
PRIMARY KEY("FID_METADONNEE","FID_ORGANISME")
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangère
-- 4.1. Clé étrangère vers la table TA_METADONNEE
ALTER TABLE ta_metadonnee_relation_organisme
ADD CONSTRAINT ta_metadonnee_relation_organisme_fid_metadonnee_FK
FOREIGN KEY (fid_metadonnee)
REFERENCES ta_metadonnee(objectid);

-- 4.2. Clé étrangère vers la table TA_ORGANISME
ALTER TABLE ta_metadonnee_relation_organisme
ADD CONSTRAINT ta_metadonnee_fid_organisme_FK
FOREIGN KEY (fid_organisme)
REFERENCES ta_organisme(objectid);

-- 5. Création des indexes des clés étrangères
CREATE INDEX ta_metadonnee_relation_organisme_fid_metadonnee_IDX ON ta_metadonnee_relation_organisme(fid_metadonnee)
TABLESPACE G_ADT_INDX;

CREATE INDEX ta_metadonnee_relation_organisme_fid_organisme_IDX ON ta_metadonnee_relation_organisme(fid_organisme)
TABLESPACE G_ADT_INDX;


-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON g_geo.ta_metadonnee_relation_organisme TO G_ADMIN_SIG;

/*
La table Ta_NOM regroupe le nom de tous les objets du référentiel (les zones administratives)
*/

-- 1. Création de la table ta_nom
CREATE TABLE ta_nom(
    objectid NUMBER(38,0)GENERATED BY DEFAULT AS IDENTITY,
    acronyme VARCHAR2(50),
    valeur VARCHAR2(4000)
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE g_geo.ta_nom IS 'Table rassemblant tous les noms des objets du schéma.';
COMMENT ON COLUMN g_geo.ta_nom.objectid IS 'Identifiant de chaque objet de la table.';
COMMENT ON COLUMN g_geo.ta_nom.acronyme IS 'Acronyme de chaque nom - Exemple : MEL pour la Métropole Européenne de Lille.';
COMMENT ON COLUMN g_geo.ta_nom.valeur IS 'Nom de chaque objet.';

-- 3. Création de la clé primaire
ALTER TABLE ta_nom 
ADD CONSTRAINT ta_nom_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON g_geo.ta_nom TO G_ADMIN_SIG;

/*
La table TA_COMMUNE regroupe toutes les communes de la MEL.
*/

-- 1. Création de la table ta_commune
CREATE TABLE ta_commune(
    objectid NUMBER(38,0)GENERATED BY DEFAULT AS IDENTITY,
    geom SDO_GEOMETRY,
    fid_lib_type_commune NUMBER(38,0),
    fid_nom NUMBER(38,0),
    fid_metadonnee NUMBER(38,0)    
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE g_geo.ta_commune IS 'Table rassemblant tous les contours communaux de la MEL et leur équivalent belge.';
COMMENT ON COLUMN g_geo.ta_commune.objectid IS 'Identifiant de chaque objet de la table.';
COMMENT ON COLUMN g_geo.ta_commune.geom IS 'Géométrie de chaque commune ou équivalent international.';
COMMENT ON COLUMN g_geo.ta_commune.fid_lib_type_commune IS 'Clé étrangère permettant de connaître le statut de la commune ou équivalent international - ta_libelle.';
COMMENT ON COLUMN g_geo.ta_commune.fid_nom IS 'Clé étrangère de la table TA_NOM permettant de connaître le nom de chaque commune ou équivalent international.';
COMMENT ON COLUMN g_geo.ta_commune.fid_metadonnee IS 'Clé étrangère permettant de retrouver la source à partir de laquelle la donnée est issue - ta_source.';


-- 3. Création de la clé primaire
ALTER TABLE ta_commune 
ADD CONSTRAINT ta_commune_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'ta_commune',
    'geom',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 594000, 964000, 0.005),SDO_DIM_ELEMENT('Y', 6987000, 7165000, 0.005)), 
    2154
);
COMMIT;

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX ta_commune_SIDX
ON ta_commune(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS('sdo_indx_dims=2, layer_gtype=POLYGON, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 6. Création des clés étrangères
-- 6.1. Clé étrangère vers la table TA_LIBELLE
ALTER TABLE ta_commune
ADD CONSTRAINT ta_commune_fid_lib_type_commune_FK 
FOREIGN KEY (fid_lib_type_commune)
REFERENCES ta_libelle(objectid);

-- 6.2. Clé étrangère vers la table TA_NOM
ALTER TABLE ta_commune
ADD CONSTRAINT ta_commune_fid_nom_FK 
FOREIGN KEY (fid_nom)
REFERENCES ta_nom(objectid);

-- 6.3. Clé étrangère vers la TA_METADONNEE
ALTER TABLE ta_commune
ADD CONSTRAINT ta_commune_fid_metadonnee_FK 
FOREIGN KEY (fid_metadonnee)
REFERENCES ta_metadonnee(objectid);

-- 7. Création des indexes sur les clés étrangères
CREATE INDEX ta_commune_fid_lib_type_commune_IDX ON ta_commune(fid_lib_type_commune)
    TABLESPACE G_ADT_INDX;

CREATE INDEX ta_commune_fid_nom_IDX ON ta_commune(fid_nom)
    TABLESPACE G_ADT_INDX;

CREATE INDEX ta_commune_fid_metadonnee_IDX ON ta_commune(fid_metadonnee)
    TABLESPACE G_ADT_INDX;

-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON g_geo.ta_commune TO G_ADMIN_SIG;

/*
La table TA_IDENTIFIANT_COMMUNE permet de regrouper tous les codes par commune. 
*/

-- 1. Création de la table
CREATE TABLE ta_identifiant_commune(
	objectid NUMBER(38,0) GENERATED ALWAYS AS IDENTITY,
	fid_commune NUMBER(38,0),
	fid_identifiant NUMBER(38,0)
);

-- 2. Création des commentaires
COMMENT ON TABLE g_geo.ta_identifiant_commune IS 'La table permet de regrouper tous les codes par commune.';
COMMENT ON COLUMN g_geo.ta_identifiant_commune.objectid IS 'Clé primaire de la table.';
COMMENT ON COLUMN g_geo.ta_identifiant_commune.fid_commune IS 'Clé étrangère de la table TA_COMMUNE.';
COMMENT ON COLUMN g_geo.ta_identifiant_commune.fid_identifiant IS 'Clé étrangère de la table TA_CODE.';

-- 3. Création de la clé primaire
ALTER TABLE TA_IDENTIFIANT_COMMUNE
ADD CONSTRAINT	TA_IDENTIFIANT_COMMUNE_PK 
PRIMARY KEY("OBJECTID")
USING INDEX TABLESPACE "G_ADT_INDX";

-- 6. Création des clés étrangères
-- 6.1. Clé étrangère vers la table TA_COMMUNE
ALTER TABLE ta_identifiant_commune
ADD CONSTRAINT ta_identifiant_commune_fid_commune_FK 
FOREIGN KEY (fid_commune)
REFERENCES ta_commune(objectid);

-- 6.2. Clé étrangère vers la table TA_CODE
ALTER TABLE ta_identifiant_commune
ADD CONSTRAINT ta_identifiant_commune_fid_identifiant_FK 
FOREIGN KEY (fid_identifiant)
REFERENCES ta_code(objectid);

-- 4. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON g_geo.TA_IDENTIFIANT_COMMUNE TO G_ADMIN_SIG;

/* 
La table TA_ZONE_ADMINISTRATIVE permet de recenser tous les noms des zones supra-communales.

*/
-- 1. Création de la table ta_zone_administrative
CREATE TABLE ta_zone_administrative(
    objectid NUMBER(38,0) GENERATED ALWAYS AS IDENTITY,
    fid_nom NUMBER(38,0),
    fid_libelle Number(38,0),
    fid_metadonnee NUMBER(38,0)
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE g_geo.ta_zone_administrative IS 'Table regroupant tous les noms des zones supra-communales.';
COMMENT ON COLUMN g_geo.ta_zone_administrative.objectid IS 'Identifiant de chaque objet de la table.';
COMMENT ON COLUMN g_geo.ta_zone_administrative.fid_nom IS 'Clé étrangère de la table TA_NOM permettant de connaître le nom de la zone supra-communale.';
COMMENT ON COLUMN g_geo.ta_zone_administrative.fid_libelle IS 'Clé étrangère de la table TA_LIBELLE permettant de catégoriser les zones administratives.';
COMMENT ON COLUMN g_geo.ta_zone_administrative.fid_metadonnee IS 'Clé étrangère de la table TA_METADONNEE.';


-- 3. Création de la clé primaire
ALTER TABLE ta_zone_administrative 
ADD CONSTRAINT ta_zone_administrative_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
-- 4.1. Clé étrangère vers la table TA_NOM
ALTER TABLE ta_zone_administrative
ADD CONSTRAINT ta_zone_administrative_fid_nom_FK
FOREIGN KEY (fid_nom)
REFERENCES ta_nom(objectid);

--4.2. Clé étrangère vers la table TA_LIBELLE
ALTER TABLE ta_zone_administrative
ADD CONSTRAINT ta_zone_administrative_fid_libelle_FK
FOREIGN KEY (fid_libelle)
REFERENCES ta_libelle(objectid);

-- 4.3. Clé étrangère vers la table TA_METADONNEE
ALTER TABLE ta_zone_administrative
ADD CONSTRAINT ta_zone_administrative_fid_metadonnee_FK
FOREIGN KEY (fid_metadonnee)
REFERENCES ta_metadonnee(objectid);

-- 5. Création des index sur les clés étrangères
CREATE INDEX ta_zone_administrative_fid_nom_IDX ON ta_zone_administrative(fid_nom)
    TABLESPACE G_ADT_INDX;

CREATE INDEX ta_zone_administrative_fid_libelle_IDX ON ta_zone_administrative(fid_libelle)
    TABLESPACE G_ADT_INDX;

CREATE INDEX ta_zone_administrative_fid_metadonnee_IDX ON ta_zone_administrative(fid_metadonnee)
    TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON g_geo.ta_zone_administrative TO G_ADMIN_SIG;

/* 
La table TA_IDENTIFIANT_ZONE_ADMINISTRATIVE permet de lier les zones supra-communales avec leurs codes.

*/
-- 1. Création de la table ta_identifiant_zone_administrative
CREATE TABLE ta_identifiant_zone_administrative(
    objectid NUMBER(38,0) GENERATED ALWAYS AS IDENTITY,
    fid_zone_administrative Number(38,0),
    fid_identifiant NUMBER(38,0)
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE g_geo.ta_identifiant_zone_administrative IS 'Table permettant de lier les zones supra-communales avec leurs codes.';
COMMENT ON COLUMN g_geo.ta_identifiant_zone_administrative.objectid IS 'Identifiant de chaque objet de la table.';
COMMENT ON COLUMN g_geo.ta_identifiant_zone_administrative.fid_zone_administrative IS 'Clé étrangère de la table TA_ZONE_ADMINISTRATIVE.';
COMMENT ON COLUMN g_geo.ta_identifiant_zone_administrative.fid_identifiant IS 'Clé étrangère de la table TA_CODE.';


-- 3. Création de la clé primaire
ALTER TABLE ta_identifiant_zone_administrative 
ADD CONSTRAINT ta_identifiant_zone_administrative_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
-- 4.1. Clé étrangère vers la table TA_ZONE_ADMINISTRATIVE
ALTER TABLE ta_identifiant_zone_administrative
ADD CONSTRAINT ta_identifiant_zone_administrative_fid_zone_administrative_FK
FOREIGN KEY (fid_zone_administrative)
REFERENCES ta_zone_administrative(objectid);

-- 4.2. Clé étrangère vers la table TA_CODE
ALTER TABLE ta_identifiant_zone_administrative
ADD CONSTRAINT ta_identifiant_zone_administrative_fid_identifiant_FK
FOREIGN KEY (fid_identifiant)
REFERENCES ta_code(objectid);

-- 5. Création des index sur les clés étrangères
CREATE INDEX ta_identifiant_zone_administrative_fid_zone_administrative_IDX ON ta_identifiant_zone_administrative(fid_zone_administrative)
    TABLESPACE G_ADT_INDX;

CREATE INDEX ta_identifiant_zone_administrative_fid_identifiant_IDX ON ta_identifiant_zone_administrative(fid_identifiant)
    TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON g_geo.ta_identifiant_zone_administrative TO G_ADMIN_SIG;

/* 
La table ta_za_communes sert de table de liaison entre les tables ta_commune et ta_zone_administrative.
Fonction : savoir quelle commune appartient à quelle zone supra-communale.

*/
-- 1. Création de la table ta_za_communes
CREATE TABLE ta_za_communes(
    objectid NUMBER(38,0) GENERATED ALWAYS AS IDENTITY,
    fid_commune NUMBER(38,0),
    fid_zone_administrative NUMBER(38,0),
    debut_validite DATE,
    fin_validite DATE
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE g_geo.ta_za_communes IS 'Table de liaison entre les tables ta_commune et ta_unite_territoriale';
COMMENT ON COLUMN g_geo.ta_za_communes.objectid IS 'Identifiant de chaque objet de la table.';
COMMENT ON COLUMN g_geo.ta_za_communes.fid_commune IS 'Clé étrangère de la table TA_COMMUNE.';
COMMENT ON COLUMN g_geo.ta_za_communes.fid_zone_administrative IS 'Clé étrangère de la table TA_ZONE_ADMINISTRATIVE.';
COMMENT ON COLUMN g_geo.ta_za_communes.debut_validite IS 'Début de validité de la zone supra-communale. Ce champ est mis à jour dés qu''une commune change.';
COMMENT ON COLUMN g_geo.ta_za_communes.fin_validite IS 'Fin de validité de la zone supra-communale. Ce champ est mis à jour dés qu''une commune change.';

-- 3. Création de la clé primaire
ALTER TABLE ta_za_communes 
ADD CONSTRAINT ta_za_communes_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
-- 4.1. Clé étrangère vers la table TA_COMMUNE
ALTER TABLE ta_za_communes
ADD CONSTRAINT ta_za_communes_fid_commune_FK
FOREIGN KEY (fid_commune)
REFERENCES ta_commune(objectid);

-- 4.2. Clé étrangère vers la table TA_ZONE_ADMINISTRATIVE
ALTER TABLE ta_za_communes
ADD CONSTRAINT ta_za_communes_fid_zone_administrative_FK
FOREIGN KEY (fid_zone_administrative)
REFERENCES ta_zone_administrative(objectid);

-- 7. Création des indexes sur les clés étrangères
CREATE INDEX ta_za_communes_fid_commune_IDX ON ta_za_communes(fid_commune)
    TABLESPACE G_ADT_INDX;

CREATE INDEX ta_za_communes_fid_zone_administrative_IDX ON ta_za_communes(fid_zone_administrative)
    TABLESPACE G_ADT_INDX;

-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON g_geo.ta_za_communes TO G_ADMIN_SIG;