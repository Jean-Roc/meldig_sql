:: Fichier bat d'insertion des données du RPG sur le schéma CUDL

:: 1. Déclaration et valorisation des variables
SET /p chemin_traitement="Veuillez saisir le chemin d'accès du fichier de traitement des données du RPG traitement_rpg.sql : "
SET /p USER="Veuillez saisir l'utilisateur Oracle : "
SET /p MDP="Veuillez saisir le MDP : "
SET /p INSTANCE="Veuillez saisir l'instance Oracle :"

:: 2.  Deplacement de la commande dans le dossier de QGIS.
CD C:/Program Files/QGIS 3.10/bin

:: 3. Mise à jour de l'encodage en UTF-8.
SET NLS_LANG=AMERICAN_AMERICA.AL32UTF8

:: 4. Mise à jour de la variable PROJ_LIB pour indiquer le bon chemin vers le fichier proj.db
setx PROJ_LIB "C:\Program Files\QGIS 3.10\share\proj"

:: 5. Import des donnees.
:: 5.1. rpg2019_mel.shp
ogr2ogr.exe -f OCI OCI:%USER%/%MDP%@%INSTANCE% \\volt\infogeo\Donnees\Externe\DRAAF\RPG_2019\RPG\rpg2019_mel.shp -nlt multipolygon -nln RPG_2019_MEL -lco SRID=2154 -dim 2

:: 5.2. parcelles_instruites_2019_mel
ogr2ogr.exe -f OCI OCI:%USER%/%MDP%@%INSTANCE% \\volt\infogeo\Donnees\Externe\DRAAF\RPG_2019\RPG\parcelles_instruites_2019_mel.xlsx -nln RPG_PARC_INSTRUITES_2019_MEL

:: 5.3. pacage_formejuridique_mel
ogr2ogr.exe -f OCI OCI:%USER%/%MDP%@%INSTANCE% \\volt\infogeo\Donnees\Externe\DRAAF\RPG_2019\RPG\pacage_formejuridique_mel.csv -nln RPG_FORMEJURIDIQUE_2019_MEL

:: 5.4. ilots2019_description
ogr2ogr.exe -f OCI OCI:%USER%/%MDP%@%INSTANCE% \\volt\infogeo\Donnees\Externe\DRAAF\RPG_2019\RPG\ilots2019_description.xlsx -nln RPG_ILOTS_DESCRIPTION_2019_MEL

:: 5.5. aides_2ndpilier
ogr2ogr.exe -f OCI OCI:%USER%/%MDP%@%INSTANCE% \\volt\infogeo\Donnees\Externe\DRAAF\RPG_2019\RPG\aides_2ndpilier.xlsx -nln RPG_AIDES_2ND_PILIER_2019_MEL

:: 5.6. aides_1erpilier
ogr2ogr.exe -f OCI OCI:%USER%/%MDP%@%INSTANCE% \\volt\infogeo\Donnees\Externe\DRAAF\RPG_2019\RPG\aides_1erpilier.xlsx -nln RPG_AIDES_1ER_PILIER_2019_MEL

:: 6. Lancement de SQL plus
CD C:/ora12c/R1/BIN

:: 7. Lancement des traitements sous sqlplus (clé primaire, indexes...)
sqlplus.exe %USER%/%MDP%@%INSTANCE% @%chemin_traitement%\traitement_rpg.sql