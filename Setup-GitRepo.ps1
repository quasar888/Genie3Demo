<#
.SYNOPSIS
    Configure un dépôt Git pour le projet Genie3Demo et le pousse sur GitHub
.DESCRIPTION
    Ce script initialise un dépôt Git local, configure les informations,
    crée un dépôt distant sur GitHub et pousse le code
.PARAMETER Username
    Nom d'utilisateur GitHub
.PARAMETER Password
    Mot de passe ou token GitHub
.NOTES
    Version: 1.0
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

# Configuration
$RepoName = "Genie3Demo"
$RepoDescription = "Google DeepMind IAG Simulation Demo - C# .NET Console Application"
$RemoteUrl = "https://github.com/$Username/$RepoName.git"
$CurrentDir = Get-Location

# Vérification que nous sommes dans le bon dossier
Write-Info "Verification du dossier courant..."
Write-Info "Dossier actuel: $CurrentDir"

if (-not (Test-Path ".\Genie3Output") -and -not (Test-Path ".\Run-Genie3Demo.ps1")) {
    Write-Error "Ce script doit etre execute depuis le dossier Genie3Demo"
    Write-Info "Dossier attendu: C:\Users\Cle\source\repos\Genie3Demo"
    pause
    exit 1
}

# Étape 1: Vérification de Git
Write-Info "Etape 1: Verification de Git..."
try {
    $gitVersion = git --version
    Write-Success "Git trouve: $gitVersion"
} catch {
    Write-Error "Git n'est pas installe ou n'est pas dans le PATH"
    Write-Info "Veuillez installer Git depuis: https://git-scm.com/download/win"
    pause
    exit 1
}

# Étape 2: Initialisation du dépôt local
Write-Info "Etape 2: Initialisation du depot Git local..."
if (Test-Path "\.git") {
    Write-Info "Depot Git deja initialise dans ce dossier"
} else {
    git init
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Erreur lors de l'initialisation Git"
        exit 1
    }
    Write-Success "Depot Git initialise avec succes"
}

# Étape 3: Configuration Git
Write-Info "Etape 3: Configuration de Git..."
git config user.name "$Username"
git config user.email "$Username@users.noreply.github.com"
git config credential.helper store

Write-Success "Configuration Git terminee"

# Étape 4: Création du fichier .gitignore
Write-Info "Etape 4: Creation du fichier .gitignore..."
$gitignoreContent = @"
# Fichiers de compilation
bin/
obj/
*.exe
*.pdb
*.dll
*.cache

# Fichiers temporaires
*.tmp
*.temp
*.log
*.bak
*.suo
*.user
*.userosscache
*.sln.docstates

# Fichiers d'IDE
.vs/
.vscode/
*.swp
*.*~
.project
.classpath
.settings/

# Fichiers de sortie
Genie3Output/
Genie3_Export_*.txt
/output/
/build/

# Fichiers de donnees
*.db
*.mdf
*.ldf

# Fichiers secrets
*.secret
*.key
*.pem
appsettings.*.json

# Fichiers OS
Thumbs.db
.DS_Store
Desktop.ini

# PowerShell
*.ps1xml

# Fichiers de projet specifiques
packages/
TestResults/
*.DotSettings
_ReSharper.*
"@

$gitignoreContent | Out-File -FilePath ".\.gitignore" -Encoding UTF8
Write-Success "Fichier .gitignore cree"

# Étape 5: Vérification de la connexion GitHub
Write-Info "Etape 5: Verification de la connexion a GitHub..."
$testConnection = $null
try {
    # Test de connexion basique à l'API GitHub
    $headers = @{
        "Authorization" = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${Username}:${Password}"))
    }
    
    $testConnection = Invoke-RestMethod -Uri "https://api.github.com/user" -Headers $headers -Method Get
    Write-Success "Connexion GitHub reussie: $($testResponse.login)"
} catch {
    Write-Info "Note: Le mot de passe peut etre un token d'acces personnel"
    Write-Info "Pour creer un token: https://github.com/settings/tokens"
}

# Étape 6: Création du dépôt distant sur GitHub
Write-Info "Etape 6: Creation du depot distant sur GitHub..."
try {
    $body = @{
        name = $RepoName
        description = $RepoDescription
        private = $false
        auto_init = $false
        gitignore_template = "VisualStudio"
    } | ConvertTo-Json
    
    $headers = @{
        "Authorization" = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${Username}:${Password}"))
        "Accept" = "application/vnd.github.v3+json"
        "Content-Type" = "application/json"
    }
    
    $response = Invoke-RestMethod -Uri "https://api.github.com/user/repos" -Headers $headers -Method Post -Body $body
    
    Write-Success "Depot GitHub cree: $($response.html_url)"
    $RemoteUrl = $response.clone_url
    
} catch {
    Write-Info "Le depot existe peut-etre deja ou erreur de creation"
    Write-Info "Verification de l'existence du depot..."
    
    try {
        $checkRepo = Invoke-RestMethod -Uri "https://api.github.com/repos/$Username/$RepoName" -Method Get
        Write-Info "Depot existe deja: $($checkRepo.html_url)"
    } catch {
        Write-Error "Impossible de verifier/creer le depot distant"
        Write-Info "Creation manuelle requise: https://github.com/new"
        Write-Info "Nom du depot: $RepoName"
        Write-Info "Description: $RepoDescription"
        Write-Info "Visibilite: Public"
        
        $createManual = Read-Host "Voulez-vous creer le depot manuellement? (O/N)"
        if ($createManual -eq "O" -or $createManual -eq "o") {
            Start-Process "https://github.com/new"
            Write-Info "Apres la creation, appuyez sur Entree pour continuer..."
            pause
        }
    }
}

