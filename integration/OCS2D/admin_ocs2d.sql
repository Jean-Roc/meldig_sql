-- Création de la vue présentant les données OCS2D au dernier millesime. 

-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW admin_ocs2d
	(
    identifiant,
    cs,
    us,
    indice,
    source,
    commentaire,
	metadonnee,
    geom,
    CONSTRAINT "admin_ocs2d_PK" PRIMARY KEY("IDENTIFIANT") DISABLE
	)
AS

-- Sous requête selection des différents usages des sols.
WITH 
	cte1 AS	(
	SELECT 
	    ggp.fid_libelle_parent AS fid_libelle_niv_0,
	    gp.fid_libelle_parent AS fid_libelle_niv_1,
	    p.fid_libelle_parent AS fid_libelle_niv_2,
	    p.fid_libelle_fils AS fid_libelle_niv_3
	FROM
	    ta_relation_libelle ggp
	INNER JOIN ta_relation_libelle gp
	ON ggp.fid_libelle_fils = gp.fid_libelle_parent
	INNER JOIN ta_relation_libelle p
	ON gp.fid_libelle_fils = p.fid_libelle_parent
	),
	usage AS
	(
	SELECT
		cte1.fid_libelle_niv_3,
		concat(tlc_niv_1.valeur,concat('.',concat(tlc_niv_2.valeur,concat('.',tlc_niv_3.valeur)))) AS libelle_court_niv_3,
		tll_niv_3.valeur AS libelle_long_niv_3
	FROM
		cte1 
	INNER JOIN ta_correspondance_libelle tc_niv_0 ON cte1.fid_libelle_niv_0 = tc_niv_0.fid_libelle 
	INNER JOIN ta_correspondance_libelle tc_niv_1 ON cte1.fid_libelle_niv_1 = tc_niv_1.fid_libelle
	INNER JOIN ta_correspondance_libelle tc_niv_2 ON cte1.fid_libelle_niv_2 = tc_niv_2.fid_libelle
	INNER JOIN ta_correspondance_libelle tc_niv_3 ON cte1.fid_libelle_niv_3 = tc_niv_3.fid_libelle
	INNER JOIN ta_libelle_court tlc_niv_0 ON tc_niv_0.fid_libelle_court = tlc_niv_0.objectid 
	INNER JOIN ta_libelle_court tlc_niv_1 ON tc_niv_1.fid_libelle_court = tlc_niv_1.objectid
	INNER JOIN ta_libelle_court tlc_niv_2 ON tc_niv_2.fid_libelle_court = tlc_niv_2.objectid
	INNER JOIN ta_libelle_court tlc_niv_3 ON tc_niv_3.fid_libelle_court = tlc_niv_3.objectid
	INNER JOIN ta_libelle tl_niv_0 ON cte1.fid_libelle_niv_0 = tl_niv_0.objectid
	INNER JOIN ta_libelle tl_niv_1 ON cte1.fid_libelle_niv_1 = tl_niv_1.objectid
	INNER JOIN ta_libelle tl_niv_2 ON cte1.fid_libelle_niv_2 = tl_niv_2.objectid
	INNER JOIN ta_libelle tl_niv_3 ON cte1.fid_libelle_niv_3 = tl_niv_3.objectid
	INNER JOIN ta_libelle_long tll_niv_0 ON tl_niv_0.fid_libelle_long = tll_niv_0.objectid
	INNER JOIN ta_libelle_long tll_niv_1 ON tl_niv_1.fid_libelle_long = tll_niv_1.objectid
	INNER JOIN ta_libelle_long tll_niv_2 ON tl_niv_2.fid_libelle_long = tll_niv_2.objectid
	INNER JOIN ta_libelle_long tll_niv_3 ON tl_niv_3.fid_libelle_long = tll_niv_3.objectid
	INNER JOIN ta_famille_libelle tfl_niv_0 ON tfl_niv_0.fid_libelle_long = tll_niv_0.objectid
	INNER JOIN ta_famille_libelle tfl_niv_1 ON tfl_niv_1.fid_libelle_long = tll_niv_1.objectid
	INNER JOIN ta_famille_libelle tfl_niv_2 ON tfl_niv_2.fid_libelle_long = tll_niv_2.objectid
	INNER JOIN ta_famille_libelle tfl_niv_3 ON tfl_niv_3.fid_libelle_long = tll_niv_3.objectid
	INNER JOIN ta_famille tf_niv_0 ON tfl_niv_0.fid_famille = tf_niv_0.objectid
	INNER JOIN ta_famille tf_niv_1 ON tfl_niv_1.fid_famille = tf_niv_1.objectid
	INNER JOIN ta_famille tf_niv_2 ON tfl_niv_2.fid_famille = tf_niv_2.objectid
	INNER JOIN
		ta_famille tf_niv_3 ON tfl_niv_3.fid_famille = tf_niv_3.objectid
	WHERE
	    tlc_niv_0.valeur = 'US'
	    AND
	    tf_niv_0.valeur = 'OCS2D'
	    AND
	    tf_niv_1.valeur = 'OCS2D'
	    AND
	    tf_niv_2.valeur = 'OCS2D'
	    AND
	    tf_niv_3.valeur = 'OCS2D'
	),
