cask "orca" do
  on_linux do
    appimage = on_arch_conditional arm: "orca-linux-arm64.AppImage", intel: "orca-linux.AppImage"
    version "1.4.253"
    sha256 arm64_linux:  "50f4182e244d67d8aef67f98d6a992055608f7093ca25f13b86cd10a4363a49b",
           x86_64_linux: "fce9baedb617c03dde941c6a4408d5bab92d17d2bed1def4015ddbd8fa74efdc"

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
