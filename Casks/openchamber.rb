cask "openchamber" do
  arch arm: "arm64", intel: "amd64"
  os linux: "linux"

  on_linux do
    version "2.5.3"
    sha256 arm64_linux:  "31c4292539cdc1e1eb67d571158fe82d085d7895ba92e0fb2bb1cf232d0a7536",
           x86_64_linux: "773a216220c49435c84be75cac75b972263344e92cff2d1cce49734c1842007c"

    url "https://github.com/openchamber/openchamber/releases/download/v#{version}/OpenChamber-#{version}-linux-#{arch}.deb"
  end

  name "OpenChamber"
  desc "Electron desktop runtime for OpenChamber"
  homepage "https://github.com/openchamber/openchamber"

  livecheck do
    url :url
    strategy :github_latest do |json, _|
      json["tag_name"]&.sub(/^v/i, "")
    end
  end

  depends_on formula: "libarchive"
  depends_on :linux
  container type: :naked

  # Upstream keeps `openchamber` on PATH for the @openchamber/web CLI, so the
  # desktop binary gets its own name instead of shadowing it.
  binary "opt/OpenChamber/openchamber", target: "openchamber-desktop"

  preflight_steps do
    move "OpenChamber-*-linux-*.deb", "openchamber.deb", source_glob: true

    run "{{HOMEBREW_PREFIX}}/opt/libarchive/bin/bsdtar",
        args: ["-xf", "{{staged_path}}/openchamber.deb", "-C", "{{staged_path}}", "data.tar.xz"]
    run "{{HOMEBREW_PREFIX}}/opt/libarchive/bin/bsdtar",
        args: ["-xf", "{{staged_path}}/data.tar.xz", "-C", "{{staged_path}}"]

    mkdir_p ".local/share/applications", base: :home

    # The shell reads an absolute icon path as-is, so no icon theme copy is needed.
    # Wayland rejects Vulkan, and Chromium starts Vulkan anyway for WebGPU via GL
    # interop, which prints an error on every launch. Disabling the Vulkan feature
    # alone does not stop it; forcing the WebGPU adapter to OpenGLES does. Only the
    # desktop launch gets these flags; the openchamber-desktop binary stays untouched.
    write_file ".local/share/applications/openchamber.desktop", <<~EOS, base: :home
      [Desktop Entry]
      Name=OpenChamber
      Exec={{HOMEBREW_PREFIX}}/bin/openchamber-desktop --disable-features=Vulkan --use-webgpu-adapter=opengles %U
      Terminal=false
      Type=Application
      Icon={{staged_path}}/usr/share/icons/hicolor/512x512/apps/openchamber.png
      StartupWMClass=openchamber
      Comment=Electron desktop runtime for OpenChamber
      Categories=Development;
    EOS

    # The deb and its payload archive are only needed to unpack the tree.
    remove "openchamber.deb"
    remove "data.tar.xz"

    # Only Homebrew manages updates; the bundled electron-updater feed would
    # bypass it.
    remove "opt/OpenChamber/resources/app-update.yml"
  end

  uninstall_postflight_steps do
    remove ".local/share/applications/openchamber.desktop", base: :home
  end

  zap trash: "~/.config/openchamber"
end
