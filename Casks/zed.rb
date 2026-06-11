cask "zed" do
  arch arm: "aarch64", intel: "x86_64"
  os linux: "linux"

  version "1.6.3"
  sha256 arm64_linux:  "bb7373c2bab7b809251030a86b3d350b31df40f6a3ae5454fff0afa3ad61877e",
         x86_64_linux: "0fd618752e4282fa46977863af6b7cdc190ae2db7e0b33aeaf835438e0538db5"

  url "https://github.com/zed-industries/zed/releases/download/v#{version}/zed-linux-#{arch}.tar.gz",
      verified: "github.com/zed-industries/zed/"
  name "Zed"
  desc "High-performance, multiplayer code editor"
  homepage "https://zed.dev/"

  livecheck do
    url :url
    strategy :github_latest do |json, _|
      json["tag_name"]&.sub(/^v/i, "")
    end
  end

  binary "zed.app/bin/zed"
  artifact "zed.app/share/icons/hicolor/512x512/apps/zed.png",
           target: "#{Dir.home}/.local/share/icons/hicolor/512x512/apps/zed.png"
  artifact "dev.zed.Zed.desktop",
           target: "#{Dir.home}/.local/share/applications/dev.zed.Zed.desktop"

  preflight do
    FileUtils.mkdir_p "#{Dir.home}/.local/share/applications"
    FileUtils.mkdir_p "#{Dir.home}/.local/share/icons/hicolor/512x512/apps"
    FileUtils.rm_f("#{Dir.home}/.local/share/icons/hicolor/512x512/apps/zed.png")
    FileUtils.rm_f("#{Dir.home}/.local/share/applications/dev.zed.Zed.desktop")

    File.write("#{staged_path}/dev.zed.Zed.desktop", <<~EOS)
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=Zed
      GenericName=Text Editor
      Comment=A high-performance, multiplayer code editor.
      TryExec=#{HOMEBREW_PREFIX}/bin/zed
      StartupNotify=true
      Exec=#{HOMEBREW_PREFIX}/bin/zed %U
      Icon=zed
      Categories=Utility;TextEditor;Development;IDE;
      Keywords=zed;
      MimeType=text/plain;application/x-zerosize;x-scheme-handler/zed;
      Actions=NewWorkspace;

      [Desktop Action NewWorkspace]
      Exec=#{HOMEBREW_PREFIX}/bin/zed --new %U
      Name=Open a new workspace
    EOS
  end

  zap trash: [
    "~/.cache/zed",
    "~/.config/zed",
    "~/.local/share/zed",
  ]
end
