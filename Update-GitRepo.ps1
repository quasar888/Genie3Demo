<#
.SYNOPSIS
    Met a jour le depot Git avec les derniers changements
.DESCRIPTION
    Ajoute tous les changements, cree un commit et pousse vers GitHub
.PARAMETER Message
    Message du commit (optionnel)
.EXAMPLE
    .\Update-GitRepo-Fixed.ps1 -Message "Ajout nouvelle fonctionnalite"
    .\Update-GitRepo-Fixed.ps1 "Correction de bug"
#>

param(
    [Parameter(Position=0)]
    [string]$Message = "Mise a jour " + (Get-Date -Format "yyyy-MM-dd HH:mm")
)

function Write-Color {
    param([string]$Text, [string]$Color = "White")
    Write-Host $Text -ForegroundColor $Color
}

Write-Color "=== MISE A JOUR DU DEPOT GIT ===" "Cyan"

# Verification Git
try {
    git --version | Out-Null
    Write-Color "Git trouve" "Green"
} catch {
    Write-Color "Git non installe" "Red"
    exit 1
}

# Verification du depot
if (-not (Test-Path ".git")) {
    Write-Color "Ce dossier n'est pas un depot Git" "Red"
    exit 1
}

# Étape 1: Vérifier la configuration Git
Write-Color "`n1. Verification de la configuration..." "Yellow"
$userName = git config user.name
$userEmail = git config user.email
$remotes = git remote -v

Write-Color "  Utilisateur: $userName" "Gray"
Write-Color "  Email: $userEmail" "Gray"
Write-Color "  Remotes:" "Gray"
if ($remotes) {
    $remotes -split "`n" | ForEach-Object {
        Write-Color "    $_" "Gray"
    }
} else {
    Write-Color "  Aucun remote configure" "Red"
}

# Étape 2: Status actuel
Write-Color "`n2. Etat actuel:" "Yellow"
git status --short

# Demander confirmation
Write-Color "`nContinuer avec ces changements? (O/N)" "Yellow"
$confirm = Read-Host
if ($confirm -ne "O" -and $confirm -ne "o") {
    Write-Color "Operation annulee" "Red"
    exit
}

# Étape 3: Ajout des fichiers
Write-Color "`n3. Ajout des fichiers..." "Yellow"
git add .

# Vérifier ce qui a été ajouté
$staged = git diff --cached --name-only
if ($staged) {
    Write-Color "  Fichiers ajoutes:" "Gray"
    $staged -split "`n" | ForEach-Object {
        Write-Color "    - $_" "Gray"
    }
} else {
    Write-Color "  Aucun changement à ajouter" "Yellow"
}

# Étape 4: Commit
Write-Color "`n4. Creation du commit..." "Yellow"
Write-Color "  Message: $Message" "Gray"
git commit -m "$Message"

if ($LASTEXITCODE -eq 0) {
    Write-Color "  Commit cree avec succes" "Green"
    
    # Afficher le dernier commit
    $lastCommit = git log --oneline -1
    Write-Color "  $lastCommit" "Gray"
} else {
    Write-Color "  Aucun changement a committer" "Yellow"
    exit 0
}

# Étape 5: Configuration de l'upstream si nécessaire
Write-Color "`n5. Configuration de la branche..." "Yellow"
$currentBranch = git branch --show-current
Write-Color "  Branche actuelle: $currentBranch" "Gray"

# Vérifier si l'upstream est configuré
$upstream = git rev-parse --abbrev-ref $currentBranch@{upstream} 2>$null
if (-not $upstream) {
    Write-Color "  Pas d'upstream configure pour $currentBranch" "Yellow"
    Write-Color "  Configuration de l'upstream..." "Gray"
    
    # Configurer l'upstream
    git push --set-upstream origin $currentBranch
    
    if ($LASTEXITCODE -eq 0) {
        Write-Color "  Upstream configure avec succes" "Green"
    } else {
        Write-Color "  Erreur lors de la configuration de l'upstream" "Red"
        Write-Color "  Tentative de push manuel..." "Yellow"
    }
}

# Étape 6: Push vers GitHub
Write-Color "`n6. Envoi vers GitHub..." "Yellow"
git push

if ($LASTEXITCODE -eq 0) {
    Write-Color "  Mise a jour envoyee avec succes!" "Green"
    
    # Obtenir l'URL du dépôt
    $repoUrl = git config --get remote.origin.url
    if ($repoUrl -match "github\.com") {
        $repoUrl = $repoUrl -replace "^git@github\.com:", "https://github.com/"
        $repoUrl = $repoUrl -replace "\.git$", ""
        Write-Color "  Depot: $repoUrl" "Cyan"
    }
} else {
    Write-Color "  Erreur lors du push" "Red"
    
    # Tentative alternative
    Write-Color "  Tentative avec --set-upstream..." "Yellow"
    git push --set-upstream origin $currentBranch
    
    if ($LASTEXITCODE -eq 0) {
        Write-Color "  Push reussi avec --set-upstream" "Green"
    } else {
        Write-Color "  Echec du push" "Red"
        
        # Afficher les suggestions
        Write-Color "`nSuggestions:" "Yellow"
        Write-Color "  1. Verifiez votre connexion internet" "White"
        Write-Color "  2. Verifiez vos credentials GitHub" "White"
        Write-Color "  3. Executez: git push --set-upstream origin $currentBranch" "White"
        Write-Color "  4. Ou: git push -u origin $currentBranch" "White"
    }
}

# Étape 7: Vérification finale
Write-Color "`n7. Verification finale..." "Yellow"
Write-Color "  Derniers commits:" "Gray"
git log --oneline -3 | ForEach-Object {
    Write-Color "    $_" "Gray"
}

Write-Color "`nEtat du depot:" "Gray"
git status --short

Write-Color "`n=== OPERATION TERMINEE ===" "Green"

# Menu de sortie
Write-Color "`nOptions:" "Cyan"
Write-Color "  [O] Ouvrir le depot GitHub dans le navigateur" "White"
Write-Color "  [S] Voir le status Git complet" "White"
Write-Color "  [Q] Quitter" "White"

$choice = Read-Host "`nChoix"
switch ($choice.ToUpper()) {
    "O" {
        $repoUrl = git config --get remote.origin.url
        if ($repoUrl) {
            $repoUrl = $repoUrl -replace "^git@github\.com:", "https://github.com/"
            $repoUrl = $repoUrl -replace "\.git$", ""
            Start-Process $repoUrl
        }
    }
    "S" {
        git status
    }
}

Write-Color "`nAppuyez sur une touche pour quitter..." "Gray"
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")