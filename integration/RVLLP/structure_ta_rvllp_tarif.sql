-- création de la table TA_RVLLP_TARIF

-- 1. Création de la table TA_RVLLP_TARIF
-- 1.1. La table TA_RVLLP_TARIF sert à acceuillir les informations provenant des données tarif de la RVLLP suivant le secteur et le local professionnel
CREATE TABLE G_DGFIP.TA_RVLLP_TARIF(
	fid_code NUMBER(38,0),
	fid_libelle VARCHAR2(2000),
	tarif NUMBER(10,3),
	fid_metadonnee NUMBER(38,0)
);

-- 1.2. Création des commentaires
COMMENT ON TABLE G_DGFIP.TA_RVLLP_TARIF IS 'La table TA_RVLLP_TARIF sert à indiquer pour chaque type de local professionnel le tarif de la Revision de la Valeur Locative des Locaux Professionnels suivant son secteur de la taxe dite RVLLP.';
COMMENT ON COLUMN G_DGFIP.TA_RVLLP_TARIF.FID_CODE IS 'Clé étrangère vers la table TA_CODE pour connaitre le secteur concerné par le tarif.';
COMMENT ON COLUMN G_DGFIP.TA_RVLLP_TARIF.FID_LIBELLE IS 'clé primaire vers la table TA_LIBELLE pour connaitre le local concerné par le tarif de la taxe.';
COMMENT ON COLUMN G_DGFIP.TA_RVLLP_TARIF.TARIF IS 'Tarif appliqué au local professionnel sur la section cadastrale considérée.';
COMMENT ON COLUMN G_DGFIP.TA_RVLLP_TARIF.fid_metadonnee IS 'Clé étrangère vers la table TA_METADONNEE pour connaitre les métadonnées de la source.';

-- 1.3. Création de la clé primaire
ALTER TABLE G_DGFIP.TA_RVLLP_TARIF
ADD CONSTRAINT ta_rvllp_PK 
PRIMARY KEY("FID_CODE","FID_LIBELLE","FID_METADONNEE")
USING INDEX TABLESPACE "G_ADT_INDX";

-- 1.4. Création des clé étrangère

-- 1.4.1. vers la table ta_libelle pour les occupations du sol
ALTER TABLE G_DGFIP.TA_RVLLP_TARIF
ADD CONSTRAINT "TA_RVLLP_TARIF_FID_CODE_FK" 
FOREIGN KEY ("FID_CODE")
REFERENCES G_GEO.TA_CODE(OBJECTID);

-- 1.4.2. vers la table ta_libelle pour les utilisations du sol
ALTER TABLE G_DGFIP.TA_RVLLP_TARIF
ADD CONSTRAINT "TA_RVLLP_FID_LIBELLE_FK" 
FOREIGN KEY ("FID_LIBELLE")
REFERENCES G_GEO.TA_LIBELLE(OBJECTID);

-- 1.4.3. vers la table ta_metadonnee pour les commentaires OCS2D
ALTER TABLE G_DGFIP.TA_RVLLP_TARIF
ADD CONSTRAINT "TA_RVLLP_FID_METADONNEE_FK" 
FOREIGN KEY ("FID_METADONNEE")
REFERENCES G_GEO.TA_METADONNEE(OBJECTID);