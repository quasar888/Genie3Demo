<#
.SYNOPSIS
    Script simple pour compiler et exécuter Genie3DeepMindDemo.cs
#>

# Configuration
$SourceFile = "Genie3Output\Genie3DeepMindDemo.cs"
$OutputExe = "Genie3Demo.exe"

Write-Host "=== COMPILATION GENIE3 DEEP MIND ===" -ForegroundColor Cyan

# Vérifier le fichier source
if (-not (Test-Path $SourceFile)) {
    Write-Host "Erreur: Fichier $SourceFile non trouve" -ForegroundColor Red
    exit 1
}

Write-Host "Fichier source: $SourceFile" -ForegroundColor Green

# Chercher le compilateur C#
$compilerPaths = @(
    "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe",
    "C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe"
)

$compiler = $null
foreach ($path in $compilerPaths) {
    if (Test-Path $path) {
        $compiler = $path
        break
    }
}

if (-not $compiler) {
    Write-Host "Erreur: Compilateur C# non trouve" -ForegroundColor Red
    Write-Host "Installez .NET Framework 4.0 ou superieur" -ForegroundColor Yellow
    exit 1
}

Write-Host "Compilateur: $compiler" -ForegroundColor Green

# Compiler
Write-Host "`nCompilation en cours..." -ForegroundColor Yellow
& $compiler /target:exe /out:$OutputExe /platform:anycpu /optimize /reference:System.dll /reference:System.Core.dll $SourceFile

if ($LASTEXITCODE -eq 0 -and (Test-Path $OutputExe)) {
    Write-Host "Compilation reussie!" -ForegroundColor Green
    $size = (Get-Item $OutputExe).Length / 1KB
    Write-Host "Executable cree: $OutputExe ($([math]::Round($size, 2)) KB)" -ForegroundColor White
    
    # Exécuter
    Write-Host "`n" + ("=" * 50) -ForegroundColor DarkCyan
    Write-Host " EXECUTION DE L'APPLICATION " -ForegroundColor Cyan
    Write-Host ("=" * 50) -ForegroundColor DarkCyan
    Write-Host ""
    
    & ".\$OutputExe"
    
    Write-Host ""
    Write-Host ("=" * 50) -ForegroundColor DarkCyan
    Write-Host "Application terminee" -ForegroundColor Cyan
    
} else {
    Write-Host "Erreur de compilation" -ForegroundColor Red
}

Write-Host "`nAppuyez sur une touche pour quitter..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")