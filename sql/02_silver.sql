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

-- TODO


/* ---------- 2.3 Interventions ----------
   Dédoublonnage : ROW_NUMBER() OVER (PARTITION BY id_ticket ORDER BY date_cloture DESC) = 1
   duree_h : NULL si clôture absente ou antérieure à l'ouverture.
   Attendu : 311 tickets ; 2 ouverts ; 3 durées invalides ; coût total 48 117,60 €. */

-- TODO


/* ---------- 2.4 Ventes (table matérialisée + index) ----------
   Règles : dédoublonner sur id_transaction ; exclure TEST01 ; exclure les horodatages
   avant 2024 ; reconstituer id_produit vide d'après le prix (annexe A) ;
   montant_ht = quantite * prix_unitaire_ht ; garder les remboursements ;
   cout_ht = quantite * prix d'achat du produit.
   Attendu : 497 728 -> 494 760 -> 494 638 -> 494 596 lignes ; 283 produits reconstitués ;
   1 969 remboursements ; CA 2024 = 237 674,30 € ; CA 2025 = 262 119,10 €. */

-- TODO
