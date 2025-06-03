# typed: true
# frozen_string_literal: true
class DockerCredentialHelperGhcr < Formula
  desc "Automagically auth to GitHub Container Registry via docker credential helper"
  homepage "https://github.com/bradschwartz/docker-credential-ghcr-login"
  url "https://github.com/bradschwartz/docker-credential-ghcr-login.git",
      revision: "ca8ce48f12b6a9cd92e795514db75a2d6d248186"
  version "0.1.0"
  license "MIT"

  livecheck do
    url :stable
    strategy :git
    regex(/^[0-9a-f]{40}$/i)
  end

  depends_on "go" => :build

  def install
    ldflags = %W[
      -s
      -w
      -buildid=
    ]
    system "go", "build", "-trimpath",
           "-ldflags", "'#{ldflags.join(" ")}'",
           *std_go_args(output: bin/"docker-credential-ghcr-login")
  end

  test do
    assert_predicate bin/"docker-credential-ghcr-login", :exist?
  end
end