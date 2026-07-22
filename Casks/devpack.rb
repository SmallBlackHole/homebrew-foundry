# Homebrew cask for the Foundry DevPack installer.
#
# Lives in the microsoft/homebrew-foundry tap; the fully-qualified name auto-taps, so a
# single command installs everything:
#
#   brew install --cask microsoft/foundry/devpack
#
# The signed + notarized binary is hosted on the microsoft/foundry-toolkit release. az comes
# from Homebrew core (declared dependency); azd + the azd Foundry extension + the skill are
# installed by our binary in postflight (--channel brew).
cask "devpack" do
  arch arm: "arm64", intel: "x64"

  version "0.0.4"
  sha256 arm:   "c73b9f46db8fc02585f2ff224724d5db64b743b880dbde2a93194239fd0142f6",
         intel: "4297d83cf5bbf07bc1e640cadfafbbbcd8026338207c7b12758e4346ce6e1e76"

  url "https://github.com/microsoft/foundry-toolkit/releases/download/devpack-installer-#{version}/foundry-devpack-osx-#{arch}.zip",
      verified: "github.com/microsoft/foundry-toolkit/"
  name "Foundry DevPack"
  desc "Foundry prerequisites installer"
  homepage "https://github.com/microsoft/foundry-toolkit"

  # az is a Homebrew core formula -> installed as a dependency. azd is NOT a brew dep: its tap
  # now requires `brew tap` + trust for dependency loading, which would break the one-command
  # install, so the binary installs azd via aka.ms/install-azd.sh in postflight instead.
  depends_on formula: "azure-cli"
  depends_on macos: :ventura

  binary "foundry-devpack"

  postflight do
    # Homebrew scrubs the environment for postflight, so give the binary a real PATH or it
    # won't find `brew` / the brew-installed `az`. `--channel brew` tells it az is provided by
    # Homebrew (verify only) while it installs azd + the extension + the skill itself.
    run_env = {
      "PATH" => "#{HOMEBREW_PREFIX}/bin:#{Dir.home}/.local/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin",
    }
    # Forward a GitHub token only when present. Homebrew strips non-HOMEBREW_ vars but keeps
    # HOMEBREW_GITHUB_API_TOKEN; the binary reads GH_TOKEN. Passing an empty value would send
    # `Authorization: Bearer ''` -> 401, so omit the key when blank.
    token = ENV["HOMEBREW_GITHUB_API_TOKEN"].to_s.strip
    run_env["GH_TOKEN"] = token unless token.empty?
    system_command "#{staged_path}/foundry-devpack",
                   args:         ["--channel", "brew"],
                   env:          run_env,
                   print_stdout: true
  end

  caveats <<~EOS
    Foundry prerequisites (Azure CLI, azd, the azd Foundry extension, and the
    microsoft-foundry skill) were set up during install.
    Re-verify or repair them anytime with:
      foundry-devpack --ensure
  EOS

  # `brew uninstall` removes the linked binary automatically; `--zap` also clears what the
  # installer created (the skill + its state). azd/az are left in place (az is a brew dep).
  zap trash: [
    "~/.agents/skills/microsoft-foundry",
    "~/.local/state/foundry-devpack",
  ]
end
