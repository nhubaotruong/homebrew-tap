cask "http-toolkit" do
  arch arm: "arm64", intel: "x64"
  os linux: "linux"

  version "1.24.4"
  sha256 arm64_linux:  "11365e42864bf7d7bdb65a9fb7192ef5af280eb3ae41e15fddedd5969b5e47f0",
         x86_64_linux: "1c335aaebbcb9b7b618916ba9482b8cf4f5c68a8aa30d15938b79baece9f1a34"

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
