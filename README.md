# Windows.

## Ambiente de Desenvolvimento.
* Objetivo: Executar comandos basicos do linux e criar programas em (C/C++ & Python).

## Listando Recursos.
* "Microsoft-Windows-Subsystem-Linux",
* "VirtualMachinePlatform",
* "HypervisorPlatform",
* "Microsoft-Hyper-V",
* "Microsoft-Hyper-V-All"

```powershell dism /online /get-features /format:table
```powershell

## Containers:
* Docker.

## Docker commands.
* Download Docker Desktop -> https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe?

## testing with portainer image.
* remove ALL schema portainer.
```bash
docker rm -f portainer              
docker rmi portainer/portainer-ce   
docker volume rm portainer_data
```

## Hyper-V.
* WSL (Windows Subsystem Linux v2).

## WSL commands.
* Download Linux Kernel v2 WSL -> https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi
```bash
wsl --status
wsl --update
wsl --list --online
wsl --install -d Debian
```

## Virtualizacao.
* Parallels, VMWARE Fusion, Virtualbox, QEMU (Linux + Docker + DevTools)

## Instalacao para ambientes com suporte.
* Instalacao VisualStudio Community (Linux, C/C++, Compiladores, DesktopAPP or Mobile).

## Instalacao para ambientes sem suporte.
* Instalando suporte a comandos basicos do linux via MY2S e Cygwin.

# Example of script(ps1) to install WSL on Windows Plataform.
./install_wsl.ps1

PowerShell -ExecutionPolicy Bypass -File .\dism.ps1
