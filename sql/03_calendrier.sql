/* =====================================================================
   DistriNova | 03 - Calendrier (silver.calendrier)
   ---------------------------------------------------------------------
   À compléter avec le guide (séance 9).
   - CTE récursive du 2024-01-01 au 2025-12-31, terminée par OPTION (MAXRECURSION 0)
   - colonnes : date_jour, annee, mois, libelle_mois, debut_mois, annee_mois,
     trimestre, jour_semaine (lundi = 1), est_ferie, est_jour_ouvre
   - jour de la semaine indépendant des réglages du serveur :
       (DATEPART(weekday, d) + @@DATEFIRST - 2) % 7 + 1
   - jours fériés : les 22 dates de l'annexe A du guide
   Attendu : 731 lignes ; 252 jours ouvrés en 2024 ; 251 en 2025.
   ===================================================================== */
USE DistriNova;
GO

-- TODO
