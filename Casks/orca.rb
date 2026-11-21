cask "orca" do
  on_linux do
    appimage = on_arch_conditional arm: "orca-linux-arm64.AppImage", intel: "orca-linux.AppImage"
    version "1.4.268"
    sha256 arm64_linux:  "90391d5aecb0b22d79aa662deb6d47ce2bcbb16b3f0e2925586e07f0b11e7203",
           x86_64_linux: "2133ba4684578b2e05210bf30f86e8caf1faa1794304501e279ecb230caa3efe"

    url "https://github.com/stablyai/orca/releases/download/v#{version}/#{appimage}"

    app_image appimage, target: "Orca.AppImage"
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

  depends_on :linux

  # Keep the name orca: the CLI's own skill guides tell agents to run `orca`.
  # /usr/bin/orca is the GNOME screen reader, so callers that cannot rely on
  # this link's PATH priority must use the absolute path.
  binary "orca"

  preflight_steps do
    # The CLI ships inside the AppImage. Run it through the AppImage's own
    # Electron in node mode. The splice fills the script slot that node leaves
    # empty under -e, which is the argv position the CLI expects.
    write_file "orca", <<~EOS
      #!/bin/bash
      exec env ELECTRON_RUN_AS_NODE=1 "${ORCA_APPIMAGE:-$HOME/Applications/Orca.AppImage}" -e 'process.argv.splice(1,0,"orca");const p=require("node:path");require(p.join(p.dirname(process.execPath),"resources/app.asar.unpacked/out/cli/index.js")).main()' -- "$@"
    EOS

    set_permissions "orca", "755"
  end

  zap trash: "~/.config/orca"
end
