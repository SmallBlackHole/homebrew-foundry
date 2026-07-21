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
  sha256 arm:   "5001da649e4b5471ae6b0455d624690e2f365c979727e541b8cd8ec16768bd8b",
         intel: "adc8480dac838cd86892d1508f5c3d9c0a7196bea88c055297e968d494921f36"

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
                   args: ["--channel", "brew"],
                   env:  run_env
  end

  # `brew uninstall` removes the linked binary automatically; `--zap` also clears what the
  # installer created (the skill + its state). azd/az are left in place (az is a brew dep).
  zap trash: [
    "~/.agents/skills/microsoft-foundry",
    "~/.local/state/foundry-devpack",
  ]
end
