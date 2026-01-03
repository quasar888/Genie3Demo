<#
.SYNOPSIS
    Configure correctement le remote Git pour le depot
.DESCRIPTION
    Configure l'upstream et les paramètres pour pousser vers GitHub
#>

Write-Host "=== CONFIGURATION GIT REMOTE ===" -ForegroundColor Cyan

# Vérifier Git
try {
    git --version | Out-Null
} catch {
    Write-Host "Git non installe" -ForegroundColor Red
    exit 1
}

# Vérifier le dépôt
if (-not (Test-Path ".git")) {
    Write-Host "Ce dossier n'est pas un depot Git" -ForegroundColor Red
    exit 1
}

# Informations actuelles
Write-Host "`n1. Informations actuelles:" -ForegroundColor Yellow
$currentBranch = git branch --show-current
Write-Host "  Branche: $currentBranch" -ForegroundColor Gray

$remotes = git remote -v
if ($remotes) {
    Write-Host "  Remotes:" -ForegroundColor Gray
    $remotes -split "`n" | ForEach-Object {
        Write-Host "    $_" -ForegroundColor Gray
    }
} else {
    Write-Host "  Aucun remote configure" -ForegroundColor Red
    exit 1
}

# Configurer l'upstream
Write-Host "`n2. Configuration de l'upstream..." -ForegroundColor Yellow
Write-Host "  Configuration de la branche $currentBranch..." -ForegroundColor Gray

# Essayer de configurer l'upstream
git push --set-upstream origin $currentBranch

if ($LASTEXITCODE -eq 0) {
    Write-Host "  Upstream configure avec succes!" -ForegroundColor Green
    
    # Configurer pour les futures branches
    git config push.autoSetupRemote true
    Write-Host "  Auto-setup configure pour les futures branches" -ForegroundColor Green
} else {
    Write-Host "  Erreur lors de la configuration" -ForegroundColor Red
    
    # Vérifier si le dépôt existe sur GitHub
    $remoteUrl = git config --get remote.origin.url
    Write-Host "`n3. Verification du depot distant..." -ForegroundColor Yellow
    Write-Host "  URL: $remoteUrl" -ForegroundColor Gray
    
    Write-Host "`n4. Solutions possibles:" -ForegroundColor Yellow
    Write-Host "  A. Creer le depot sur GitHub d'abord" -ForegroundColor White
    Write-Host "  B. Verifier les permissions" -ForegroundColor White
    Write-Host "  C. Utiliser un token d'acces personnel" -ForegroundColor White
    
    $choice = Read-Host "`nChoisissez une option (A/B/C) ou Q pour quitter"
    
    switch ($choice.ToUpper()) {
        "A" {
            Write-Host "Ouvrez https://github.com/new" -ForegroundColor Cyan
            Write-Host "Nom du depot: Genie3Demo" -ForegroundColor White
            Write-Host "Visibilite: Public" -ForegroundColor White
            Write-Host "NE PAS initialiser avec README" -ForegroundColor White
            Start-Process "https://github.com/new"
        }
        "C" {
            Write-Host "Pour creer un token:" -ForegroundColor White
            Write-Host "1. Allez sur: https://github.com/settings/tokens" -ForegroundColor Gray
            Write-Host "2. Cliquez sur 'Generate new token'" -ForegroundColor Gray
            Write-Host "3. Donnez-lui un nom (ex: Genie3Demo)" -ForegroundColor Gray
            Write-Host "4. Selectionnez 'repo' pour les permissions" -ForegroundColor Gray
            Write-Host "5. Copiez le token et utilisez-le comme mot de passe" -ForegroundColor Gray
        }
    }
}

# Vérification finale
Write-Host "`n5. Verification finale:" -ForegroundColor Yellow
git remote show origin

Write-Host "`n=== CONFIGURATION TERMINEE ===" -ForegroundColor Green
Write-Host "`nExecutez .\Update-GitRepo-Fixed.ps1 pour mettre a jour le depot" -ForegroundColor Yellow

pause