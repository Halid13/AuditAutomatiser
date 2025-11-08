# User_Audit.ps1 — Audit simple des comptes utilisateurs

Ce dépôt contient un petit script PowerShell `User_Audit.ps1` qui lit un fichier CSV d'utilisateurs, identifie les comptes actifs dont la dernière connexion est plus ancienne qu'un seuil donné, exporte la liste et affiche un résumé en console. Ce README explique rapidement ce que fait le script et comment le tester pour l'utiliser dans un projet personnel.

## But

- Lire un fichier CSV d'utilisateurs (colonnes attendues : DisplayName, SamAccountName, Department, Enabled, LastLogonDate).
- Filtrer uniquement les comptes "actifs" (`Enabled` = `TRUE`) dont `LastLogonDate` est antérieure à la date limite calculée par `-Days` (par défaut 10 jours).
- Exporter les utilisateurs concernés dans `Inactive_ActiveUsers.csv`.
- Afficher un résumé console contenant le nombre total d'utilisateurs, le nombre d'utilisateurs actifs mais inactifs depuis plus de N jours, et la liste des départements concernés.

## Format attendu du CSV d'entrée

Le script suppose un CSV avec un en-tête similaire à :

DisplayName,SamAccountName,Department,Enabled,LastLogonDate

Exemples de valeurs :
- `Enabled` : `TRUE` ou `FALSE` (chaîne de caractères majuscules ou minuscules selon le fichier — le script gère `TRUE`)
- `LastLogonDate` : date sous forme ISO ou convertible par `[datetime]::Parse`, p. ex. `2025-10-15`.

Le repository contient un fichier d'exemple `pwsh_dataset.csv`.

## Paramètres du script

- `-Days` (int) : seuil d'inactivité en jours. Valeur par défaut : `10`.
- `-Path` (string) : chemin vers le fichier CSV d'entrée. Par défaut, le script utilise `Test Technique/pwsh_dataset.csv` (ou `pwsh_dataset.csv` selon l'implémentation). Vous pouvez passer un chemin relatif ou absolu.

## Utilisation

Ouvrez PowerShell dans le dossier `Test Technique` (ou adaptez le chemin) puis exécutez :

```powershell
# Exécution simple (utilise la valeur par défaut Days=10 et le CSV par défaut)
.\User_Audit.ps1

# Spécifier un seuil différent
.\User_Audit.ps1 -Days 15

# Spécifier un fichier CSV particulier
.\User_Audit.ps1 -Path ".\pwsh_dataset.csv"
```

Remarque : si votre politique d'exécution empêche l'exécution de scripts, vous pouvez exécuter la session courante temporairement :

```powershell
# (Exécuter en tant qu'administrateur si nécessaire)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\User_Audit.ps1
```

## Résultat attendu

- Un fichier `Inactive_ActiveUsers.csv` est créé dans le répertoire courant, contenant les colonnes `DisplayName, SamAccountName, Department, Enabled, LastLogonDate` pour les comptes identifiés.
- La console affiche un résumé, par exemple :

```
Total users: 4
Active but inactive > 10 days: 2
Departments concerned: Finance, HR
```

Les libellés exacts peuvent varier légèrement selon la version du script (français/anglais). Le CSV exporté contient les enregistrements filtrés.

## Exemples de tests (rapides)

1. Test de base avec le fichier fourni :
   - Placez-vous dans le dossier contenant `User_Audit.ps1` et `pwsh_dataset.csv`.
   - Lancez :

```powershell
.\User_Audit.ps1 -Days 10 -Path ".\pwsh_dataset.csv"
```

   - Vérifiez que `Inactive_ActiveUsers.csv` existe et contient uniquement les comptes actifs dont `LastLogonDate` est antérieur à `(Get-Date).AddDays(-10)`.

2. Test valeur extrême (aucun utilisateur trouvé) :

```powershell
.\User_Audit.ps1 -Days 0 -Path ".\pwsh_dataset.csv"
```

   - `-Days 0` sélectionnera les comptes dont la dernière connexion est antérieure à aujourd'hui (probablement zéro résultats si les dates sont récentes). Vérifiez que le script gère bien la situation et affiche `Aucun` ou `None` pour les départements.

3. Test d'un chemin inexistant :

```powershell
.\User_Audit.ps1 -Path ".\nonexistent.csv"
```

   - Le script doit afficher une erreur indiquant que le fichier est introuvable et se terminer proprement.

## Points d'amélioration possibles

- Normaliser la lecture du champ `Enabled` (gestion robuste de `True/False`, `1/0`, `Yes/No`).
- Supporter plusieurs formats de date avec `TryParseExact` si nécessaire.
- Ajouter un paramètre `-OutFile` pour contrôler le nom/chemin de sortie.
- Ajouter des tests unitaires Pester pour automatiser la validation des différents cas.

## Licence & usage

Ce script est un utilitaire simple fourni tel quel. Vous pouvez l'adapter pour vos besoins personnels ou l'intégrer dans vos workflows d'administration.

---

Si vous voulez, je peux :
- Ajouter le paramètre `-OutFile` et implémenter l'amélioration `Enabled` plus robuste.
- Ajouter un petit exemple automatisé (script de test) ou un fichier `pwsh_dataset.csv` de démonstration si besoin.