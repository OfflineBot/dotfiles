
# dotfiles

Personal dotfiles for Arch Linux, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Usage

Clone the repo:

```sh
git clone https://github.com/offlinebot/.dotfiles ~/.dotfiles
cd ~/.dotfiles
```

Stow a package:

```sh
stow .
```

## Install

Run `install.sh` to install packages via pacman and paru:

```sh
./install.sh
```

if not working consider using `chmod +x ./install.sh`

