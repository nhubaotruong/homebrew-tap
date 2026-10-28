cask "zed" do
  arch arm: "aarch64", intel: "x86_64"
  os linux: "linux"

  version "1.26.2"

  on_linux do
    sha256 arm64_linux:  "167c53a4b1ea13a788e6281269ccf0421b7fe77186267b4cd3d91e06a6fba928",
           x86_64_linux: "4d7b972019f25bd0a8cc6f4c56c81ab7ad9205f3461d00ac79259b34a03856d2"

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
