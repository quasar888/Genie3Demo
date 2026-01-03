<#
.SYNOPSIS
    Met a jour le depot Git avec les derniers changements
.DESCRIPTION
    Ajoute tous les changements, cree un commit et pousse vers GitHub
.PARAMETER Message
    Message du commit (optionnel)
.EXAMPLE
    .\Update-GitRepo.ps1 -Message "Ajout nouvelle fonctionnalite"
    .\Update-GitRepo.ps1 "Correction de bug"
#>

param(
    [Parameter(Position=0)]
    [string]$Message = "Mise a jour " + (Get-Date -Format "yyyy-MM-dd HH:mm")
)

Write-Host "=== MISE A JOUR DU DEPOT GIT ===" -ForegroundColor Cyan

# Verification Git
try {
    git --version | Out-Null
} catch {
    Write-Host "Git non installe" -ForegroundColor Red
    exit 1
}

# Verification du depot
if (-not (Test-Path ".git")) {
    Write-Host "Ce dossier n'est pas un depot Git" -ForegroundColor Red
    exit 1
}

# Status
Write-Host "
Etat actuel:" -ForegroundColor Yellow
git status --short

# Ajout des fichiers
Write-Host "
Ajout des fichiers..." -ForegroundColor Yellow
git add .

# Commit
Write-Host "Creation du commit..." -ForegroundColor Yellow
git commit -m "$Message"

if ($LASTEXITCODE -eq 0) {
    Write-Host "Commit cree avec succes" -ForegroundColor Green
    
    # Push
    Write-Host "Envoi vers GitHub..." -ForegroundColor Yellow
    git push
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Mise a jour terminee avec succes!" -ForegroundColor Green
        Write-Host "Depot: https://github.com/quasar888/Genie3Demo" -ForegroundColor Cyan
    } else {
        Write-Host "Erreur lors du push" -ForegroundColor Red
    }
} else {
    Write-Host "Aucun changement a committer" -ForegroundColor Yellow
}

Write-Host "
Appuyez sur une touche pour continuer..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
