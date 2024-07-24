# typed: true
# frozen_string_literal: true
class AwsSessionManagerPlugin < Formula
    desc "Official Amazon AWS session manager plugin"
    homepage "https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html"
    livecheck do
      url "https://docs.aws.amazon.com/systems-manager/latest/userguide/plugin-version-history.html"
      regex(%r{<td tabindex="-1">(\d+(?:\.\d+)+)</td>}i)
    end

    depends_on :linux
    
    url "https://s3.amazonaws.com/session-manager-downloads/plugin/1.2.650.0/ubuntu_64bit/session-manager-plugin.deb"
    sha256 "16b3aac73cfbc134bc008b5388fb3f9f7f45c8e9af4f9eeb6585a611f75a3dd6"
    
    def install
        system "ar", "x", "session-manager-plugin.deb"
        system "tar", "xf", "data.tar.gz"
        bin.install "usr/local/sessionmanagerplugin/bin/session-manager-plugin"
        prefix.install_metafiles
    end

    depends_on "awscli"

    test do
        system bin/"session-manager-plugin"
    end
end
