# dotfiles

![dotfiles](https://i.imgur.com/O9yZikB.png)

## Installation

### Unix

Dependencies:

- GNU Stow
- cURL

```bash
chmod +x setup.sh
./setup.sh [-n: dry run]
```

### NT (Windows 11)

Dependencies:

- Administrator PowerShell 7+ window
- WinGet (built-in on Windows 11)

```powershell
Set-ExecutionPolicy Unrestricted
./pwsh/install/install.ps1
```