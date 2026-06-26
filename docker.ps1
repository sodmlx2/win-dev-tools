Write-Host "... Docker ..." -ForegroundColor Cyan

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
