cask "zed" do
  arch arm: "aarch64", intel: "x86_64"
  os linux: "linux"

  version "1.27.0"

  on_linux do
    sha256 arm64_linux:  "9e4f8b182f41d4cd434cbbc6d1562329a33ef048d65a39bae0665465d0a638bb",
           x86_64_linux: "719f6bf649ea8d87961adbf728e178561bac3f598d72d7949558d1150cfc43dd"

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
