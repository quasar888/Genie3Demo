<#
.SYNOPSIS
    Configure un dépôt Git pour le projet Genie3Demo et le pousse sur GitHub
.DESCRIPTION
    Ce script initialise un dépôt Git local, configure les informations,
    crée un dépôt distant sur GitHub et pousse le code
.NOTES
    Version: 1.1 (Corrigé pour création de dépôt)
    Auteur: Assistant IA
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Username = "quasar888",
    
    [Parameter(Mandatory=$true)]
    [string]$Password = "Blazor18"
)

# Fonction pour l'affichage coloré
function Write-Status {
    param([string]$Message, [string]$Color = "White", [string]$Prefix = "[*]")
    Write-Host "$Prefix $Message" -ForegroundColor $Color
}

function Write-Success {
    param([string]$Message)
    Write-Status $Message "Green" "[+]"
}

function Write-Error {
    param([string]$Message)
    Write-Status $Message "Red" "[-]"
}

function Write-Info {
    param([string]$Message)
    Write-Status $Message "Cyan" "[i]"
}

function Write-Warning {
    param([string]$Message)
    Write-Status $Message "Yellow" "[!]"
}

# Configuration
$RepoName = "Genie3Demo"
$RepoDescription = "Google DeepMind IAG Simulation Demo - C# .NET Console Application"
$CurrentDir = Get-Location

Write-Status "=== CONFIGURATION GIT POUR GENIE3DEMO ===" "Cyan"
Write-Info "Utilisateur: $Username"
Write-Info "Depot: $RepoName"
Write-Info "Dossier: $CurrentDir"

# Vérification du dossier
if (-not (Test-Path ".\Run-Genie3Demo.ps1")) {
    Write-Error "Script Run-Genie3Demo.ps1 non trouve"
    Write-Info "Executez ce script depuis: C:\Users\Cle\source\repos\Genie3Demo"
    pause
    exit 1
}

# Étape 1: Vérification Git
Write-Info "Etape 1: Verification de Git..."
try {
    $gitVersion = git --version
    Write-Success "Git: $gitVersion"
} catch {
    Write-Error "Git non installe"
    Write-Info "Installez Git depuis: https://git-scm.com/download/win"
    pause
    exit 1
}

# Étape 2: Vérification des credentials GitHub
Write-Info "Etape 2: Verification des credentials GitHub..."
$githubToken = $Password
$isToken = $false

# Vérification si c'est un token ou un mot de passe
if ($Password.Length -eq 40 -and $Password -match "^[a-fA-F0-9]{40}$") {
    Write-Info "Token GitHub detecte"
    $isToken = $true
} else {
    Write-Warning "Mot de passe detecte (recommande: utiliser un token)"
    Write-Info "Creer un token: https://github.com/settings/tokens"
    Write-Info "Permissions necessaires: repo, write:packages, delete:packages"
}

# Étape 3: Création du dépôt sur GitHub
Write-Info "Etape 3: Creation du depot sur GitHub..."
$createRepo = $true
$repoUrl = "https://github.com/$Username/$RepoName"
$remoteUrl = "https://github.com/$Username/$RepoName.git"

try {
    # Essai de récupération du dépôt existant
    $headers = @{
        "Authorization" = "token $githubToken"
        "Accept" = "application/vnd.github.v3+json"
    }
    
    $repoInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/$Username/$RepoName" `
                                  -Headers $headers `
                                  -Method Get `
                                  -ErrorAction SilentlyContinue
    
    if ($repoInfo) {
        Write-Success "Depot existe deja: $repoUrl"
        $createRepo = $false
    }
} catch {
    Write-Info "Depot non trouve, creation..."
}

