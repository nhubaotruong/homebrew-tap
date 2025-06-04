# typed: true
# frozen_string_literal: true
class DockerCredentialHelperGhcrLogin < Formula
  desc "Automagically auth to GitHub Container Registry via docker credential helper"
  homepage "https://github.com/bradschwartz/docker-credential-ghcr-login"
  url "https://github.com/bradschwartz/docker-credential-ghcr-login.git",
      revision: "ca8ce48f12b6a9cd92e795514db75a2d6d248186"
  version "0.1.0"
  license "MIT"
  head "https://github.com/bradschwartz/docker-credential-ghcr-login.git", branch: "main"

  livecheck do
    skip "Formula tracks latest commit SHA from HEAD"
  end

  depends_on "go" => :build
  depends_on "gh"

  def install
    system "go", "build", "-trimpath",
           "-ldflags", "-s -w -buildid=",
           *std_go_args(output: bin/"docker-credential-ghcr-login")
  end

  test do
    assert_predicate bin/"docker-credential-ghcr-login", :exist?
  end
end