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
    root_url "https://github.com/nhubaotruong/homebrew-tap/releases/download/aws-session-manager-plugin-1.2.792.0"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "bd02db95d73b87bc809425f1f4cb95309befe320afdf612967f63c631f826950"
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
