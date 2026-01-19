cask "claude-desktop" do
  arch arm: "arm64", intel: "amd64"
  os linux: "linux"

  version "1.2.1+claude1.1.381"
  sha256 arm64_linux:  "8a7ea96aa7de1c60ab80b9bc49e6a135a3bd34348e541222e1b3f2146d58d4c6",
         x86_64_linux: "4cc3d1ffd0137863c3c2491b57c26e79629f098c4a3733d2ed53d62ed74ee1ec"

  url "https://github.com/aaddrick/claude-desktop-debian/releases/download/v#{version}/claude-desktop_#{version.to_s.split("claude").last}_#{arch}.deb",
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

  preflight do
    system_command "#{Formula["libarchive"].opt_bin}/bsdtar",
                   args: ["-xf", "#{staged_path}/claude-desktop_#{version.to_s.split("claude").last}_#{arch}.deb",
                          "--strip-components=0", "-C", staged_path, "data.tar.zst"]

    system_command "#{Formula["libarchive"].opt_bin}/bsdtar",
                   args: ["-xf", "#{staged_path}/data.tar.zst", "-C", staged_path]

    # Patch the launcher script to use Homebrew paths
    launcher = "#{staged_path}/usr/bin/claude-desktop"
    content = File.read(launcher)
    content.gsub!("/usr/lib/claude-desktop", "#{staged_path}/usr/lib/claude-desktop")
    File.write(launcher, content)
  end

  postflight do
    FileUtils.mkdir_p "#{Dir.home}/.local/share/applications"
    FileUtils.mkdir_p "#{Dir.home}/.local/share/icons"

    FileUtils.cp "#{staged_path}/usr/share/icons/hicolor/256x256/apps/claude-desktop.png",
                 "#{Dir.home}/.local/share/icons/claude-desktop.png"

    File.write("#{Dir.home}/.local/share/applications/claude-desktop.desktop", <<~EOS)
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

  uninstall delete: [
    "#{Dir.home}/.local/share/applications/claude-desktop.desktop",
    "#{Dir.home}/.local/share/icons/claude-desktop.png",
  ]

  zap trash: [
    "~/.config/Claude",
    "~/.local/share/Claude",
  ]
end
