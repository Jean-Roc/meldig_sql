@echo off
echo Bienvenu dans l import de la nomenclature des points de vigilance !

:: 1. Déclaration et valorisation des variables
SET /p chemin_import="Veuillez saisir le chemin d'accès du dossier contenant les donnees à importer :"
SET /p USER="Veuillez saisir l'utilisateur Oracle : "    
SET /p MDP="Veuillez saisir le MDP : "    
SET /p INSTANCE="Veuillez saisir l'instance Oracle :"     

:: 2. Se mettre dans l'environnement de QGIS ;
c:
cd C:\Program Files\QGIS 3.10\bin

:: 3. Configurer le système d'encodage des caractères en UTF-8
SET NLS_LANG=AMERICAN_AMERICA.AL32UTF8

:: 4. Rediriger la variable PROJ_LIB vers le bon fichier proj.db afin qu'ogr2ogr trouve le bon scr
setx PROJ_LIB "C:\Program Files\QGIS 3.10\share\proj"

:: 5. Import de la nomenclature
ogr2ogr -f OCI OCI:%USER%/%MDP%@%INSTANCE% %chemin_import%\TEMP_FAMILLE.csv -nln TEMP_FAMILLE_POINT_VIGILANCE
ogr2ogr -f OCI OCI:%USER%/%MDP%@%INSTANCE% %chemin_import%\TEMP_LIBELLE.csv -nln TEMP_LIBELLE_POINT_VIGILANCE

pause