Write-Host "." -ForegroundColor Cyan

# Obtém a lista de recursos disponíveis.
$allFeaturesOutput = dism.exe /online /Get-Features /Format:Table | Out-String

# Filtra o ouput do DISM para mostrar apenas as linhas contendo Hyper ou Virtual
$linhasFeatures = $allFeaturesOutput -split "`r`n"
foreach ($linha in $linhasFeatures) {
    if ($linha -match "(?i)Hyper|Virtual|Subsystem-Linux") {
        Write-Host " -> $linha" -ForegroundColor Magenta
    }
}

# Lista de recursos.
$features = @(
    "Microsoft-Windows-Subsystem-Linux",
    "VirtualMachinePlatform",
    "HypervisorPlatform",
    "Microsoft-Hyper-V",
    "Microsoft-Hyper-V-All"
)

$requiresRestart = $false

foreach ($feature in $features) {
    Write-Host "Analisando o recurso: $feature..."
    
    # Verifica se o recurso sequer existe nesta edição do Windows
    if ($allFeaturesOutput -match $feature) {
        Write-Host " -> Recurso suportado pelo sistema operacional." -ForegroundColor Green
        
        # Executa o DISM para coletar informações sobre o recurso
        $dismOutput = dism.exe /online /Get-FeatureInfo /FeatureName:$feature | Out-String
        
        # Verifica pelo status (Inglês ou Português)
        if ($dismOutput -match "Enabled" -or $dismOutput -match "Habilitado") {
            Write-Host " -> Status: Já está habilitado." -ForegroundColor Green
        }
        else {
            Write-Host " -> Status: Não está habilitado. Ativando agora..." -ForegroundColor Yellow
            
            # Habilita o recurso
            $process = Start-Process -FilePath "dism.exe" -ArgumentList "/online /Enable-Feature /FeatureName:$feature /All /NoRestart" -Wait -NoNewWindow -PassThru
            
            if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
                Write-Host " -> Recurso $feature ativado com sucesso!" -ForegroundColor Green
                $requiresRestart = $true
            }
            else {
                Write-Host " -> Falha ao ativar o recurso $feature. Código de erro: $($process.ExitCode)" -ForegroundColor Red
            }
        }
    }
    else {
        Write-Host " -> O recurso '$feature' NÃO está disponível nesta edição do Windows." -ForegroundColor DarkGray
        Write-Host " -> (Ex: o Windows Home não possui o Microsoft-Hyper-V-All nativo)." -ForegroundColor DarkGray
        Write-Host " -> Ignorando recurso de forma segura." -ForegroundColor DarkGray
    }
}

Write-Host "--------------------------------------------------------" -ForegroundColor Cyan
Write-Host "Processamento de recursos via DISM finalizado." -ForegroundColor Cyan



if ($requiresRestart) {
    Write-Host "==========================================================================" -ForegroundColor Yellow
    Write-Host "ATENÇÃO: Múltiplos recursos (WSL / Virtual Machine / Hyper-V) foram instalados ou ativados." -ForegroundColor Yellow
    Write-Host "É NECESSÁRIO REINICIAR o sistema para que as alterações tenham efeito." -ForegroundColor Yellow
    Write-Host "Após reiniciar, execute este script novamente (se necessário) para concluir as etapas." -ForegroundColor Yellow
    Write-Host "==========================================================================" -ForegroundColor Yellow
}
else {
    Write-Host "==========================================================================" -ForegroundColor Green
    Write-Host "Todos os recursos suportados pelo seu sistema já se encontram ativos." -ForegroundColor Green
    Write-Host "O WSL 2 e a atualização do Kernel foram configurados com sucesso!" -ForegroundColor Green
    Write-Host "==========================================================================" -ForegroundColor Green
}
