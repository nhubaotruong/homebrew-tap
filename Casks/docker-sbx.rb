cask "docker-sbx" do
  os linux: "linux"

  version "0.32.0"
  sha256 "2da12380b1b7669b24ff8b6a1c18097fee89c256c6f50e034efe99e1d7816413"

  url "https://github.com/docker/sbx-releases/releases/download/v#{version}/DockerSandboxes-linux.tar.gz",
      verified: "github.com/docker/sbx-releases/"
  name "Docker Sandboxes"
  desc "Safe sandbox environments for AI agents built by Docker"
  homepage "https://docs.docker.com/ai/sandboxes"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on formula: "e2fsprogs"

  binary "bin/sbx"

  preflight do
    srcdir = "#{staged_path}/docker-sbx"

    FileUtils.mkdir_p "#{staged_path}/bin"
    FileUtils.mkdir_p "#{staged_path}/libexec/lib"

    FileUtils.install "#{srcdir}/sbx", "#{staged_path}/bin/sbx", mode: 0755

    %w[containerd-shim-nerdbox-v1 mkfs.erofs].each do |f|
      FileUtils.install "#{srcdir}/#{f}", "#{staged_path}/libexec/#{f}", mode: 0755
    end

    Dir.glob("#{srcdir}/nerdbox-{kernel,initrd}-*").each do |f|
      FileUtils.install f, "#{staged_path}/libexec/#{File.basename(f)}", mode: 0644
    end

    FileUtils.install "#{srcdir}/libsailor.so", "#{staged_path}/libexec/lib/libsailor.so", mode: 0755
  end

  zap trash: "~/.docker/sbx"
end
