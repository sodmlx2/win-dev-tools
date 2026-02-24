# win-docker-intro
Example of .ps1 script to install docker utils on Windows Plataform and install Portainer platform.

## Docker commands.
* Download Docker Desktop -> https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe?

## testing with portainer image.
* remove ALL schema portainer.
```bash
docker rm -f portainer              
docker rmi portainer/portainer-ce   
docker volume rm portainer_data
```

## WSL commands.
* Download Linux Kernel v2 WSL -> https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi
```bash
wsl --status
wsl --update
wsl --list --online
wsl --install -d Debian
```
