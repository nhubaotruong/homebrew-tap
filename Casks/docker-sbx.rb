cask "docker-sbx" do
  os linux: "linux"

  version "0.28.2"
  sha256 "533ac8fae548c946fd726cb08726a6b656ee95f01cc74a71a9afd04890592aa2"

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

    FileUtils.install "#{srcdir}/libkrun.so", "#{staged_path}/libexec/lib/libkrun.so", mode: 0755
  end

  zap trash: "~/.docker/sbx"
end
