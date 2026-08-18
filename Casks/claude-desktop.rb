cask "claude-desktop" do
  arch arm: "arm64", intel: "amd64"
  os linux: "linux"

  on_linux do
    version "3.2.2+claude1.30096.5"
    sha256 arm64_linux:  "9de0fbb5300d80bbf91dc7e4a4d066bfd6bead3830a0d7ae6c8b0a8529cf59ea",
           x86_64_linux: "e699763dd0e33bd831a1c771ea2684ead894f2680f02c71693a4e345046bd8f5"

    claude_version = version.split("+claude")[1]
    url "https://github.com/aaddrick/claude-desktop-debian/releases/download/v#{version.gsub("+", "%2B")}/claude-desktop_#{claude_version}_#{arch}.deb",
        verified: "github.com/aaddrick/claude-desktop-debian/"
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

  preflight do
    claude_version = version.split("+claude")[1]

    system_command "#{formula_opt_bin("libarchive")}/bsdtar",
                   args: ["-xf", "#{staged_path}/claude-desktop_#{claude_version}_#{arch}.deb",
                          "--strip-components=0", "-C", staged_path, "data.tar.xz"]

    system_command "#{formula_opt_bin("libarchive")}/bsdtar",
                   args: ["-xf", "#{staged_path}/data.tar.xz", "-C", staged_path]

    # Create target directories
    FileUtils.mkdir_p "#{Dir.home}/.local/share/applications"
    FileUtils.mkdir_p "#{Dir.home}/.local/share/icons"

    # Clear stale targets to avoid "Generic Artifact already exists" on upgrade
    icon_path = "#{Dir.home}/.local/share/icons/claude-desktop.png"
    desktop_path = "#{Dir.home}/.local/share/applications/claude-desktop.desktop"
    FileUtils.rm(icon_path) if File.exist?(icon_path) || File.symlink?(icon_path)
    FileUtils.rm(desktop_path) if File.exist?(desktop_path) || File.symlink?(desktop_path)

    # Create .desktop file in staged_path
    File.write("#{staged_path}/claude-desktop.desktop", <<~EOS)
      [Desktop Entry]
      Type=Application
      Name=Claude Desktop
      Comment=Claude AI desktop application
      GenericName=AI Assistant
      Exec=#{HOMEBREW_PREFIX}/bin/claude-desktop %U
      Icon=#{Dir.home}/.local/share/icons/claude-desktop.png
      Terminal=false
      StartupNotify=true
      StartupWMClass=Claude
      Categories=Office;Utility;Network;
      MimeType=x-scheme-handler/claude;
      Keywords=claude;ai;assistant;anthropic;
    EOS
  end

  zap trash: [
    "~/.config/Claude",
    "~/.local/share/Claude",
  ]
end