# Étape 7: Ajout des fichiers
Write-Info "Etape 7: Ajout des fichiers au depot local..."

# Liste des fichiers à ajouter
$filesToAdd = @(
    "Run-Genie3Demo.ps1",
    "Setup-GitRepo.ps1",
    ".gitignore",
    "Genie3Output\Genie3DeepMindDemo.cs"
)

foreach ($file in $filesToAdd) {
    if (Test-Path $file) {
        git add $file
        Write-Info "  Ajoute: $file"
    }
}

# Ajout de tous les fichiers .ps1
Get-ChildItem -Filter "*.ps1" | ForEach-Object {
    git add $_.FullName
    Write-Info "  Ajoute: $($_.Name)"
}

# Ajout des fichiers C#
Get-ChildItem -Filter "*.cs" -Recurse | ForEach-Object {
    git add $_.FullName
    Write-Info "  Ajoute: $($_.Name)"
}

Write-Success "Fichiers ajoutes au staging area"

# Étape 8: Commit initial
Write-Info "Etape 8: Creation du commit initial..."
$commitMessage = "Initial commit - Genie3 Google DeepMind IAG Simulation Demo

- Application console C# .NET simulant l'IA generative
- Modules NLP, generation creative et apprentissage par renforcement
- Script PowerShell d'automatisation
- Compatible C# 5 / .NET Framework 4.0+

Project: Simulation d'architecture IA type Google DeepMind"

git commit -m $commitMessage

if ($LASTEXITCODE -ne 0) {
    Write-Error "Erreur lors du commit. Verifiez s'il y a des changements a committer."
    git status
} else {
    Write-Success "Commit initial cree avec succes"
}

# Étape 9: Configuration de la remote
Write-Info "Etape 9: Configuration du depot distant..."
$currentRemote = git remote -v
if ($currentRemote -like "*$RepoName*") {
    Write-Info "Remote deja configuree"
} else {
    git remote add origin $RemoteUrl
    Write-Success "Remote 'origin' configuree: $RemoteUrl"
}

# Étape 10: Push vers GitHub
Write-Info "Etape 10: Push vers GitHub..."
Write-Info "URL: $RemoteUrl"
Write-Info "Utilisateur: $Username"

try {
    # Configuration des credentials
    $credentialUrl = $RemoteUrl.Replace("https://", "https://${Username}:${Password}@")
    
    Write-Info "Envoi du code vers GitHub..."
    git push -u origin main
    
    if ($LASTEXITCODE -ne 0) {
        # Essai avec la branche master
        Write-Info "Essai avec la branche 'master'..."
        git push -u origin master
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Code pousse avec succes vers GitHub!"
        
        # Récupération de l'URL du dépôt
        $repoUrl = "https://github.com/$Username/$RepoName"
        Write-Success "Depot disponible a: $repoUrl"
        
        # Ouverture dans le navigateur
        $openBrowser = Read-Host "Voulez-vous ouvrir le depot dans le navigateur? (O/N)"
        if ($openBrowser -eq "O" -or $openBrowser -eq "o") {
            Start-Process $repoUrl
        }
    } else {
        Write-Error "Erreur lors du push"
        Write-Info "Verifiez vos credentials et votre connexion internet"
    }
    
} catch {
    Write-Error "Erreur lors du push: $_"
}

# Étape 11: Résumé final
Write-Info "`n=== RESUME DE LA CONFIGURATION ==="
Write-Host "Depot local:  $CurrentDir" -ForegroundColor Cyan
Write-Host "Depot distant: $RemoteUrl" -ForegroundColor Cyan
Write-Host "Nom du depot:  $RepoName" -ForegroundColor Cyan
Write-Host "Utilisateur:   $Username" -ForegroundColor Cyan

git status
Write-Info "`nCommandes Git utiles:"
Write-Host "  git status                          " -NoNewline -ForegroundColor Gray
Write-Host "# Voir l'etat du depot" -ForegroundColor White

Write-Host "  git log --oneline                   " -NoNewline -ForegroundColor Gray
Write-Host "# Voir l'historique" -ForegroundColor White

Write-Host "  git pull origin main               " -NoNewline -ForegroundColor Gray
Write-Host "# Recuperer les changements" -ForegroundColor White

Write-Host "  git add .                          " -NoNewline -ForegroundColor Gray
Write-Host "# Ajouter tous les changements" -ForegroundColor White

Write-Host "  git commit -m 'message'            " -NoNewline -ForegroundColor Gray
Write-Host "# Creer un commit" -ForegroundColor White

Write-Host "  git push                           " -NoNewline -ForegroundColor Gray
Write-Host "# Envoyer les changements" -ForegroundColor White

Write-Success "`nConfiguration Git terminee!"

# Nettoyage des credentials en mémoire
Clear-Variable -Name Password -ErrorAction SilentlyContinue
Clear-Variable -Name Username -ErrorAction SilentlyContinue
[GC]::Collect()

Write-Info "`nAppuyez sur Entree pour quitter..."
pause