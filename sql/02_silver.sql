/* =====================================================================
   DistriNova | 02 - Couche SILVER : tables typées et nettoyées
   ---------------------------------------------------------------------
   À compléter avec le guide (séances 8 et 9).
   Principe : une table silver par source, créée par SELECT ... INTO
   depuis le bronze, avec des types SQL corrects et une clé primaire.
   Rappels de conversion :
     - date française (jj/mm/aaaa)      : TRY_CONVERT(date, x, 103)
     - date et heure françaises          : TRY_CONVERT(datetime2(0), x, 103)
     - date ISO (aaaa-mm-jj hh:mi:ss)    : TRY_CONVERT(datetime2(0), x, 120)
     - nombre à virgule décimale         : TRY_CONVERT(decimal(10,2), REPLACE(x, ',', '.'))
     - vide -> NULL                      : NULLIF(x, '')
   ===================================================================== */
USE DistriNova;
GO

/* ---------- 2.2 Référentiels ----------
   silver.sites      (26 lignes, PK id_site)
   silver.machines   (43 lignes, PK id_machine)
   silver.produits   (39 lignes, PK id_produit)
   silver.objectifs  (72 lignes)
   silver.visites    (5 211 lignes, PK id_visite)
   Contrôle : 0 valeur devenue NULL à la conversion alors que le texte n'était pas vide. */

DROP TABLE IF EXISTS silver.sites;
SELECT
    id_site,
    raison_sociale,
    secteur,
    commune,
    code_postal,
    departement,
    TRY_CONVERT(int, NULLIF(effectif, '')) AS effectif,
    TRY_CONVERT(date, NULLIF(date_debut_contrat, ''), 103) AS date_debut_contrat,
    TRY_CONVERT(date, NULLIF(date_fin_contrat, ''), 103) AS date_fin_contrat,
    TRY_CONVERT(decimal(5,4), REPLACE(taux_commission, ',', '.')) AS taux_commission,
    commercial
INTO silver.sites
FROM bronze.sites;
GO
ALTER TABLE silver.sites ALTER COLUMN id_site NVARCHAR(10) NOT NULL;
GO
ALTER TABLE silver.sites ADD CONSTRAINT PK_sites PRIMARY KEY (id_site);
GO
DROP TABLE IF EXISTS silver.machines;
SELECT
    id_machine,
    num_serie,
    type_machine,
    modele,
    id_site,
    TRY_CONVERT(date, NULLIF(date_installation, ''), 103) AS date_installation,
    TRY_CONVERT(date, NULLIF(date_retrait, ''), 103) AS date_retrait,
    TRY_CONVERT(decimal(10,2), REPLACE(cout_mensuel_ht, ',', '.')) AS cout_mensuel_ht,
    statut
INTO silver.machines
FROM bronze.machines;
GO
ALTER TABLE silver.machines ALTER COLUMN id_machine NVARCHAR(10) NOT NULL;
GO
ALTER TABLE silver.machines ADD CONSTRAINT PK_machines PRIMARY KEY (id_machine);
GO
DROP TABLE IF EXISTS silver.produits;
SELECT
    id_produit,
    libelle,
    categorie,
    TRY_CONVERT(decimal(10,2), REPLACE(prix_achat_ht, ',', '.')) AS prix_achat_ht,
    TRY_CONVERT(decimal(10,2), REPLACE(prix_vente_ht, ',', '.')) AS prix_vente_ht,
    actif
INTO silver.produits
FROM bronze.produits;
GO
ALTER TABLE silver.produits ALTER COLUMN id_produit NVARCHAR(10) NOT NULL;
GO
ALTER TABLE silver.produits ADD CONSTRAINT PK_produits PRIMARY KEY (id_produit);
GO
DROP TABLE IF EXISTS silver.objectifs;
SELECT
    commercial,
    TRY_CONVERT(date, mois, 103) AS mois,
    TRY_CONVERT(decimal(12,2), REPLACE(objectif_ca_ht, ',', '.')) AS objectif_ca_ht
