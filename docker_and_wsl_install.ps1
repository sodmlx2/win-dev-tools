Write-Host "--- docker_and_wsl_install.ps1 ---" -ForegroundColor Cyan

# Verifica se o script está rodando como Administrador
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Este script precisa ser executado como Administrador (Elevated Privileges)."
    Write-Warning "Por favor, abra o PowerShell como Administrador e tente novamente."
    Exit
}

Write-Host "Verificando e habilitando recursos necessários (WSL, Máquina Virtual, Hyper-V)..." -ForegroundColor Cyan

# Obtém a lista de recursos disponíveis para não tentarmos analisar/instalar o que não existe
Write-Host "Obtendo lista de recursos disponíveis do Windows nesta máquina..." -ForegroundColor Cyan
$allFeaturesOutput = dism.exe /online /Get-Features /Format:Table | Out-String

Write-Host "========================================================" -ForegroundColor Magenta
Write-Host "Procurando por recursos relacionados a 'Hyper' ou 'Virtual'..." -ForegroundColor Magenta

# Filtra o ouput do DISM para mostrar apenas as linhas contendo Hyper ou Virtual
$linhasFeatures = $allFeaturesOutput -split "`r`n"
foreach ($linha in $linhasFeatures) {
    if ($linha -match "(?i)Hyper|Virtual|Subsystem-Linux") {
        Write-Host " -> $linha" -ForegroundColor Magenta
    }
}
Write-Host "========================================================" -ForegroundColor Magenta

# Lista de recursos necessários (WSL, Máquina Virtual, Hyper-V e seus possíveis nomes)
$features = @(
    "Microsoft-Windows-Subsystem-Linux",
    "VirtualMachinePlatform",
    "HypervisorPlatform",
    "Microsoft-Hyper-V",
    "Microsoft-Hyper-V-All"
)

$requiresRestart = $false

foreach ($feature in $features) {
    Write-Host "--------------------------------------------------------" -ForegroundColor Cyan
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

Write-Host "--------------------------------------------------------" -ForegroundColor Cyan
Write-Host "Atualizando Kernel do Linux para WSL 2 e configurando versão padrão..." -ForegroundColor Cyan

$kernelInstalled = $false
# 1. Verifica se já existe uma instalação moderna do WSL apontando para um kernel
$wslVersionOutput = wsl --version 2>&1 | Out-String
if ($wslVersionOutput -match "kernel" -or $wslVersionOutput -match "WSL version") {
    $kernelInstalled = $true
}
else {
    # 2. Verifica se o MSI antigo do "Windows Subsystem for Linux Update" já foi instalado
    $wslUpdateMsi = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*", "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -match "Windows Subsystem for Linux Update" }
    if ($wslUpdateMsi) {
        $kernelInstalled = $true
    }
}

if ($kernelInstalled) {
    Write-Host "O Kernel do WSL 2 já está instalado/atualizado nesta máquina (download ignorado)." -ForegroundColor Green
}
else {
    try {
        Write-Host "Baixando o instalador do Kernel do WSL 2..." -ForegroundColor Yellow
        $wslUpdateUrl = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
        $wslUpdateInstaller = "$env:TEMP\wsl_update_x64.msi"
        Invoke-WebRequest -Uri $wslUpdateUrl -OutFile $wslUpdateInstaller -UseBasicParsing
        
        Write-Host "Instalando a atualização do Kernel silenciosamente..." -ForegroundColor Yellow
        $process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$wslUpdateInstaller`" /quiet /norestart" -Wait -PassThru -NoNewWindow
        
        if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 1641 -or $process.ExitCode -eq 3010) {
            Write-Host "Atualização do Kernel do WSL 2 instalada com sucesso." -ForegroundColor Green
        }
        else {
            Write-Host "O instalador do Kernel finalizou com código $($process.ExitCode)" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Erro ao baixar ou instalar o Kernel do WSL 2: $_" -ForegroundColor Red
    }
}

try {
    Write-Host "Definindo a versão padrão do WSL para 2..." -ForegroundColor Yellow
    # Executando o comando wsl e ignorando possíveis erros caso o sistema não tenha reiniciado ainda
    wsl --set-default-version 2
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Versão padrão configurada para 2 com sucesso." -ForegroundColor Green
    }
    else {
        Write-Host "Aviso: Não foi possível definir a versão padrão do WSL (ExitCode: $LASTEXITCODE). Pode ser necessário reiniciar antes." -ForegroundColor Yellow
    }
}
catch {
    Write-Host "Aviso: Exceção ao tentar definir a versão padrão do wsl. Pode ser necessário reiniciar o computador." -ForegroundColor Yellow
}

Write-Host "--------------------------------------------------------" -ForegroundColor Cyan
Write-Host "Verificando instalação do Docker Desktop..." -ForegroundColor Cyan

$dockerExe = "$env:ProgramFiles\Docker\Docker\Docker Desktop.exe"
if (Test-Path $dockerExe) {
    Write-Host "O Docker Desktop já está instalado." -ForegroundColor Green
}
else {
    Write-Host "Docker Desktop não encontrado. Iniciando o download (Aguarde, este arquivo é grande)..." -ForegroundColor Yellow
    try {
        $dockerInstaller = "$env:TEMP\DockerDesktopInstaller.exe"
        $dockerUrl = "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe"
        Invoke-WebRequest -Uri $dockerUrl -OutFile $dockerInstaller -UseBasicParsing
        
        Write-Host "Download concluído. Iniciando instalação silenciosa (pode demorar alguns minutos)..." -ForegroundColor Yellow
        $process = Start-Process -FilePath $dockerInstaller -ArgumentList "install --quiet --accept-license" -Wait -PassThru -NoNewWindow
        
        if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 1641 -or $process.ExitCode -eq 3010) {
            Write-Host "Docker Desktop instalado com sucesso!" -ForegroundColor Green
            $requiresRestart = $true
        }
        else {
            Write-Host "O instalador do Docker Desktop concluiu, porém retornou o código de saída: $($process.ExitCode)" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Erro ao tentar baixar ou instalar o Docker Desktop: $_" -ForegroundColor Red
    }
}

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
