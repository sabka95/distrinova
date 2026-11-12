/* =====================================================================
   DistriNova | 05 - Analyses (guide, séance 11)
   ---------------------------------------------------------------------
   Une requête par question. Au-dessus de chacune : la question métier,
   les techniques utilisées et le résultat obtenu en une phrase.
   ===================================================================== */
USE DistriNova;
GO

/* Q1 - CA mensuel, variation vs mois précédent et vs même mois N-1, cumul annuel
   Techniques : LAG, LAG(..., 12), SUM() OVER (PARTITION BY ... ORDER BY ...)
   Contrôle : juin 2025 = 24 141,30 € (meilleur mois) ; juillet 2025 vs juillet 2024 = +6,97 % */

WITH ca_mensuel AS (
    SELECT DATEFROMPARTS(YEAR(date_vente), MONTH(date_vente), 1) AS mois,
           SUM(montant_ht) AS ca
    FROM silver.ventes
    GROUP BY DATEFROMPARTS(YEAR(date_vente), MONTH(date_vente), 1)
)
SELECT
    mois,
    ca,
    ca / LAG(ca) OVER (ORDER BY mois) - 1 AS evolution_vs_mois_precedent,
    ca / LAG(ca, 12) OVER (ORDER BY mois) - 1 AS evolution_vs_n_moins_1,
    SUM(ca) OVER (PARTITION BY YEAR(mois) ORDER BY mois ROWS UNBOUNDED PRECEDING) AS cumul_annuel
FROM ca_mensuel
ORDER BY mois;
GO
-- Résultat : chaque mois de 2025 dépasse le même mois de 2024 ; meilleur mois juin 2025 (24 141,30 €),
-- plus faible août 2024 (16 501,50 €, -22,4 % sur juillet) : creux d'été récurrent.

/* Q2 - Top 3 des produits par catégorie en 2025
   Techniques : DENSE_RANK() OVER (PARTITION BY ...)
   Contrôle : n°1 des boissons chaudes = Expresso, 27 225,60 € */

WITH ca_produit AS (
    SELECT p.categorie, p.libelle, SUM(v.montant_ht) AS ca
    FROM silver.ventes v
    JOIN silver.produits p ON p.id_produit = v.id_produit
    WHERE YEAR(v.date_vente) = 2025
    GROUP BY p.categorie, p.libelle
),
classes AS (
    SELECT *, DENSE_RANK() OVER (PARTITION BY categorie ORDER BY ca DESC) AS rang
    FROM ca_produit
)
SELECT categorie, rang, libelle, ca
FROM classes
WHERE rang <= 3
ORDER BY categorie, rang;
GO
-- Résultat : l'Expresso domine (27 225,60 € en 2025) ; en frais, le sandwich jambon-beurre fait 20 863,50 €,
-- plus que toute la catégorie snack salé.

/* Q3 - Classes ABC des produits 2025 (A <= 80 % du CA cumulé, B <= 95 %, C au-delà)
   Techniques : SUM() OVER (ORDER BY ... ROWS UNBOUNDED PRECEDING)
   Contrôle : A = 17, B = 10, C = 11 */

WITH ca_produit AS (
    SELECT id_produit, SUM(montant_ht) AS ca
    FROM silver.ventes
    WHERE YEAR(date_vente) = 2025
    GROUP BY id_produit
),
cumul AS (
    SELECT id_produit, ca,
           SUM(ca) OVER (ORDER BY ca DESC ROWS UNBOUNDED PRECEDING) / SUM(ca) OVER () AS part_cumulee
    FROM ca_produit
),
abc AS (
    SELECT *,
           CASE WHEN part_cumulee <= 0.80 THEN 'A'
                WHEN part_cumulee <= 0.95 THEN 'B'
                ELSE 'C' END AS classe
    FROM cumul
)
SELECT classe, COUNT(*) AS nb_produits, SUM(ca) AS ca
FROM abc
GROUP BY classe
ORDER BY classe;
GO
-- Résultat : 17 produits sur 38 (classe A) font 80 % du CA 2025 (207 653,70 €) ; les 11 produits de
-- classe C ne pèsent que 13 153,70 €.

/* Q4 - Compte de résultat par machine 2025 (créer la vue gold.v_pnl_machine_annuel)
   Piège : une CTE par source de coût, sinon les jointures multiplient les lignes
   Contrôle : marge contributive totale 2025 = 45 143,40 € ; 11 machines négatives */