INTO silver.objectifs
FROM bronze.objectifs;
GO
DROP TABLE IF EXISTS silver.visites;
SELECT
    id_visite,
    id_machine,
    TRY_CONVERT(date, date_visite, 23) AS date_visite,
    technicien,
    TRY_CONVERT(int, duree_min) AS duree_min,
    TRY_CONVERT(int, nb_articles_charges) AS nb_articles_charges,
    TRY_CONVERT(decimal(10,2), valeur_perimes_ht) AS valeur_perimes_ht
INTO silver.visites
FROM bronze.visites_reassort;
GO
ALTER TABLE silver.visites ALTER COLUMN id_visite NVARCHAR(20) NOT NULL;
GO
ALTER TABLE silver.visites ADD CONSTRAINT PK_visites PRIMARY KEY (id_visite);
GO

/* Contrôle : nombre de lignes et conversions ratées (attendu : 0 partout) */
SELECT 'silver.sites' AS table_silver, COUNT(*) AS nb_lignes,
       SUM(CASE WHEN date_debut_contrat IS NULL OR taux_commission IS NULL THEN 1 ELSE 0 END) AS conversions_ratees
FROM silver.sites
UNION ALL
SELECT 'silver.machines', COUNT(*),
       SUM(CASE WHEN date_installation IS NULL OR cout_mensuel_ht IS NULL THEN 1 ELSE 0 END)
FROM silver.machines
UNION ALL
SELECT 'silver.produits', COUNT(*),
       SUM(CASE WHEN prix_achat_ht IS NULL OR prix_vente_ht IS NULL THEN 1 ELSE 0 END)
FROM silver.produits
UNION ALL
SELECT 'silver.objectifs', COUNT(*),
       SUM(CASE WHEN mois IS NULL OR objectif_ca_ht IS NULL THEN 1 ELSE 0 END)
FROM silver.objectifs
UNION ALL
SELECT 'silver.visites', COUNT(*),
       SUM(CASE WHEN date_visite IS NULL OR valeur_perimes_ht IS NULL THEN 1 ELSE 0 END)
FROM silver.visites;
GO



/* ---------- 2.3 Interventions ----------
   Dédoublonnage : ROW_NUMBER() OVER (PARTITION BY id_ticket ORDER BY date_cloture DESC) = 1
   duree_h : NULL si clôture absente ou antérieure à l'ouverture.
   Attendu : 311 tickets ; 2 ouverts ; 3 durées invalides ; coût total 48 117,60 €. */

DROP TABLE IF EXISTS silver.interventions;
WITH typees AS (
    SELECT
        id_ticket,
        id_machine,
        TRY_CONVERT(datetime2(0), NULLIF(date_ouverture, ''), 103) AS date_ouverture,
        TRY_CONVERT(datetime2(0), NULLIF(date_cloture, ''), 103) AS date_cloture,
        type_panne,
        technicien,
        TRY_CONVERT(decimal(10,2), REPLACE(NULLIF(cout_ht, ''), ',', '.')) AS cout_ht
    FROM bronze.interventions
),
classees AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY id_ticket ORDER BY date_cloture DESC) AS rang
    FROM typees
)
SELECT
    id_ticket,
    id_machine,
    date_ouverture,
    date_cloture,
    type_panne,
    technicien,
    cout_ht,
    CASE WHEN date_cloture >= date_ouverture
         THEN DATEDIFF(MINUTE, date_ouverture, date_cloture) / 60.0
    END AS duree_h
INTO silver.interventions
FROM classees
WHERE rang = 1;
GO

SELECT COUNT(*) AS nb_tickets,
       SUM(CASE WHEN date_cloture IS NULL THEN 1 ELSE 0 END) AS tickets_ouverts,
       SUM(CASE WHEN date_cloture < date_ouverture THEN 1 ELSE 0 END) AS durees_invalides,
       SUM(cout_ht) AS cout_total,
       SUM(CASE WHEN YEAR(date_ouverture) = 2025 THEN cout_ht END) AS cout_2025
