cask "claude-desktop" do
  arch arm: "arm64", intel: "amd64"
  os linux: "linux"

  on_linux do
    version "3.3.6+claude2.26454.2"
    sha256 arm64_linux:  "30b2f854d7cc4422b43e8f39f07573c87f7981605197766262d88153c7e9938b",
           x86_64_linux: "b251a0224a8635874f33598df8ed8952b427f84815ee59580cc022d6bdb2430f"

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

  depends_on formula: "libarchive"
  depends_on :linux
  container type: :naked

  binary "usr/bin/claude-desktop"
  artifact "usr/share/icons/hicolor/256x256/apps/claude-desktop.png",
           target: "#{Dir.home}/.local/share/icons/hicolor/256x256/apps/claude-desktop.png"
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
    mkdir_p ".local/share/icons/hicolor/256x256/apps", base: :home

    # Clear stale targets to avoid "Generic Artifact already exists" on upgrade
    remove ".local/share/icons/claude-desktop.png", base: :home
    remove ".local/share/icons/hicolor/256x256/apps/claude-desktop.png", base: :home
    remove ".local/share/applications/claude-desktop.desktop", base: :home

    # Build the .desktop in staged_path; the artifact stanza installs it into
    # the user's home. Icon names the hicolor theme entry, not an absolute path.
    run "bash", args: ["-c", <<~DESKTOP]
      cat > "{{staged_path}}/claude-desktop.desktop" <<EOF
      [Desktop Entry]
      Type=Application
      Name=Claude Desktop
      Comment=Claude AI desktop application
      GenericName=AI Assistant
      Exec={{HOMEBREW_PREFIX}}/bin/claude-desktop %U
      Icon=claude-desktop
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
