# Windows.

## Ambiente de Desenvolvimento.
* Objetivo: Executar comandos basicos do linux e criar programas em (C/C++ & Python).

## Listando Recursos.
* "Microsoft-Windows-Subsystem-Linux"
* "VirtualMachinePlatform"
* "HypervisorPlatform"
* "Microsoft-Hyper-V"
* "Microsoft-Hyper-V-All"

* Obtendo a lista de Recursos via DISM.
```powershell
dism /online /get-features /format:table
```

* Obtendo a lista de Recursos via "Get-WindowsOptionalFeature"
```powershell
Get-WindowsOptionalFeature -Online
```

## Configuração: Microsoft-Windows-Subsystem-Linux.
* Download Linux Kernel v2 WSL -> https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi

```powershell
wsl --status
wsl --update
wsl --list --online
wsl --install -d Debian
```
## Containers:
* Docker.

## Docker commands.
* Download Docker Desktop -> https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe?

## Hyper-V.
* WSL (Windows Subsystem Linux v2).

## Virtualizacao.
* Parallels, VMWARE Fusion, Virtualbox, QEMU (Linux + Docker + DevTools)

## Instalacao para ambientes com suporte.
* Instalacao VisualStudio Community (Linux, C/C++, Compiladores, DesktopAPP or Mobile).

## Instalacao para ambientes sem suporte.
* Instalando suporte a comandos basicos do linux via MY2S e Cygwin.

# Example of script(ps1) to install WSL on Windows Plataform.
PowerShell -ExecutionPolicy Bypass -File .\dism.ps1
