/* =====================================================================
   DistriNova | 07 - Contrôles qualité (à relancer après chaque modification)
   ---------------------------------------------------------------------
   Chaque requête doit renvoyer 0 ligne ou la valeur attendue indiquée.
   Idées de contrôles à écrire :
     - unicité des clés (id_site, id_machine, id_produit, id_ticket, id_transaction)
     - intégrité : toute machine pointe vers un site, toute vente vers une machine et un produit
     - conversions : aucune valeur NULL là où le texte bronze n'était pas vide
     - réconciliation : CA silver.ventes = CA gold.fact_ventes = somme des P&L par machine
     - cohérence : aucune vente hors de la période d'installation de sa machine
   ===================================================================== */
USE DistriNova;
GO

-- Attendu : 5 lignes à 0.
SELECT 'Doublons de machines' AS controle, COUNT(*) - COUNT(DISTINCT id_machine) AS anomalies FROM silver.machines
UNION ALL
SELECT 'Machines sans site', COUNT(*) FROM silver.machines m
 WHERE NOT EXISTS (SELECT 1 FROM silver.sites s WHERE s.id_site = m.id_site)
UNION ALL
SELECT 'Ventes sans produit', COUNT(*) FROM silver.ventes WHERE id_produit IS NULL
UNION ALL
SELECT 'Ventes hors période d''installation', COUNT(*) FROM silver.ventes v
  JOIN silver.machines m ON m.id_machine = v.id_machine
 WHERE v.date_vente < m.date_installation OR v.date_vente > COALESCE(m.date_retrait, '2099-12-31')
UNION ALL
SELECT 'Écart CA silver vs P&L 2025',
       CAST(ABS((SELECT SUM(montant_ht) FROM silver.ventes WHERE YEAR(date_vente) = 2025)
              - (SELECT SUM(ca) FROM gold.v_pnl_machine_annuel WHERE annee = 2025)) AS int);
GO

