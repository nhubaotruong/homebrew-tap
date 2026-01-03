# typed: true
# frozen_string_literal: true

cask "http-toolkit" do
  arch arm: "arm64", intel: "x64"

  version "1.24.2"
  depends_on linux: :any
  sha256 arm:   "66fd303044545db610ed3b47e651265e1e3fa84dae002151458e49e2857f101b",
         intel: "962f2e3aeefcc9a4d9ce3671001d90f36bc9bb0b6c9924716fc218309dfa138a"

  url "https://github.com/httptoolkit/httptoolkit-desktop/releases/download/v#{version}/HttpToolkit-#{version}-linux-#{arch}.zip",
      verified: "github.com/httptoolkit/httptoolkit-desktop/"
  name "HTTP Toolkit"
  desc "HTTP(S) debugging proxy, analyzer, and client"
  homepage "https://httptoolkit.tech/"

  livecheck do
    url :url
    strategy :github_latest
  end

  resource "icon" do
    url "https://raw.githubusercontent.com/httptoolkit/httptoolkit-desktop/refs/heads/main/src/icons/icon.svg"
    sha256 "d6f7b68e3cf4659a0dd4c2d465e9ee2268a288a0c357c909f5f4176b1d919d38"
  end

  binary "HttpToolkit-#{version}-linux-#{arch}/httptoolkit"

  preflight do
    FileUtils.mkdir_p "#{Dir.home}/.local/share/applications"
    FileUtils.mkdir_p "#{Dir.home}/.local/share/icons"

    resource("icon").stage do
      FileUtils.cp "icon.svg", "#{Dir.home}/.local/share/icons/httptoolkit.svg"
    end

    File.write("#{staged_path}/HttpToolkit-#{version}-linux-#{arch}/httptoolkit.desktop", <<~EOS)
      [Desktop Entry]
      Type=Application
      Name=HTTP Toolkit
      Comment=HTTP(S) debugging proxy, analyzer, and client
      GenericName=HTTP Debugger
      Exec=#{staged_path}/HttpToolkit-#{version}-linux-#{arch}/httptoolkit %U
      Icon=#{Dir.home}/.local/share/icons/httptoolkit.svg
      Terminal=false
      StartupNotify=true
      StartupWMClass=HTTP Toolkit
      Categories=Development;Network;
      MimeType=x-scheme-handler/httptoolkit;
      Keywords=httptoolkit;http;debugging;proxy;
    EOS
  end

  artifact "HttpToolkit-#{version}-linux-#{arch}/httptoolkit.desktop",
           target: "#{Dir.home}/.local/share/applications/httptoolkit.desktop"

  uninstall delete: [
    "#{Dir.home}/.local/share/applications/httptoolkit.desktop",
    "#{Dir.home}/.local/share/icons/httptoolkit.svg",
  ]

  zap trash: [
    "~/.config/HTTP Toolkit",
    "~/.config/httptoolkit-server",
    "~/.local/share/HTTP Toolkit",
    "~/.local/share/httptoolkit",
    "~/.cache/httptoolkit",
  ]
end
