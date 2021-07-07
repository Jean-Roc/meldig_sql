/*
Requêtes permettant la suppression de tous les objets, et donc des données, liés aux points de vigilance (tables, contraintes, déclencheurs).
	1. Suppression de la table d'audit ;
	2. Suppression de la table des points de vigilance et de ses métadonnées spatiales ;
*/

-- 1. Suppression de la table d'audit ;
	DROP TABLE G_GESTIONGEO.TA_GG_POINT_VIGILANCE_AUDIT  CASCADE CONSTRAINTS;

-- 2. Suppression de la table des points de vigilance et de ses métadonnées spatiales ;
	DROP TABLE G_GESTIONGEO.TA_GG_POINT_VIGILANCE CASCADE CONSTRAINTS;

	DELETE 
	FROM 
		USER_SDO_GEOM_METADATA 
	WHERE 
		TABLE_NAME = 'TA_GG_POINT_VIGILANCE';
	COMMIT;
	/