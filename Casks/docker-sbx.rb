cask "docker-sbx" do
  os linux: "linux"

  version "0.39.0"
  sha256 "2ec45bc7938c20c2f406fe8cc72294ad5a954bdc047601484b89bf1a108311d4"

  url "https://github.com/docker/sbx-releases/releases/download/v#{version}/DockerSandboxes-linux.tar.gz"
  name "Docker Sandboxes"
  desc "Safe sandbox environments for AI agents built by Docker"
  homepage "https://docs.docker.com/ai/sandboxes"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :linux
  depends_on formula: "e2fsprogs"

  binary "bin/sbx"

  preflight_steps do
    mkdir_p "bin"
    mkdir_p "libexec/lib"

    copy "docker-sbx/sbx", "bin/sbx"
    set_permissions "bin/sbx", "0755"
    copy "docker-sbx/containerd-shim-nerdbox-v1", "libexec/containerd-shim-nerdbox-v1"
    set_permissions "libexec/containerd-shim-nerdbox-v1", "0755"
    copy "docker-sbx/mkfs.erofs", "libexec/mkfs.erofs"
    set_permissions "libexec/mkfs.erofs", "0755"

    # Versioned kernel/initrd artifacts cannot be enumerated statically, so
    # mirror the original Dir.glob + FileUtils.install loop in the shell.
    run "bash",
        args: ["-c",
               "for f in \"{{staged_path}}\"/docker-sbx/nerdbox-{kernel,initrd}-*; " \
               "do if [ -e \"$f\" ]; then " \
               "install -m 0644 \"$f\" \"{{staged_path}}/libexec/$(basename \"$f\")\"; fi; done"]

    copy "docker-sbx/libsailor.so", "libexec/lib/libsailor.so"
    set_permissions "libexec/lib/libsailor.so", "0755"
  end

  zap trash: "~/.docker/sbx"
end
