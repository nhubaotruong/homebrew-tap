cask "claude-desktop" do
  arch arm: "arm64", intel: "amd64"
  os linux: "linux"

  version "2.0.14+claude1.8555.2"
  sha256 arm64_linux:  "a7e4b3b1aec0d0a9c4f87c8a4223ca961695651a01398dac901f60af89a3eade",
         x86_64_linux: "344665eb633f98780db50fc6f09eba4e2e7fa2495c88bb96a3e44fb6476fb6b1"

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
