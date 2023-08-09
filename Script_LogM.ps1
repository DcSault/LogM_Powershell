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

# Demandez à l'utilisateur d'entrer le code
$chosenCode = Read-Host "Veuillez entrer le code"

# Utilisez Invoke-RestMethod pour obtenir le fichier JSON de la liste d'erreurs
$headers = @{
    "Content-Type" = "application/json"
}
$body = @{
    "code" = $chosenCode
} | ConvertTo-Json

$errorList = Invoke-RestMethod -Uri "http://localhost:3000/verify" -Method POST -Headers $headers -Body $body

# Lisez le contenu du fichier log
$logContent = Get-Content $latestLogFile.FullName

# Créez une table de hachage pour enregistrer les erreurs rencontrées
$foundErrors = @{}

# Parcourez chaque erreur dans la liste d'erreurs
foreach ($err in $errorList.data) {
    $escapedCode = [regex]::Escape($err.code)
    if (($logContent -match $escapedCode) -and (!$foundErrors[$err.code])) {
        $errorLine = $logContent | Where-Object { $_ -match $escapedCode } | Select-Object -Last 1
        
        if ($errorLine.Length -ge 19) {
            $errorTime = $errorLine.Substring(0, 19)
        } else {
            $errorTime = $errorLine
        }
        
        Write-Host "`n==================================================`n"
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
