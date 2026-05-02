cask "claude-desktop" do
  arch arm: "arm64", intel: "amd64"
  os linux: "linux"

  version "2.0.8+claude1.5354.0"
  sha256 arm64_linux:  "1f79fdded9791ecb009c67b9d8db5adae0ca22d11ba0de0fbe86c4c6fe06f221",
         x86_64_linux: "72992feb22656cf13ff219c3600d1d10548196c48bbffd039429315d05f192ef"

  version_array = version.split("+claude")
  major_minor_patch = version_array[0]
  claude_version = version_array[1]
  url "https://github.com/aaddrick/claude-desktop-debian/releases/download/v#{version.gsub("+", "%2B")}/claude-desktop_#{claude_version}-#{major_minor_patch}_#{arch}.deb",
      verified: "github.com/aaddrick/claude-desktop-debian/"
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
  container type: :naked

  binary "usr/bin/claude-desktop"
  artifact "usr/share/icons/hicolor/256x256/apps/claude-desktop.png",
           target: "#{Dir.home}/.local/share/icons/claude-desktop.png"
  artifact "claude-desktop.desktop",
           target: "#{Dir.home}/.local/share/applications/claude-desktop.desktop"

  preflight do
    version_array = version.split("+claude")
    major_minor_patch = version_array[0]
    claude_version = version_array[1]

    system_command "#{Formula["libarchive"].opt_bin}/bsdtar",
                   args: ["-xf", "#{staged_path}/claude-desktop_#{claude_version}-#{major_minor_patch}_#{arch}.deb",
                          "--strip-components=0", "-C", staged_path, "data.tar.zst"]

    system_command "#{Formula["libarchive"].opt_bin}/bsdtar",
                   args: ["-xf", "#{staged_path}/data.tar.zst", "-C", staged_path]

    # Patch the launcher script to use Homebrew paths
    launcher = "#{staged_path}/usr/bin/claude-desktop"
    content = File.read(launcher)
    content.gsub!("/usr/lib/claude-desktop", "#{staged_path}/usr/lib/claude-desktop")
    File.write(launcher, content)

    # Create target directories
    FileUtils.mkdir_p "#{Dir.home}/.local/share/applications"
    FileUtils.mkdir_p "#{Dir.home}/.local/share/icons"

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
