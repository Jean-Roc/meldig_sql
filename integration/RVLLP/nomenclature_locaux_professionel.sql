-- Fichier regroupant les différentes requêtes nécessaires à l'insertion des éléments issus de la Base Permanente des Equipements BPE.


-- 1. Création de la vue G_GEO.BPE_NOMENCLATURE_LISTE pour simplifier son insertion
CREATE OR REPLACE VIEW G_GEO.NOMENCLATURE_LOCAUX_PROFESSIONNEL_LISTE AS
SELECT DISTINCT
	LC_niv_0 AS libelle_court, 
	LL_niv_0 AS libelle_long,
	'niv_0' AS niveau
FROM G_GEO.BPE_NOMENCLATURE
UNION ALL
SELECT DISTINCT
	LC_niv_1 AS libelle_court, 
	LL_niv_1 AS libelle_long,
	'niv_1' AS niveau
FROM G_GEO.BPE_NOMENCLATURE
;


-- 2. Insertion des libelles courts dans G_GEO.TA_LIBELLE_COURT
MERGE INTO G_GEO.TA_LIBELLE_COURT a
USING
	(
	SELECT DISTINCT
		libelle_court
	FROM
		G_GEO.NOMENCLATURE_LOCAUX_PROFESSIONNEL_LISTE
	) b
ON (UPPER(a.valeur) = UPPER(b.libelle_court))
WHEN NOT MATCHED THEN
INSERT (a.valeur)
VALUES (b.libelle_court)
;


-- 3. Insertion des libelles longs dans G_GEO.TA_LIBELLE_LONG
MERGE INTO G_GEO.TA_LIBELLE_LONG a
USING
	(
	SELECT DISTINCT
		libelle_long
	FROM
		G_GEO.NOMENCLATURE_LOCAUX_PROFESSIONNEL_LISTE
	) b
ON (UPPER(a.valeur) = UPPER(b.libelle_long))
WHEN NOT MATCHED THEN
INSERT (a.valeur)
VALUES (b.libelle_long)
;


-- 4. Insertion de la famille 'BPE' dans la table G_GEO.TA_FAMILLE
MERGE INTO TA_FAMILLE a
USING
	(
		SELECT 'catégories de locaux professionnels' AS VALEUR FROM DUAL
	)b
ON (UPPER(a.valeur) = UPPER(b.valeur))
WHEN NOT MATCHED THEN
INSERT (a.valeur)
VALUES (b.valeur)
;


-- 5. Insertion des relations familles-libelles dans G_GEO.TA_FAMILLE_LIBELLE
MERGE INTO TA_FAMILLE_LIBELLE a
USING
	(
	SELECT
		f.objectid fid_famille,
		l.objectid fid_libelle_long
    FROM
        G_GEO.TA_FAMILLE f,
        G_GEO.TA_LIBELLE_LONG l
	WHERE 
		f.valeur = 'catégories de locaux professionnels' AND
		l.valeur IN
			(
			SELECT DISTINCT
				libelle_long
			FROM
				G_GEO.NOMENCLATURE_LOCAUX_PROFESSIONNEL_LISTE
			)
		) b
ON (a.fid_famille = b.fid_famille
AND a.fid_libelle_long = b.fid_libelle_long)
WHEN NOT MATCHED THEN
INSERT (a.fid_famille,a.fid_libelle_long)
VALUES (b.fid_famille,b.fid_libelle_long)
;


-- 6. Creation d'une vue des relations entre les libelles 'BPE' pour faciliter l'insertion des libelles
CREATE OR REPLACE VIEW G_GEO.G_GEO.LOCAUX_PROFESSIONNEL_RELATION AS
SELECT DISTINCT
    lc_niv_1 AS lcf,
    ll_niv_1 AS llf,
    lc_niv_0 AS lcp,
    ll_niv_0 AS llp
FROM
	G_GEO.NOMENCLATURE_LOCAUX_PROFESSIONNEL
;


-- 7. creation de la table G_GEO.BPE_FUSION pour normaliser les données.
-- Cette table est nécessaire pour récuperer l'ensemble des objectids des libellés et ainsi pouvoir insérer en base les correspondances entres les libellés longs et libellés courts ainsi que les relations en les libellés fils et parents.
SET SERVEROUTPUT ON
DECLARE
--  variable pour récuperer le nom de la séquence de la table.
    v_sequence VARCHAR2(200);
