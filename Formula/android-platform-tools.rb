class AndroidPlatformTools < Formula
  desc "Android SDK component"
  homepage "https://developer.android.com/tools/releases/platform-tools"
  url "https://dl.google.com/android/repository/platform-tools_r37.0.0-linux.zip"
  sha256 "198ae156ab285fa555987219af237b31102fefe8b9d2bc274708a8d4f2865a07"

  livecheck do
    url :homepage
    regex(/data-text=["']?[^"' >]*?v?(\d+(?:\.\d+)+)["'> (]/i)
  end

  bottle do
    root_url "https://github.com/nhubaotruong/homebrew-tap/releases/download/android-platform-tools-37.0.0"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "74f0635fef7133470c1a3fa91a26c57f3ecc8dacbc430bbb5ac8e1baf08bb2ed"
  end

  depends_on :linux

  def install
    # Install bundled libc++.so
    lib.install Dir["lib64/*"]

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
    assert_match "Android Debug Bridge", shell_output("#{bin}/adb --version")
    assert_match "fastboot version", shell_output("#{bin}/fastboot --version")
    assert_predicate bin/"etc1tool", :executable?
    assert_predicate bin/"hprof-conv", :executable?
    assert_predicate bin/"make_f2fs", :executable?
    assert_predicate bin/"make_f2fs_casefold", :executable?
    assert_predicate bin/"mke2fs", :executable?
  end
end
