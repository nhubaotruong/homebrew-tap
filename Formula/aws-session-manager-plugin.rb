class AwsSessionManagerPlugin < Formula
  desc "Official Amazon AWS session manager plugin"
  homepage "https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html"
  url "https://s3.amazonaws.com/session-manager-downloads/plugin/1.2.804.0/ubuntu_64bit/session-manager-plugin.deb"
  version "1.2.804.0"
  sha256 "5ca19f45bd29082cd28f5001444cc0e9743b866f6431503dfd528bdc81a21bc3"

  livecheck do
    url "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/VERSION"
    regex(/(\d+\.\d+\.\d+\.\d+)/i)
  end

  bottle do
    root_url "https://github.com/nhubaotruong/homebrew-tap/releases/download/aws-session-manager-plugin-1.2.804.0"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "3c94259d41f1866f350d80e37e6d1112daf7a2001b97c38c60d85d874a562984"
  end

  depends_on :linux

  def install
    system "ar", "x", "session-manager-plugin.deb"
    system "tar", "xf", "data.tar.gz"
    bin.install "usr/local/sessionmanagerplugin/bin/session-manager-plugin"
    prefix.install_metafiles
  end

  test do
    system bin/"session-manager-plugin"
  end
end
