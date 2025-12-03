Mostly dotfiles and hacky scripts

## Getting started

- Install Nix the package manager https://nixos.org/download/
- Install standalone multiuser home-manager https://nix-community.github.io/home-manager/index.xhtml#sec-install-standalone

```bash
# Clone .config repo
mkdir "$HOME/projects"
cd "$HOME/projects"
git clone git@github.com:Baarsgaard/.config.git dotconfig

mv "$HOME/.config/home-manager/home.nix" "$HOME/.config/home-manager/home.nix.bak"
ln -s "$HOME/projects/dotconfig/home-manager/home.nix" "$HOME/.config/home-manager/home.nix"

home-manager switch
```
