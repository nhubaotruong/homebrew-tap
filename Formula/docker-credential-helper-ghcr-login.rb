# typed: true
# frozen_string_literal: true

class DockerCredentialHelperGhcrLogin < Formula
  desc "Automagically auth to GitHub Container Registry via docker credential helper"
  homepage "https://github.com/bradschwartz/docker-credential-ghcr-login"
  head "https://github.com/bradschwartz/docker-credential-ghcr-login.git",
    branch: "main"
  license "MIT"

  livecheck do
    url :head
    strategy :git
  end

  depends_on "go" => :build
  depends_on "gh"

  def install
    system "go", "build", "-trimpath",
           "-ldflags", "-s -w -buildid=",
           *std_go_args(output: bin/"docker-credential-ghcr-login")
  end

  test do
    assert_path_exists bin/"docker-credential-ghcr-login"
  end
end
