cask "docker-credential-ghcr-login" do
  arch arm: "arm64", intel: "amd64"
  os linux: "linux"

  version "0.2.0"

  on_linux do
    sha256 arm64_linux:  "e866d63d3335cdc67b7e0ed16e2dfe84500826b13677bbd9fc42009a2c23a1d9",
           x86_64_linux: "01e7657acced71105fe22ce4394f323d2dca3a915c881d8711b67e555c57e070"

    url "https://github.com/bradschwartz/docker-credential-ghcr-login/releases/download/v#{version}/docker-credential-ghcr-login_#{version}_linux_#{arch}.tar.gz"
  end

  name "Docker Credential Helper for GHCR"
  desc "Automagically auth to GitHub Container Registry via docker credential helper"
  homepage "https://github.com/bradschwartz/docker-credential-ghcr-login"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :linux
  depends_on formula: "gh"

  binary "docker-credential-ghcr-login"
end
