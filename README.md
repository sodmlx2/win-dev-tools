# Windows.

### Ambiente de Desenvolvimento.
* Objetivo: Executar comandos basicos do linux e criar programas em (C/C++ & Python).

### Observando os Recursos.
* Valide o suporte a virtualização (BIOS).
* Pressione "Win+R" e digite no prompt "cmd" e pressione ENTER.

Obtendo informações sobre a máquina local:
```cmd
systeminfo
```

```cmd
taskmgr
```

### Recursos de Virtualização.
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
### Habilita os recursos via script.

```powershell
PowerShell -ExecutionPolicy Bypass -File .\dism.ps1
```

### Configuração: Microsoft-Windows-Subsystem-Linux.

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
  
### Docker.
Download Docker Desktop:
* https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe?
