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

-- TODO

/* Q2 - Top 3 des produits par catégorie en 2025
   Techniques : DENSE_RANK() OVER (PARTITION BY ...)
   Contrôle : n°1 des boissons chaudes = Expresso, 27 225,60 € */

-- TODO

/* Q3 - Classes ABC des produits 2025 (A <= 80 % du CA cumulé, B <= 95 %, C au-delà)
   Techniques : SUM() OVER (ORDER BY ... ROWS UNBOUNDED PRECEDING)
   Contrôle : A = 17, B = 10, C = 11 */

-- TODO

/* Q4 - Compte de résultat par machine 2025 (créer la vue gold.v_pnl_machine_annuel)
   Piège : une CTE par source de coût, sinon les jointures multiplient les lignes
   Contrôle : marge contributive totale 2025 = 45 143,40 € ; 11 machines négatives */

-- TODO

/* Q5 - Effet prix / effet volume des boissons chaudes 2025 vs 2024, périmètre constant
   Techniques : FULL OUTER JOIN, COALESCE
   Contrôle : effet prix = +15 252,30 € ; effet volume = -46,50 € */

-- TODO

/* Q6 - Pannes 2025 par modèle
   Contrôle : CoolBox 400 = 47 tickets dont 41 de réfrigération ; 2 076,63 € par machine */

-- TODO

/* Q7 - Pannes jamais déclarées (créer la vue gold.v_pannes_silencieuses)
   Techniques : LAG sur les jours avec ventes, calendrier, chevauchement d'intervalles
   Contrôle : 20 machines éligibles ; 6 épisodes ; 583,31 € de CA perdu */

-- TODO

/* Q8 - Atteinte des objectifs 2025 par commercial
   Contrôle : Karim Benali 105,78 % ; Julie Martin 99,54 % ; Thomas Lefèvre 95,83 % */

-- TODO
