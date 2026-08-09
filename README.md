# dotfiles

Meus dotfiles, gerenciados com [chezmoi](https://www.chezmoi.io).

## Uso

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply hiukky
```

## Comandos úteis

```sh
chezmoi add ~/.zshrc      # passar um arquivo a ser gerenciado
chezmoi edit ~/.zshrc     # editar via chezmoi
chezmoi diff              # ver o que vai mudar
chezmoi apply             # aplicar as mudanças
chezmoi cd                # entrar no diretório fonte
```
