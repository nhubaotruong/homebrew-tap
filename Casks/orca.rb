cask "orca" do
  on_linux do
    appimage = on_arch_conditional arm: "orca-linux-arm64.AppImage", intel: "orca-linux.AppImage"
    version "1.4.280"
    sha256 arm64_linux:  "34db076dbf51c89f01a73db9ef6a17c42bb99124e95de197ef579f2cdd9faae6",
           x86_64_linux: "7fa4d975bdd151787bb12537908464f87695ecc3f1c26cf553220ee86d3c06c2"

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