CREATE OR ALTER VIEW gold.v_pnl_machine_annuel AS
WITH ventes AS (
    SELECT v.id_machine, YEAR(v.date_vente) AS annee,
           SUM(v.montant_ht) AS ca,
           SUM(v.cout_ht) AS cmv,
           SUM(CASE WHEN p.categorie = N'Frais' THEN v.montant_ht ELSE 0 END) AS ca_frais
    FROM silver.ventes v
    JOIN silver.produits p ON p.id_produit = v.id_produit
    GROUP BY v.id_machine, YEAR(v.date_vente)
),
passages AS (
    SELECT id_machine, YEAR(date_visite) AS annee,
           COUNT(*) AS nb_passages,
           SUM(valeur_perimes_ht) AS perimes
    FROM silver.visites
    GROUP BY id_machine, YEAR(date_visite)
),
pannes AS (
    SELECT id_machine, YEAR(date_ouverture) AS annee,
           SUM(CASE WHEN type_panne = N'Réfrigération' THEN 1 ELSE 0 END) AS nb_pannes_froid,
           SUM(cout_ht) AS maintenance
    FROM silver.interventions
    GROUP BY id_machine, YEAR(date_ouverture)
),
couts AS (
    SELECT id_machine, YEAR(mois) AS annee, SUM(cout_ht) AS cout_machine
    FROM gold.fact_couts_machine
    GROUP BY id_machine, YEAR(mois)
)
SELECT
    c.annee,
    m.id_machine, m.type_machine, m.modele, m.statut, m.id_site, m.raison_sociale, m.taux_commission,
    COALESCE(v.ca, 0) AS ca,
    COALESCE(v.cmv, 0) AS cmv,
    COALESCE(v.ca, 0) * m.taux_commission AS commission,
    COALESCE(pa.nb_passages, 0) * 18 + COALESCE(pa.perimes, 0) AS reassort,
    COALESCE(pa.nb_passages, 0) AS nb_passages,
    COALESCE(pa.perimes, 0) AS perimes,
    COALESCE(pn.maintenance, 0) AS maintenance,
    COALESCE(pn.nb_pannes_froid, 0) AS nb_pannes_froid,
    c.cout_machine,
    COALESCE(v.ca_frais, 0) AS ca_frais,
    COALESCE(v.ca, 0) - COALESCE(v.cmv, 0) - COALESCE(v.ca, 0) * m.taux_commission
      - (COALESCE(pa.nb_passages, 0) * 18 + COALESCE(pa.perimes, 0))
      - COALESCE(pn.maintenance, 0) - c.cout_machine AS marge_contributive
FROM couts c
JOIN gold.dim_machine m ON m.id_machine = c.id_machine
LEFT JOIN ventes v ON v.id_machine = c.id_machine AND v.annee = c.annee
LEFT JOIN passages pa ON pa.id_machine = c.id_machine AND pa.annee = c.annee
LEFT JOIN pannes pn ON pn.id_machine = c.id_machine AND pn.annee = c.annee;
GO

SELECT
    SUM(ca) AS ca, SUM(cmv) AS cmv, SUM(commission) AS commission, SUM(reassort) AS reassort,
    SUM(maintenance) AS maintenance, SUM(cout_machine) AS cout_machine,
    SUM(marge_contributive) AS marge_contributive,
    SUM(CASE WHEN marge_contributive < 0 THEN 1 ELSE 0 END) AS machines_negatives
FROM gold.v_pnl_machine_annuel
WHERE annee = 2025;
GO
-- Résultat : marge contributive 2025 de 45 143,40 € (17,22 % du CA) ; 11 machines sur 43 perdent de l'argent,
-- dont 4 CoolBox 400 ; la pire, M019, perd 2 660,13 €.

/* Q5 - Effet prix / effet volume des boissons chaudes 2025 vs 2024, périmètre constant
   Techniques : FULL OUTER JOIN, COALESCE
   Contrôle : effet prix = +15 252,30 € ; effet volume = -46,50 € */

