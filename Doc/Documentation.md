# AuditAutomatiser

## Nom du projet
AuditAutomatiser

## Objectif du projet
Ce projet a deux objectifs principaux :

1. Faciliter les audits d'utilisateurs en entreprise en fournissant un petit utilitaire PowerShell pour détecter les comptes actifs mais inactifs depuis un certain nombre de jours et exporter la liste pour investigation.
2. Servir de support pédagogique pour apprendre la rédaction et l'analyse de scripts PowerShell (bonnes pratiques, gestion d'erreurs, formats de données).

## Contenu de la documentation
- But : identifier les comptes `Enabled` dont la `LastLogonDate` est antérieure à la date de cutoff (calculée à partir de `-Days`).
- Entrée : un CSV avec les colonnes attendues `DisplayName, SamAccountName, Department, Enabled, LastLogonDate`.
- Sortie : `Inactive_ActiveUsers.csv` contenant les comptes filtrés.

## Script analysé : `User_Audit.ps1`
Ci-dessous, j'explique chaque section / ligne importante du script fourni.

```powershell
param(
    [int]$Days = 10,
    [string]$Path = "Chemin\Vers\Votre\Fichier.csv"
)
```
- `param(...)` : définit les paramètres acceptés par le script quand on l'appelle.
  - `[int]$Days = 10` : paramètre entier `Days` avec valeur par défaut 10 (seuil en jours d'inactivité).
  - `[string]$Path = "Chemin\Vers\Votre\Fichier.csv"` : chemin par défaut vers le fichier CSV d'entrée.

```powershell
if (-not (Test-Path $Path)) {
    Write-Error "Fichier introuvable: $Path"
    exit 1
}
```
- `Test-Path $Path` : vérifie si le fichier passé via `$Path` existe.
- `-not` : négation logique ; si le fichier n'existe pas, on entre dans le bloc.
- `Write-Error` : écrit un message d'erreur (flux d'erreur). Utile pour debug/CI.
- `exit 1` : quitte le script avec le code de sortie `1` (indique une erreur).

```powershell
$csv = Import-Csv -Path $Path
```
- `Import-Csv` lit le fichier CSV et retourne un tableau d'objets PowerShell où chaque colonne est une propriété.
- `$csv` contient la collection d'enregistrements utilisateurs.

```powershell
$total = $csv.Count
```
- `$csv.Count` : nombre total de lignes (utilisateurs) importées depuis le CSV. Stocké pour le résumé en sortie.

```powershell
$cutoff = (Get-Date).AddDays(-$Days)
```
- `Get-Date` : obtient la date/heure actuelle.
- `.AddDays(-$Days)` : soustrait `$Days` jours pour calculer la date limite (cutoff). Les comptes dont `LastLogonDate` est antérieure à cette date sont considérés "inactifs".

```powershell
$filtered = $csv | Where-Object {
    $enabled = $_.Enabled -eq "True"
    $dt = $null
    if ($_.LastLogonDate) {
        try {
            $dt = [datetime]::Parse($_.LastLogonDate.ToString())
        } catch {
            $dt = $null
        }
    }
    $enabled -and $dt -and ($dt -lt $cutoff)
}
```
Explication détaillée du bloc `Where-Object` :
- `$csv | Where-Object { ... }` : pour chaque enregistrement (`$_`) on évalue une condition ; seuls les objets pour lesquels la condition est vraie sont conservés dans `$filtered`.
- `$enabled = $_.Enabled -eq "True"` : crée une variable booléenne `$enabled` qui est vraie si la propriété `Enabled` vaut la chaîne "True".
  - Remarque : l'opérateur `-eq` sur des chaînes en PowerShell est insensible à la casse par défaut, mais la comparaison suppose que le champ contient la valeur textuelle attendue.
  - Amélioration possible : normaliser la valeur (`$_.Enabled.ToString().Trim().ToLower()`), ou convertir en booléen robuste (`[bool]::TryParse(...)` ou tester `-in @('true','1','yes')`).
