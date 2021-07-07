@echo off
echo Bienvenue dans la mise à jour de la table TA_FAMILLE_LIBELLE !
echo PREREQUIS : avoir copié/collé les familles et les libelles du schéma de DEV vers velui de PROD pour les tables TA_FAMILLE, TA_LIBELLE_LONG et TA_LIBELLE.
echo Le projet qgis servant à cet effet s appelle transfert_famille_libelle_g_geo_maj.qgs et se trouve ici : UF_Acquisition\test_point_vigilance\projets_qgis

:: 1. Déclaration et valorisation des variables
SET /p chemin_traitement="Veuillez saisir le chemin d'accès du dossier contenant les codes à exécuter :"
SET /p USER="Veuillez saisir l'utilisateur Oracle : "    
SET /p MDP="Veuillez saisir le MDP : "    
SET /p INSTANCE="Veuillez saisir l'instance Oracle :"     

:: 7. Se mettre dans l'environnement SQL plus.
CD C:/ora12c/R1/BIN

:: 8. Lancement des requetes SQL.
sqlplus.exe %USER%/%MDP%@%INSTANCE% @%chemin_traitement%\maj_ta_famille_libelle.sql

pause