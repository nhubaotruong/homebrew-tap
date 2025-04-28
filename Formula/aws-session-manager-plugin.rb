# typed: true
# frozen_string_literal: true
class AwsSessionManagerPlugin < Formula
    desc "Official Amazon AWS session manager plugin"
    homepage "https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html"
    livecheck do
      url "https://docs.aws.amazon.com/systems-manager/latest/userguide/plugin-version-history.html"
      regex(%r{<td tabindex="-1">(\d+(?:\.\d+)+)</td>}i)
    end

    url "https://s3.amazonaws.com/session-manager-downloads/plugin/1.2.707.0/ubuntu_64bit/session-manager-plugin.deb"
    sha256 "91cc9a1a8df6f730622d5e11a8610be6e06d5858408e8029b56d0d63aedd0a68"
    
    def install
        system "ar", "x", "session-manager-plugin.deb"
        system "tar", "xf", "data.tar.gz"
        bin.install "usr/local/sessionmanagerplugin/bin/session-manager-plugin"
        prefix.install_metafiles
    end

    depends_on "awscli"
    depends_on :linux

    test do
        system bin/"session-manager-plugin"
    end
end
