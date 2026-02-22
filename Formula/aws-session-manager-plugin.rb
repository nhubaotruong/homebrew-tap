class AwsSessionManagerPlugin < Formula
  desc "Official Amazon AWS session manager plugin"
  homepage "https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html"
  url "https://s3.amazonaws.com/session-manager-downloads/plugin/1.2.779.0/ubuntu_64bit/session-manager-plugin.deb"
  sha256 "37c1af3f7b88604e5c31908d2866c89e74d1a111dee9217d3b14e3e60121a3ff"

  livecheck do
    url "https://docs.aws.amazon.com/systems-manager/latest/userguide/plugin-version-history.html"
    regex(%r{<td tabindex="-1">(\d+(?:\.\d+)+)</td>}i)
  end

  bottle do
    root_url "https://github.com/nhubaotruong/homebrew-tap/releases/download/aws-session-manager-plugin-1.2.764"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "bfe9ccf1b00d6f94025e2010aaf2b34121a488ccf3322b7fb5565e08a5e4dbdd"
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
