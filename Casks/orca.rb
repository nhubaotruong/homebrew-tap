cask "orca" do
  arch arm: "arm64", intel: "amd64"
  os linux: "linux"

  on_linux do
    version "1.4.245"
    sha256 arm64_linux:  "9dd7cd390f5e1169e6f4a5234a829e732a3b3130302bf5066dbdcc96bf3d2f8d",
           x86_64_linux: "54420e22d49dda9df66ed4e943b62844c955d4fd9d5c1059bf8f7702b760bc89"

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
    # Wayland rejects Vulkan, and Chromium starts Vulkan anyway for WebGPU via GL
    # interop, which prints an error on every launch. Disabling the Vulkan feature
    # alone does not stop it; forcing the WebGPU adapter to OpenGLES does. Only the
    # desktop launch gets these flags; the orca-ide binary stays untouched.
    write_file ".local/share/applications/orca-ide.desktop", <<~EOS, base: :home
      [Desktop Entry]
      Name=Orca
      Exec={{HOMEBREW_PREFIX}}/bin/orca-ide --disable-features=Vulkan --use-webgpu-adapter=opengles %U
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
