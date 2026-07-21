# homebrew-foundry

Homebrew tap for the **Foundry DevPack** installer.

## Install

```sh
brew install --cask microsoft/foundry/devpack
```

That single command:

1. Installs `az` (Azure CLI) from Homebrew core (declared dependency).
2. Downloads the signed, notarized `foundry-devpack` binary and links it onto your `PATH`.
3. Runs it (`--channel brew`) to install the remaining Foundry prerequisites — `azd`, the azd
   Foundry extension, and the `microsoft-foundry` skill.

The binary itself is Developer-ID signed and Apple-notarized, so Gatekeeper allows it to run
even though Homebrew quarantines cask artifacts.

## Update

```sh
brew upgrade --cask microsoft/foundry/devpack
```

## Uninstall

```sh
brew uninstall --cask devpack           # removes the binary
brew uninstall --zap --cask devpack     # also removes the installed skill + state
```

> `az` (a Homebrew dependency) and `azd` are left in place; remove them separately if desired.

## Requirements

- macOS Ventura (13) or later
- Apple Silicon or Intel

## Release source

The binary assets are published on the
[microsoft/foundry-toolkit](https://github.com/microsoft/foundry-toolkit/releases) releases
(tag `devpack-installer-<version>`), built and signed by the internal release pipeline. Each new
version bumps `version` and the two per-arch `sha256` values in `Casks/devpack.rb`.
