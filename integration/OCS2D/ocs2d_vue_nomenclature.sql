-- Requete SQL créant deux vues synthétisant la nomenclature OCS2D. Ces vues simplifient la normalisation des données.

-- vue de la nomenclature v_nomenclature_ocs2d_usage
CREATE OR REPLACE VIEW v_nomenclature_ocs2d_usage AS
WITH cte1 AS
	(
	SELECT 
	    ggp.fid_libelle_parent AS fid_libelle_niv_0,
	    gp.fid_libelle_parent AS fid_libelle_niv_1,
	    p.fid_libelle_parent AS fid_libelle_niv_2,
	    p.fid_libelle_fils AS fid_libelle_niv_3
	FROM
	    ta_libelle_relation ggp
	INNER JOIN ta_libelle_relation gp
	ON ggp.fid_libelle_fils = gp.fid_libelle_parent
	INNER JOIN ta_libelle_relation p
	ON gp.fid_libelle_fils = p.fid_libelle_parent
	)
	SELECT
		cte1.fid_libelle_niv_0,
		tlc_niv_0.valeur AS libelle_court_niv_0,
		tll_niv_0.valeur AS libelle_long_niv_0,
		cte1.fid_libelle_niv_1,
		tlc_niv_0.valeur || tlc_niv_1.valeur AS libelle_court_niv_1,
		tll_niv_1.valeur AS libelle_long_niv_1,		
		cte1.fid_libelle_niv_2,
		tlc_niv_0.valeur || tlc_niv_1.valeur || '.' || tlc_niv_2.valeur AS libelle_court_niv_2,
		tll_niv_2.valeur AS libelle_long_niv_2,
		cte1.fid_libelle_niv_3,
		tlc_niv_0.valeur || tlc_niv_1.valeur || '.' || tlc_niv_2.valeur || '.' || tlc_niv_3.valeur AS libelle_court_niv_3,
		tll_niv_3.valeur AS libelle_long_niv_3
	FROM
		cte1 
	INNER JOIN ta_libelle_correspondance tc_niv_0 ON cte1.fid_libelle_niv_0 = tc_niv_0.fid_libelle 
	INNER JOIN ta_libelle_correspondance tc_niv_1 ON cte1.fid_libelle_niv_1 = tc_niv_1.fid_libelle
	INNER JOIN ta_libelle_correspondance tc_niv_2 ON cte1.fid_libelle_niv_2 = tc_niv_2.fid_libelle
	INNER JOIN ta_libelle_correspondance tc_niv_3 ON cte1.fid_libelle_niv_3 = tc_niv_3.fid_libelle
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
    tf_niv_0.valeur = 'OCS2D: usage du sol'
    AND
    tf_niv_1.valeur = 'OCS2D: usage du sol'
    AND
    tf_niv_2.valeur = 'OCS2D: usage du sol'
    AND
    tf_niv_3.valeur = 'OCS2D: usage du sol'
ORDER BY
	libelle_court_niv_0,
	libelle_court_niv_1,
	libelle_court_niv_2,
	libelle_court_niv_3;


-- vue de la nomenclature nomenclature_ocs2d_occupation
CREATE OR REPLACE VIEW v_nomenclature_ocs2d_occupation AS
WITH cte1 AS
	(
	SELECT 
	    ggp.fid_libelle_parent AS fid_libelle_niv_0,
	    gp.fid_libelle_parent AS fid_libelle_niv_1,
	    p.fid_libelle_parent AS fid_libelle_niv_2,
	    p.fid_libelle_fils AS fid_libelle_niv_3
	FROM
	    ta_libelle_relation ggp
	INNER JOIN ta_libelle_relation gp
	ON ggp.fid_libelle_fils = gp.fid_libelle_parent
	INNER JOIN ta_libelle_relation p
	ON gp.fid_libelle_fils = p.fid_libelle_parent
	)
	select
		cte1.fid_libelle_niv_0,
		tlc_niv_0.valeur AS libelle_court_niv_0,
		tll_niv_0.valeur AS libelle_long_niv_0,
		cte1.fid_libelle_niv_1,
		tlc_niv_0.valeur || tlc_niv_1.valeur AS libelle_court_niv_1,
		tll_niv_1.valeur AS libelle_long_niv_1,		
		cte1.fid_libelle_niv_2,
		tlc_niv_0.valeur || tlc_niv_1.valeur || '.' ||tlc_niv_2.valeur AS libelle_court_niv_2,
		tll_niv_2.valeur AS libelle_long_niv_2,
		cte1.fid_libelle_niv_3,
		tlc_niv_0.valeur || tlc_niv_1.valeur || '.' || tlc_niv_2.valeur || '.' || tlc_niv_3.valeur AS libelle_court_niv_3,
		tll_niv_3.valeur AS libelle_long_niv_3
	FROM
		cte1 
	INNER JOIN ta_libelle_correspondance tc_niv_0 ON cte1.fid_libelle_niv_0 = tc_niv_0.fid_libelle 
	INNER JOIN ta_libelle_correspondance tc_niv_1 ON cte1.fid_libelle_niv_1 = tc_niv_1.fid_libelle
	INNER JOIN ta_libelle_correspondance tc_niv_2 ON cte1.fid_libelle_niv_2 = tc_niv_2.fid_libelle
	INNER JOIN ta_libelle_correspondance tc_niv_3 ON cte1.fid_libelle_niv_3 = tc_niv_3.fid_libelle
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
    tlc_niv_0.valeur = 'CS'
    AND
    tf_niv_0.valeur = 'OCS2D: couvert du sol'
    AND
    tf_niv_1.valeur = 'OCS2D: couvert du sol'
    AND
    tf_niv_2.valeur = 'OCS2D: couvert du sol'
    AND
    tf_niv_3.valeur = 'OCS2D: couvert du sol'
ORDER BY
	libelle_court_niv_0,
	libelle_court_niv_1,
	libelle_court_niv_2,
	libelle_court_niv_3;