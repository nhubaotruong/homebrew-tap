cask "aws-session-manager-plugin" do
  os linux: "linux"

  version "1.2.835.0"
  sha256 "7c6dcad12518571cc7959a713e6a8ae1bdf6ed66fd9bee37dc189e39ca58ae03"

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
    bsdtar = "#{formula_opt_bin("libarchive")}/bsdtar"
    system_command bsdtar, args: ["-xf", "#{staged_path}/session-manager-plugin.deb",
                                  "-C", staged_path.to_s]
    system_command bsdtar, args: ["-xf", "#{staged_path}/data.tar.gz",
                                  "-C", staged_path.to_s]
  end
end