WITH perimetre AS (
    SELECT id_machine
    FROM silver.machines
    WHERE date_installation < '2024-01-01' AND date_retrait IS NULL
),
par_produit AS (
    SELECT v.id_produit, YEAR(v.date_vente) AS annee,
           SUM(v.quantite) AS volume, SUM(v.montant_ht) AS ca
    FROM silver.ventes v
    JOIN silver.produits p ON p.id_produit = v.id_produit
    WHERE p.categorie = N'Boisson chaude'
      AND v.id_machine IN (SELECT id_machine FROM perimetre)
    GROUP BY v.id_produit, YEAR(v.date_vente)
),
comparaison AS (
    SELECT
        COALESCE(a.id_produit, b.id_produit) AS id_produit,
        COALESCE(a.volume, 0) AS volume_2024,
        COALESCE(b.volume, 0) AS volume_2025,
        COALESCE(a.ca, 0) AS ca_2024,
        COALESCE(b.ca, 0) AS ca_2025,
        a.ca / NULLIF(a.volume, 0) AS prix_2024,
        b.ca / NULLIF(b.volume, 0) AS prix_2025
    FROM (SELECT * FROM par_produit WHERE annee = 2024) a
    FULL OUTER JOIN (SELECT * FROM par_produit WHERE annee = 2025) b
        ON b.id_produit = a.id_produit
)
SELECT
    SUM(ca_2024) AS ca_2024,
    SUM(ca_2025) AS ca_2025,
    SUM(ca_2025) - SUM(ca_2024) AS variation_ca,
    SUM((COALESCE(prix_2025, prix_2024) - COALESCE(prix_2024, prix_2025)) * volume_2025) AS effet_prix,
    SUM((volume_2025 - volume_2024) * COALESCE(prix_2024, prix_2025)) AS effet_volume
FROM comparaison;
GO
-- Résultat : la hausse de 0,10 € a payé : +15 252,30 € d'effet prix pour -46,50 € d'effet volume,
-- soit +15 205,80 € de CA à périmètre constant.

/* Q6 - Pannes 2025 par modèle
   Contrôle : CoolBox 400 = 47 tickets dont 41 de réfrigération ; 2 076,63 € par machine */

WITH parc AS (
    SELECT m.modele, COUNT(DISTINCT c.id_machine) AS nb_machines
    FROM gold.fact_couts_machine c
    JOIN silver.machines m ON m.id_machine = c.id_machine
    WHERE YEAR(c.mois) = 2025
    GROUP BY m.modele
),
pannes AS (
    SELECT m.modele,
           COUNT(*) AS nb_tickets,
           SUM(CASE WHEN i.type_panne = N'Réfrigération' THEN 1 ELSE 0 END) AS nb_pannes_froid,
           SUM(i.cout_ht) AS cout_total,
           AVG(CASE WHEN i.type_panne = N'Réfrigération' THEN i.duree_h END) AS duree_moyenne_froid_h
    FROM silver.interventions i
    JOIN silver.machines m ON m.id_machine = i.id_machine
    WHERE YEAR(i.date_ouverture) = 2025
    GROUP BY m.modele
)
SELECT
    p.modele,
    pa.nb_machines,
    p.nb_tickets,
    p.nb_pannes_froid,
    CAST(p.cout_total / pa.nb_machines AS decimal(10,2)) AS cout_par_machine,
    CAST(p.duree_moyenne_froid_h AS decimal(6,1)) AS duree_moyenne_froid_h
FROM pannes p
JOIN parc pa ON pa.modele = p.modele
ORDER BY cout_par_machine DESC;
GO
-- Résultat : une CoolBox 400 coûte 2 076,63 € de maintenance par an, près de trois fois une FrigoVend 500
-- (729,89 €) ; 41 pannes de froid sur 6 machines, 59,1 h d'arrêt en moyenne.

/* Q7 - Pannes jamais déclarées (créer la vue gold.v_pannes_silencieuses)
   Techniques : LAG sur les jours avec ventes, calendrier, chevauchement d'intervalles
   Contrôle : 20 machines éligibles ; 6 épisodes ; 583,31 € de CA perdu */

