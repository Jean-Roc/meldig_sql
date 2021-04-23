-- Requete sql necessaire à la normalisation des données RVLLP.

-- 1. Renommage des colonnes de la table des données d'import RVLLP
ALTER TABLE RVLLP RENAME COLUMN "Code commune" TO code_commune; 
ALTER TABLE RVLLP RENAME COLUMN "Préfixe" TO pre;
ALTER TABLE RVLLP RENAME COLUMN "Libellé de commune" TO nom_commune;


-- 2. Mise à jour du champs prefixe afin d'ajouter '000' aux lignes où la valeur est NULL
UPDATE RVLLP
SET PRE = '000'
WHERE PRE IS NULL;

-- 3. Ajout d'une colonne code_com pour avoir les codes au type caracère et au format XXX
-- 3.1. Ajout d'une colonne code_com pour avoir les codes au type caractère
ALTER TABLE RVLLP
ADD CODE_COM CHAR(3 BYTE);

-- 3.2. Mise des codes au format XXX 
UPDATE RVLLP
SET CODE_COM = 
                CASE 
                    WHEN LENGTH(code_commune) = 1 THEN '00' || CAST(code_commune AS VARCHAR2(3))
                    WHEN LENGTH(code_commune) = 2 THEN '0' || CAST(code_commune AS VARCHAR2(3))
                    WHEN LENGTH(code_commune) = 3 THEN CAST(code_commune AS VARCHAR2(3))
                END;

-- 4. Normalisation des données dans la table TA_RVLLP
MERGE INTO TA_RVLLP a
USING
	(
		SELECT
			a.IDU AS FID_IDU,
			c.objectid AS FID_CODE_RVLLP,
			m.objectid AS FID_METADONNEE
		FROM
			SECTION_CADASTRALE_LMCU a
			RIGHT JOIN G_DGFIP.RVLLP b ON b.CODE_COM = a.CODE_COM
			INNER JOIN G_GEO.TA_CODE c ON c.valeur = b.secteur
			INNER JOIN G_GEO.TA_LIBELLE l ON l.objectid = c.fid_libelle
			INNER JOIN G_GEO.TA_LIBELLE_LONG ll ON ll.objectid = l.fid_libelle_long
			INNER JOIN G_GEO.TA_FAMILLE_LIBELLE fl ON fl.fid_libelle_long = ll.objectid
			INNER JOIN G_GEO.TA_FAMILLE f ON f.objectid = fl.fid_famille,
			G_GEO.TA_METADONNE m
			INNER JOIN G_GEO.TA_RELATION_ORGANISME ro ON ro.fid_metadonnee = m.objectid
			INNER JOIN G_GEO.TA_ORGANISME o ON o.objectid = ro.fid_organisme
			INNER JOIN G_GEO.TA_SOURCE s ON s.objectid = m.fid_source
			INNER JOIN G_GEO.TA_DATE_ACQUISITION da ON da.objectid = m.fid_acquisition
		WHERE
		    b."Section" IS NULL
		AND UPPER(f.valeur) = 'RVLLP'
		AND UPPER(ll.valeur) = 'SECTEUR'
		AND UPPER(o.valeur)= 'DGFIP'
		AND 
			m.objectid IN
			(
			SELECT
			    a.objectid AS id_mtd
			FROM
			    ta_metadonnee a
			    INNER JOIN ta_source b ON a.fid_source = b.objectid
			    INNER JOIN ta_date_acquisition c ON c.objectid = a.fid_acquisition
			WHERE
			    c.millesime IN(
			                SELECT
			                    MAX(b.millesime) as MILLESIME
			                FROM
			                    ta_metadonnee a
			                INNER JOIN ta_date_acquisition  b ON a.fid_acquisition = b.objectid 
			                INNER JOIN ta_source c ON c.objectid = a.fid_source
			                WHERE
			                	UPPER(s.nom_source) = 'RVLLP'
			                )
		AND
		    UPPER(s.nom_source) = 'RVLLP'
		UNION ALL SELECT
			a.IDU AS FID_IDU,
			c.objectid AS FID_CODE_RVLLP,
			m.objectid AS FID_METADONNEE
		FROM
			SECTION_CADASTRALE_LMCU a
			RIGHT JOIN G_DGFIP.RVLLP b ON (b.CODE_COM = a.CODE_COM
		                            	AND b.pre = a.pre
		                            	AND b."Section" = a.section)
			INNER JOIN G_GEO.TA_CODE c ON c.valeur = b.secteur
			INNER JOIN G_GEO.TA_LIBELLE l ON l.objectid = c.fid_libelle
			INNER JOIN G_GEO.TA_LIBELLE_LONG ll ON ll.objectid = l.fid_libelle_long
			INNER JOIN G_GEO.TA_FAMILLE_LIBELLE fl ON fl.fid_libelle_long = ll.objectid
			INNER JOIN G_GEO.TA_FAMILLE f ON f.objectid = fl.fid_famille,
			G_GEO.TA_METADONNE m
			INNER JOIN G_GEO.TA_RELATION_ORGANISME ro ON ro.fid_metadonnee = m.objectid
			INNER JOIN G_GEO.TA_ORGANISME o ON o.objectid = ro.fid_organisme
			INNER JOIN G_GEO.TA_SOURCE s ON s.objectid = m.fid_source
			INNER JOIN G_GEO.TA_DATE_ACQUISITION da ON da.objectid = m.fid_acquisition
		WHERE
		    b."Section" IS NOT NULL
		AND UPPER(f.valeur) = 'RVLLP'
		AND UPPER(ll.valeur) = 'SECTEUR'
		AND UPPER(o.valeur)= 'DGFIP'
		AND 
			m.objectid IN
			(
			SELECT
			    a.objectid AS id_mtd
			FROM
			    ta_metadonnee a
			    INNER JOIN ta_source b ON a.fid_source = b.objectid
			    INNER JOIN ta_date_acquisition c ON c.objectid = a.fid_acquisition
			WHERE
			    c.millesime IN(
			                SELECT
			                    MAX(b.millesime) as MILLESIME
			                FROM
			                    ta_metadonnee a
			                INNER JOIN ta_date_acquisition  b ON a.fid_acquisition = b.objectid 
			                INNER JOIN ta_source c ON c.objectid = a.fid_source
			                WHERE
			                	UPPER(s.nom_source) = 'RVLLP'
			                )
		AND
		    UPPER(s.nom_source) = 'RVLLP'
	)b
ON (a.fid_idu = b.fid_idu
AND a.fid_code_rvllp = b.fid_code_rvllp
AND a.fid_metadonnee = b.fid_metadonnee)
WHEN NOT MATCHED THEN
INSERT (a.fid_idu,a.fid_code,a.fid_code_rvllp,a.fid_metadonnee)
VALUES (b.fid_idu,b.fid_code,b.fid_code_rvllp,b.fid_metadonnee)
;