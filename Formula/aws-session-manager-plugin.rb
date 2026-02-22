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
    root_url "https://github.com/nhubaotruong/homebrew-tap/releases/download/aws-session-manager-plugin-1.2.779"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "f8e26a51ee1799c4070cf7a64144904ef5cd537c3e7b972bfe85d8a9a4a97306"
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
