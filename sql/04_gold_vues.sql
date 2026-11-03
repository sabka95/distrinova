/* =====================================================================
   DistriNova | 04 - Couche GOLD : modèle en étoile (vues lues par Power BI)
   ---------------------------------------------------------------------
   À compléter avec le guide (séance 10). Une vue par table du modèle :
     gold.dim_date            1 ligne par jour
     gold.dim_machine         1 ligne par machine (+ site, secteur, commune, commercial, taux)
     gold.dim_produit         1 ligne par produit
     gold.dim_commercial      1 ligne par commercial (3)
     gold.fact_ventes         1 ligne par transaction
     gold.fact_interventions  1 ligne par ticket
     gold.fact_visites        1 ligne par passage de réassort
     gold.fact_couts_machine  1 ligne par machine et par mois où elle est installée
     gold.fact_objectifs      1 ligne par commercial et par mois
   Utilise CREATE OR ALTER VIEW pour pouvoir relancer le script.
   Attendu : gold.fact_couts_machine = 1 012 lignes ; somme 2025 = 39 060 €.
   ===================================================================== */
USE DistriNova;
GO

-- TODO
