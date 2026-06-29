# Windows.

## Ambiente de Desenvolvimento.
* Objetivo: Executar comandos basicos do linux e criar programas em (C/C++ & Python).

## Observando os Recursos.
* Valide o suporte a virtualização (BIOS).
* Pressione "Win+R" e digite no prompt "cmd" e pressione ENTER.

Obtendo informações sobre a máquina local:
```cmd
systeminfo
```

```cmd
taskmgr
```

## Recursos de Virtualização.
* "Microsoft-Windows-Subsystem-Linux",
* "VirtualMachinePlatform",
* "HypervisorPlatform",
* "Microsoft-Hyper-V",
* "Microsoft-Hyper-V-All"

Obtendo a lista de Recursos via PowerShell:
```powershell
dism /online /get-features /format:table
```
```powershell
Get-WindowsOptionalFeature -Online
```

## Configuração: Microsoft-Windows-Subsystem-Linux.

Instala o WSL e habilita o suporte a VirtualMachinePlatform.
```powershell
wsl --install
```

Verifica se os recursos estão instalados.
```powershell
wsl --status
```
Atualiza o WSL.
```powershell
wsl --update
```
### Download Linux Kernel v2 WSL.
* https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi

### Instalando uma Distribuição Linux WSL.  
```powershell
wsl --list --online
wsl --install -d Debian
```
### Guia Oficial da Microsoft
* https://learn.microsoft.com/pt-br/windows/wsl/install
  
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
