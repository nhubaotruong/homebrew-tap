cask "zed" do
  arch arm: "aarch64", intel: "x86_64"
  os linux: "linux"

  version "1.15.1"

  on_linux do
    sha256 arm64_linux:  "bd6186135cd7f909c8b487e89f2da1d0be0e0c8cebd3be36a707b9823194749a",
           x86_64_linux: "b9a8a080e707487111436665270a0c961b21a06b86f194375a0c940067cb1a17"

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

  depends_on :linux

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