-- Sous requête selection des différents couverts des sols.
	cte2 AS (
	SELECT 
	    ggp.fid_libelle_parent AS fid_libelle_niv_0,
	    gp.fid_libelle_parent AS fid_libelle_niv_1,
	    p.fid_libelle_parent AS fid_libelle_niv_2,
	    p.fid_libelle_fils AS fid_libelle_niv_3
	FROM
	    ta_relation_libelle ggp
	INNER JOIN ta_relation_libelle gp
	ON ggp.fid_libelle_fils = gp.fid_libelle_parent
	INNER JOIN ta_relation_libelle p
	ON gp.fid_libelle_fils = p.fid_libelle_parent
	),
	couvert AS (
	SELECT
		cte2.fid_libelle_niv_3,
		concat(tlc_niv_1.valeur,concat('.',concat(tlc_niv_2.valeur,concat('.',tlc_niv_3.valeur)))) AS libelle_court_niv_3,
		tll_niv_3.valeur AS libelle_long_niv_3
	FROM
		cte2
	INNER JOIN ta_correspondance_libelle tc_niv_0 ON cte2.fid_libelle_niv_0 = tc_niv_0.fid_libelle 
	INNER JOIN ta_correspondance_libelle tc_niv_1 ON cte2.fid_libelle_niv_1 = tc_niv_1.fid_libelle
	INNER JOIN ta_correspondance_libelle tc_niv_2 ON cte2.fid_libelle_niv_2 = tc_niv_2.fid_libelle
	INNER JOIN ta_correspondance_libelle tc_niv_3 ON cte2.fid_libelle_niv_3 = tc_niv_3.fid_libelle
	INNER JOIN ta_libelle_court tlc_niv_0 ON tc_niv_0.fid_libelle_court = tlc_niv_0.objectid 
	INNER JOIN ta_libelle_court tlc_niv_1 ON tc_niv_1.fid_libelle_court = tlc_niv_1.objectid
	INNER JOIN ta_libelle_court tlc_niv_2 ON tc_niv_2.fid_libelle_court = tlc_niv_2.objectid
	INNER JOIN ta_libelle_court tlc_niv_3 ON tc_niv_3.fid_libelle_court = tlc_niv_3.objectid
	INNER JOIN ta_libelle tl_niv_0 ON cte2.fid_libelle_niv_0 = tl_niv_0.objectid
	INNER JOIN ta_libelle tl_niv_1 ON cte2.fid_libelle_niv_1 = tl_niv_1.objectid
	INNER JOIN ta_libelle tl_niv_2 ON cte2.fid_libelle_niv_2 = tl_niv_2.objectid
	INNER JOIN ta_libelle tl_niv_3 ON cte2.fid_libelle_niv_3 = tl_niv_3.objectid
	INNER JOIN ta_libelle_long tll_niv_0 ON tl_niv_0.fid_libelle_long = tll_niv_0.objectid
	INNER JOIN ta_libelle_long tll_niv_1 ON tl_niv_1.fid_libelle_long = tll_niv_1.objectid
	INNER JOIN ta_libelle_long tll_niv_2 ON tl_niv_2.fid_libelle_long = tll_niv_2.objectid
	INNER JOIN ta_libelle_long tll_niv_3 ON tl_niv_3.fid_libelle_long = tll_niv_3.objectid
	INNER JOIN ta_famille_libelle tfl_niv_0 ON tfl_niv_0.fid_libelle_long = tll_niv_0.objectid
	INNER JOIN ta_famille_libelle tfl_niv_1 ON tfl_niv_1.fid_libelle_long = tll_niv_1.objectid
	INNER JOIN ta_famille_libelle tfl_niv_2 ON tfl_niv_2.fid_libelle_long = tll_niv_2.objectid
	INNER JOIN ta_famille_libelle tfl_niv_3 ON tfl_niv_3.fid_libelle_long = tll_niv_3.objectid
	INNER JOIN ta_famille tf_niv_0 ON tfl_niv_0.fid_famille = tf_niv_0.objectid
	INNER JOIN ta_famille tf_niv_1 ON tfl_niv_1.fid_famille = tf_niv_1.objectid
	INNER JOIN ta_famille tf_niv_2 ON tfl_niv_2.fid_famille = tf_niv_2.objectid
	INNER JOIN ta_famille tf_niv_3 ON tfl_niv_3.fid_famille = tf_niv_3.objectid
	WHERE
    tlc_niv_0.valeur = 'CS'
	    AND
	    tf_niv_0.valeur = 'OCS2D'
	    AND
	    tf_niv_1.valeur = 'OCS2D'
	    AND
	    tf_niv_2.valeur = 'OCS2D'
	    AND
	    tf_niv_3.valeur = 'OCS2D'
	),
	-- Selection du dernier millesime
		millesime AS (
		SELECT 
			ocs2d.objectid AS OBJECTID,
			MAX(a.MILLESIME) AS MILLESIME
		FROM
			ta_ocs2d ocs2d
		-- métadonnée
		INNER JOIN ta_metadonnee m ON m.objectid = ocs2d.metadonnee
		INNER JOIN ta_source s ON s.objectid = m.fid_source
		INNER JOIN ta_provenance p ON p.objectid = m.fid_provenance
		INNER JOIN ta_date_acquisition a ON a.objectid = m.fid_acquisition
		INNER JOIN ta_organisme o ON o.objectid = m.fid_organisme
		INNER JOIN ta_echelle e ON e.objectid = m.fid_echelle
        GROUP BY ocs2d.objectid
	)
	-- Selection principale

	SELECT
    o.objectid AS identifiant,
	c.libelle_court_niv_3 AS cs,
	u.libelle_court_niv_3 AS us,
    oi.valeur AS indice,
    ocs.valeur AS source,
    ocm.valeur AS commentaire,
	CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(s.nom_source, ' - '),org.acronyme), ' - '),e.echelle), ' - '),ml.MILLESIME) AS metadonnee,
	og.geom
	FROM
	    ta_ocs2d o
	INNER JOIN usage u ON u.fid_libelle_niv_3= o.us
	INNER JOIN couvert c ON c.fid_libelle_niv_3 = o.cs
	INNER JOIN ta_ocs2d_indice oi ON oi.objectid = o.indice
	LEFT JOIN ta_ocs2d_relation_commentaire orc ON orc.fid_ocs2d = o.objectid
	LEFT JOIN ta_ocs2d_commentaire ocm ON ocm.objectid = orc.fid_ocs2d_commentaire
    INNER JOIN ta_ocs2d_source ocs ON ocs.objectid = o.source
	INNER JOIN ta_ocs2d_geom og ON og.objectid = o.geom
	INNER JOIN ta_metadonnee m on m.objectid = o.metadonnee
	INNER JOIN ta_source s ON s.objectid = m.fid_source
	INNER JOIN ta_organisme org ON org.objectid = m.fid_organisme
	INNER JOIN ta_date_acquisition d ON d.objectid = m.fid_acquisition
    INNER JOIN ta_echelle e ON e.objectid = m.fid_echelle
    INNER JOIN millesime ml ON ml.objectid = o.objectid
