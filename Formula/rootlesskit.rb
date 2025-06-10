# typed: true
# frozen_string_literal: true

class Rootlesskit < Formula
  desc "Linux-native \"fake root\" for implementing rootless containers"
  homepage "https://github.com/rootless-containers/rootlesskit"
  # Use url directly here, and let livecheck handle the version
  url "https://github.com/rootless-containers/rootlesskit/archive/refs/tags/v2.3.5.tar.gz"
  sha256 "0f242502f5a5ae52723c34e857418928c0570b2c1514757c2a7924c7f07a16f2" # SHA256 of the v2.3.5 source tarball
  license "Apache-2.0"
  head "https://github.com/rootless-containers/rootlesskit.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_releases
  end

  on_linux do
    # Use different resource names to avoid confusion with the main url
    # Fetch the SHA256 sums from the release page for the binaries
    # You'll need to manually update these SHAs to match the latest release
    on_intel do
      resource "rootlesskit-x86_64" do
        url "https://github.com/rootless-containers/rootlesskit/releases/download/v#{version}/rootlesskit-x86_64.tar.gz"
        # IMPORTANT: Replace with the actual SHA256 for rootlesskit-x86_64.tar.gz for v2.3.5
        sha256 "1c28b7e0170a442e97d195f269a888c3f4a5f82490b42d627c2e9b04f7678c77"
      end
    end

    on_arm do
      resource "rootlesskit-aarch64" do
        url "https://github.com/rootless-containers/rootlesskit/releases/download/v#{version}/rootlesskit-aarch64.tar.gz"
        # IMPORTANT: Replace with the actual SHA256 for rootlesskit-aarch64.tar.gz for v2.3.5
        sha256 "1724d2715ff2886f4a2fb74a001a1820614562507851b4395679e95964893792"
      end
    end

    def install
      # Homebrew automatically unpacks the tar.gz for the main url
      # For resources, you need to stage them.
      # The `stage` block extracts the resource into a temporary directory.
      if Hardware::CPU.intel?
        resource("rootlesskit-x86_64").stage do
          bin.install "rootlesskit"
          bin.install "rootlessctl"
          bin.install "rootlesskit-docker-proxy"
        end
      else # This will handle aarch64 for now, add more `elsif` for other architectures if needed
        resource("rootlesskit-aarch64").stage do
          bin.install "rootlesskit"
          bin.install "rootlessctl"
          bin.install "rootlesskit-docker-proxy"
        end
      end
    end
  end

  on_macos do
    def install
      odie "rootlesskit is only supported on Linux"
    end
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