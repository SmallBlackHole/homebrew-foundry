# Homebrew cask for the Foundry DevPack installer.
#
# Lives in the microsoft/homebrew-foundry tap; the fully-qualified name auto-taps:
#
#   brew install --cask microsoft/foundry/devpack         # stages the CLI (+ az)
#   foundry-devpack install [--preset cli|vscode|copilot]  # provisions (omit --preset for all)
#
# This is a THIN cask: it only downloads the signed + notarized binary (hosted on the
# microsoft/foundry-toolkit release), links it onto PATH, and installs az as a dependency. It
# does NOT run the binary -- provisioning (azd + the azd Foundry extension + the skill, and
# optionally the VS Code extension / Copilot canvas) is the explicit `foundry-devpack install`
# step, which lets users pick a preset.
cask "devpack" do
  arch arm: "arm64", intel: "x64"

  version "0.0.6"
  sha256 arm:   "39364cf208423570155df0d11571b5b1ce523c5eacb4234ac8871233e69193ce",
         intel: "d6bcf96950e9a4aa93584484721ed0bb988a3830faba9533c6361f1c90fa8619"

  url "https://github.com/microsoft/foundry-toolkit/releases/download/devpack-installer-#{version}/foundry-devpack-osx-#{arch}.zip",
      verified: "github.com/microsoft/foundry-toolkit/"
  name "Foundry DevPack"
  desc "Foundry prerequisites installer"
  homepage "https://github.com/microsoft/foundry-toolkit"

  # az is a Homebrew core formula -> installed as a dependency. azd is NOT a brew dep: it ships
  # as a cask in the third-party `azure/azd` tap (which needs `brew trust`), so `foundry-devpack
  # install` provisions azd itself via aka.ms/install-azd.sh.
  depends_on formula: "azure-cli"
  depends_on macos: :ventura

  # Thin cask: stage the CLI on PATH only. Provisioning is the explicit `foundry-devpack install`
  # step (see caveats), so users can choose a preset. No postflight -> `brew install` never runs
  # the binary (also sidesteps any nested-brew concerns).
  binary "foundry-devpack"

  caveats <<~EOS
    The foundry-devpack CLI is installed. Finish setting up your Foundry prerequisites with:

      foundry-devpack install                     # everything (default)
      foundry-devpack install --preset cli        # Azure CLI + azd + azd Foundry extension + skill
      foundry-devpack install --preset vscode     # the above + VS Code Foundry extension
      foundry-devpack install --preset copilot    # the above + Foundry Copilot plugin (needs the Copilot CLI)

    Re-run any time to verify or repair.
  EOS

  # `brew uninstall` removes the linked binary automatically; `--zap` also clears what the
  # installer created (the skill + its state). azd/az are left in place (az is a brew dep).
  zap trash: [
    "~/.agents/skills/microsoft-foundry",
    "~/.local/state/foundry-devpack",
  ]
end
