cask "zed" do
  arch arm: "aarch64", intel: "x86_64"
  os linux: "linux"

  version "1.11.3"

  on_linux do
    sha256 arm64_linux:  "deba67d5fcc042b8ad9f92e803464b4ea0b220880fdc373ba5827fcad4ebd9fc",
           x86_64_linux: "483ee09c885801dd7a0230e3ccf5c463c4dbe4559927f5856fd568e7b1a32e3e"

    url "https://github.com/zed-industries/zed/releases/download/v#{version}/zed-linux-#{arch}.tar.gz",
        verified: "github.com/zed-industries/zed/"
  end
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

  preflight do
    icon_dir = "#{Dir.home}/.local/share/icons/hicolor/512x512/apps"
    apps_dir = "#{Dir.home}/.local/share/applications"
    FileUtils.mkdir_p apps_dir
    FileUtils.mkdir_p icon_dir

    FileUtils.cp "#{staged_path}/zed.app/share/icons/hicolor/512x512/apps/zed.png",
                 "#{icon_dir}/zed.png"

    File.write("#{apps_dir}/dev.zed.Zed.desktop", <<~EOS)
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

  uninstall_postflight do
    FileUtils.rm "#{Dir.home}/.local/share/applications/dev.zed.Zed.desktop", force: true
    FileUtils.rm "#{Dir.home}/.local/share/icons/hicolor/512x512/apps/zed.png", force: true
  end

  zap trash: [
    "~/.cache/zed",
    "~/.config/zed",
    "~/.local/share/zed",
  ]
end