FROM silver.interventions;
GO



/* ---------- 2.4 Ventes (table matérialisée + index) ----------
   Règles : dédoublonner sur id_transaction ; exclure TEST01 ; exclure les horodatages
   avant 2024 ; reconstituer id_produit vide d'après le prix (annexe A) ;
   montant_ht = quantite * prix_unitaire_ht ; garder les remboursements ;
   cout_ht = quantite * prix d'achat du produit.
   Attendu : 497 728 -> 494 760 -> 494 638 -> 494 596 lignes ; 283 produits reconstitués ;
   1 969 remboursements ; CA 2024 = 237 674,30 € ; CA 2025 = 262 119,10 €. */

/* Entonnoir : 497 728 -> 494 760 -> 494 638 -> 494 596 */
WITH numerotees AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY id_transaction ORDER BY id_transaction) AS rang
    FROM bronze.telemetrie_transactions
)
SELECT
    COUNT(*) AS lignes_brutes,
    SUM(CASE WHEN rang = 1 THEN 1 ELSE 0 END) AS apres_dedoublonnage,
    SUM(CASE WHEN rang = 1 AND id_machine NOT LIKE 'TEST%' THEN 1 ELSE 0 END) AS sans_machine_test,
    SUM(CASE WHEN rang = 1 AND id_machine NOT LIKE 'TEST%' AND horodatage >= '2024-01-01' THEN 1 ELSE 0 END) AS sans_dates_1970
FROM numerotees;
GO

DROP TABLE IF EXISTS silver.ventes;
WITH numerotees AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY id_transaction ORDER BY id_transaction) AS rang
    FROM bronze.telemetrie_transactions
),
typees AS (
    SELECT
        id_transaction,
        id_machine,
        NULLIF(id_produit, '') AS id_produit,
        TRY_CONVERT(datetime2(0), horodatage, 120) AS horodatage,
        TRY_CONVERT(int, quantite) AS quantite,
        TRY_CONVERT(decimal(10,2), prix_unitaire_ht) AS prix_unitaire_ht,
        moyen_paiement
    FROM numerotees
    WHERE rang = 1
),
corrigees AS (
    SELECT
        id_transaction,
        id_machine,
        COALESCE(id_produit,
                 CASE prix_unitaire_ht WHEN 1.30 THEN 'P025' WHEN 1.20 THEN 'P030' END) AS id_produit,
        horodatage,
        quantite,
        prix_unitaire_ht,
        moyen_paiement
    FROM typees
    WHERE id_machine NOT LIKE 'TEST%'
      AND horodatage >= '2024-01-01'
)
SELECT
    c.id_transaction,
    c.id_machine,
    c.id_produit,
    c.horodatage,
    CAST(c.horodatage AS date) AS date_vente,
    DATEPART(HOUR, c.horodatage) AS heure,
    c.quantite,
    c.prix_unitaire_ht,
    CAST(c.quantite * c.prix_unitaire_ht AS decimal(10,2)) AS montant_ht,
    CAST(c.quantite * p.prix_achat_ht AS decimal(10,2)) AS cout_ht,
    c.moyen_paiement
INTO silver.ventes
FROM corrigees c
LEFT JOIN silver.produits p ON p.id_produit = c.id_produit;
GO
CREATE INDEX IX_ventes_machine_date ON silver.ventes (id_machine, date_vente);
GO

SELECT
    COUNT(*) AS nb_lignes,
    SUM(CASE WHEN quantite < 0 THEN 1 ELSE 0 END) AS remboursements,
    SUM(CASE WHEN id_produit IS NULL THEN 1 ELSE 0 END) AS produits_manquants,
    SUM(CASE WHEN YEAR(date_vente) = 2024 THEN montant_ht END) AS ca_2024,
    SUM(CASE WHEN YEAR(date_vente) = 2025 THEN montant_ht END) AS ca_2025
FROM silver.ventes;
GO

