/* =====================================================================
   DistriNova | 00 - Création de la base et couche BRONZE (fichiers bruts)
   ---------------------------------------------------------------------
   Fourni avec le kit. À exécuter une fois, en entier, dans SSMS.
   Prérequis : kit décompressé dans C:\distrinova (sinon, remplace ce
   chemin partout dans le script).
   Bronze = copie fidèle des fichiers, toutes les colonnes en texte.
   Conversions et nettoyage : couche silver (02_silver.sql).
   ===================================================================== */
USE master;
GO
IF DB_ID(N'DistriNova') IS NULL
    CREATE DATABASE DistriNova;
GO
USE DistriNova;
GO
IF SCHEMA_ID(N'bronze') IS NULL EXEC (N'CREATE SCHEMA bronze');
GO
IF SCHEMA_ID(N'silver') IS NULL EXEC (N'CREATE SCHEMA silver');
GO
IF SCHEMA_ID(N'gold') IS NULL EXEC (N'CREATE SCHEMA gold');
GO

/* ---------- 1. Télémétrie des machines (export système, séparateur virgule) ---------- */
DROP TABLE IF EXISTS bronze.telemetrie_transactions;
CREATE TABLE bronze.telemetrie_transactions (
    id_transaction   NVARCHAR(20),
    id_machine       NVARCHAR(20),
    id_produit       NVARCHAR(20),
    horodatage       NVARCHAR(30),
    quantite         NVARCHAR(10),
    prix_unitaire_ht NVARCHAR(20),
    montant_ht       NVARCHAR(20),
    moyen_paiement   NVARCHAR(20)
);
GO
BULK INSERT bronze.telemetrie_transactions
FROM 'C:\distrinova\data\raw\telemetrie_transactions.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n',
      CODEPAGE = '65001', TABLOCK);
GO

/* ---------- 2. Visites de réassort (application terrain, séparateur virgule) ---------- */
DROP TABLE IF EXISTS bronze.visites_reassort;
CREATE TABLE bronze.visites_reassort (
    id_visite           NVARCHAR(20),
    id_machine          NVARCHAR(20),
    date_visite         NVARCHAR(30),
    technicien          NVARCHAR(100),
    duree_min           NVARCHAR(10),
    nb_articles_charges NVARCHAR(10),
    valeur_perimes_ht   NVARCHAR(20)
);
GO
BULK INSERT bronze.visites_reassort
FROM 'C:\distrinova\data\raw\visites_reassort.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n',
      CODEPAGE = '65001', TABLOCK);
GO

/* ---------- 3. Contrôle des volumes ----------
   Attendu : telemetrie_transactions = 497 728 ; visites_reassort = 5 211 */
SELECT 'bronze.telemetrie_transactions' AS table_bronze, COUNT(*) AS nb_lignes FROM bronze.telemetrie_transactions
UNION ALL
SELECT 'bronze.visites_reassort', COUNT(*) FROM bronze.visites_reassort;
GO
