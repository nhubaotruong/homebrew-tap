cask "claude-desktop" do
  arch arm: "arm64", intel: "amd64"
  os linux: "linux"

  on_linux do
    version "3.2.4+claude1.46388.2"
    sha256 arm64_linux:  "b944a2154528815bb476bfb1e7091f8a3e329b3c67f6c11de8d41668a603bd9e",
           x86_64_linux: "98bf54e85e4916068c4281459b0f0431d8ff68034773f3ee98311d7206566ab1"

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
