# typed: true
# frozen_string_literal: true

class Rootlesskit < Formula
  desc "Linux-native \"fake root\" for implementing rootless containers"
  homepage "https://github.com/rootless-containers/rootlesskit"
  version "2.3.5"
  url "https://github.com/rootless-containers/rootlesskit.git",
      tag:      "v2.3.5"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :git
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  on_linux do
    on_intel do
      resource "x86_64-binary" do
        url "https://github.com/rootless-containers/rootlesskit/releases/download/v#{version}/rootlesskit-x86_64.tar.gz"
        sha256 "35c4618e1e9a5cb2aaea08edbba6e3de5bbeedd00a65fcf7d14f31fc942a7655"
      end
    end

    on_arm do
      resource "aarch64-binary" do
        url "https://github.com/rootless-containers/rootlesskit/releases/download/v#{version}/rootlesskit-aarch64.tar.gz"
        sha256 "35c4618e1e9a5cb2aaea08edbba6e3de5bbeedd00a65fcf7d14f31fc942a7655" # This needs to be updated with correct aarch64 SHA
      end
    end

    def install
      if Hardware::CPU.intel?
        resource("x86_64-binary").stage do
          bin.install "rootlesskit"
          bin.install "rootlessctl"
          bin.install "rootlesskit-docker-proxy"
        end
      else
        resource("aarch64-binary").stage do
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
    system "#{bin}/rootlesskit"
    system "#{bin}/rootlessctl"
    system "#{bin}/rootlesskit-docker-proxy"
  end
end 