cask "aws-session-manager-plugin" do
  os linux: "linux"

  version "1.2.814.0"
  sha256 "67ddd12b963c28e44126f9732075caae333cc5f55e902623bd6a107ead2bcc56"

  url "https://s3.amazonaws.com/session-manager-downloads/plugin/#{version}/ubuntu_64bit/session-manager-plugin.deb"
  name "AWS Session Manager Plugin"
  desc "Official Amazon AWS session manager plugin"
  homepage "https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html"

  livecheck do
    url "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/VERSION"
    regex(/(\d+\.\d+\.\d+\.\d+)/i)
  end

  depends_on formula: "libarchive"
  container type: :naked

  binary "usr/local/sessionmanagerplugin/bin/session-manager-plugin"

  preflight do
    bsdtar = "#{Formula["libarchive"].opt_bin}/bsdtar"
    system_command bsdtar, args: ["-xf", "#{staged_path}/session-manager-plugin.deb",
                                  "-C", staged_path.to_s]
    system_command bsdtar, args: ["-xf", "#{staged_path}/data.tar.gz",
                                  "-C", staged_path.to_s]
  end
end
