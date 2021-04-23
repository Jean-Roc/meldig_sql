-- Creation de la vue restituant la nomenclature des catégories des locaux professionnels

REATE OR REPLACE VIEW V_NOMENCLATURE_EQUIPEMENT_BPE AS
WITH cte1 AS
	(
	SELECT 
	    ggp.fid_libelle_parent AS fid_libelle_niv_0,
	    gp.fid_libelle_parent AS fid_libelle_niv_1
	from
		ta_libelle_relation ggp
	INNER JOIN ta_libelle_relation gp ON ggp.fid_libelle_fils = gp.fid_libelle_parent
	)
	SELECT
		cte1.fid_libelle_niv_0,
		tlc_niv_0.valeur AS libelle_court_niv_0,
		tll_niv_0.valeur AS libelle_long_niv_0,
		cte1.fid_libelle_niv_1,
		tlc_niv_0.valeur || tlc_niv_1.valeur AS libelle_court_niv_1,
		tll_niv_1.valeur AS libelle_long_niv_1
	FROM
		cte1 
	INNER JOIN ta_libelle_correspondance tc_niv_0 ON cte1.fid_libelle_niv_0 = tc_niv_0.fid_libelle
	INNER JOIN ta_libelle_correspondance tc_niv_1 ON cte1.fid_libelle_niv_1 = tc_niv_1.fid_libelle
	INNER JOIN ta_libelle_court tlc_niv_0 ON tc_niv_0.fid_libelle_court = tlc_niv_0.objectid
	INNER JOIN ta_libelle_court tlc_niv_1 ON tc_niv_1.fid_libelle_court = tlc_niv_1.objectid
	INNER JOIN ta_libelle tl_niv_0 ON cte1.fid_libelle_niv_0 = tl_niv_0.objectid
	INNER JOIN ta_libelle tl_niv_1 ON cte1.fid_libelle_niv_1 = tl_niv_1.objectid
	INNER JOIN ta_libelle_long tll_niv_0 ON tl_niv_1.fid_libelle_long = tll_niv_0.objectid
	INNER JOIN ta_libelle_long tll_niv_1 ON tl_niv_1.fid_libelle_long = tll_niv_1.objectid
	INNER JOIN ta_famille_libelle tfl_niv_0 ON tfl_niv_0.fid_libelle_long = tll_niv_0.objectid    
	INNER JOIN ta_famille_libelle tfl_niv_1 ON tfl_niv_1.fid_libelle_long = tll_niv_1.objectid
	INNER JOIN ta_famille tf_niv_0 ON tfl_niv_0.fid_famille = tf_niv_0.objectid
	INNER JOIN ta_famille tf_niv_1 ON tfl_niv_1.fid_famille = tf_niv_1.objectid
WHERE
    tf_niv_0.valeur = 'catégories de locaux professionnels'
    AND
    tf_niv_1.valeur = 'catégories de locaux professionnels'
ORDER BY
	libelle_court_niv_0,
	libelle_court_niv_1
;