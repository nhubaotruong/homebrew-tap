cask "zed" do
  arch arm: "aarch64", intel: "x86_64"
  os linux: "linux"

  version "1.5.4"
  sha256 arm64_linux:  "303df2ec732551700e9d367a57851ea22e641ad0bf00affc854fb8d49bf045bd",
         x86_64_linux: "cdb7e6782b5cebddc5560c6cd976c2bc38e34ae71d9b9b17033c49354fb7c31b"

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