- `$dt = $null` : initialise `$dt`.
- `if ($_.LastLogonDate) { ... }` : si la colonne `LastLogonDate` n'est pas vide, on tente de la convertir en datetime.
  - `try { $dt = [datetime]::Parse($_.LastLogonDate.ToString()) } catch { $dt = $null }` : on tente la conversion ; en cas d'échec (`Parse` lève), on met `$dt` à `$null` pour ignorer l'enregistrement.
  - Remarque : `Parse` peut lever si le format n'est pas reconnu ; `TryParseExact` ou `Get-Date -Date` avec gestion d'erreurs peuvent être plus robustes.
- Condition finale : `$enabled -and $dt -and ($dt -lt $cutoff)`
  - On garde l'utilisateur seulement si : le compte est activé (`$enabled`), la date de dernière connexion a été parsée (`$dt` n'est pas `$null`) et la date est antérieure au cutoff (`$dt -lt $cutoff`).

```powershell
$filtered | Select-Object DisplayName,SamAccountName,Department,Enabled,LastLogonDate |
    Export-Csv -Path "Inactive_ActiveUsers.csv" -NoTypeInformation -Encoding UTF8
```
- `Select-Object ...` : sélectionne les colonnes à exporter pour garder un CSV propre et lisible.
- `Export-Csv -Path "Inactive_ActiveUsers.csv" -NoTypeInformation -Encoding UTF8` : écrit le CSV de sortie nommé `Inactive_ActiveUsers.csv` dans le répertoire courant, sans ajouter la ligne `#TYPE` et en encodage UTF-8.
  - Remarque : le nom est fixe. On pourrait ajouter un paramètre `-OutFile` pour laisser l'utilisateur choisir le chemin de sortie.

```powershell
$affected = $filtered.Count
```
- `$affected` : nombre d'utilisateurs trouvés par le filtre (utilisé pour le résumé).

```powershell
$departments = $filtered | ForEach-Object { $_.Department } | Where-Object { $_ } | Sort-Object -Unique
```
- Cette ligne :
  - Récupère la valeur `Department` pour chaque enregistrement filtré (`ForEach-Object { $_.Department }`).
  - `Where-Object { $_ }` filtre les valeurs non vides/nulles.
  - `Sort-Object -Unique` trie et supprime les doublons pour obtenir la liste unique des départements concernés.

```powershell
$deptList = if ($departments) { $departments -join ", " } else { "Aucun" }
```
- Si `$departments` n'est pas vide, on crée une chaîne comma-separated (`-join ", "`) ; sinon on met `"Aucun"`.

```powershell
Write-Output "Total users: $total"
Write-Output "Active but inactive > $Days days: $affected"
Write-Output "Departments concerned: $deptList"
```
- `Write-Output` affiche les informations de résumé en console. Ceci fournit un feedback rapide à l'opérateur.

## Remarques & améliorations proposées
- Robustesse sur le champ `Enabled` : accepter `true/false`, `1/0`, `yes/no` ou autres formats en normalisant la valeur ou en utilisant une conversion booléenne.
- Gestion des formats de date : utiliser `TryParseExact` ou tester plusieurs formats connus (ISO, dd/MM/yyyy, etc.) afin d'éviter les erreurs de parsing.
- Paramètre `-OutFile` : permettre de définir le nom et chemin du fichier de sortie.
- Mode `-WhatIf` / `-Confirm` pour certaines actions (utile si vous ajoutez suppression ou modifications ultérieures).
- Tests unitaires Pester : automatiser la validation (CSV avec dates valides/invalides, Enabled variés, fichiers manquants).
- Logging plus structuré : écrire un log détaillé avec timestamps ou utiliser `Write-Verbose`/`Write-Information` et `-Verbose` pour mode verbeux.

---

**Auteur :** Halid13
