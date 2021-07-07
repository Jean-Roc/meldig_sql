@echo off
echo Bienvenue dans la gestion des droits des points de vigilance !

:: 1. Déclaration et valorisation des variables
SET /p chemin_traitement="Veuillez saisir le chemin d'accès du dossier contenant les codes de traitement des points de vigilance :"
SET /p USER_DROITS="Veuillez saisir l'utilisateur Oracle dans lequel se situe la table a laquelle font reference les FK des pts de vigilance : "    
SET /p MDP_DROITS="Veuillez saisir le MDP : "    
SET /p INSTANCE_DROITS="Veuillez saisir l'instance Oracle :"    

:: 2. Execution de sqlplus. pour lancer les requetes SQL.
sqlplus.exe %USER_DROITS%/%MDP_DROITS%@%INSTANCE_DROITS% @%chemin_traitement%\gestion_des_droits_points_vigilance.sql

pause