cask "claude-desktop" do
  arch arm: "arm64", intel: "amd64"
  os linux: "linux"

  on_linux do
    version "3.2.4+claude1.49585.0"
    sha256 arm64_linux:  "8a3ae3e007c36a213a16b1b5394e3a0c836baf0cf88a08491e8202952ae27020",
           x86_64_linux: "e0b4ce6313943a69e9bd61749a293bfca241b4dfb37f88df6411b4b69ec67a40"

    claude_version = version.split("+claude")[1]
    url "https://github.com/aaddrick/claude-desktop-debian/releases/download/v#{version.gsub("+", "%2B")}/claude-desktop_#{claude_version}_#{arch}.deb"
  end

  name "Claude Desktop"
  desc "Claude AI desktop application"
  homepage "https://claude.ai/"

  livecheck do
    url :url
    strategy :github_latest do |json, _|
      json["tag_name"]&.sub(/^v/i, "")
    end
  end

  depends_on :linux
  depends_on formula: "libarchive"
  container type: :naked

  binary "usr/bin/claude-desktop"
  artifact "usr/share/icons/hicolor/256x256/apps/claude-desktop.png",
           target: "#{Dir.home}/.local/share/icons/claude-desktop.png"
  artifact "claude-desktop.desktop",
           target: "#{Dir.home}/.local/share/applications/claude-desktop.desktop"

  preflight_steps do
    # Normalise the versioned deb filename: the steps DSL cannot derive the
    # claude version from the cask version, so rename the single staged deb.
    move "claude-desktop_*.deb", "claude-desktop.deb", source_glob: true

    run "{{HOMEBREW_PREFIX}}/opt/libarchive/bin/bsdtar",
        args: ["-xf", "{{staged_path}}/claude-desktop.deb",
               "--strip-components=0", "-C", "{{staged_path}}", "data.tar.xz"]
    run "{{HOMEBREW_PREFIX}}/opt/libarchive/bin/bsdtar",
        args: ["-xf", "{{staged_path}}/data.tar.xz", "-C", "{{staged_path}}"]

    # Create target directories
    mkdir_p ".local/share/applications", base: :home
    mkdir_p ".local/share/icons", base: :home

    # Clear stale targets to avoid "Generic Artifact already exists" on upgrade
    remove ".local/share/icons/claude-desktop.png", base: :home
    remove ".local/share/applications/claude-desktop.desktop", base: :home

    # Create .desktop file in staged_path. The Icon line needs the real $HOME,
    # which the steps DSL cannot interpolate, so write it through the shell.
    run "bash", args: ["-c", <<~DESKTOP]
      cat > "{{staged_path}}/claude-desktop.desktop" <<EOF
      [Desktop Entry]
      Type=Application
      Name=Claude Desktop
      Comment=Claude AI desktop application
      GenericName=AI Assistant
      Exec={{HOMEBREW_PREFIX}}/bin/claude-desktop %U
      Icon=$HOME/.local/share/icons/claude-desktop.png
      Terminal=false
      StartupNotify=true
      StartupWMClass=Claude
      Categories=Office;Utility;Network;
      MimeType=x-scheme-handler/claude;
      Keywords=claude;ai;assistant;anthropic;
      EOF
    DESKTOP
  end

  zap trash: [
    "~/.config/Claude",
    "~/.local/share/Claude",
  ]
end
