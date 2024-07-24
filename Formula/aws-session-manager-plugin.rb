# typed: true
# frozen_string_literal: true
class AwsSessionManagerPlugin < Formula
    desc "Official Amazon AWS session manager plugin"
    homepage "https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html"
    version "1.2.463.0"
    livecheck do
      url "https://docs.aws.amazon.com/systems-manager/latest/userguide/plugin-version-history.html"
      regex(%r{<td tabindex="-1">(\d+(?:\.\d+)+)</td>}i)
    end

    depends_on :linux
    
    url "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb"
    sha256 "cc58fc31e2239230336b243fa97bd63a7202068dd7ce8470eaf654c1928c10a8"
    
    def install
      bin.install "bin/session-manager-plugin"
      prefix.install %w[LICENSE VERSION]
    end

    depends_on "awscli"

    test do
        system bin/"session-manager-plugin"
    end
end
