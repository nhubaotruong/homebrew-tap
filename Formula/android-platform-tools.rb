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
    
    url "https://dl.google.com/android/repository/platform-tools_r35.0.2-linux.zip"
    sha256 "acfdcccb123a8718c46c46c059b2f621140194e5ec1ac9d81715be3d6ab6cd0a"
    
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