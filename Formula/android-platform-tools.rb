class AndroidPlatformTools < Formula
  desc "Android SDK component"
  homepage "https://developer.android.com/tools/releases/platform-tools"
  url "https://dl.google.com/android/repository/platform-tools_r36.0.2-linux.zip"
  sha256 "3afdea91441815ab41254193df0343d92c1b1c0d0237165c3a345c8af8891c31"

  livecheck do
    url :homepage
    regex(/data-text=["']?[^"' >]*?v?(\d+(?:\.\d+)+)["'> (]/i)
  end

  depends_on :linux

  def install
    bin.install "adb"
    bin.install "etc1tool"
    bin.install "fastboot"
    bin.install "hprof-conv"
    bin.install "make_f2fs"
    bin.install "make_f2fs_casefold"
    bin.install "mke2fs"
    prefix.install_metafiles
  end

  test do
    system bin/"adb"
    system bin/"etc1tool"
    system bin/"fastboot"
    system bin/"hprof-conv"
    system bin/"make_f2fs"
    system bin/"make_f2fs_casefold"
    system bin/"mke2fs"
  end
end
