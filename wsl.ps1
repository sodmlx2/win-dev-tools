Write-Host "... WSL ..." -ForegroundColor Cyan

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
