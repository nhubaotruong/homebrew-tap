cask "http-toolkit" do
  arch arm: "arm64", intel: "x64"
  os linux: "linux"

  version "1.27.1"

  on_linux do
    sha256 arm64_linux:  "9101a7589f2a6ce849fe97811a795255868debdece004ce350954c0c39f6c1fc",
           x86_64_linux: "2776a46c2d847b1c7968ad8d6edc312de278b6216cf7e3fdf6502aad45a162d5"

    url "https://github.com/httptoolkit/httptoolkit-desktop/releases/download/v#{version}/HttpToolkit-#{version}-linux-#{arch}.zip"
  end

  name "HTTP Toolkit"
  desc "HTTP(S) debugging proxy, analyzer, and client"
  homepage "https://httptoolkit.tech/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :linux
  depends_on formula: "wget"

  binary "httptoolkit"
  artifact "httptoolkit.svg",
           target: "#{Dir.home}/.local/share/icons/httptoolkit.svg"
  artifact "httptoolkit.desktop",
           target: "#{Dir.home}/.local/share/applications/httptoolkit.desktop"

  preflight_steps do
    # Create target directories
    mkdir_p ".local/share/applications", base: :home
    mkdir_p ".local/share/icons", base: :home

    # Download icon to staged_path
    run "{{HOMEBREW_PREFIX}}/opt/wget/bin/wget",
        args:           ["-qO", "{{staged_path}}/httptoolkit.svg",
                         "https://raw.githubusercontent.com/httptoolkit/httptoolkit-desktop/main/src/icons/icon.svg"],
        network_access: true

    # Create .desktop file in staged_path. The Icon line needs the real $HOME,
    # which the steps DSL cannot interpolate, so write it through the shell.
    run "bash", args: ["-c", <<~DESKTOP]
      cat > "{{staged_path}}/httptoolkit.desktop" <<EOF
      [Desktop Entry]
      Type=Application
      Name=HTTP Toolkit
      Comment=HTTP(S) debugging proxy, analyzer, and client
      GenericName=HTTP Debugger
      Exec={{HOMEBREW_PREFIX}}/bin/httptoolkit %U
      Icon=$HOME/.local/share/icons/httptoolkit.svg
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
