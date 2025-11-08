Super, je te fais une version **propre + lisible + stylée**, avec **emojis élégants** (pas trop, juste pour donner du charme ✨).
Toujours claire, pro, mais plus agréable à lire.

---

# 🧾 Audit des comptes utilisateurs inactifs — `User_Audit.ps1`

Ce script PowerShell analyse un fichier CSV d'utilisateurs pour identifier les **comptes actifs** qui **ne se sont pas connectés depuis un certain nombre de jours**.
Il exporte ces comptes dans un fichier et affiche un résumé clair en console.

---

## 🎯 Objectif

* Lire un fichier CSV d'utilisateurs
* Filtrer les comptes **Enabled = TRUE**
* Détecter ceux dont la dernière connexion remonte à plus de **N jours**
* Exporter le résultat dans `Inactive_ActiveUsers.csv`
* Afficher un résumé rapide 📊

---

## 🔧 Paramètres

| Paramètre | Rôle                         | Valeur par défaut  |
| --------- | ---------------------------- | ------------------ |
| `-Days`   | Nombre de jours d'inactivité | `10`               |
| `-Path`   | Chemin du fichier CSV source | `pwsh_dataset.csv` |

---

## ▶️ Exemples d’utilisation

```powershell
# Exécution simple
.\User_Audit.ps1

# Modifier le seuil d’inactivité
.\User_Audit.ps1 -Days 15

# Utiliser un CSV spécifique
.\User_Audit.ps1 -Path ".\mon_fichier.csv"
```

💡 Si l'exécution des scripts est bloquée :

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

---

## 📦 Résultat obtenu

Le script génère :

* Un fichier : **`Inactive_ActiveUsers.csv`**
* Un résumé dans la console, par exemple :

```
Total users: 120
Active but inactive > 10 days: 18
Departments concerned: IT, Finance, Sales
```

---

## 📄 Format CSV attendu

```
DisplayName,SamAccountName,Department,Enabled,LastLogonDate
Doe John,jdoe,IT,TRUE,2025-01-12
```

---

## 🚀 Améliorations possibles

* Support de plusieurs formats de date
* Gestion souple du champ `Enabled` (`true/false`, `1/0`, etc.)
* Paramètre `-OutFile` pour choisir le nom du fichier exporté
* Tests automatisés (Pester) pour valider le comportement

---

**Auteur :** Halid13