-- corp de la procédure.
BEGIN
-- recupere le nom de la sequence
    BEGIN
    SELECT s.NAME INTO v_sequence
        FROM
           sys.IDNSEQ$ os
           INNER JOIN sys.obj$ t ON (t.obj# = os.obj#)
           INNER JOIN sys.obj$ s ON (s.obj# = os.seqobj#)
           INNER JOIN sys.col$ c ON (c.obj# = t.obj# AND c.col# = os.intcol#)
           INNER JOIN all_users u ON (u.user_id = t.owner#)
        WHERE t.NAME = 'G_GEO.TA_LIBELLE'
        AND u.username = 'G_GEO';
    DBMS_OUTPUT.PUT_LINE(v_sequence || '.nextval');
    END;
-- execution de la requete
    BEGIN
    EXECUTE IMMEDIATE
    'CREATE TABLE G_GEO.NOMENCLATURE_LOCAUX_PROFESSIONNEL_FUSION AS
    SELECT
    -- Attention à la séquence utilisée
          '||v_sequence||'.nextval as objectid,
    -- Attention à la séquence utilisée
          b.objectid AS fid_libelle_long,
          a.libelle_long,
          c.objectid AS fid_libelle_court,
          a.libelle_court,
          a.niveau
      FROM
          G_GEO.NOMENCLATURE_LOCAUX_PROFESSIONNEL_LISTE a
      JOIN
          G_GEO.TA_LIBELLE_LONG b ON b.valeur = a.libelle_long
      INNER JOIN G_GEO.TA_FAMILLE_LIBELLE d ON d.fid_libelle_long = b.objectid
      INNER JOIN G_GEO.TA_FAMILLE e ON e.objectid = d.fid_famille
      LEFT JOIN G_GEO.TA_LIBELLE_COURT c ON c.valeur = a.libelle_court
      WHERE
      	e.valeur = 'catégories de locaux professionnels'';
      END;
END;
/


-- 8. Insertion des 'objectid' et des 'fid_libelle_long' grâce à la table temporaire G_GEO.NOMENCLATURE_LOCAUX_PROFESSIONNEL_FUSION(voir 13., 14.)
MERGE INTO G_GEO.TA_LIBELLE a
USING
    (
    SELECT
        objectid, 
        fid_libelle_long
    FROM
        G_GEO.NOMENCLATURE_LOCAUX_PROFESSIONNEL_FUSION
    ) b
ON (a.objectid = b.objectid
AND a.fid_libelle_long = b.fid_libelle_long)
WHEN NOT MATCHED THEN
INSERT (a.objectid,a.fid_libelle_long)
VALUES (b.objectid,b.fid_libelle_long)
;


-- 9. Insertion des données dans G_GEO.TA_CORRESPONDANCE_LIBELLE grâce à la table temporaire G_GEO.BPE_FUSION(voir 13., 14.)
MERGE INTO G_GEO.TA_CORRESPONDANCE_LIBELLE a
USING
	(
	SELECT
		objectid,
		fid_libelle_court
	FROM
        G_GEO.NOMENCLATURE_LOCAUX_PROFESSIONNEL_FUSION
	) b
ON (a.fid_libelle = b.objectid
AND a.fid_libelle_court = b.fid_libelle_court)
WHEN NOT MATCHED THEN
INSERT (a.fid_libelle,a.fid_libelle_court)
VALUES (b.objectid,b.fid_libelle_court)
;


-- 10. Insertion des données dans ta_relation_libelle(hiérarchie des libelles comme par exemple A1(services publics > A101(police)) grâce à la table temporaire G_GEO.BPE_FUSION(voir 13., 14.)
MERGE INTO G_GEO.TA_LIBELLE_RELATION a
USING 
	(
	SELECT
	    a.objectid fid_libelle_fils,
        a.libelle_long libelle_long_fils,
        a.libelle_court libelle_court_fils,
	    b.objectid fid_libelle_parent,
        b.libelle_long libelle_long_parent,
        b.libelle_court libelle_court_parent
	FROM
	    G_GEO.NOMENCLATURE_LOCAUX_PROFESSIONNEL_FUSION a,
	    G_GEO.NOMENCLATURE_LOCAUX_PROFESSIONNEL_FUSION b,
	    G_GEO.LOCAUX_PROFESSIONNEL_RELATION c
	WHERE
	        a.libelle_court = c.lcf
	    AND
	        a.libelle_long = c.llf
	    AND
	        b.libelle_court =c.lcp
	    AND
	        b.libelle_long =c.llp
	    AND
	        (a.niveau = 'niv_1' AND b.niveau = 'niv_0')
    AND
    	a.objectid IN (SELECT objectid FROM G_GEO.TA_LIBELLE)
    AND
    	b.objectid IN (SELECT objectid FROM G_GEO.TA_LIBELLE)
	)b
ON (a.fid_libelle_fils = b.fid_libelle_fils
AND a.fid_libelle_parent = b.fid_libelle_parent)
WHEN NOT MATCHED THEN
INSERT (a.fid_libelle_fils,a.fid_libelle_parent)
VALUES (b.fid_libelle_fils,b.fid_libelle_parent)
;


-- 11. Suppression des tables temporaires créées pour insérer la nomenclature des locaux professionnels.
-- 11.1. Suppression de la table G_GEO.BPE_NOMENCLATURE
DROP TABLE G_GEO.NOMENCLATURE_LOCAUX_PROFESSIONNEL_FUSION cascade constraints;

-- 10.2. Suppression de la vue V_NOMENCLATURE_EQUIPEMENT_BPE
DROP VIEW G_GEO.NOMENCLATURE_LOCAUX_PROFESSIONNEL_LISTE;

-- 10.3. Suppression de la vue V_NOMENCLATURE_VARIABLE_BPE
DROP VIEW G_GEO.LOCAUX_PROFESSIONNEL_RELATION;