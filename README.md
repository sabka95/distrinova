# DistriNova — Rentabilité d'un parc de distributeurs automatiques

> **Modèle de README à compléter.** Remplace chaque `[À compléter]` par tes résultats,
> supprime ce bloc, puis ajoute tes captures dans `docs/img/`.

**Excel (Power Query, Power Pivot) · SQL Server (T-SQL) · Power BI (DAX)**
Données synthétiques réalistes : 43 machines, 26 clients B2B en Île-de-France, 2024-2025.

![Page Décision du dashboard](docs/img/05_decision.png)

## Le problème

DistriNova exploite 43 distributeurs automatiques (café, boissons fraîches, snacks, produits frais)
chez 26 clients B2B. Le CA progresse, mais personne ne sait quelles machines gagnent de l'argent
une fois tous les coûts imputés. La direction veut une décision machine par machine pour 2026.

## Recommandations

| Action | Machines | Gain estimé 2026 |
| --- | --- | --- |
| Remplacer les CoolBox 400 | [À compléter] | [À compléter] € |
| Retirer | [À compléter] | [À compléter] € |
| Renégocier la commission | [À compléter] | [À compléter] € |
| Revoir l'assortiment frais | [À compléter] | [À compléter] € |
| **Total** | | **[À compléter] €** |

Constats clés :
- [À compléter : marge contributive 2025 et son évolution]
- [À compléter : effet prix / effet volume de la hausse des boissons chaudes]
- [À compléter : coût de maintenance CoolBox 400 vs FrigoVend 500]
- [À compléter : pannes non déclarées détectées]

## Architecture

![Modèle en étoile dans Power BI](docs/img/modele.png)

| Couche | Outil | Rôle |
| --- | --- | --- |
| Préparation | Excel / Power Query | Profilage, nettoyage des référentiels, journal d'anomalies |
| Bronze | SQL Server | Fichiers bruts chargés tels quels (texte) |
| Silver | SQL Server | Tables typées, dédoublonnées, corrigées |
| Gold | SQL Server | Modèle en étoile en vues, analyses, vue de décision |
| Restitution | Power BI | Modèle, mesures DAX, 5 pages orientées décision |

## Démarche

### 1. Excel / Power Query
- [À compléter : sources profilées, nombre d'anomalies, techniques utilisées]
- Journal d'anomalies : [docs/journal_anomalies.md](docs/journal_anomalies.md)

### 2. SQL Server
- [À compléter : couches, règles de nettoyage, entonnoir de lignes]
- Analyses : [sql/05_analyses.sql](sql/05_analyses.sql) — CTE, fonctions de fenêtrage, gaps and islands

### 3. Power BI
- [À compléter : modèle, mesures clés, paramètres de simulation]
- Mesures documentées : [powerbi/mesures_dax.md](powerbi/mesures_dax.md)

## Structure du repo

```
├── data/
│   ├── raw/            # 8 sources brutes (données synthétiques)
│   └── clean/          # 5 exports Excel nettoyés
├── excel/              # classeur de préparation Power Query
├── sql/                # 00-01 chargement bronze, 02-07 silver, gold, analyses, contrôles
├── powerbi/            # rapport .pbix et documentation des mesures
└── docs/               # dictionnaire de données, journal d'anomalies, captures
```

## Reproduire le projet

1. Décompresser le repo dans `C:\distrinova`.
2. Exécuter `sql/00_bronze_creation_et_chargement_brut.sql` dans SSMS (SQL Server Express).
3. Exécuter `sql/01_bronze_chargement_exports_excel.sql`, puis les scripts `02` à `07` dans l'ordre.
4. Ouvrir `powerbi/distrinova.pbix` et actualiser (serveur `localhost\SQLEXPRESS`).

## Compétences mobilisées

Power Query (fusions, dépivotage, import de dossier, imputation) · Power Pivot ·
T-SQL (CTE, CTE récursive, ROW_NUMBER, LAG, DENSE_RANK, fenêtres cumulées, vues, contrôles qualité) ·
modélisation en étoile · DAX (time intelligence, RANKX, SUMX/RELATED, paramètres de simulation) ·
data storytelling.

---
Données entièrement synthétiques, générées pour ce projet. Toute ressemblance avec une entreprise existante serait fortuite.
