-- Création du trigger BEF_TA_POINT_TOPO_F_RECAL

/*
Objectif : créer un trigger d'incrémentation de la PK de la table GEO.TA_POINT_TOPO_F_RECAL, en utilisant la séquence TA_POINT_TOPO_F_SEQ utilisée pour incrémenter la PK de la table TA_POINT_TOPO_GPS. cela nous permet d'éviter les doublons de PK entre TA_POINT_TOPO_F_RECAL et TA_POINT_TOPO_F (dont les données proviennent de TA_POINT_TOPO_GPS).
*/

create or replace TRIGGER GEO.BEF_TA_POINT_TOPO_F_RECAL
BEFORE INSERT ON GEO.TA_POINT_TOPO_F_RECAL
FOR EACH ROW

BEGIN
  :new.OBJECTID := TA_POINT_TOPO_F_SEQ.nextval;
END;