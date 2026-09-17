cask "zed" do
  arch arm: "aarch64", intel: "x86_64"
  os linux: "linux"

  version "1.20.1"

  on_linux do
    sha256 arm64_linux:  "7081248afe9bfd4882482e685f1ffd1bdae7596072d52c959fbee6d976aaf0ba",
           x86_64_linux: "a273674d829d7a536bfc2566967df9eb83718f191242b26d3ebe3a46f36f4de2"

    url "https://github.com/zed-industries/zed/releases/download/v#{version}/zed-linux-#{arch}.tar.gz"
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

  preflight_steps do
    mkdir_p ".local/share/applications", base: :home
    mkdir_p ".local/share/icons/hicolor/512x512/apps", base: :home

    copy "zed.app/share/icons/hicolor/512x512/apps/zed.png",
         ".local/share/icons/hicolor/512x512/apps/zed.png", target_base: :home

    write_file ".local/share/applications/dev.zed.Zed.desktop", <<~EOS, base: :home
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=Zed
      GenericName=Text Editor
      Comment=A high-performance, multiplayer code editor.
      TryExec={{HOMEBREW_PREFIX}}/bin/zed
      StartupNotify=true
      Exec={{HOMEBREW_PREFIX}}/bin/zed %U
      Icon=zed
      Categories=Utility;TextEditor;Development;IDE;
      Keywords=zed;
      MimeType=text/plain;application/x-zerosize;x-scheme-handler/zed;
      Actions=NewWorkspace;

      [Desktop Action NewWorkspace]
      Exec={{HOMEBREW_PREFIX}}/bin/zed --new %U
      Name=Open a new workspace
    EOS
  end

  uninstall_postflight_steps do
    remove ".local/share/applications/dev.zed.Zed.desktop", base: :home
    remove ".local/share/icons/hicolor/512x512/apps/zed.png", base: :home
  end

  zap trash: [
    "~/.cache/zed",
    "~/.config/zed",
    "~/.local/share/zed",
  ]
end
