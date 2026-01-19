class AndroidPlatformTools < Formula
  desc "Android SDK component"
  homepage "https://developer.android.com/tools/releases/platform-tools"
  url "https://dl.google.com/android/repository/platform-tools_r36.0.2-linux.zip"
  sha256 "3afdea91441815ab41254193df0343d92c1b1c0d0237165c3a345c8af8891c31"

  livecheck do
    url :homepage
    regex(/data-text=["']?[^"' >]*?v?(\d+(?:\.\d+)+)["'> (]/i)
  end

  bottle do
    root_url "https://github.com/nhubaotruong/homebrew-tap/releases/download/android-platform-tools-36.0.2"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "4207b032b877d736b24acba29deb0c642c112059aefe7d9e696f784c35347495"
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
