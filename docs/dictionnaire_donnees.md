# Dictionnaire des données brutes (`data/raw/`)

Données synthétiques couvrant le 1er janvier 2024 au 31 décembre 2025. Tous les montants sont en euros HT.
Tous les fichiers sont encodés en UTF-8. Les descriptions donnent le sens attendu de chaque colonne :
les écarts entre ce sens et le contenu réel font partie de l'exercice.

## crm_sites.csv — CRM commercial (séparateur `;`)

Un client = un site équipé de machines.

| Colonne | Description |
| --- | --- |
| id_site | Identifiant du site, format S + 3 chiffres (S001) |
| raison_sociale | Nom du client |
| secteur | Secteur d'activité du site |
| ville | Ville saisie par le commercial |
| code_postal | Code postal du site (5 chiffres) |
| effectif | Nombre de personnes présentes sur le site |
| date_debut_contrat | Début du contrat de mise à disposition |
| date_fin_contrat | Fin du contrat, vide si le contrat est en cours |
| taux_commission | Part du CA HT reversée au client |
| commercial | Commercial responsable du compte |

## ref_communes.csv — référentiel postal (séparateur `;`)

| Colonne | Description |
| --- | --- |
| code_postal | Code postal (clé) |
| commune | Nom officiel de la commune |
| code_departement | Numéro du département |
| departement | Nom du département |

## parc_machines.csv — logiciel de gestion de parc (séparateur `,`, champs entre guillemets)

| Colonne | Description |
| --- | --- |
| id_machine | Identifiant de la machine (M001) |
| num_serie | Numéro de série constructeur |
| type_modele | Famille de machine et modèle constructeur |
| id_site | Site où la machine est installée |
| date_installation | Date d'installation sur le site |
| cout_mensuel | Coût mensuel de la machine (leasing ou amortissement) |
| statut | Statut de la machine dans le parc |
| date_retrait | Date de retrait, vide si la machine est en place |

Familles : Café (boissons chaudes), Froid (boissons fraîches), Snack (snacks), Combo (produits frais, boissons fraîches et snacks).

## catalogue_produits.csv — service achats (séparateur `;`)

| Colonne | Description |
| --- | --- |
| id_produit | Identifiant du produit (P001) |
| libelle | Nom du produit |
| categorie | Catégorie du produit |
| prix_achat_ht | Prix d'achat unitaire actuel |
| prix_vente_ht | Prix de vente unitaire actuel (tarif 2025) |
| actif | Produit encore référencé (O) ou non (N) |

Le prix réellement payé à chaque vente figure dans la télémétrie (`prix_unitaire_ht`).

## objectifs_commerciaux.xlsx — direction commerciale

Onglet « Objectifs » : une ligne par commercial, une colonne par mois (2024-01 à 2025-12),
objectif de CA mensuel HT en euros.

## interventions/interventions_AAAA_MM.csv — outil de maintenance (séparateur `;`)

Un fichier par mois d'export, 24 fichiers. Chaque export liste les tickets ouverts ou mis à jour dans le mois.

| Colonne | Description |
| --- | --- |
| ticket | Identifiant du ticket (INT-2024-0001) |
| machine | Machine concernée |
| ouverture | Date et heure d'ouverture du ticket (jj/mm/aaaa hh:mm) |
| cloture | Date et heure de clôture, vide si le ticket était ouvert au moment de l'export |
| type_panne | Nature de la panne, saisie par le technicien |
| technicien | Technicien intervenu |
| cout | Coût de l'intervention (pièces et main-d'œuvre), vide si non clôturé |

## telemetrie_transactions.csv — télémétrie des machines (séparateur `,`)

Une ligne = une vente remontée par une machine.

| Colonne | Description |
| --- | --- |
| id_transaction | Identifiant unique de la transaction |
| id_machine | Machine ayant réalisé la vente |
| id_produit | Produit vendu |
| horodatage | Date et heure de la vente (aaaa-mm-jj hh:mm:ss) |
| quantite | Nombre d'articles (−1 pour un remboursement automatique) |
| prix_unitaire_ht | Prix unitaire appliqué |
| montant_ht | Montant de la ligne |
| moyen_paiement | ESPECES, CB ou APP (application mobile) |

## visites_reassort.csv — application terrain (séparateur `,`)

Une ligne = un passage d'un technicien pour réapprovisionner une machine.

| Colonne | Description |
| --- | --- |
| id_visite | Identifiant du passage |
| id_machine | Machine réapprovisionnée |
| date_visite | Date du passage (aaaa-mm-jj) |
| technicien | Technicien |
| duree_min | Durée du passage en minutes |
| nb_articles_charges | Nombre d'articles chargés |
| valeur_perimes_ht | Valeur d'achat des produits périmés retirés |
