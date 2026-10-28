# dotfiles

![dotfiles](https://i.imgur.com/O9yZikB.png)

## Installation

### Unix

Dependencies:

- GNU Stow (on macOS, `./setup.sh` installs it with Homebrew)
- cURL

- macOS: `./setup.sh` installs them from the [Brewfile](Brewfile) with Homebrew, so on a new Mac install [Homebrew](https://brew.sh) first.
- Linux: install the same packages with your package manager. Debian and Ubuntu install fd and bat as `fdfind` and `batcat`; the shell aliases handle that.

```bash
chmod +x setup.sh
./setup.sh [-n: dry run]
```

### NT (Windows 11)

Dependencies:

- Administrator PowerShell 7+ window
- WinGet (built-in on Windows 11)

`install.ps1` installs the Windows versions of the tools above with WinGet.

```powershell
Set-ExecutionPolicy -Scope Process Bypass
./pwsh/install/install.ps1
```

## Machine-specific settings

These untracked files are loaded when they exist (`*.local` is gitignored):

| File | Use it for |
| --- | --- |
| `~/.gitconfig.local` | Your Git name and email (the shared `.gitconfig` sets none) and credential helpers |
| `~/.bashrc.local` | Bash tokens and overrides |
| `~/.zshrc.local` | Zsh tokens and overrides (put PATH, Homebrew, and NVM setup in `~/.zshenv`) |
