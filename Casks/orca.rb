cask "orca" do
  arch arm: "arm64", intel: "amd64"
  os linux: "linux"

  on_linux do
    version "1.4.244"
    sha256 arm64_linux:  "acb430a7ec1b3b8ef30c47ceadb61bb679571c7fdede12a7e6a3a210538a8620",
           x86_64_linux: "8fe4c5c3696c789d2da05e43e0cc9d95af9c1ddbf907f52b9c06203b068c4c89"

    url "https://github.com/stablyai/orca/releases/download/v#{version}/orca-ide_#{version}_#{arch}.deb"
  end

  name "Orca"
  desc "Next-gen IDE for parallel agentic development"
  homepage "https://github.com/stablyai/orca"

  livecheck do
    url :url
    strategy :github_latest do |json, _|
      json["tag_name"]&.sub(/^v/i, "")
    end
  end

  depends_on formula: "libarchive"
  depends_on :linux
  container type: :naked

  binary "opt/Orca/orca-ide"

  preflight_steps do
    move "orca-ide_*.deb", "orca-ide.deb", source_glob: true

    run "{{HOMEBREW_PREFIX}}/opt/libarchive/bin/bsdtar",
        args: ["-xf", "{{staged_path}}/orca-ide.deb", "-C", "{{staged_path}}", "data.tar.xz"]
    run "{{HOMEBREW_PREFIX}}/opt/libarchive/bin/bsdtar",
        args: ["-xf", "{{staged_path}}/data.tar.xz", "-C", "{{staged_path}}"]

    mkdir_p ".local/share/applications", base: :home

    # The shell reads an absolute icon path as-is, so no icon theme copy is needed.
    write_file ".local/share/applications/orca-ide.desktop", <<~EOS, base: :home
      [Desktop Entry]
      Name=Orca
      Exec={{HOMEBREW_PREFIX}}/bin/orca-ide %U
      Terminal=false
      Type=Application
      Icon={{staged_path}}/usr/share/icons/hicolor/512x512/apps/orca-ide.png
      StartupWMClass=orca
      Comment=Next-gen IDE for parallel agentic development
      MimeType=text/markdown;text/csv;text/tab-separated-values;x-scheme-handler/orca;
      Categories=Utility;
    EOS

    # The deb and its payload archive are only needed to unpack the tree.
    remove "orca-ide.deb"
    remove "data.tar.xz"

    # Only Homebrew manages updates; the bundled electron-updater feed would
    # bypass it.
    remove "opt/Orca/resources/app-update.yml"
  end

  uninstall_postflight_steps do
    remove ".local/share/applications/orca-ide.desktop", base: :home
  end

  zap trash: "~/.config/orca"
end
