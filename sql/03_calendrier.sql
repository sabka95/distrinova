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

DROP TABLE IF EXISTS silver.feries;
CREATE TABLE silver.feries (
    date_ferie DATE PRIMARY KEY,
    libelle NVARCHAR(50)
);
INSERT INTO silver.feries (date_ferie, libelle) VALUES
('2024-01-01', N'Jour de l''an'), ('2024-04-01', N'Lundi de Pâques'), ('2024-05-01', N'Fête du travail'),
('2024-05-08', N'Victoire 1945'), ('2024-05-09', N'Ascension'), ('2024-05-20', N'Lundi de Pentecôte'),
('2024-07-14', N'Fête nationale'), ('2024-08-15', N'Assomption'), ('2024-11-01', N'Toussaint'),
('2024-11-11', N'Armistice'), ('2024-12-25', N'Noël'),
('2025-01-01', N'Jour de l''an'), ('2025-04-21', N'Lundi de Pâques'), ('2025-05-01', N'Fête du travail'),
('2025-05-08', N'Victoire 1945'), ('2025-05-29', N'Ascension'), ('2025-06-09', N'Lundi de Pentecôte'),
('2025-07-14', N'Fête nationale'), ('2025-08-15', N'Assomption'), ('2025-11-01', N'Toussaint'),
('2025-11-11', N'Armistice'), ('2025-12-25', N'Noël');
GO
DROP TABLE IF EXISTS silver.calendrier;
WITH jours AS (
    SELECT CAST('2024-01-01' AS date) AS d
    UNION ALL
    SELECT DATEADD(DAY, 1, d) FROM jours WHERE d < '2025-12-31'
),
enrichis AS (
    SELECT d, (DATEPART(WEEKDAY, d) + @@DATEFIRST - 2) % 7 + 1 AS jour_semaine
    FROM jours
)
SELECT
    e.d AS date_jour,
    YEAR(e.d) AS annee,
    MONTH(e.d) AS mois,
    FORMAT(e.d, 'MMMM', 'fr-FR') AS libelle_mois,
    DATEFROMPARTS(YEAR(e.d), MONTH(e.d), 1) AS debut_mois,
    FORMAT(e.d, 'yyyy-MM') AS annee_mois,
    DATEPART(QUARTER, e.d) AS trimestre,
    e.jour_semaine,
    CASE WHEN f.date_ferie IS NOT NULL THEN 1 ELSE 0 END AS est_ferie,
    CASE WHEN e.jour_semaine <= 5 AND f.date_ferie IS NULL THEN 1 ELSE 0 END AS est_jour_ouvre
INTO silver.calendrier
FROM enrichis e
LEFT JOIN silver.feries f ON f.date_ferie = e.d
OPTION (MAXRECURSION 0);
GO

SELECT annee, COUNT(*) AS nb_jours, SUM(est_jour_ouvre) AS jours_ouvres, SUM(est_ferie) AS feries
FROM silver.calendrier
GROUP BY annee
ORDER BY annee;
GO

