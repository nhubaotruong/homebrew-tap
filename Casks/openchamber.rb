cask "openchamber" do
  arch arm: "arm64", intel: "amd64"
  os linux: "linux"

  on_linux do
    version "2.5.2"
    sha256 arm64_linux:  "4e2ea3a464a9b39e138680a7596ceda365f17a91f7d3f13270190377fdda2857",
           x86_64_linux: "a8b1284f12c93446e572f480e1b09a597601b881634ec814d125275721d31ce8"

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
    mkdir_p ".local/share/icons/hicolor/512x512/apps", base: :home

    copy "usr/share/icons/hicolor/512x512/apps/openchamber.png",
         ".local/share/icons/hicolor/512x512/apps/openchamber.png", target_base: :home

    write_file ".local/share/applications/openchamber.desktop", <<~EOS, base: :home
      [Desktop Entry]
      Name=OpenChamber
      Exec={{HOMEBREW_PREFIX}}/bin/openchamber-desktop %U
      Terminal=false
      Type=Application
      Icon=openchamber
      StartupWMClass=openchamber
      Comment=Electron desktop runtime for OpenChamber
      Categories=Development;
    EOS

    # The deb and its payload archive are only needed to unpack the tree.
    remove "openchamber.deb"
    remove "data.tar.xz"

    # A stale user icon cache hides the icon of the desktop entry.
    run "gtk-update-icon-cache", args: ["-f", "-t", "#{Dir.home}/.local/share/icons/hicolor"],
        writable_paths: [".local/share/icons/hicolor"], writable_base: :home, must_succeed: false
    run "update-desktop-database", args: ["#{Dir.home}/.local/share/applications"],
        writable_paths: [".local/share/applications"], writable_base: :home, must_succeed: false
  end

  uninstall_postflight_steps do
    remove ".local/share/applications/openchamber.desktop", base: :home
    remove ".local/share/icons/hicolor/512x512/apps/openchamber.png", base: :home
  end

  zap trash: "~/.config/openchamber"
end
