cask "tailmix-gui" do
  arch arm: "aarch64", intel: "x86_64"
  os linux: "linux"

  version "1.0.0"

  on_linux do
    sha256 arm64_linux:  "30daf4f07874cbeb347eb0aad4fa4c59f8b9eeb080b03c92dd7d51739461765f",
           x86_64_linux: "b1d69288e94f37008fa805d944a0643a4ef5326046dd706e01acd2bd82f5a794"

    url "https://github.com/nhubaotruong/tailmix-gui/releases/download/v#{version}/tailmix-gui-#{version}-#{arch}-linux.tar.gz"
  end

  name "Tailmix GUI"
  desc "GNOME frontend for tailmix"
  homepage "https://github.com/nhubaotruong/tailmix-gui"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on formula: "gtk4"
  depends_on formula: "libadwaita"
  depends_on :linux

  binary "tailmix-gui"
  artifact "io.github.nhubaotruong.TailmixGui.desktop",
           target: "#{Dir.home}/.local/share/applications/io.github.nhubaotruong.TailmixGui.desktop"
  artifact "share/metainfo/io.github.nhubaotruong.TailmixGui.metainfo.xml",
           target: "#{Dir.home}/.local/share/metainfo/io.github.nhubaotruong.TailmixGui.metainfo.xml"
  artifact "share/icons/hicolor/scalable/apps/io.github.nhubaotruong.TailmixGui.svg",
           target: "#{Dir.home}/.local/share/icons/hicolor/scalable/apps/io.github.nhubaotruong.TailmixGui.svg"

  preflight_steps do
    mkdir_p ".local/share/applications", base: :home
    mkdir_p ".local/share/metainfo", base: :home
    mkdir_p ".local/share/icons/hicolor/scalable/apps", base: :home

    # Desktop sessions may not have the brew bin dir on PATH.
    copy "share/applications/io.github.nhubaotruong.TailmixGui.desktop",
         "io.github.nhubaotruong.TailmixGui.desktop"
    inreplace "io.github.nhubaotruong.TailmixGui.desktop",
              "Exec=tailmix-gui", "Exec={{HOMEBREW_PREFIX}}/bin/tailmix-gui"
  end
end
