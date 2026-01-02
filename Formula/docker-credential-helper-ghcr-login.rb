# typed: true
# frozen_string_literal: true

class DockerCredentialHelperGhcrLogin < Formula
  desc "Automagically auth to GitHub Container Registry via docker credential helper"
  homepage "https://github.com/bradschwartz/docker-credential-ghcr-login"
  url "https://github.com/bradschwartz/docker-credential-ghcr-login.git",
    revision: "706dc0da92388a6993dbe5c32090beb550585b30"
  head "https://github.com/bradschwartz/docker-credential-ghcr-login.git",
    branch: "main"
  version Utils.git_short_head
  license "MIT"

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
