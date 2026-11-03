/* =====================================================================
   DistriNova | 07 - Contrôles qualité (à relancer après chaque modification)
   ---------------------------------------------------------------------
   Chaque requête doit renvoyer 0 ligne ou la valeur attendue indiquée.
   Idées de contrôles à écrire :
     - unicité des clés (id_site, id_machine, id_produit, id_ticket, id_transaction)
     - intégrité : toute machine pointe vers un site, toute vente vers une machine et un produit
     - conversions : aucune valeur NULL là où le texte bronze n'était pas vide
     - réconciliation : CA silver.ventes = CA gold.fact_ventes = somme des P&L par machine
     - cohérence : aucune vente hors de la période d'installation de sa machine
   ===================================================================== */
USE DistriNova;
GO

-- TODO
