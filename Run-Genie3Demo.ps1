<#
.SYNOPSIS
    Démo Genie3 - Simulation d'IA générative type Google DeepMind
.DESCRIPTION
    Ce script crée et exécute une application console .NET qui simule
    des fonctionnalités d'IA générative avancée
.NOTES
    Version: 1.2 (Compatibilité C# 5 - Sans Unicode)
    Auteur: Assistant IA
#>

# Configuration
$projectName = "Genie3DeepMindDemo"
$outputDir = ".\Genie3Output"
$csFile = "$projectName.cs"
$exeFile = "$projectName.exe"

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

Write-ColorOutput "=== GENIE3 GOOGLE DEEP MIND IAG DEMONSTRATION ===" "Cyan"
Write-ColorOutput "Initialisation du systeme..." "Yellow"

# Création du répertoire de sortie
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

# Création du fichier source C# (version compatible C# 5 - ASCII pur)
$sourceCode = @'
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.IO;
using System.Text;

namespace Genie3.DeepMindDemo
{
    public class CognitiveState
    {
        public double Confidence { get; set; }
        public string Focus { get; set; }
        public List<string> Context { get; set; }
        public DateTime Timestamp { get; set; }
        
        public CognitiveState()
        {
            Context = new List<string>();
            Timestamp = DateTime.Now;
        }
    }
    
    public class NLProcessor
    {
        private readonly Random _random = new Random();
        
        public Tuple<string, double> ProcessInput(string input)
        {
            var keywords = new Dictionary<string, string[]>
            {
                { "creer", new[] { "Je vais generer un concept...", "Creation en cours...", "Voici une idee :" } },
                { "expliquer", new[] { "Permettez-moi d'elucider...", "Explication detaillee :", "Le concept est le suivant :" } },
                { "resoudre", new[] { "Analyse du probleme...", "Solution proposee :", "Approche de resolution :" } },
                { "simuler", new[] { "Lancement de la simulation...", "Resultats simules :", "Modelisation :" } }
            };
            
            string lowerInput = input.ToLower();
            string[] responses = { "J'analyse votre requete...", "Traitement en cours...", "Consideration des parametres..." };
            
            foreach (var kvp in keywords)
            {
                if (lowerInput.Contains(kvp.Key))
                {
                    string selected = kvp.Value[_random.Next(kvp.Value.Length)];
                    return Tuple.Create(selected, _random.NextDouble() * 0.5 + 0.5);
                }
            }
            
            return Tuple.Create(responses[_random.Next(responses.Length)], _random.NextDouble() * 0.3 + 0.3);
        }
    }
    
    public class CreativeGenerator
    {
        private static readonly string[][] IdeaTemplates = 
        {
            new[] { "Un systeme qui ", "en utilisant ", "pour atteindre ", "avec comme resultat " },
            new[] { "Concept : ", "base sur ", "integrant ", "dans le but de " },
            new[] { "Innovation : ", "combinant ", "afin de ", "ce qui permet " }
        };
        
        private static readonly string[][] Components = 
        {
            new[] { "l'IA generative", "les reseaux de neurones", "l'apprentissage profond", "les transformers" },
            new[] { "des donnees multimodales", "la vision par ordinateur", "le NLP avance", "le reinforcement learning" },
            new[] { "resoudre des problemes complexes", "creer de l'art numerique", "composer de la musique", "generer du code" },
            new[] { "une efficacite accrue", "une creativite augmentee", "de nouvelles decouvertes", "une automatisation intelligente" }
        };
        
        public string GenerateIdea(int seed)
        {
            var random = new Random(seed);
            var template = IdeaTemplates[random.Next(IdeaTemplates.Length)];
            var idea = "";
            
            for (int i = 0; i < template.Length; i++)
            {
                idea += template[i];
                if (i < Components.Length)
                {
                    idea += Components[i][random.Next(Components[i].Length)];
                }
            }
            
            return idea;
        }
        
        public List<string> GenerateMultipleIdeas(int count)
        {
            var ideas = new List<string>();
            for (int i = 0; i < count; i++)
            {
                ideas.Add(GenerateIdea(Environment.TickCount + i));
            }
            return ideas;
        }
    }
    
    public class ReinforcementSimulator
    {
        public class TrainingEpisode
        {
            public int Episode { get; set; }
            public double Reward { get; set; }
            public double Loss { get; set; }
            public string Action { get; set; }
        }
        
        public List<TrainingEpisode> SimulateTraining(int episodes)
        {
            var random = new Random();
            var trainingLog = new List<TrainingEpisode>();
            
            for (int i = 0; i < episodes; i++)
            {
                double progress = (double)i / episodes;
                double reward = Math.Sin(progress * Math.PI) * 0.8 + random.NextDouble() * 0.2;
                double loss = Math.Exp(-progress * 3) + random.NextDouble() * 0.1;
                
                trainingLog.Add(new TrainingEpisode
                {
                    Episode = i + 1,
                    Reward = Math.Round(reward, 3),
                    Loss = Math.Round(loss, 3),
                    Action = GetRandomAction(random)
                });
            }
            
            return trainingLog;
        }
        
        private string GetRandomAction(Random random)
        {
            string[] actions = 
            {
                "Exploration", "Exploitation", "Policy Update", 
                "Value Estimation", "Gradient Descent", "Backpropagation"
            };
            return actions[random.Next(actions.Length)];
        }
    }
    
    public class Genie3System
    {
        private readonly NLProcessor _nlp;
        private readonly CreativeGenerator _generator;
        private readonly ReinforcementSimulator _rlSimulator;
        private CognitiveState _currentState;
        
        public Genie3System()
        {
            _nlp = new NLProcessor();
            _generator = new CreativeGenerator();
            _rlSimulator = new ReinforcementSimulator();
            _currentState = new CognitiveState
            {
                Confidence = 0.7,
                Focus = "Systeme initialise",
                Context = new List<string> { "Demarrage", "Mode demonstration" }
            };
        }
        
        public void UpdateState(string focus, double confidenceChange)
        {
            _currentState.Focus = focus;
            _currentState.Confidence = Math.Max(0.1, Math.Min(1.0, _currentState.Confidence + confidenceChange));
            _currentState.Timestamp = DateTime.Now;
        }
        
        public void RunInteractiveSession()
        {
            Console.Clear();
            DisplayHeader();
            
            Console.WriteLine("\n[PHASE 1] Traitement du Langage Naturel");
            Console.WriteLine(new string('=', 50));
            
            string[] testInputs = 
            {
                "Peux-tu expliquer le fonctionnement des reseaux de neurones ?",
                "Cree-moi un concept innovant d'IA",
                "Resoudre ce probleme de logique",
                "Simule un entrainement par renforcement"
            };
            
            foreach (var input in testInputs)
            {
                Console.WriteLine("\n>>> Input: " + input);
                var result = _nlp.ProcessInput(input);
                Console.WriteLine("<<< Reponse: " + result.Item1);
                Console.WriteLine("*** Confiance: " + result.Item2.ToString("P0"));
                
                string shortInput = input.Length > 20 ? input.Substring(0, 20) + "..." : input;
                UpdateState("Traitement: " + shortInput, result.Item2 - 0.5);
                System.Threading.Thread.Sleep(800);
            }
            
            Console.WriteLine("\n\n[PHASE 2] Generation Creative (IAG)");
            Console.WriteLine(new string('=', 50));
            
            Console.WriteLine("\nGeneration d'idees innovantes :");
            var ideas = _generator.GenerateMultipleIdeas(4);
            
            for (int i = 0; i < ideas.Count; i++)
            {
                Console.WriteLine("\n  Idee #" + (i + 1) + ":");
                Console.WriteLine("  " + ideas[i]);
                System.Threading.Thread.Sleep(600);
            }
            
            Console.WriteLine("\n\n[PHASE 3] Simulation RL (DeepMind Style)");
            Console.WriteLine(new string('=', 50));
            
            Console.WriteLine("\nEntrainement par renforcement :");
            var trainingData = _rlSimulator.SimulateTraining(8);
            
            Console.WriteLine("\nEpisode | Recompense | Perte    | Action");
            Console.WriteLine("--------|------------|----------|----------------");
            
            foreach (var episode in trainingData)
            {
                Console.WriteLine(string.Format("{0,7} | {1,10} | {2,8} | {3}", 
                    episode.Episode, episode.Reward, episode.Loss, episode.Action));
                System.Threading.Thread.Sleep(200);
            }
            
            DisplayCognitiveState();
            ExportResults(ideas, trainingData);
        }
        
        private void DisplayHeader()
        {
            Console.ForegroundColor = ConsoleColor.Cyan;
            Console.WriteLine();
            Console.WriteLine("========================================");
            Console.WriteLine("    GENIE3 DEEP MIND IAG SIMULATION     ");
            Console.WriteLine("    Version 3.0 - Mode Demonstration    ");
            Console.WriteLine("========================================");
            Console.WriteLine();
            Console.ResetColor();
        }
        
        private void DisplayCognitiveState()
        {
            Console.WriteLine("\n\n[ETAT COGNITIF DU SYSTEME]");
            Console.WriteLine(new string('=', 50));
            Console.WriteLine("Focus actuel: " + _currentState.Focus);
            Console.WriteLine("Niveau de confiance: " + _currentState.Confidence.ToString("P0"));
            Console.WriteLine("Contexte: " + string.Join(" -> ", _currentState.Context));
            Console.WriteLine("Derniere mise a jour: " + _currentState.Timestamp.ToString("HH:mm:ss"));
            
            Console.Write("\nConfiance: [");
            int barLength = 20;
            int filled = (int)(_currentState.Confidence * barLength);
            
            if (_currentState.Confidence > 0.7)
                Console.ForegroundColor = ConsoleColor.Green;
            else if (_currentState.Confidence > 0.4)
                Console.ForegroundColor = ConsoleColor.Yellow;
            else
                Console.ForegroundColor = ConsoleColor.Red;
                
            Console.Write(new string('#', filled));
            Console.Write(new string('.', barLength - filled));
            Console.ResetColor();
            Console.WriteLine("] " + _currentState.Confidence.ToString("P0"));
        }
        
        private void ExportResults(List<string> ideas, List<ReinforcementSimulator.TrainingEpisode> trainingData)
        {
            try
            {
                string timestamp = DateTime.Now.ToString("yyyyMMdd_HHmmss");
                string exportPath = "Genie3_Export_" + timestamp + ".txt";
                
                using (var writer = new StreamWriter(exportPath, false, Encoding.UTF8))
                {
                    writer.WriteLine("=== GENIE3 DEEP MIND SIMULATION EXPORT ===");
                    writer.WriteLine("Date: " + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
                    writer.WriteLine("\n--- IDEES GENEREES ---");
                    
                    for (int i = 0; i < ideas.Count; i++)
                    {
                        writer.WriteLine("\nIdee #" + (i + 1) + ":");
                        writer.WriteLine(ideas[i]);
                    }
                    
                    writer.WriteLine("\n--- DONNEES D'ENTRAINEMENT RL ---");
                    writer.WriteLine("Episode,Recompense,Perte,Action");
                    foreach (var episode in trainingData)
                    {
                        writer.WriteLine(episode.Episode + "," + episode.Reward + "," + episode.Loss + "," + episode.Action);
                    }
                    
                    writer.WriteLine("\n--- ETAT FINAL ---");
                    writer.WriteLine("Focus: " + _currentState.Focus);
                    writer.WriteLine("Confiance: " + _currentState.Confidence.ToString("P0"));
                    writer.WriteLine("Contexte: " + string.Join("; ", _currentState.Context));
                }
                
                Console.WriteLine("\n>>> Resultats exportes dans: " + exportPath);
            }
            catch (Exception ex)
            {
                Console.WriteLine("\n>>> Erreur lors de l'export: " + ex.Message);
            }
        }
    }
    
    class Program
    {
        static void Main(string[] args)
        {
            Console.Title = "Genie3 DeepMind IAG Simulation";
            
            try
            {
                Console.WriteLine("Initialisation du systeme Genie3...");
                System.Threading.Thread.Sleep(500);
                
                var genie = new Genie3System();
                
                Console.WriteLine("Lancement de la session interactive...");
                System.Threading.Thread.Sleep(1000);
                
                genie.RunInteractiveSession();
                
                Console.WriteLine("\n\n>>> Simulation terminee avec succes !");
                Console.WriteLine("\nAppuyez sur une touche pour quitter...");
                Console.ReadKey();
            }
            catch (Exception ex)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine("\n>>> ERREUR: " + ex.Message);
                Console.ResetColor();
                Console.WriteLine("\nAppuyez sur une touche pour quitter...");
                Console.ReadKey();
            }
        }
    }
}
'@

Write-ColorOutput "Generation du code source C# (ASCII pur)..." "Green"

# Écriture du fichier avec encodage ASCII pour éviter tout problème
$sourceCode | Out-File -FilePath "$outputDir\$csFile" -Encoding ASCII

Write-ColorOutput "Compilation de l'application..." "Yellow"

# Recherche du compilateur
$compilerPaths = @(
    "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe",
    "C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe"
)

$compilerFound = $false
foreach ($path in $compilerPaths) {
    if (Test-Path $path) {
        $compilerPath = $path
        $compilerFound = $true
        Write-ColorOutput "Compilateur trouve: $path" "Gray"
        break
    }
}

if (-not $compilerFound) {
    Write-ColorOutput "ERREUR: Compilateur C# introuvable." "Red"
    Write-ColorOutput "Veuillez installer .NET Framework 4.0 ou superieur." "Yellow"
    exit 1
}

# Options de compilation
$compileArgs = @(
    "/out:$outputDir\$exeFile",
    "/reference:System.Core.dll",
    "/reference:System.Threading.Tasks.dll",
    "/platform:anycpu",
    "/optimize",
    "/target:exe",
    "$outputDir\$csFile"
)

Write-ColorOutput "Compilation en cours..." "Gray"
& $compilerPath $compileArgs

if ($LASTEXITCODE -eq 0 -and (Test-Path "$outputDir\$exeFile")) {
    Write-ColorOutput "SUCCES: Compilation terminee!" "Green"
    Write-ColorOutput "Execution de la demonstration Genie3..." "Cyan"
    Write-Host ""
    Write-Host "----------------------------------------" -ForegroundColor DarkGray
    
    # Execution
    $oldLocation = Get-Location
    try {
        Set-Location $outputDir
        & ".\$exeFile"
    }
    finally {
        Set-Location $oldLocation
    }
    
    Write-Host "----------------------------------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-ColorOutput "=== FIN DE LA DEMONSTRATION ===" "Cyan"
    
    # Verification des fichiers generes
    Write-ColorOutput "`nFichiers generes dans '$outputDir' :" "Yellow"
    $files = Get-ChildItem $outputDir
    foreach ($file in $files) {
        $sizeKB = [math]::Round($file.Length / 1KB, 2)
        Write-Host ("  - {0,-30} {1,8} KB" -f $file.Name, $sizeKB) -ForegroundColor Gray
    }
    
    # Recherche des exports
    $exportFiles = Get-ChildItem -Path "." -Filter "Genie3_Export_*.txt" -ErrorAction SilentlyContinue
    if ($exportFiles.Count -gt 0) {
        $latestExport = $exportFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        Write-ColorOutput "`nDernier fichier d'export :" "Green"
        Write-Host "  " $latestExport.FullName -ForegroundColor Gray
        
        Write-ColorOutput "`nApercu du contenu :" "Yellow"
        $lines = Get-Content $latestExport.FullName -TotalCount 15
        foreach ($line in $lines) {
            Write-Host "  $line" -ForegroundColor DarkGray
        }
        if ((Get-Content $latestExport.FullName).Count -gt 15) {
            Write-Host "  ..." -ForegroundColor DarkGray
        }
    }
    
    Write-ColorOutput "`nPour reexecuter :" "White"
    Write-Host "  cd $outputDir" -ForegroundColor Gray
    Write-Host "  .\$exeFile" -ForegroundColor Gray
}
else {
    Write-ColorOutput "ERREUR: Echec de la compilation." "Red"
    Write-ColorOutput "Code de sortie: $LASTEXITCODE" "Yellow"
    
    # Affichage des erreurs detaillees
    if (Test-Path "$outputDir\$csFile") {
        Write-ColorOutput "`nVerification du fichier source..." "Yellow"
        
        # Verification des caracteres problematiques
        $content = Get-Content "$outputDir\$csFile" -Raw
        $problemLines = @()
        
        for ($i = 0; $i -lt $content.Length; $i++) {
            $charCode = [int][char]$content[$i]
            if ($charCode -gt 127 -and $charCode -ne 10 -and $charCode -ne 13 -and $charCode -ne 9) {
                $lineNum = ($content.Substring(0, $i) -split "`n").Count
                $problemLines += "Ligne ~$lineNum : Char $i = U+$($charCode.ToString('X4'))"
            }
        }
        
        if ($problemLines.Count -gt 0) {
            Write-ColorOutput "Caracteres non-ASCII detectes :" "Red"
            $problemLines | Select-Object -First 5 | ForEach-Object {
                Write-Host "  $_" -ForegroundColor Gray
            }
        }
    }
    
    # Solution alternative : Compilation simple
    Write-ColorOutput "`nEssai de compilation alternative..." "Yellow"
    $simpleSource = @'
using System;
class Program {
    static void Main() {
        Console.WriteLine("Genie3 Demo - Systeme operationnel");
        Console.WriteLine("Appuyez sur une touche...");
        Console.ReadKey();
    }
}
'@
    
    $simpleSource | Out-File "$outputDir\SimpleDemo.cs" -Encoding ASCII
    & $compilerPath /out:"$outputDir\SimpleDemo.exe" "$outputDir\SimpleDemo.cs"
    
    if (Test-Path "$outputDir\SimpleDemo.exe") {
        Write-ColorOutput "Demo simple compilee avec succes." "Green"
    }
}

Write-ColorOutput "`nScript termine." "White"