if ($createRepo) {
    try {
        $body = @{
            name = $RepoName
            description = $RepoDescription
            private = $false
            auto_init = $false
            gitignore_template = "VisualStudio"
            license_template = "mit"
        } | ConvertTo-Json -Compress
        
        $headers = @{
            "Authorization" = "token $githubToken"
            "Accept" = "application/vnd.github.v3+json"
            "Content-Type" = "application/json"
        }
        
        $response = Invoke-RestMethod -Uri "https://api.github.com/user/repos" `
                                      -Headers $headers `
                                      -Method Post `
                                      -Body $body
        
        Write-Success "Depot cree sur GitHub: $($response.html_url)"
        Write-Success "URL SSH: $($response.ssh_url)"
        Write-Success "URL HTTPS: $($response.clone_url)"
        
        # Attendre que le dépôt soit prêt
        Write-Info "Attente de la creation du depot..."
        Start-Sleep -Seconds 3
        
    } catch {
        Write-Error "Erreur lors de la creation du depot: $_"
        Write-Warning "Creation manuelle necessaire"
        Write-Info "1. Allez sur: https://github.com/new"
        Write-Info "2. Nom: $RepoName"
        Write-Info "3. Description: $RepoDescription"
        Write-Info "4. Public"
        Write-Info "5. Ne PAS initialiser avec README"
        Write-Info "6. .gitignore: VisualStudio"
        Write-Info "7. Licence: MIT"
        
        $choice = Read-Host "Apres avoir cree le depot, appuyez sur (C) pour continuer ou (Q) pour quitter"
        if ($choice -eq "Q" -or $choice -eq "q") {
            exit
        }
    }
}

# Étape 4: Initialisation Git locale
Write-Info "Etape 4: Initialisation locale Git..."

if (Test-Path ".git") {
    Write-Info "Depot Git local deja initialise"
} else {
    git init
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Depot Git initialise"
    } else {
        Write-Error "Erreur d'initialisation Git"
        exit 1
    }
}

# Étape 5: Configuration Git
Write-Info "Etape 5: Configuration Git..."
git config user.name $Username
git config user.email "$Username@users.noreply.github.com"

# Configuration de la branche par défaut
git config init.defaultBranch main

Write-Success "Configuration Git terminee"

# Étape 6: Création des fichiers Git
Write-Info "Etape 6: Creation des fichiers Git..."

# .gitignore
$gitignore = @"
# Visual Studio
.vs/
*.suo
*.user
*.userosscache
*.sln.docstates

# Build results
[Dd]ebug/
[Dd]ebugPublic/
[Rr]elease/
[Rr]eleases/
x64/
x86/
[Ww][Ii][Nn]32/
[Aa][Rr][Mm]/
[Aa][Rr][Mm]64/
bld/
[Bb]in/
[Oo]bj/
[Oo]ut/
msbuild.log
msbuild.err
msbuild.wrn

# Output
Genie3Output/
Genie3_Export_*.txt
/output/
/build/

# Executables
*.exe
*.dll
*.pdb

# PowerShell
*.ps1xml
*.pssc
*.psm1

# Temporary files
*.tmp
*.temp
*.log
*.bak
"@

$gitignore | Out-File -FilePath ".\.gitignore" -Encoding UTF8
Write-Success ".gitignore cree"

# README.md
$readme = @"
# Genie3Demo - Google DeepMind IAG Simulation

Application console C# .NET simulant une architecture IA de type Google DeepMind avec IA Generative.

## Description

Ce projet demontre une simulation d'intelligence artificielle generative inspiree des systemes Google DeepMind. Il inclut:

- **Module NLP** : Traitement du langage naturel
- **Module de generation creative** : IA generative (IAG)
- **Module d'apprentissage par renforcement** : Simulation RL
- **Systeme cognitif** : Etat mental simule de l'IA

## Fonctionnalites

1. **Simulation NLP** : Comprehension et generation de reponses
2. **Generation d'idees** : Creation de concepts innovants
3. **Entrainement RL** : Simulation d'apprentissage par renforcement
4. **Export de donnees** : Generation de rapports d'analyse
5. **Interface console interactive** : Session utilisateur pas-a-pas

## Technologies

- C# .NET Framework 4.0+
- Compatible C# 5
- PowerShell pour l'automatisation
- Git pour le controle de version

## Installation

1. Clonez le depot:
\`\`\`bash
git clone https://github.com/$Username/$RepoName.git
\`\`\`

2. Executez le script PowerShell:
\`\`\`powershell
cd Genie3Demo
.\Run-Genie3Demo.ps1
\`\`\`

## Structure du projet

\`\`\`
Genie3Demo/
├── Run-Genie3Demo.ps1          # Script principal
├── Setup-GitRepo.ps1           # Configuration Git
├── Genie3DeepMindDemo.cs       # Code source C#
├── .gitignore                  # Fichiers ignores
└── README.md                   # Documentation
\`\`\`

## Utilisation

L'application demarre une session interactive avec 4 phases:

1. **Phase 1** : Traitement du langage naturel
2. **Phase 2** : Generation creative d'idees
3. **Phase 3** : Simulation d'apprentissage par renforcement
4. **Phase 4** : Export des resultats

## Exigences

- Windows 7+
- .NET Framework 4.0 ou superieur
- PowerShell 5.0+
- Git (pour le controle de version)

## Auteur

- **$Username** - Developpement initial

## Licence

Ce projet est sous licence MIT. Voir le fichier LICENSE pour plus de details.
"@

$readme | Out-File -FilePath ".\README.md" -Encoding UTF8
Write-Success "README.md cree"

# Étape 7: Ajout des fichiers au staging
Write-Info "Etape 7: Ajout des fichiers..."

# Liste des fichiers à ajouter
$files = @(
    "Run-Genie3Demo.ps1",
    "Setup-GitRepo-Fixed.ps1",
    "Setup-GitRepo.ps1",
    "Check-GitStatus.ps1",
    "README.md",
    ".gitignore"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        git add $file
        Write-Info "  Ajoute: $file"
    }
}

# Ajout des fichiers C# s'ils existent
if (Test-Path ".\Genie3Output\Genie3DeepMindDemo.cs") {
    git add ".\Genie3Output\Genie3DeepMindDemo.cs"
    Write-Info "  Ajoute: Genie3Output\Genie3DeepMindDemo.cs"
}

# Ajout récursif des fichiers .ps1 et .cs
Get-ChildItem -Filter "*.ps1" -Recurse | Where-Object { $_.Directory.Name -ne ".git" } | ForEach-Object {
    git add $_.FullName
    Write-Info "  Ajoute: $($_.Name)"
}

Get-ChildItem -Filter "*.cs" -Recurse | Where-Object { $_.Directory.Name -ne ".git" } | ForEach-Object {
    git add $_.FullName
    Write-Info "  Ajoute: $($_.Name)"
}

Write-Success "Fichiers ajoutes"

# Étape 8: Commit initial
Write-Info "Etape 8: Commit initial..."

$commitMessage = @"
Initial commit - Genie3 Google DeepMind IAG Simulation

Project: Simulation d'architecture IA type Google DeepMind
Version: 1.0
Author: $Username

Contenu:
- Application console C# .NET simulant l'IA generative
- Modules NLP, generation creative et apprentissage par renforcement
- Script PowerShell d'automatisation et de configuration
- Documentation README
- Compatible C# 5 / .NET Framework 4.0+

Fonctionnalites principales:
1. Traitement du langage naturel (NLP)
2. Generation d'idees creatives (IAG)
3. Simulation d'apprentissage par renforcement (RL)
4. Systeme cognitif avec etat mental
5. Export de donnees au format texte
"@

git commit -m $commitMessage

if ($LASTEXITCODE -eq 0) {
    Write-Success "Commit cree avec succes"
    
    # Afficher le commit
    git log --oneline -1
} else {
    Write-Error "Erreur lors du commit"
    Write-Info "Verifiez s'il y a des changements: git status"
    git status
    exit 1
}

# Étape 9: Configuration de la remote
Write-Info "Etape 9: Configuration du depot distant..."

# Vérifier si la remote existe déjà
$remotes = git remote -v
if ($remotes -like "*origin*") {
    Write-Info "Remote 'origin' existe deja"
    git remote set-url origin $remoteUrl
    Write-Success "URL de origin mise a jour"
} else {
    git remote add origin $remoteUrl
    Write-Success "Remote 'origin' ajoutee: $remoteUrl"
}

# Étape 10: Push vers GitHub
Write-Info "Etape 10: Envoi vers GitHub..."

# Vérification de la branche actuelle
$currentBranch = git branch --show-current
if (-not $currentBranch) {
    # Créer la branche main si elle n'existe pas
    git branch -M main
    $currentBranch = "main"
}

Write-Info "Branche actuelle: $currentBranch"
Write-Info "URL distante: $remoteUrl"

# Configuration des credentials pour cette session
$credentialHelper = git config credential.helper
if (-not $credentialHelper) {
    git config credential.helper "store --file=.git-credentials"
    Write-Info "Helper credential configure"
}

# Essai de push
Write-Info "Envoi en cours..."
try {
    # Force push pour la première fois
    git push -u origin $currentBranch --force
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Code envoye avec succes vers GitHub!"
        Write-Success "Depot disponible: $repoUrl"
        
        # Vérification
        Write-Info "Verification du push..."
        git log --oneline -3
    } else {
        Write-Error "Erreur lors du push (code: $LASTEXITCODE)"
        
        # Essai alternatif avec token dans l'URL
        Write-Info "Essai avec authentification directe..."
        $tokenUrl = $remoteUrl.Replace("https://", "https://${Username}:${githubToken}@")
        git push $tokenUrl $currentBranch --force
    }
} catch {
    Write-Error "Exception lors du push: $_"
}

# Étape 11: Vérification finale
Write-Info "`n=== VERIFICATION FINALE ==="

Write-Info "Etat du depot local:"
git status

Write-Info "`nBranches:"
git branch -a

Write-Info "`nDerniers commits:"
git log --oneline -3

Write-Info "`nRemotes:"
git remote -v

# Étape 12: Création d'un script de mise à jour
Write-Info "`nEtape 12: Creation d'un script de mise a jour..."

$updateScript = @"
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
    [string]`$Message = "Mise a jour " + (Get-Date -Format "yyyy-MM-dd HH:mm")
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
Write-Host "`nEtat actuel:" -ForegroundColor Yellow
git status --short

# Ajout des fichiers
Write-Host "`nAjout des fichiers..." -ForegroundColor Yellow
git add .

# Commit
Write-Host "Creation du commit..." -ForegroundColor Yellow
git commit -m "`$Message"

if (`$LASTEXITCODE -eq 0) {
    Write-Host "Commit cree avec succes" -ForegroundColor Green
    
    # Push
    Write-Host "Envoi vers GitHub..." -ForegroundColor Yellow
    git push
    
    if (`$LASTEXITCODE -eq 0) {
        Write-Host "Mise a jour terminee avec succes!" -ForegroundColor Green
        Write-Host "Depot: https://github.com/$Username/$RepoName" -ForegroundColor Cyan
    } else {
        Write-Host "Erreur lors du push" -ForegroundColor Red
    }
} else {
    Write-Host "Aucun changement a committer" -ForegroundColor Yellow
}

Write-Host "`nAppuyez sur une touche pour continuer..." -ForegroundColor Gray
`$null = `$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
"@

$updateScript | Out-File -FilePath ".\Update-GitRepo.ps1" -Encoding UTF8
Write-Success "Script de mise a jour cree: Update-GitRepo.ps1"

# Étape 13: Résumé
Write-Status "`n=== CONFIGURATION TERMINEE ===" "Green"

Write-Host "`nINFORMATIONS:" -ForegroundColor Cyan
Write-Host "  Depot local:  $CurrentDir" -ForegroundColor White
Write-Host "  Depot GitHub: $repoUrl" -ForegroundColor White
Write-Host "  Utilisateur:  $Username" -ForegroundColor White
Write-Host "  Branche:      $currentBranch" -ForegroundColor White

Write-Host "`nCOMMANDES UTILES:" -ForegroundColor Cyan
Write-Host "  .\Update-GitRepo.ps1                          " -NoNewline -ForegroundColor Gray
Write-Host "# Mettre a jour le depot" -ForegroundColor White

Write-Host "  .\Check-GitStatus.ps1                         " -NoNewline -ForegroundColor Gray
Write-Host "# Verifier l'etat Git" -ForegroundColor White

Write-Host "  git status                                    " -NoNewline -ForegroundColor Gray
Write-Host "# Voir l'etat" -ForegroundColor White

Write-Host "  git log --oneline -5                          " -NoNewline -ForegroundColor Gray
Write-Host "# Voir l'historique" -ForegroundColor White

Write-Host "  git push                                      " -NoNewline -ForegroundColor Gray
Write-Host "# Envoyer les changements" -ForegroundColor White

Write-Host "`nPROCHAINES ETAPES:" -ForegroundColor Cyan
Write-Host "  1. Ouvrez $repoUrl dans votre navigateur" -ForegroundColor White
Write-Host "  2. Modifiez des fichiers" -ForegroundColor White
Write-Host "  3. Executez .\Update-GitRepo.ps1 pour pousser" -ForegroundColor White
Write-Host "  4. Consultez l'historique sur GitHub" -ForegroundColor White

# Ouverture du dépôt dans le navigateur
$openBrowser = Read-Host "`nOuvrir le depot dans le navigateur? (O/N)"
if ($openBrowser -eq "O" -or $openBrowser -eq "o") {
    Start-Process $repoUrl
}

# Nettoyage des credentials
Clear-Variable -Name Password -ErrorAction SilentlyContinue
Clear-Variable -Name githubToken -ErrorAction SilentlyContinue
Clear-Variable -Name Username -ErrorAction SilentlyContinue
[GC]::Collect()

Write-Success "`nConfiguration complete!"
Write-Host "`nAppuyez sur Entree pour quitter..." -ForegroundColor Gray
pause