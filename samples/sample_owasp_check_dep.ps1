<#
.SYNOPSIS
    Instala e configura o OWASP Dependency-Check (SCA) no Windows.

.DESCRIPTION
    - Verifica se o Java (JRE/JDK) esta instalado (requisito obrigatorio).
    - Baixa a versao mais recente do Dependency-Check diretamente do GitHub (release oficial).
    - Extrai para uma pasta local.
    - Adiciona o diretorio "bin" ao PATH do usuario (opcional).
    - Configura a NVD API Key (se fornecida) para acelerar o "update" do banco de CVEs.
    - Executa o update inicial do banco de dados NVD (pode demorar).

.NOTES
    Execute em um PowerShell com permissao para escrever em Program Files (ou ajuste $InstallDir).
    Se necessario, rode antes:  Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#>

param(
    [string]$InstallDir = "C:\Tools\dependency-check",
    [string]$NvdApiKey = "",          # cole sua NVD API Key aqui ou passe via -NvdApiKey
    [switch]$AddToPath,               # adiciona o bin/ ao PATH do usuario
    [switch]$SkipInitialUpdate        # pula o update inicial (nao recomendado)
)

$ErrorActionPreference = "Stop"

function Write-Step($msg) {
    Write-Host ""
    Write-Host "==> $msg" -ForegroundColor Cyan
}

# 1. Verificar Java -----------------------------------------------------
Write-Step "Verificando instalacao do Java..."
$javaCmd = Get-Command java -ErrorAction SilentlyContinue
if ($javaCmd) {
    # java -version escreve no stderr; capturamos sem deixar o ErrorActionPreference
    # global (Stop) abortar o script por causa disso.
    $prevEap = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    $javaVersionOutput = (& java -version 2>&1) | Out-String
    $ErrorActionPreference = $prevEap
    Write-Host $javaVersionOutput
} else {
    Write-Host "Java nao encontrado no PATH." -ForegroundColor Red
    Write-Host "Dependency-Check requer Java 11+ (recomendado JDK/JRE 17)." -ForegroundColor Yellow
    Write-Host "Baixe em: https://adoptium.net/" -ForegroundColor Yellow
    throw "Instale o Java e execute o script novamente."
}

# 2. Descobrir a ultima versao via GitHub API ---------------------------
Write-Step "Consultando a ultima versao do Dependency-Check no GitHub..."
$releaseApi = "https://api.github.com/repos/jeremylong/DependencyCheck/releases/latest"
$headers = @{ "User-Agent" = "PowerShell-DependencyCheck-Setup" }

$release = Invoke-RestMethod -Uri $releaseApi -Headers $headers
$version = $release.tag_name -replace '^v', ''
$asset = $release.assets | Where-Object { $_.name -like "*-release.zip" } | Select-Object -First 1

if (-not $asset) {
    throw "Nao foi possivel localizar o pacote .zip de release. Verifique manualmente: https://github.com/jeremylong/DependencyCheck/releases"
}

Write-Host "Versao encontrada: $version"
Write-Host "Arquivo: $($asset.name)"

# 3. Download -------------------------------------------------------------
$zipPath = Join-Path $env:TEMP $asset.name
Write-Step "Baixando Dependency-Check $version (isso pode levar alguns minutos)..."
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zipPath -Headers $headers

# 4. Extrair --------------------------------------------------------------
Write-Step "Extraindo para $InstallDir ..."
if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
}

$tempExtract = Join-Path $env:TEMP "dc-extract"
if (Test-Path $tempExtract) { Remove-Item $tempExtract -Recurse -Force }
Expand-Archive -Path $zipPath -DestinationPath $tempExtract -Force

# a extracao gera uma pasta "dependency-check" dentro do zip
$extractedFolder = Get-ChildItem $tempExtract | Select-Object -First 1
Copy-Item -Path (Join-Path $extractedFolder.FullName "*") -Destination $InstallDir -Recurse -Force

Remove-Item $zipPath -Force
Remove-Item $tempExtract -Recurse -Force

$binPath = Join-Path $InstallDir "bin"
$batPath = Join-Path $binPath "dependency-check.bat"

if (-not (Test-Path $batPath)) {
    throw "Instalacao falhou: $batPath nao encontrado."
}
Write-Host "Instalado em: $InstallDir" -ForegroundColor Green

# 5. Adicionar ao PATH (opcional) -----------------------------------------
if ($AddToPath) {
    Write-Step "Adicionando $binPath ao PATH do usuario..."
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$binPath*") {
        [Environment]::SetEnvironmentVariable("Path", "$currentPath;$binPath", "User")
        Write-Host "PATH atualizado. Abra um novo terminal para o efeito ter valor." -ForegroundColor Yellow
    } else {
        Write-Host "Ja estava no PATH."
    }
}

# 6. NVD API Key ------------------------------------------------------------
if (-not $NvdApiKey) {
    Write-Step "Nenhuma NVD API Key fornecida."
    Write-Host "Sem a key, o update do banco NVD sera MUITO lento (rate limit severo)." -ForegroundColor Yellow
    Write-Host "Solicite gratuitamente em: https://nvd.nist.gov/developers/request-an-api-key" -ForegroundColor Yellow
    Write-Host "Depois rode: .\dependency-check.bat --updateonly --nvdApiKey SUA_KEY" -ForegroundColor Yellow
} else {
    Write-Host "NVD API Key fornecida (sera usada apenas nesta execucao, nao e persistida em arquivo)." -ForegroundColor Green
}

# 7. Update inicial do banco NVD -------------------------------------------
if (-not $SkipInitialUpdate) {
    Write-Step "Executando update inicial do banco NVD (pode demorar bastante na primeira vez)..."
    Push-Location $binPath
    try {
        if ($NvdApiKey) {
            & .\dependency-check.bat --updateonly --nvdApiKey $NvdApiKey
        } else {
            & .\dependency-check.bat --updateonly
        }
    } finally {
        Pop-Location
    }
} else {
    Write-Host "Update inicial pulado (--SkipInitialUpdate)." -ForegroundColor Yellow
}

# 8. Resumo -------------------------------------------------------------
Write-Step "Setup concluido!"
Write-Host "Binario: $batPath"
Write-Host ""
Write-Host "Exemplo de scan de um projeto:" -ForegroundColor Cyan
Write-Host "  $batPath --project `"MeuProjeto`" --scan `"C:\caminho\do\projeto`" --format HTML --out `"C:\caminho\relatorio`" --nvdApiKey SUA_KEY"
Write-Host ""
Write-Host "Dica: guarde sua NVD API Key em uma variavel de ambiente (ex: NVD_API_KEY) em vez de digitar em texto puro." -ForegroundColor Yellow