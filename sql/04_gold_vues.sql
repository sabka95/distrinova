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

CREATE OR ALTER VIEW gold.dim_date AS
SELECT date_jour, annee, mois, libelle_mois, debut_mois, annee_mois, trimestre,
       jour_semaine, est_ferie, est_jour_ouvre
FROM silver.calendrier;
GO
CREATE OR ALTER VIEW gold.dim_machine AS
SELECT m.id_machine, m.type_machine, m.modele, m.statut, m.date_installation, m.date_retrait,
       m.cout_mensuel_ht, s.id_site, s.raison_sociale, s.secteur, s.commune, s.departement,
       s.taux_commission, s.commercial
FROM silver.machines m
JOIN silver.sites s ON s.id_site = m.id_site;
GO
CREATE OR ALTER VIEW gold.dim_produit AS
SELECT id_produit, libelle, categorie, prix_achat_ht, prix_vente_ht, actif
FROM silver.produits;
GO
CREATE OR ALTER VIEW gold.dim_commercial AS
SELECT DISTINCT commercial
FROM silver.sites;
GO
CREATE OR ALTER VIEW gold.fact_ventes AS
SELECT id_transaction, date_vente, heure, id_machine, id_produit, moyen_paiement,
       quantite, montant_ht, cout_ht
FROM silver.ventes;
GO
CREATE OR ALTER VIEW gold.fact_interventions AS
SELECT id_ticket, CAST(date_ouverture AS date) AS date_ouverture, id_machine, type_panne,
       duree_h, cout_ht
FROM silver.interventions;
GO
CREATE OR ALTER VIEW gold.fact_visites AS
SELECT id_visite, date_visite, id_machine, valeur_perimes_ht
FROM silver.visites;
GO
CREATE OR ALTER VIEW gold.fact_couts_machine AS
SELECT m.id_machine, c.debut_mois AS mois, m.cout_mensuel_ht AS cout_ht
FROM silver.machines m
JOIN (SELECT DISTINCT debut_mois FROM silver.calendrier) c
  ON m.date_installation <= EOMONTH(c.debut_mois)
 AND (m.date_retrait IS NULL OR m.date_retrait >= c.debut_mois);
GO
CREATE OR ALTER VIEW gold.fact_objectifs AS
SELECT commercial, mois, objectif_ca_ht
FROM silver.objectifs;
GO

SELECT COUNT(*) AS nb_lignes,
       SUM(CASE WHEN YEAR(mois) = 2025 THEN cout_ht END) AS cout_2025
FROM gold.fact_couts_machine;
GO

