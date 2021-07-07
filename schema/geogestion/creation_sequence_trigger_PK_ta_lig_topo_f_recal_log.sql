/*
Objectif : Créer la séquence et le trigger d'incrémentation de la PK de la table GEO.TA_LIG_TOPO_F_RECAL_LOG.
*/

-- Création de la séquence SEQ_TA_LIG_TOPO_F_RECAL_LOG
CREATE SEQUENCE GEO.SEQ_TA_LIG_TOPO_F_RECAL_LOG  INCREMENT BY 1 START WITH 1 ;

/

-- Création du trigger BEF_TA_LIG_TOPO_F_RECAL_LOG
create or replace TRIGGER GEO.BEF_TA_LIG_TOPO_F_RECAL_LOG
BEFORE INSERT ON GEO.TA_LIG_TOPO_F_RECAL_LOG
FOR EACH ROW

BEGIN
  :new.OBJECTID := SEQ_TA_LIG_TOPO_F_RECAL_LOG.nextval;
END;