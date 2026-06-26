# Força o terminal a interpretar acentos corretamente (UTF-8)
[console]::InputEncoding = [System.Text.Encoding]::UTF8
[console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "." -ForegroundColor Cyan

# Lista de recursos que queremos garantir que estejam ativos
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
    
    # Verifica de forma precisa se o recurso existe no sistema
    $checkFeature = Get-WindowsOptionalFeature -Online -FeatureName $feature -ErrorAction SilentlyContinue

    if ($checkFeature) {
        Write-Host " -> Recurso suportado pelo sistema operacional." -ForegroundColor Green
        
        # Verifica se o status já é Enabled
        if ($checkFeature.State -eq "Enabled") {
            Write-Host " -> Status: Já está habilitado." -ForegroundColor Green
        }
        else {
            Write-Host " -> Status: Não está habilitado. Ativando agora..." -ForegroundColor Yellow
            
            # Habilita o recurso usando o DISM conforme sua lógica original
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
        Write-Host " -> Ignorando recurso de forma segura." -ForegroundColor DarkGray
    }
}

Write-Host ""
if ($requiresRestart) {
    Write-Host "=========================================" -ForegroundColor Yellow
    Write-Host "REINICIE O PC para concluir a instalação!" -ForegroundColor Yellow
    Write-Host "Após reiniciar, execute o script de novo." -ForegroundColor Yellow
    Write-Host "=========================================" -ForegroundColor Yellow
}
else {
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host "--- Todos os recursos foram ativados! ---" -ForegroundColor Green
    Write-Host "=========================================" -ForegroundColor Green
}