CREATE OR ALTER VIEW gold.v_pannes_silencieuses AS
WITH rang_jours_ouvres AS (
    SELECT date_jour, est_jour_ouvre,
           SUM(est_jour_ouvre) OVER (ORDER BY date_jour ROWS UNBOUNDED PRECEDING) AS rang_ouvre
    FROM silver.calendrier
),
ventes_jours_ouvres AS (
    SELECT v.id_machine, COUNT(*) AS nb_ventes
    FROM silver.ventes v
    JOIN silver.calendrier c ON c.date_jour = v.date_vente
    WHERE v.quantite > 0 AND c.est_jour_ouvre = 1
    GROUP BY v.id_machine
),
jours_installes AS (
    SELECT m.id_machine, COUNT(*) AS nb_jours_ouvres
    FROM gold.dim_machine m
    JOIN silver.calendrier c
      ON c.est_jour_ouvre = 1
     AND c.date_jour >= m.date_installation
     AND c.date_jour <= COALESCE(m.date_retrait, '2025-12-31')
    WHERE m.secteur <> N'Enseignement'
    GROUP BY m.id_machine
),
eligibles AS (
    SELECT j.id_machine
    FROM jours_installes j
    JOIN ventes_jours_ouvres v ON v.id_machine = j.id_machine
    WHERE v.nb_ventes * 1.0 / j.nb_jours_ouvres >= 15
),
jours_avec_ventes AS (
    SELECT DISTINCT v.id_machine, v.date_vente
    FROM silver.ventes v
    JOIN eligibles e ON e.id_machine = v.id_machine
),
ecarts AS (
    SELECT id_machine,
           LAG(date_vente) OVER (PARTITION BY id_machine ORDER BY date_vente) AS derniere_vente,
           date_vente AS reprise
    FROM jours_avec_ventes
),
mesures AS (
    SELECT e.id_machine, e.derniere_vente, e.reprise,
           r2.rang_ouvre - r1.rang_ouvre - r2.est_jour_ouvre AS jours_ouvres_muets
    FROM ecarts e
    JOIN rang_jours_ouvres r1 ON r1.date_jour = e.derniere_vente
    JOIN rang_jours_ouvres r2 ON r2.date_jour = e.reprise
),
ca_annuel AS (
    SELECT id_machine, YEAR(date_vente) AS annee, SUM(montant_ht) AS ca
    FROM silver.ventes
    GROUP BY id_machine, YEAR(date_vente)
),
jours_ouvres_annee AS (
    SELECT annee, SUM(est_jour_ouvre) AS nb_jours_ouvres
    FROM silver.calendrier
    GROUP BY annee
)
SELECT
    mz.id_machine,
    mz.derniere_vente,
    mz.reprise,
    mz.jours_ouvres_muets,
    CAST(ca.ca / jo.nb_jours_ouvres * mz.jours_ouvres_muets AS decimal(10,2)) AS ca_perdu
FROM mesures mz
JOIN ca_annuel ca ON ca.id_machine = mz.id_machine AND ca.annee = YEAR(mz.derniere_vente)
JOIN jours_ouvres_annee jo ON jo.annee = YEAR(mz.derniere_vente)
WHERE mz.jours_ouvres_muets >= 3
  AND NOT EXISTS (
        SELECT 1
          FROM silver.interventions i
         WHERE i.id_machine = mz.id_machine
           AND i.date_ouverture < DATEADD(DAY, 1, CAST(mz.reprise AS datetime2))
           AND COALESCE(i.date_cloture, '2099-12-31') >= mz.derniere_vente);
GO

SELECT id_machine, derniere_vente, reprise, jours_ouvres_muets, ca_perdu
FROM gold.v_pannes_silencieuses
ORDER BY derniere_vente;
GO
-- Résultat : 6 pannes jamais déclarées sur les machines à fort débit, 4 à 5 jours ouvrés sans vente chacune,
-- pour 583,31 € de CA perdu : une alerte automatique est recommandée.

/* Q8 - Atteinte des objectifs 2025 par commercial
   Contrôle : Karim Benali 105,78 % ; Julie Martin 99,54 % ; Thomas Lefèvre 95,83 % */

WITH ca AS (
    SELECT m.commercial, SUM(v.montant_ht) AS ca_2025
    FROM silver.ventes v
    JOIN gold.dim_machine m ON m.id_machine = v.id_machine
    WHERE YEAR(v.date_vente) = 2025
    GROUP BY m.commercial
),
objectifs AS (
    SELECT commercial, SUM(objectif_ca_ht) AS objectif_2025
    FROM silver.objectifs
    WHERE YEAR(mois) = 2025
    GROUP BY commercial
)
SELECT ca.commercial, ca.ca_2025, o.objectif_2025,
       CAST(ca.ca_2025 / o.objectif_2025 AS decimal(6,4)) AS taux_atteinte
FROM ca
JOIN objectifs o ON o.commercial = ca.commercial
ORDER BY taux_atteinte DESC;
GO
-- Résultat : l'équipe atteint 101,75 % de son objectif 2025 ; Karim Benali 105,78 %, Julie Martin 99,54 %,
-- Thomas Lefèvre 95,83 %.
