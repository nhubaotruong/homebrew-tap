# typed: true
# frozen_string_literal: true
class AndroidPlatformTools < Formula
    name "Android SDK Platform-Tools"
    desc "Android SDK component"
    homepage "https://developer.android.com/tools/releases/platform-tools"
    livecheck do
        url :homepage
        regex(/data-text=["']?[^"' >]*?v?(\d+(?:\.\d+)+)["'> (]/i)
    end

    depends_on :linux
    
    url "https://dl.google.com/android/repository/platform-tools_r35.0.1-linux.zip"
    sha256 "823d270be01444828ccd09e94209ff394fb8a8457243e1c15689fe0544acbc72"
    
    def install
        system "unzip", "platform-tools_r35.0.1-linux.zip"
        bin.install "platform-tools/adb"
        bin.install "platform-tools/etc1tool"
        bin.install "platform-tools/fastboot"
        bin.install "platform-tools/hprof-conv"
        bin.install "platform-tools/make_f2fs"
        bin.install "platform-tools/make_f2fs_casefold"
        bin.install "platform-tools/mke2fs"
        prefix.install_metafiles
    end

    test do
        system bin/"platform-tools/adb"
        system bin/"platform-tools/etc1tool"
        system bin/"platform-tools/fastboot"
        system bin/"platform-tools/hprof-conv"
        system bin/"platform-tools/make_f2fs"
        system bin/"platform-tools/make_f2fs_casefold"
        system bin/"platform-tools/mke2fs"
    end
end