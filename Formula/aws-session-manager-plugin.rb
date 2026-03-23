class AwsSessionManagerPlugin < Formula
  desc "Official Amazon AWS session manager plugin"
  homepage "https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html"
  url "https://s3.amazonaws.com/session-manager-downloads/plugin/1.2.792.0/ubuntu_64bit/session-manager-plugin.deb"
  version "1.2.792.0"
  sha256 "34e2e68254c77a182264232ed47985901e5f07f190c280400746a004276830c4"

  livecheck do
    url "https://docs.aws.amazon.com/systems-manager/latest/userguide/plugin-version-history.html"
    regex(%r{<td tabindex="-1">(\d+\.\d+\.\d+\.\d+)</td>}i)
  end

  bottle do
    root_url "https://github.com/nhubaotruong/homebrew-tap/releases/download/aws-session-manager-plugin-1.2.792.0"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "e5868bc36f93b2d9caf5457ddaa0e790637c0962d84bae078f7200c4092c936e"
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
