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
switch ($userChoice) {
    "1" { $folderPath = "C:\ProgramData\MICEN4\logs" }
    "2" { 
        $folderPath = Join-Path -Path $Env:LOCALAPPDATA -ChildPath "GenApi\RedactionActes\Log"
        Write-Host "`nVeuillez choisir le type de log:`n"
        Write-Host "1) Authentification`n2) Exception`n"
        $userSubChoice = Read-Host "Votre choix"
        switch ($userSubChoice) {
            "1" { $filter = "Log_Authentification*.log" }
            "2" { $filter = "iNot.Exceptions*.log" }
            default { Write-Host "Choix non reconnu, veuillez réessayer."; exit }
        }
    }
    default { Write-Host "Choix non reconnu, veuillez réessayer."; exit }
}

# Vérifiez si le dossier existe
if (!(Test-Path -Path $folderPath)) {
    Write-Host "Le dossier spécifié n'existe pas : $folderPath"
    exit
}

# Obtenez le fichier .log le plus récent en utilisant le filtre
$latestLogFile = Get-ChildItem -Path $folderPath -Filter $filter | Sort-Object LastAccessTime -Descending | Select-Object -First 1

# Imprimez le nom du fichier le plus récent avec une ligne de séparation
Write-Host "`n==================================================`n"
Write-Host "Fichier le plus recent: $($latestLogFile.FullName)" -ForegroundColor Cyan
Write-Host "`n==================================================`n"

# Utilisez Invoke-RestMethod pour obtenir le fichier JSON de la liste d'erreurs
$url = "https://raw.githubusercontent.com/DcSault/script_powershell/main/LogM/erreur.json?$(Get-Date -Format o)"
$errorList = Invoke-RestMethod -Uri $url

# Lisez le contenu du fichier log
$logContent = Get-Content $latestLogFile.FullName

# Créez une table de hachage pour enregistrer les erreurs rencontrées
$foundErrors = @{}

# Parcourez chaque erreur dans la liste d'erreurs
foreach ($err in $errorList) {
    # Vérifiez si le contenu du fichier log contient l'erreur et si l'erreur n'a pas déjà été trouvée
    if (($logContent -match $err.code) -and (!$foundErrors[$err.code])) {
        # Obtenez l'heure de l'erreur
        $errorLine = $logContent | Where-Object { $_ -match $err.code } | Select-Object -Last 1
        $errorTime = $errorLine.Substring(0, 19) # Adaptez cela en fonction du format d'horodatage de votre fichier log
        
        # Imprimez les détails de l'erreur avec des couleurs et des lignes de séparation
        Write-Host "Erreur trouvee: $($err.code)" -ForegroundColor Red
        Write-Host "TDA: $($err.tda)" -ForegroundColor Magenta
        Write-Host "Categorie: $($err.category)" -ForegroundColor Blue
        Write-Host "Heure: $errorTime" -ForegroundColor Yellow
        Write-Host "Description: $($err.description)" -ForegroundColor Green
        Write-Host "Solution: $($err.solution)" -ForegroundColor White
        Write-Host "`n==================================================`n"
        
        # Marquez l'erreur comme trouvée
        $foundErrors[$err.code] = $true
    }
}

# Pause et demande à l'utilisateur s'il souhaite ouvrir le fichier de log
Write-Host "`nVoulez-vous ouvrir le fichier de log dans le Bloc-notes ? (O/N)`n"
$input = Read-Host

# Vérifiez si l'utilisateur a répondu par 'O' ou 'o'
if ($input -eq "O" -or $input -eq "o") {
    # Ouvrir le fichier de journal avec Notepad
    Start-Process Notepad.exe -ArgumentList $latestLogFile.FullName
}

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
