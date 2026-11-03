/* =====================================================================
   DistriNova | 01 - Couche BRONZE : chargement des 5 exports Excel
   ---------------------------------------------------------------------
   Fourni avec le kit. À exécuter APRÈS la phase 1 (Excel), quand les
   5 fichiers existent dans C:\distrinova\data\clean\.
   Excel en français enregistre les CSV avec ';' comme séparateur.
   Si tes fichiers utilisent ',' (Windows en anglais), remplace ';'
   par ',' dans les 5 FIELDTERMINATOR ci-dessous.
   L'ordre des colonnes suit celui du guide (séance 5, point de contrôle) :
   si une valeur atterrit dans la mauvaise colonne, vérifie l'ordre de ton export.
   ===================================================================== */
USE DistriNova;
GO

DROP TABLE IF EXISTS bronze.sites;
CREATE TABLE bronze.sites (
    id_site            NVARCHAR(10),
    raison_sociale     NVARCHAR(200),
    secteur            NVARCHAR(50),
    commune            NVARCHAR(100),
    code_postal        NVARCHAR(10),
    departement        NVARCHAR(100),
    effectif           NVARCHAR(20),
    date_debut_contrat NVARCHAR(30),
    date_fin_contrat   NVARCHAR(30),
    taux_commission    NVARCHAR(20),
    commercial         NVARCHAR(100)
);
GO
BULK INSERT bronze.sites
FROM 'C:\distrinova\data\clean\sites_clean.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ';', ROWTERMINATOR = '\n', CODEPAGE = '65001');
GO

DROP TABLE IF EXISTS bronze.machines;
CREATE TABLE bronze.machines (
    id_machine        NVARCHAR(10),
    num_serie         NVARCHAR(30),
    type_machine      NVARCHAR(30),
    modele            NVARCHAR(50),
    id_site           NVARCHAR(10),
    date_installation NVARCHAR(30),
    date_retrait      NVARCHAR(30),
    cout_mensuel_ht   NVARCHAR(20),
    statut            NVARCHAR(20)
);
GO
BULK INSERT bronze.machines
FROM 'C:\distrinova\data\clean\machines_clean.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ';', ROWTERMINATOR = '\n', CODEPAGE = '65001');
GO

DROP TABLE IF EXISTS bronze.produits;
CREATE TABLE bronze.produits (
    id_produit    NVARCHAR(10),
    libelle       NVARCHAR(100),
    categorie     NVARCHAR(50),
    prix_achat_ht NVARCHAR(20),
    prix_vente_ht NVARCHAR(20),
    actif         NVARCHAR(5)
);
GO
BULK INSERT bronze.produits
FROM 'C:\distrinova\data\clean\produits_clean.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ';', ROWTERMINATOR = '\n', CODEPAGE = '65001');
GO

DROP TABLE IF EXISTS bronze.interventions;
CREATE TABLE bronze.interventions (
    id_ticket      NVARCHAR(20),
    id_machine     NVARCHAR(10),
    date_ouverture NVARCHAR(30),
    date_cloture   NVARCHAR(30),
    type_panne     NVARCHAR(50),
    technicien     NVARCHAR(100),
    cout_ht        NVARCHAR(20),
    fichier_source NVARCHAR(100)
);
GO
BULK INSERT bronze.interventions
FROM 'C:\distrinova\data\clean\interventions_clean.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ';', ROWTERMINATOR = '\n', CODEPAGE = '65001');
GO

DROP TABLE IF EXISTS bronze.objectifs;
CREATE TABLE bronze.objectifs (
    commercial     NVARCHAR(100),
    mois           NVARCHAR(30),
    objectif_ca_ht NVARCHAR(20)
);
GO
BULK INSERT bronze.objectifs
FROM 'C:\distrinova\data\clean\objectifs_clean.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ';', ROWTERMINATOR = '\n', CODEPAGE = '65001');
GO

/* Contrôle des volumes. Attendu : sites 26 ; machines 43 ; produits 39 ;
   interventions 321 ; objectifs 72 */
SELECT 'bronze.sites' AS table_bronze, COUNT(*) AS nb_lignes FROM bronze.sites
UNION ALL SELECT 'bronze.machines', COUNT(*) FROM bronze.machines
UNION ALL SELECT 'bronze.produits', COUNT(*) FROM bronze.produits
UNION ALL SELECT 'bronze.interventions', COUNT(*) FROM bronze.interventions
UNION ALL SELECT 'bronze.objectifs', COUNT(*) FROM bronze.objectifs;
GO

/* Aperçu : les accents doivent s'afficher correctement (ex. « Hôtel d'agglomération »).
   Sinon, ton export n'est pas en UTF-8 : réenregistre-le en « CSV UTF-8 ». */
SELECT TOP (5) * FROM bronze.sites;
GO
