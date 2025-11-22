# typed: true
# frozen_string_literal: true

class Rootlesskit < Formula
  desc "Linux-native \"fake root\" for implementing rootless containers"
  homepage "https://github.com/rootless-containers/rootlesskit"
  url "https://github.com/rootless-containers/rootlesskit.git",
      tag:      "v2.3.5",
      revision: "0cc0811acc6e4daee71817383e62fb811590bc13"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :git
    regex(/^v(\d+(?:\.\d+)+)$/i)
  end

  def install
    if OS.linux?
      current_version = version
      # Use different resource names to avoid confusion with the main url
      # Fetch the SHA256 sums from the release page for the binaries
      # You'll need to manually update these SHAs to match the latest release
      if Hardware::CPU.intel?
        resource("rootlesskit-x86_64").stage do
          bin.install "rootlesskit"
          bin.install "rootlessctl"
          bin.install "rootlesskit-docker-proxy"
        end
      elsif Hardware::CPU.arm?
        resource("rootlesskit-aarch64").stage do
          bin.install "rootlesskit"
          bin.install "rootlessctl"
          bin.install "rootlesskit-docker-proxy"
        end
      end
    else
      odie "rootlesskit is only supported on Linux"
    end
  end

  resource "rootlesskit-x86_64" do
    url "https://github.com/rootless-containers/rootlesskit/releases/download/v#{version}/rootlesskit-x86_64.tar.gz"
    sha256 "118208e25becd144ee7317c172fc9decce7b16174d5c1bbf80f1d1d0eacc6b5f"
  end

  resource "rootlesskit-aarch64" do
    url "https://github.com/rootless-containers/rootlesskit/releases/download/v#{version}/rootlesskit-aarch64.tar.gz"
    sha256 "478c14c3195bf989cd9a8e6bd129d227d5d88f1c11418967ffdc84a0072cc7a2"
  end

  test do
    # Simple test to check if binaries exist and are executable
    system "#{bin}/rootlesskit", "--version"
    system "#{bin}/rootlessctl", "--version"
    # rootlesskit-docker-proxy might need more context to run without error,
    # so a simple existence check or version check might be sufficient for a basic test.
    # If it errors out without arguments, consider a less intrusive test.
    system "#{bin}/rootlesskit-docker-proxy", "--help" # Or similar command that doesn't require a running daemon
  end
end
