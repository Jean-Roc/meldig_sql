@echo off
echo Bienvenue dans la creation des tables, triggers, l import et le traitement des points de vigilance !

:: 1. Déclaration et valorisation des variables
SET /p chemin_import="Veuillez saisir le chemin d'accès du dossier contenant les donnees à importer :"
SET /p chemin_traitement="Veuillez saisir le chemin d'accès du dossier contenant les codes de traitement des points de vigilance :"
SET /p USER="Veuillez saisir l'utilisateur Oracle : "    
SET /p MDP="Veuillez saisir le MDP : "    
SET /p INSTANCE="Veuillez saisir l'instance Oracle :"     

:: 2. Concatenation des fichiers SQL en un seul pour pour permettre l'execution des commandes par Oracle
type %chemin_traitement%\Creation_structure_points_de_vigilance.sql > points_vigilance_temp.sql | echo. >> points_vigilance_temp.sql ^
| type %chemin_traitement%\declencheurs_points_de_vigilance.sql.sql >> points_vigilance_temp.sql | echo. >> points_vigilance_temp.sql ^
| type %chemin_traitement%\conversion_donnees_points_vigilance.sql.sql.sql >> points_vigilance_temp.sql | echo. >> points_vigilance_temp.sql

:: 2. Se mettre dans l'environnement de QGIS ;
c:
cd C:\Program Files\QGIS 3.10\bin

:: 3. Configurer le système d'encodage des caractères en UTF-8
SET NLS_LANG=AMERICAN_AMERICA.AL32UTF8

:: 4. Rediriger la variable PROJ_LIB vers le bon fichier proj.db afin qu'ogr2ogr trouve le bon scr
setx PROJ_LIB "C:\Program Files\QGIS 3.10\share\proj"

:: 5. Importer les données brutes en base
:: 5.1. Import des points de vigilance
ogr2ogr -f OCI OCI:%USER%/%MDP%@%INSTANCE% %chemin_import%\Point_interet_yann.shp -nln TEMP_POINT_VIGILANCE -nlt point -lco SRID=2154 -dim 2
ogr2ogr -f OCI -append OCI:%USER%/%MDP%@%INSTANCE% %chemin_import%\Point_interet.shp -nln TEMP_POINT_VIGILANCE -nlt point -lco SRID=2154 -dim 2

:: 6. Execution de sqlplus. pour lancer les requetes SQL.
sqlplus.exe %USER%/%MDP%@%INSTANCE% @%chemin_traitement%\points_vigilance_temp.sql

pause