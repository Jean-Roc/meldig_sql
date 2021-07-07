@echo off
echo Bienvenue dans le traitements des points de vigilance et leur insertion dans les tables finales !

:: 1. Déclaration et valorisation des variables
SET /p chemin_traitement="Veuillez saisir le chemin d'accès du dossier contenant les codes à exécuter :"
SET /p USER="Veuillez saisir l'utilisateur Oracle : "    
SET /p MDP="Veuillez saisir le MDP : "    
SET /p INSTANCE="Veuillez saisir l'instance Oracle :"     

:: 2. Concatener les fichiers de codes pour en permettre l'execution
type %chemin_traitement%\conversion_donnees_points_vigilance.sql > traitement_pts_vigilance_temp.sql | echo. >> traitement_pts_vigilance_temp.sql ^
| type %chemin_traitement%\suppression_tables_de_construction.sql >> traitement_pts_vigilance_temp.sql | echo. >> traitement_pts_vigilance_temp.sql

:: 7. Se mettre dans l'environnement SQL plus.
CD C:/ora12c/R1/BIN

:: 8. Lancement des requetes SQL.
sqlplus.exe %USER%/%MDP%@%INSTANCE% @%chemin_traitement%\traitement_pts_vigilance_temp.sql

pause