class DockerCredentialHelperGhcrLogin < Formula
  desc "Automagically auth to GitHub Container Registry via docker credential helper"
  homepage "https://github.com/bradschwartz/docker-credential-ghcr-login"
  url "https://github.com/bradschwartz/docker-credential-ghcr-login.git",
      revision: "706dc0da92388a6993dbe5c32090beb550585b30"
  version "706dc0d"
  license "MIT"

  bottle do
    root_url "https://github.com/nhubaotruong/homebrew-tap/releases/download/docker-credential-helper-ghcr-login-706dc0d"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "PLACEHOLDER_SHA256"
  end

  head "https://github.com/bradschwartz/docker-credential-ghcr-login.git",
       branch: "main"

  livecheck do
    url :head
    strategy :git
  end

  depends_on "go" => :build
  depends_on "gh"

  def install
    ENV["CGO_ENABLED"] = "0"
    system "go", "build", "-trimpath",
           "-ldflags", "-s -w -buildid=",
           *std_go_args(output: bin/"docker-credential-ghcr-login")
  end

  test do
    assert_path_exists bin/"docker-credential-ghcr-login"
  end
end
