# PowerShell Script pour la Gestion des Erreurs

Ce script permet à l'utilisateur de choisir un répertoire, puis de rechercher le fichier `.log` le plus récent dans ce répertoire. Il vérifie ensuite le contenu de ce fichier par rapport à une liste d'erreurs et affiche les détails des erreurs trouvées.

## 📜 Script

```powershell
# Demandez à l'utilisateur de choisir le répertoire
Write-Host "`nVeuillez choisir le repertoire:`n"
Write-Host "1) MICEN4`n2) INOT`n"

# Lisez le choix de l'utilisateur
$userChoice = Read-Host "Votre choix"

# Définissez le chemin du dossier et le filtre en fonction du choix de l'utilisateur
$filter = "*.log"
# ... [le reste du script est ici]

# Mettez le script en pause à la fin
pause
```

## 🖥 Fonctionnalités

1. **Choix du répertoire** : L'utilisateur choisit entre MICEN4 et INOT.
2. **Filtrage des logs** : Selon le choix du répertoire, l'utilisateur peut également choisir un type de log.
3. **Vérification de l'existence du dossier** : Le script vérifie si le dossier spécifié existe.
4. **Affichage du fichier .log le plus récent** : Le script trouve et affiche le fichier .log le plus récent.
5. **Comparaison avec une liste d'erreurs** : Le contenu du fichier .log est vérifié par rapport à une liste d'erreurs pour trouver les erreurs correspondantes.
6. **Affichage des détails des erreurs** : Les détails de chaque erreur trouvée sont affichés.
7. **Ouvrir le fichier de log** : À la fin, l'utilisateur a la possibilité d'ouvrir le fichier de log dans le Bloc-notes.

## 🛠 Utilisation
Pour exécuter ce script, ouvrez PowerShell et naviguez jusqu'au dossier contenant le script. Exécutez ensuite le script avec la commande :

```
.\Script_LogM.ps1
```
