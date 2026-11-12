/* =====================================================================
   DistriNova | 06 - Vue de décision 2025 (gold.v_decision_2025)
   ---------------------------------------------------------------------
   À compléter avec le guide (séance 12). Une ligne par machine active,
   ses indicateurs 2025, l'action (première règle vraie) et le gain estimé.
     1. Remplacer            : 4 pannes de réfrigération ou plus en 2025
     2. Retirer              : marge contributive < 0 et CA < 3 500 €
     3. Renégocier           : taux de commission >= 10 % et marge < 15 % du CA
     4. Revoir l'assortiment : machine Combo et démarque frais > 15 %
     5. Surveiller           : marge < 10 % du CA
     6. Conserver            : le reste
   Attendu : 6 / 4 / 2 / 2 / 7 / 20 machines ; gain total = 12 934,41 €.
   ===================================================================== */
USE DistriNova;
GO

CREATE OR ALTER VIEW gold.v_decision_2025 AS
WITH pnl AS (
    SELECT *,
           CASE WHEN ca_frais > 0 THEN perimes / ca_frais END AS demarque_frais
    FROM gold.v_pnl_machine_annuel
    WHERE annee = 2025 AND statut = N'Active'
),
reference AS (
    SELECT AVG(maintenance) AS maintenance_frigovend
    FROM gold.v_pnl_machine_annuel
    WHERE annee = 2025 AND modele = N'FrigoVend 500'
),
actions AS (
    SELECT p.*, r.maintenance_frigovend,
           CASE
               WHEN p.nb_pannes_froid >= 4 THEN N'Remplacer'
               WHEN p.marge_contributive < 0 AND p.ca < 3500 THEN N'Retirer'
               WHEN p.taux_commission >= 0.10 AND p.marge_contributive < 0.15 * p.ca THEN N'Renégocier'
               WHEN p.type_machine = N'Combo' AND p.demarque_frais > 0.15 THEN N'Revoir l''assortiment'
               WHEN p.marge_contributive < 0.10 * p.ca THEN N'Surveiller'
               ELSE N'Conserver'
           END AS action
    FROM pnl p
    CROSS JOIN reference r
)
SELECT
    id_machine, raison_sociale, modele, ca, marge_contributive, nb_pannes_froid,
    taux_commission, demarque_frais, action,
    CASE action
        WHEN N'Remplacer' THEN maintenance - maintenance_frigovend - 300
        WHEN N'Retirer' THEN -marge_contributive
        WHEN N'Renégocier' THEN ca * (taux_commission - 0.06)
        WHEN N'Revoir l''assortiment' THEN 0.6 * perimes
        ELSE 0
    END AS gain_estime
FROM actions;
GO

SELECT action, COUNT(*) AS nb_machines, CAST(SUM(gain_estime) AS decimal(10,2)) AS gain_estime
FROM gold.v_decision_2025
GROUP BY action
ORDER BY gain_estime DESC;
GO
-- Résultat : 21 machines sur 41 appellent une action ; remplacer 6 CoolBox, retirer 4 machines, revoir 2 assortiments
-- et renégocier 2 commissions rapporterait 12 934,41 € par an (+28,7 % de marge).

/* Plan d'action machine par machine (Conserver exclu) */
SELECT id_machine, raison_sociale, modele, action, CAST(gain_estime AS decimal(10,2)) AS gain_estime
FROM gold.v_decision_2025
WHERE action <> N'Conserver'
ORDER BY gain_estime DESC;
GO

