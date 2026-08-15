cask "http-toolkit" do
  arch arm: "arm64", intel: "x64"
  os linux: "linux"

  version "1.27.0"

  on_linux do
    sha256 arm64_linux:  "0d40ee2d03d1d75df730f1c134f7f2ad5bfbc0de5a836e5cd029283088d858d2",
           x86_64_linux: "cb27586145e33f7e04117adeb83e5fb672cbd7bc2942499727ed1df4d42cc303"

    url "https://github.com/httptoolkit/httptoolkit-desktop/releases/download/v#{version}/HttpToolkit-#{version}-linux-#{arch}.zip",
        verified: "github.com/httptoolkit/httptoolkit-desktop/"
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

  preflight do
    # Create target directories
    FileUtils.mkdir_p "#{Dir.home}/.local/share/applications"
    FileUtils.mkdir_p "#{Dir.home}/.local/share/icons"

    # Download icon to staged_path
    system_command "#{formula_opt_bin("wget")}/wget",
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
