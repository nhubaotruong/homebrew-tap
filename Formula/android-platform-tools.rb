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
        prefix.install Dir["*"] # Install all files into the prefix directory
        bin.install Dir["platform-tools/*"].select { |f| File.executable? f }
      end
    
    test do
        system "#{bin}/adb", "version"
    end
end