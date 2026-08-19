cask "rar" do
  version "7.23"
  sha256 "759b4b6aa0d9f77131882162951193f3a0e54bf60e1d8dc4255aa308accab588"

  url "https://www.rarlab.com/rar/rarlinux-x64-#{version.no_dots}.tar.gz"
  name "RAR Archiver"
  desc "Archive manager for data compression and backups"
  homepage "https://www.rarlab.com/"

  livecheck do
    url "https://www.rarlab.com/download.htm"
    regex(/>\s*RAR\s+for\s+Linux.*?v?(\d+(:?\.\d+)+)\s*</i)
  end

  depends_on :linux

  binary "rar/rar"
  binary "rar/unrar"
  artifact "rar/default.sfx", target: "#{HOMEBREW_PREFIX}/lib/default.sfx"
  artifact "rar/rarfiles.lst", target: "#{HOMEBREW_PREFIX}/etc/rarfiles.lst"

  # No zap stanza required
end
