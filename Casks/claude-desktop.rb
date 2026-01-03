# typed: true
# frozen_string_literal: true

cask "claude-desktop" do
  arch arm: "arm64", intel: "amd64"
  os linux: "linux"

  version "1.1.10+claude0.14.10"
  sha256 arm64_linux:  "9b30d142d138ef4a02d28216c5da36fe29a29e5e6e38eefc5a745ca5dd309b53",
         x86_64_linux: "ea646177f75bb92a2ea6b49b74690e34926aaaf798d5a38df2380fe049464f6a"

  url "https://github.com/aaddrick/claude-desktop-debian/releases/download/v#{version}/claude-desktop_#{version.to_s.split("claude").last}_#{arch}.deb",
      verified: "github.com/aaddrick/claude-desktop-debian/"
  name "Claude Desktop"
  desc "Claude AI desktop application"
  homepage "https://claude.ai/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on formula: "binutils"

  binary "usr/bin/claude-desktop"

  preflight do
    system_command "ar",
                   args:  ["x", "#{staged_path}/claude-desktop_#{version.csv.second}_#{arch}.deb"],
                   chdir: staged_path

    system_command "tar",
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
      Exec=#{staged_path}/usr/bin/claude-desktop %U
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
