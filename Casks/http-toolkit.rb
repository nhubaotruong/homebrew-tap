cask "http-toolkit" do
  arch arm: "arm64", intel: "x64"
  os linux: "linux"

  version "1.27.2"

  on_linux do
    sha256 arm64_linux:  "d1278556d0c72ecd972a573e394bcde5c3798c48ce70c53a8f074f0110ff4dfd",
           x86_64_linux: "d1227b56ae09c57bd6d801e073786939779676447c5238f25643b4a3657be3db"

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
