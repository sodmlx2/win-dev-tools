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

Obtendo a lista de Recursos via comando DISM:
```powershell
dism /online /get-features /format:table
```

Obtendo a lista de Recursos via PowerShell:
```powershell
Get-WindowsOptionalFeature -Online
```

Habilita os recursos via script.
```powershell
PowerShell -ExecutionPolicy Bypass -File .\dism.ps1
```

### Microsoft-Windows-Subsystem-Linux.
Instalação do WSL e suporte a VirtualMachinePlatform.
* https://learn.microsoft.com/pt-br/windows/wsl/install

Inicia a instalação do WSL e verifica os recursos adicionais.
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

Habilita os recursos via script.
```powershell
PowerShell -ExecutionPolicy Bypass -File .\wsl.ps1
```

### Linux Kernel v2 WSL.
Download do patch.
* https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi

### Instalando uma Distribuição Linux WSL.  

Listando distribuições.
```powershell
wsl --list --online
```

Instalando o Linux Debian.
```powershell
wsl --install -d Debian
```

### Docker.
Download Docker Desktop:
* https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe?

Habilita os recursos via script.
```powershell
PowerShell -ExecutionPolicy Bypass -File .\docker.ps1
```
