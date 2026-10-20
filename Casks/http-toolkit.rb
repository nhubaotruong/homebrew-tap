cask "http-toolkit" do
  arch arm: "arm64", intel: "x64"
  os linux: "linux"

  version "1.27.3"

  on_linux do
    sha256 arm64_linux:  "ecc222a2520eb2d56a40a6a952d1e78f75a7e03c6aca4c7ba1479a850ac2f0ab",
           x86_64_linux: "a5aed9babda9b9806facea1b1c449c5591270dee5b814f24d5a32ae34ee40fe4"

    url "https://github.com/httptoolkit/httptoolkit-desktop/releases/download/v#{version}/HttpToolkit-#{version}-linux-#{arch}.zip"
  end

  name "HTTP Toolkit"
  desc "HTTP(S) debugging proxy, analyzer, and client"
  homepage "https://httptoolkit.tech/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on formula: "wget"
  depends_on :linux

  binary "httptoolkit"
  artifact "httptoolkit.svg",
           target: "#{Dir.home}/.local/share/icons/hicolor/scalable/apps/httptoolkit.svg"
  artifact "httptoolkit.desktop",
           target: "#{Dir.home}/.local/share/applications/httptoolkit.desktop"

  preflight_steps do
    # Create target directories
    mkdir_p ".local/share/applications", base: :home
    mkdir_p ".local/share/icons/hicolor/scalable/apps", base: :home

    # Download icon to staged_path
    run "{{HOMEBREW_PREFIX}}/opt/wget/bin/wget",
        args:           ["-qO", "{{staged_path}}/httptoolkit.svg",
                         "https://raw.githubusercontent.com/httptoolkit/httptoolkit-desktop/main/src/icons/icon.svg"],
        network_access: true

    # Build the .desktop in staged_path; the artifact stanza installs it into
    # the user's home. Icon names the hicolor theme entry, not an absolute path.
    run "bash", args: ["-c", <<~DESKTOP]
      cat > "{{staged_path}}/httptoolkit.desktop" <<EOF
      [Desktop Entry]
      Type=Application
      Name=HTTP Toolkit
      Comment=HTTP(S) debugging proxy, analyzer, and client
      GenericName=HTTP Debugger
      Exec={{HOMEBREW_PREFIX}}/bin/httptoolkit %U
      Icon=httptoolkit
      Terminal=false
      StartupNotify=true
      StartupWMClass=HTTP Toolkit
      Categories=Development;Network;
      MimeType=x-scheme-handler/httptoolkit;
      Keywords=httptoolkit;http;debugging;proxy;
      EOF
    DESKTOP
  end

  zap trash: [
    "~/.cache/httptoolkit",
    "~/.config/HTTP Toolkit",
    "~/.config/httptoolkit-server",
    "~/.local/share/HTTP Toolkit",
    "~/.local/share/httptoolkit",
  ]
end
