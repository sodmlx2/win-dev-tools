# 2. Verifica se o serviço Docker está ativo
if (-not (docker ps -a 2>$null)) {
    Write-Host "[ ERRO ] O Docker está instalado, mas o serviço não está rodando." -ForegroundColor Yellow
    Write-Host "Por favor, inicie o Docker Desktop."
    exit
}

# 3. Verifica se o container Portainer já existe
$containerExistente = docker ps -a --filter "name=portainer" --format "{{.Names}}"

if ($containerExistente -eq "portainer") {
    $status = docker inspect -f '{{.State.Status}}' portainer
    Write-Host "[ AVISO ] O Portainer já está instalado no seu sistema!" -ForegroundColor Blue
    Write-Host "Status atual: $status" -ForegroundColor Cyan
    
    if ($status -ne "running") {
        Write-Host "Iniciando o container existente..."
        docker start portainer
    }
    
    Write-Host "Acesse em: https://localhost:9443" -ForegroundColor Green
    exit
}

# 4. Verifica/Cria o volume se necessário
$volumeExiste = docker volume ls -q --filter "name=portainer_data"
if (-not $volumeExiste) {
    Write-Host "Criando volume 'portainer_data'..."
    docker volume create portainer_data
}
else {
    Write-Host "Volume 'portainer_data' já existe, reutilizando..." -ForegroundColor Gray
}

# 5. Instalação (se passar por todas as verificações acima)
Write-Host "Instalando Portainer..." -ForegroundColor Yellow
docker run -d `
    -p 8000:8000 `
    -p 9443:9443 `
    --name portainer `
    --restart=always `
    -v /var/run/docker.sock:/var/run/docker.sock `
    -v portainer_data:/data `
    portainer/portainer-ce:latest

Write-Host "`n[ SUCESSO ] Portainer configurado e pronto para uso." -ForegroundColor Green
Write-Host "Acesse: https://localhost:9443" -ForegroundColor Cyan
