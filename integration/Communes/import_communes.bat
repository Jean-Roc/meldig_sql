@echo off
echo Bienvenu dans l insertion des donnees des communes en base !
:: Import des communes reçues de l'IGN en base.

:: Déclaration et valorisation des variables
SET /p chemin_insertion="Veuillez saisir le chemin d'accès du dossier contenant TOUTES les communes de TOUS les départements : "    
SET /p USER="Veuillez saisir l'utilisateur Oracle : "    
SET /p MDP="Veuillez saisir le MDP : "    
SET /p INSTANCE="Veuillez saisir l'instance Oracle :"     

:: 1. Se mettre dans l'environnement de QGIS ;
c:
cd C:\Program Files\QGIS 3.10\bin

:: Configurer le système d'encodage des caractères en UTF-8
SET NLS_LANG=AMERICAN_AMERICA.AL32UTF8

:: Rediriger la variable PROJ_LIB vers le bon fichier proj.db afin qu'ogr2ogr trouve le bon scr
setx PROJ_LIB "C:\Program Files\QGIS 3.10\share\proj"

ogr2ogr -f OCI -sql "SELECT INSEE_COM, INSEE_DEP, NOM FROM COMMUNE WHERE INSEE_DEP = '02'" OCI:%USER%/%MDP%@%INSTANCE% %chemin_insertion%\02\COMMUNE.shp -nln TEMP_COMMUNES -nlt multipolygon -lco SRID=2154 -dim 2
ogr2ogr -f OCI -append -sql "SELECT INSEE_COM, INSEE_DEP, NOM FROM COMMUNE WHERE INSEE_DEP = '59'" OCI:%USER%/%MDP%@%INSTANCE% %chemin_insertion%\59\COMMUNE.shp -nln TEMP_COMMUNES -lco SRID=2154 -dim 2
ogr2ogr -f OCI -append -sql "SELECT INSEE_COM, INSEE_DEP, NOM FROM COMMUNE WHERE INSEE_DEP = '60'" OCI:%USER%/%MDP%@%INSTANCE% %chemin_insertion%\60\COMMUNE.shp -nln TEMP_COMMUNES -lco SRID=2154 -dim 2
ogr2ogr -f OCI -append -sql "SELECT INSEE_COM, INSEE_DEP, NOM FROM COMMUNE WHERE INSEE_DEP = '62'" OCI:%USER%/%MDP%@%INSTANCE% %chemin_insertion%\62\COMMUNE.shp -nln TEMP_COMMUNES -lco SRID=2154 -dim 2
ogr2ogr -f OCI -append -sql "SELECT INSEE_COM, INSEE_DEP, NOM FROM COMMUNE WHERE INSEE_DEP = '80'" OCI:%USER%/%MDP%@%INSTANCE% %chemin_insertion%\80\COMMUNE.shp -nln TEMP_COMMUNES -lco SRID=2154 -dim 2
pause