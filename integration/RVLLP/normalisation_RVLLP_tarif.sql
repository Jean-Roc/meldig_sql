-- Fichier contenant les requêtes permettant la normalisation des données 

MERGE INTO TA_RVLLP_TARIF a
USING
	(
		-- sous requete pour selectionner la nomenclature des locaux professionnels
		WITH nomenclature AS
			(
				(
				SELECT 
				    ggp.fid_libelle_parent AS fid_libelle_niv_0,
				    gp.fid_libelle_parent AS fid_libelle_niv_1
				from
					ta_libelle_relation ggp
				INNER JOIN ta_libelle_relation gp ON ggp.fid_libelle_fils = gp.fid_libelle_parent
				)
			SELECT
				tl_niv_0.objectid AS objectid_niv_0,
				tlc_niv_0.valeur AS libelle_court_niv_0,
				tll_niv_0.valeur AS libelle_long_niv_0,
				tl_niv_1.objectid AS objectid_niv_1,
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
			),
		-- sous requete pour mettre les données de la table de recensement en forme avant leurs insertions. Metter les données dans une colonne plutot que d'avoir une colonne par secteur.
		tarif AS (
			SELECT
				"Catégorie",
				"Secteur",
				tarif
			FROM
				tarif
			UNPIVOT
				(tarif for ("Secteur") IN
				("secteur 1" AS 1,
				"secteur 2" AS 2,
				"secteur 3" AS 3,
				"secteur 4" AS 4,
				"secteur 5" AS 5,
				"secteur 6" AS 6))
				)
		SELECT
			a.objectid AS fid_code,
			nomenclature.objectid_niv_1 AS fid_libelle,
			tarif AS tarif,
			c.objectid AS fid_metadonnee
		FROM
			tarif 
		INNER JOIN G_GEO.TA_CODE a ON a.valeur = tarif.secteur
		INNER JOIN G_GEO.TA_LIBELLE b ON b.objectid = a.fid_libelle
		INNER JOIN G_GEO.TA_LIBELLE_LONG c ON c.objectid = b.fid_libelle_long
		INNER JOIN G_GEO.TA_FAMILLE_LIBELLE d ON d.fid_libelle_long = c.objectid
		INNER JOIN G_GEO.TA_FAMILLE e ON e.objetid = d.fid_famille
		INNER JOIN nomenclature ON nomenclature.libelle_court_niv_1 = tarif."Catégorie",
			G_GEO.TA_METADONNEE f
        INNER JOIN G_GEO.TA_SOURCE g ON g.objectid = f.fid_source
        INNER JOIN G_GEO.TA_DATE_ACQUISITION h ON f.fid_acquisition = h.objectid
        INNER JOIN G_GEO.TA_PROVENANCE i ON f.fid_provenance = i.objectid,
        INNER JOIN G_GEO.TA_METADONNEE_RELATION_ORGANISME j ON j.fid_metadonnee = f.objectid
        INNER JOIN G_GEO.TA_ORGANISME k ON k.objectid = j.fid_organisme
        WHERE
            b.nom_source = 'grille tarifaire RVLLP'
		AND
		    h.millesime IN ('01/01/2020')
		AND
		    c.date_acquisition = TO_DATE(SYSDATE,'dd/mm/yy')
        AND
            d.url = 'https://www.impots.gouv.fr/portail/revision-des-valeurs-locatives-des-locaux-professionnels'
        AND
            e.nom_organisme = 'Direction Générale des Finances Publiques'
        AND
			d.valeur = 'secteur'
		AND
			e.valeur = 'RVLLP'
	)b
ON(a.fid_code = b.fid_code
AND a.fid_libelle =b.fid_libelle
AND a.tarif = b.tarif
AND a.fid_metadonnee = b.fid_metadonnee)
WHEN NOT MATCHED THEN
INSERT(a.fid_code, a.fid_libelle, a.tarif, a.fid_metadonnee)
VALUES(b.fid_code, b.fid_libelle, b.tarif, b.fid_metadonnee)
;