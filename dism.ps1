# Força o terminal a interpretar acentos corretamente (UTF-8)
[console]::InputEncoding = [System.Text.Encoding]::UTF8
[console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Lista de recursos que queremos mapear.
$features = @(
    # windows single lang pack home.
    "Microsoft-Windows-Subsystem-Linux",
    "VirtualMachinePlatform",
    "HypervisorPlatform",

    # windows all lang pack pro.
    "Microsoft-Hyper-V",
    "Microsoft-Hyper-V-All"
)

$requiresRestart = $false

foreach ($feature in $features) {

    Write-Host "--- Analisando o Recurso Adicional -> $feature"

    # Verifica de forma precisa se o recurso existe no sistema.
    $checkFeature = Get-WindowsOptionalFeature -Online -FeatureName $feature -ErrorAction SilentlyContinue

    if ($checkFeature) {
        Write-Host " -> Recurso suportado pelo sistema operacional." -ForegroundColor Green
        
        # Verifica se o status já é Enabled
        if ($checkFeature.State -eq "Enabled") {
            Write-Host " -> Status: Já está habilitado." -ForegroundColor Green
        } else {
            # Habilita o recurso usando o DISM conforme sua lógica original
            $process = Start-Process -FilePath "dism.exe" -ArgumentList "/online /Enable-Feature /FeatureName:$feature /All /NoRestart" -Wait -NoNewWindow -PassThru
            
            if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
                Write-Host " -> Recurso $feature ativado com sucesso!" -ForegroundColor Green
                $requiresRestart = $true
            } else {
                Write-Host " -> Falha ao ativar o recurso $feature. Código de erro: $($process.ExitCode)" -ForegroundColor Red
            }
        }
    }
    else {
        Write-Host " -> O recurso '$feature' NÃO está disponível nesta edição do Windows." -ForegroundColor DarkGray
    }
}

if ($requiresRestart) {
    Write-Host "* Reinicie e execute o script novamente!" -ForegroundColor Yellow
} else {
    Write-Host "* Todos os recursos foram ativados!" -ForegroundColor Green
}
