# Journal d'anomalies

Une ligne par anomalie trouvée pendant le profilage (phase 1), complétée au fil du projet.
Le statut passe à « Corrigé » quand la règle est appliquée et vérifiée par un point de contrôle.

| # | Fichier | Colonne | Anomalie constatée | Volume | Règle de correction | Outil | Statut |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | crm_sites.csv | id_site | S014 présent deux fois (fusion de deux exports CRM, ville écrite différemment) | 1 ligne en trop | Garder une seule ligne par id_site ; contrôle : 26 sites | Excel | Corrigé |
| 2 | crm_sites.csv | secteur | Même secteur écrit de plusieurs façons : casse, accents, singulier/pluriel, abréviations (« Indus. », « Admin », « Enseignement sup. ») ; 20 libellés bruts | 11 lignes | Ramener chaque variante à l'un des 8 secteurs ; contrôle : Bureaux 7, Industrie 5, Logistique 3, Santé 3, Sport 3, Administration 2, Enseignement 2, Commerce 1 | Excel | Corrigé |
| 3 | crm_sites.csv | secteur | S024 sans secteur | 1 ligne | Bureaux (espace de coworking, réponse du métier) | Excel | Corrigé |
| 4 | crm_sites.csv | ville | Saisie libre : casse, abréviations (St, Ste), tirets, espaces en trop | 10 lignes au moins | Ville remplacée par la commune et le département du référentiel, via le code postal ; contrôle : aucune commune vide | Excel | Corrigé |
| 5 | crm_sites.csv | code_postal | Espaces dans le code postal (« 95 800 », « 95100 ») : la fusion avec ref_communes échoue | 2 lignes | Supprimer tous les espaces avant la fusion | Excel | Corrigé |
| 6 | crm_sites.csv | date_debut_contrat | Deux formats de date : JJ/MM/AAAA et AAAA-MM-JJ | 5 lignes au format ISO | Conversion en date avec les paramètres régionaux fr-FR | Excel | Corrigé |
| 7 | crm_sites.csv | effectif | Effectif vide (S006, S026) | 2 lignes | Laissé vide (null) : aucune source fiable pour le compléter, et la colonne ne sert à aucun calcul | Excel | Corrigé |
| 8 | crm_sites.csv | taux_commission | Trois écritures : pourcentage avec % (« 10 % », « 10% »), fraction (« 0,07 »), points sans % (« 10 », « 5 ») | 15 + 8 + 4 lignes | Retirer « % » et les espaces, convertir en nombre, diviser par 100 si la valeur dépasse 1 ; contrôle : max 0,12, moyenne 6,88 % | Excel | Corrigé |
| 9 | crm_sites.csv | commercial | Variantes de casse, accent manquant (Lefevre), espace doublé ou en fin de texte | 8 lignes | Supprimer les espaces en trop, majuscule à chaque mot, Lefevre → Lefèvre ; contrôle : Julie Martin 10 sites, Karim Benali 9, Thomas Lefèvre 7 | Excel | Corrigé |
| 10 | parc_machines.csv | toutes | M033 exportée deux fois, à l'identique | 1 ligne en trop | Supprimer les doublons sur toutes les colonnes ; contrôle : 43 machines | Excel | Corrigé |
| 11 | parc_machines.csv | type_modele | Famille et modèle dans la même colonne, deux séparateurs (« - » et « \| »), casse et accents variables ; 17 libellés bruts | 44 lignes | Unifier le séparateur, fractionner en type_machine et modele, retrouver l'écriture officielle ; contrôle : Café 21, Froid 8, Combo 8, Snack 6 ; BaristaPro 300 14, DuoVend 2 8, BaristaPro 500 7, CoolBox 400 6, SpiralMax 6 6, FrigoVend 500 2 | Excel | Corrigé |
| 12 | parc_machines.csv | id_site | Identifiants mal saisis : « S9 » (M016), « s014 » (M025), « S020 » précédé d'une espace (M034) | 3 lignes | Garder les chiffres, compléter à 3 chiffres, préfixer « S » ; contrôle : aucune machine sans site | Excel | Corrigé |
| 13 | parc_machines.csv | cout_mensuel | Coût en texte : symbole « € », décimales variables (« 65,00 € », « 95,0 », « 60 € ») | 33 lignes | Retirer « € » et les espaces, convertir en nombre ; contrôle : somme 3 315 € | Excel | Corrigé |
| 14 | parc_machines.csv | statut | 6 écritures pour 2 statuts réels (Active, active, ACTIVE, En service, Retirée, RETIREE) | 18 lignes non conformes | MAJUSCULES, puis « commence par RETIR » → Retirée, sinon Active ; « En service » traité comme Active ; contrôle : Active 41, Retirée 2 | Excel | Corrigé |
| 15 | parc_machines.csv | date_installation | Deux formats de date : JJ/MM/AAAA et AAAA-MM-JJ | 14 lignes au format ISO | Conversion en date avec les paramètres régionaux fr-FR | Excel | Corrigé |
| 16 | catalogue_produits.csv | libelle | Espaces en trop au début ou à la fin (« Cappuccino », « Wrap poulet », « Chips nature 45g »…) | 4 lignes | Supprimer les espaces au début et à la fin, sans toucher à la casse | Excel | Corrigé |
| 17 | catalogue_produits.csv | categorie | 17 libellés pour 5 catégories : pluriel, casse, accents oubliés, « Produit frais » | 22 lignes non conformes | Ramener chaque libellé à Boisson chaude, Boisson fraîche, Snack sucré, Snack salé ou Frais ; contrôle : Boisson fraîche 10, Boisson chaude 9, Snack sucré 9, Frais 6, Snack salé 5 | Excel | Corrigé |
| 18 | catalogue_produits.csv | prix_achat_ht, prix_vente_ht | Symbole « € » dans certaines cellules, nombre de décimales variable | 8 lignes (achat), 26 lignes (vente) | Retirer « € » et les espaces, convertir en nombre décimal ; contrôle : somme des prix de vente 60,90 € | Excel | Corrigé |
| 19 | catalogue_produits.csv | actif | 4 écritures (O, N, Oui, oui) | 4 lignes non conformes | Première lettre en majuscule : O ou N ; contrôle : un seul produit inactif, P007 | Excel | Corrigé |
| 20 | catalogue_produits.csv | prix_achat_ht | P031 (Crackers salés) sans prix d'achat : sa marge est incalculable | 1 ligne | Médiane des prix d'achat de sa catégorie, calculée par requête (pas de valeur tapée) ; contrôle : P031 = 0,39 €, somme des prix d'achat 22,97 € | Excel | Corrigé |
| 21 | interventions (24 fichiers) | toutes | 24 exports mensuels séparés, dates et coûts au format français | 321 lignes | Import de dossier, colonne fichier_source, typage avec les paramètres régionaux fr-FR | Excel | Corrigé |
| 22 | interventions (24 fichiers) | type_panne | 27 libellés différents pour 6 vrais types de panne (casse, accents, synonymes : « Froid », « Refrigeration », « Groupe froid HS »…) | 321 lignes à recoder | Minuscules, puis listes de correspondance (List.Contains) vers 6 types ; contrôle : Réfrigération 89, Monnayeur / paiement 84, Distribution 63, Connectivité 35, Hydraulique 30, Électrique 20 | Excel | Corrigé |
| 23 | interventions (24 fichiers) | cout | Coût en texte, avec ou sans « € », décimales variables (« 82,62 € », « 221,54 ») | 130 lignes avec « € » | Retirer « € » et les espaces, convertir en nombre ; contrôle : somme 48 117,60 € | Excel | Corrigé |
| 24 | interventions (24 fichiers) | cloture, cout | Tickets encore ouverts à la date de l'export : clôture et coût vides | 12 lignes | Vides transformés en null avant le typage Date/Heure (fr-FR) | Excel | Corrigé |
| 25 | interventions (24 fichiers) | ticket | Même ticket dans deux exports mensuels consécutifs : ouvert (sans clôture ni coût) dans le premier, clôturé dans le second | 10 tickets (321 lignes pour 311 tickets) | Gardés dans Excel avec leur fichier_source ; en SQL (silver.interventions), une ligne par ticket : ROW_NUMBER() par id_ticket, trié par date de clôture décroissante (les NULL passent en dernier), rang 1 conservé ; contrôle : 311 tickets, dont 2 encore ouverts, coûts inchangés (48 117,60 €, dont 25 888,08 € en 2025) | SQL | Corrigé |
| 26 | interventions (24 fichiers) | cloture | Clôture antérieure à l'ouverture : INT-2024-0124, INT-2025-0044, INT-2025-0091 (trouvée en comparant à l'annexe B) | 3 tickets | Tickets conservés avec leur coût ; duree_h calculée seulement si la clôture suit l'ouverture, sinon NULL ; contrôle : 3 durées invalides, 5 durées NULL au total avec les 2 tickets ouverts | SQL | Corrigé |
| 27 | objectifs_commerciaux.xlsx | feuille Objectifs | Tableau de présentation : titre, note, mois en colonnes, ligne et colonne TOTAL | 1 feuille, 24 mois | Supprimer titre, note et totaux, dépivoter les mois ; contrôle : 72 lignes, 500 800 € au total, dont 243 200 € en 2024 et 257 600 € en 2025 | Excel | Corrigé |
| 28 | telemetrie_transactions.csv | id_transaction | Transactions envoyées deux fois, à l'identique | 2 968 lignes : 497 728 lignes pour 494 760 identifiants | Garder une ligne par id_transaction (ROW_NUMBER, rang 1) dans silver.ventes ; contrôle : 497 728 → 494 760 lignes | SQL | Corrigé |
| 29 | telemetrie_transactions.csv | id_machine | TEST01 : banc d'essai, absent du parc | 122 ventes | Exclure les ventes des machines de test (id_machine NOT LIKE 'TEST%') ; contrôle : 494 760 → 494 638 lignes | SQL | Corrigé |
| 30 | telemetrie_transactions.csv | horodatage | Ventes datées du 01/01/1970 (date par défaut d'une horloge non réglée), toutes sur M010 | 42 ventes | Exclure les ventes datées avant le 01/01/2024 ; contrôle : 494 638 → 494 596 lignes | SQL | Corrigé |
| 31 | telemetrie_transactions.csv | montant_ht | Montants enregistrés ×100 sur M031 du 10 au 12 mars 2025 (jusqu'à 100 € pour un article) | 155 lignes, 154 après dédoublonnage | montant_ht recalculé sur toutes les lignes = quantite × prix_unitaire_ht (protège aussi contre une future erreur du même type) ; contrôle : CA 2025 = 262 119,10 € (272 296,30 € avec le montant brut) | SQL | Corrigé |
| 32 | telemetrie_transactions.csv | id_produit | Ventes sans produit sur 5 machines Snack (M003, M007, M014, M026, M029), du 1er octobre au 15 novembre 2025, à 1,30 € ou 1,20 € | 285 lignes, 283 après dédoublonnage | Produit reconstitué d'après le prix : COALESCE(id_produit, 1,30 € → P025 Cookies, 1,20 € → P030 Chips paprika), les deux produits absents de ces machines pendant la période ; contrôle : 0 produit manquant | SQL | Corrigé |

Les 1 982 lignes à quantité −1 (1 969 après dédoublonnage) ne sont pas une anomalie : ce sont des remboursements, à garder car le CA se calcule remboursements déduits.

## Règles métier et hypothèses

- Objectifs 2025 = CA 2024 réel + 8 % (note de la direction commerciale, version du 16/12/2024). À vérifier en SQL à la séance 11.
- « En service » dans le parc = machine active (synonyme confirmé par le métier).
- Effectif inconnu pour 2 sites : laissé vide plutôt qu'inventé.
- Prix d'achat de P031 imputé (médiane de la catégorie Snack salé, 0,39 €) et non observé. La médiane plutôt que la moyenne : elle n'est pas tirée vers le haut par un produit cher comme le mélange de fruits secs (0,80 €).
- Comment signaler l'imputation aux lecteurs des chiffres : [ton idée ici].
- Fichiers propres exportés en CSV UTF-8 (séparateur point-virgule) dans data/clean : l'ordre des colonnes est le contrat lu par le script SQL 01.
- TEST01 : banc d'essai du service technique, qui envoie de vraies transactions de test.
- M010 : horloge déréglée (après une coupure ou une réinitialisation), la date envoyée vaut 0, soit le 01/01/1970.
- M031 : mise à jour du logiciel de la machine qui a enregistré les montants en centimes pendant trois jours, puis corrigée.
- Ventes sans produit : changement de planogramme sur les machines Snack ; deux emplacements n'étaient plus associés à leur produit jusqu'à la correction du 15 novembre 2025.

## Bilan de la phase 1

Journal comparé à l'annexe B : les 30 anomalies du jeu sont couvertes. Le journal en compte 32 lignes, certaines anomalies étant détaillées en plusieurs lignes : 25 sont corrigées dans Excel, 7 le seront en SQL (séances 8 et 9).

## Phase 2 — contrôles de chargement (séances 7 et 8)

- Bronze : 7 tables chargées en texte, sans transformation ; volumes conformes aux fichiers (telemetrie_transactions 497 728, visites_reassort 5 211, sites 26, machines 43, produits 39, interventions 321, objectifs 72).
- Incident de chargement : sites_clean.csv et machines_clean.csv refusés par BULK INSERT (erreur 7301) tant qu'ils étaient ouverts dans Excel. Règle : fermer les fichiers sources avant tout chargement.
- Silver (référentiels) : sites, machines, produits, objectifs et visites typés (date, int, decimal) ; clé primaire sur id_site, id_machine, id_produit ; 0 conversion ratée (texte rempli en bronze et NULL en silver), contrôle vérifié en provoquant volontairement un échec.
- Silver (interventions) : 321 lignes → 311 tickets, voir lignes 25 et 26.
- Avancement fin de séance 8 : 27 lignes corrigées sur 32.

## Phase 2 — silver.ventes et calendrier (séance 9)

- Entonnoir de la télémétrie, mesuré règle par règle : 497 728 lignes brutes → 494 760 après dédoublonnage (−2 968) → 494 638 sans machine de test (−122) → 494 596 sans les dates de 1970 (−42).
- silver.ventes : 494 596 ventes, 1 969 remboursements conservés (quantité −1, montant négatif), 283 produits reconstitués, 0 produit manquant ; montant et coût recalculés (quantité × prix unitaire, quantité × prix d'achat du catalogue) ; index sur (id_machine, date_vente).
- CA 2024 = 237 674,30 € ; CA 2025 = 262 119,10 €, soit +10,28 %.
- silver.feries : 22 jours fériés (annexe A). silver.calendrier : 731 jours ; 2024 = 366 jours, 252 ouvrés, 11 fériés ; 2025 = 365 jours, 251 ouvrés, 11 fériés. Jour de la semaine indépendant du réglage du serveur (lundi = 1).
- Bilan : les 32 lignes du journal sont corrigées ; la couche silver est complète.

## Phase 2 — couche gold (séance 10)

- 9 vues créées avec CREATE OR ALTER VIEW, en ne lisant que la couche silver : 4 dimensions et 5 tables de faits, organisées en modèle en étoile.
- Volumes : dim_date 731 jours, dim_machine 43 machines (aucune perdue à la jointure avec les sites), dim_produit 39, dim_commercial 3, fact_ventes 494 596, fact_interventions 311, fact_visites 5 211, fact_couts_machine 1 012, fact_objectifs 72.
- Règle métier appliquée : le coût machine est dû pour chaque mois entamé, de l'installation au retrait (jointure sur une condition d'inégalité avec EOMONTH) ; contrôle : coût machine 2025 = 39 060 €.
- fact_interventions : date d'ouverture ramenée au jour (sans l'heure) pour que chaque ticket se relie au calendrier ; la durée exacte reste dans duree_h.
- Choix de conception : secteur, commune et commercial du site recopiés dans dim_machine (pas de dimension site séparée) ; dim_commercial fait le pont entre les objectifs et les machines de chaque commercial.

## Phase 2 — analyses (séance 11)

| # | Question | Résultat |
| --- | --- | --- |
| Q1 | Évolution mensuelle du CA | Chaque mois de 2025 dépasse le même mois de 2024 ; meilleur mois juin 2025 (24 141,30 €), plus faible août 2024 (16 501,50 €, −22,4 % sur juillet) ; CA 2025 = 262 119,10 € (+10,28 %) |
| Q2 | Top 3 par catégorie (2025) | N°1 : Expresso 27 225,60 €, Sandwich jambon-beurre 20 863,50 €, Cola 33cl 12 169,30 €, Barre chocolat caramel 7 474,80 €, Chips nature 45g 5 000,40 € |
| Q3 | Classes ABC (2025) | A : 17 produits, 207 653,70 € (80 % du CA) ; B : 10 produits, 41 311,70 € ; C : 11 produits, 13 153,70 € |
| Q4 | Compte de résultat par machine (2025) | Marge contributive 45 143,40 € (17,22 % du CA) ; 11 machines déficitaires sur 43, dont 4 CoolBox 400 ; pire M019 (−2 660,13 €), meilleure M020 (+4 718,21 €) |
| Q5 | Hausse de prix des boissons chaudes | Effet prix +15 252,30 €, effet volume −46,50 €, variation +15 205,80 € à périmètre constant : la hausse a payé |
| Q6 | Pannes par modèle (2025) | CoolBox 400 : 2 076,63 € de maintenance par machine, 41 pannes de froid sur 6 machines, 59,1 h d'arrêt moyen ; FrigoVend 500 : 729,89 € |
| Q7 | Pannes jamais déclarées | 6 épisodes de 4 à 5 jours ouvrés sans vente ni ticket sur 20 machines à fort débit ; 583,31 € de CA perdu |
| Q8 | Atteinte des objectifs (2025) | Équipe 101,75 % ; Karim Benali 105,78 %, Julie Martin 99,54 %, Thomas Lefèvre 95,83 % |

Piège évité (Q4, Q8) : chaque source est résumée au grain machine × année (ou commercial) avant les jointures, pour ne pas multiplier les lignes.

## Phase 2 — décision et contrôles qualité (séance 12)

- Vue gold.v_decision_2025 : 6 règles testées dans l'ordre sur les 41 machines actives (Remplacer, Retirer, Renégocier, Revoir l'assortiment, Surveiller, Conserver) ; référence de maintenance FrigoVend 500 = 729,89 €.
- Résultat : Remplacer 6 machines (6 280,50 €), Retirer 4 (4 800,41 €), Revoir l'assortiment 2 (1 508,81 €), Renégocier 2 (344,69 €), Surveiller 7, Conserver 20 ; gain total estimé 12 934,41 € par an, soit +28,7 % de marge contributive.
- Plan d'action : 21 machines ; en tête M019 Concession AutoPlus (Retirer, 2 660,13 €), puis M043 FitCity Argenteuil (Remplacer, 1 815,67 €). M019 est aussi une Combo à 40 % de démarque, mais la règle Retirer passe avant.
- Hypothèses des gains (à présenter comme telles) : 300 € de leasing en plus pour une FrigoVend, 60 % des périmés évités, commission renégociable à 6 %, coût d'un passage de 18 €.
- Contrôles qualité (07_controles_qualite.sql) : 5 contrôles à 0 (unicité, intégrité, complétude, cohérence des dates, réconciliation silver / gold) ; le contrôle de réconciliation a été testé en provoquant volontairement un écart.

## Où chaque règle est appliquée

| Lignes du journal | Script |
| --- | --- |
| 1 à 27 (sauf 25, 26) | Excel : classeur distrinova_preparation.xlsx (Power Query), exports data/clean |
| 25, 26 | sql/02_silver.sql : silver.interventions |
| 28 à 32 | sql/02_silver.sql : silver.ventes |
| Calendrier et jours fériés | sql/03_calendrier.sql |
| Règle du coût machine par mois entamé | sql/04_gold_vues.sql : gold.fact_couts_machine |
| Contrôles permanents | sql/07_controles_qualite.sql |
