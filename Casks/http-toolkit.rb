cask "http-toolkit" do
  arch arm: "arm64", intel: "x64"
  os linux: "linux"

  version "1.24.2"
  sha256 arm64_linux:  "66fd303044545db610ed3b47e651265e1e3fa84dae002151458e49e2857f101b",
         x86_64_linux: "962f2e3aeefcc9a4d9ce3671001d90f36bc9bb0b6c9924716fc218309dfa138a"

  url "https://github.com/httptoolkit/httptoolkit-desktop/releases/download/v#{version}/HttpToolkit-#{version}-linux-#{arch}.zip",
      verified: "github.com/httptoolkit/httptoolkit-desktop/"
  name "HTTP Toolkit"
  desc "HTTP(S) debugging proxy, analyzer, and client"
  homepage "https://httptoolkit.tech/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on formula: "wget"

  binary "httptoolkit"
  artifact "httptoolkit.svg",
           target: "#{Dir.home}/.local/share/icons/httptoolkit.svg"
  artifact "httptoolkit.desktop",
           target: "#{Dir.home}/.local/share/applications/httptoolkit.desktop"

  preflight do
    # Create target directories
    FileUtils.mkdir_p "#{Dir.home}/.local/share/applications"
    FileUtils.mkdir_p "#{Dir.home}/.local/share/icons"

    # Download icon to staged_path
    system_command "#{Formula["wget"].opt_bin}/wget",
                   args: ["-qO", "#{staged_path}/httptoolkit.svg",
                          "https://raw.githubusercontent.com/httptoolkit/httptoolkit-desktop/main/src/icons/icon.svg"]

    # Create .desktop file in staged_path
    File.write("#{staged_path}/httptoolkit.desktop", <<~EOS)
      [Desktop Entry]
      Type=Application
      Name=HTTP Toolkit
      Comment=HTTP(S) debugging proxy, analyzer, and client
      GenericName=HTTP Debugger
      Exec=#{HOMEBREW_PREFIX}/bin/httptoolkit %U
      Icon=#{Dir.home}/.local/share/icons/httptoolkit.svg
      Terminal=false
      StartupNotify=true
      StartupWMClass=HTTP Toolkit
      Categories=Development;Network;
      MimeType=x-scheme-handler/httptoolkit;
      Keywords=httptoolkit;http;debugging;proxy;
    EOS
  end

  zap trash: [
    "~/.cache/httptoolkit",
    "~/.config/HTTP Toolkit",
    "~/.config/httptoolkit-server",
    "~/.local/share/HTTP Toolkit",
    "~/.local/share/httptoolkit",
  ]
end
