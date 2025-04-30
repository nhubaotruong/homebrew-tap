# typed: true
# frozen_string_literal: true
class AndroidPlatformTools < Formula
    desc "Android SDK component"
    homepage "https://developer.android.com/tools/releases/platform-tools"
    livecheck do
        url :homepage
        regex(/data-text=["']?[^"' >]*?v?(\d+(?:\.\d+)+)["'> (]/i)
    end

    depends_on :linux
    
    url "https://dl.google.com/android/repository/platform-tools_r36.0.0-linux.zip"
    sha256 "0ead642c943ffe79701fccca8f5f1c69c4ce4f43df2eefee553f6ccb27cbfbe8"
    
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