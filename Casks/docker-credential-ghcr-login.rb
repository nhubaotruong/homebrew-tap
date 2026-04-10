cask "docker-credential-ghcr-login" do
  arch arm: "arm64", intel: "amd64"
  os linux: "linux"

  version "0.1.0"
  sha256 arm64_linux:  "25678d9e7d052e10afff4d14e37ed4b4833bda1a65049442ad98d820b9e978f3",
         x86_64_linux: "38970351fa919cc1dc3b94f49d6f46e6f37d7508b3cf025924de3ff5747a9e7a"

  url "https://github.com/bradschwartz/docker-credential-ghcr-login/releases/download/v#{version}/docker-credential-ghcr-login_#{version}_linux_#{arch}.tar.gz",
      verified: "github.com/bradschwartz/docker-credential-ghcr-login/"
  name "Docker Credential Helper for GHCR"
  desc "Automagically auth to GitHub Container Registry via docker credential helper"
  homepage "https://github.com/bradschwartz/docker-credential-ghcr-login"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on formula: "gh"

  binary "docker-credential-ghcr-login"
end