;


-- 2. Création des commentaires de table et de colonnes
COMMENT ON TABLE admin_ocs2d IS 'Vue proposant les communes actuelles de la MEL extraites de la BdTopo de l''IGN.';
COMMENT ON COLUMN admin_ocs2d.identifiant IS 'Clé primaire de la vue.';
COMMENT ON COLUMN admin_ocs2d.cs IS 'Code caractérisant le type de couvert du sol.';
COMMENT ON COLUMN admin_ocs2d.us IS 'Code caractérisant l''usage du sol.';
COMMENT ON COLUMN admin_ocs2d.indice IS 'Indice de la zone OCS2D.';
COMMENT ON COLUMN admin_ocs2d.source IS 'Donnée source utilisé pour la production de la donnée OCSD';
COMMENT ON COLUMN admin_ocs2d.commentaire IS 'Remarque sur le polygone OCS2D';
COMMENT ON COLUMN admin_ocs2d.metadonnee IS 'metadonnée de la vue';
COMMENT ON COLUMN admin_ocs2d.geom IS 'Géométrie de chaque polygone - de type polygone.';


-- 3. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'admin_ocs2d',
    'geom',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 594000, 964000, 0.005),SDO_DIM_ELEMENT('Y', 6987000, 7165000, 0.005)), 
    2154
);


-- 4. Création de l'index spatial
CREATE INDEX admin_ocs2d_SIDX
ON admin_ocs2d(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=POLYGON, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);