# typed: true
# frozen_string_literal: true
class AwsSessionManagerPlugin < Formula
    desc "Official Amazon AWS session manager plugin"
    homepage "https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html"
    livecheck do
      url "https://docs.aws.amazon.com/systems-manager/latest/userguide/plugin-version-history.html"
      regex(%r{<td tabindex="-1">(\d+(?:\.\d+)+)</td>}i)
    end

    url "https://s3.amazonaws.com/session-manager-downloads/plugin/1.2.764.0/ubuntu_64bit/session-manager-plugin.deb"
    sha256 "beed4c95c42afd29756d9ecea59c3fcbf937b2c35b9ef84d12b93ac6e74726ba"
    
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
