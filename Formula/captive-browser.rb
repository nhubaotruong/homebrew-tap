# typed: true
# frozen_string_literal: true
class CaptiveBrowser < Formula
  desc "A dedicated Chrome instance to log into captive portals without messing with DNS settings."
  homepage "https://github.com/FiloSottile/captive-browser"
  url "https://github.com/FiloSottile/captive-browser"
  sha256 "201374fcc1bc2d5b54930f6cd0ae4eb4bce8f75ad9bcb853e849f1fa899dda66"
  # Using go install to fetch the binary instead of compiling from source
  version "0.1.0"
  license "MIT"

  # livecheck do
  #   url :stable
  #   strategy :github_latest
  # end

  depends_on "go" => :build

  def install
    # Install static binary using go get
    ENV["GOBIN"] = bin
    system "go", "install", "github.com/FiloSottile/captive-browser@latest"

    # Install OS-specific example configuration files to pkgshare
    if OS.mac?
      (pkgshare/"captive-browser-mac.toml").write <<~EOS
        # browser is the shell (/bin/sh) command executed once the proxy starts.
        # When browser exits, the proxy exits. An extra env var PROXY is available.
        #
        # Here, we use a separate Chrome instance in Incognito mode, so that
        # it can run (and be waited for) alongside the default one, and that
        # it maintains no state across runs. To configure this browser open a
        # normal window in it, settings will be preserved.
        browser = """
            open -n -W -a "Google Chrome" --args \
            --user-data-dir="$HOME/Library/Application Support/Google/Captive" \
            --proxy-server="socks5://$PROXY" \
            --host-resolver-rules="MAP * ~NOTFOUND , EXCLUDE localhost" \
            --no-first-run --new-window --incognito \
            http://example.com
        """

        # dhcp-dns is the shell (/bin/sh) command executed to obtain the DHCP
        # DNS server address. The first match of an IPv4 regex is used.
        # IPv4 only, because let's be real, it's a captive portal.
        # You may need to change en0 to your active network interface.
        dhcp-dns = "ipconfig getoption en0 domain_name_server"

        # socks5-addr is the listen address for the SOCKS5 proxy server.
        socks5-addr = "localhost:1666"

        # ProTip: to disable the insecure system captive browser see here:
        # https://github.com/drduh/macOS-Security-and-Privacy-Guide#captive-portal
        # If that doesn't work, disable SIP (remember to re-enable it), and
        # rename "/System/Library/CoreServices/Captive Network Assistant.app".
      EOS
    elsif OS.linux?
      (pkgshare/"captive-browser-linux.toml").write <<~EOS
        # browser is the shell (/bin/sh) command executed once the proxy starts.
        # When browser exits, the proxy exits. An extra env var PROXY is available.
        #
        # Here, we use a separate Chrome instance in Incognito mode, so that
        # it can run (and be waited for) alongside the default one, and that
        # it maintains no state across runs. To configure this browser open a
        # normal window in it, settings will be preserved.
        browser = """
            google-chrome \
            --user-data-dir="$HOME/.google-chrome-captive" \
            --proxy-server="socks5://$PROXY" \
            --host-resolver-rules="MAP * ~NOTFOUND , EXCLUDE localhost" \
            --no-first-run --new-window --incognito \
            http://example.com
        """

        # dhcp-dns is the shell (/bin/sh) command executed to obtain the DHCP
        # DNS server address. The first match of an IPv4 regex is used.
        # This command attempts to get the first DNS server via nmcli.
        # You may need to adjust this for your specific Linux setup or network interface.
        # For example, to specify an interface:
        # dhcp-dns = "nmcli dev show YOUR_INTERFACE_NAME | grep IP4.DNS | awk '{print $2}' | head -n 1"
        dhcp-dns = "nmcli dev show | grep IP4.DNS | awk '{print $2}' | head -n 1"

        # socks5-addr is the listen address for the SOCKS5 proxy server.
        socks5-addr = "localhost:1666"
      EOS
    end
  end

  def caveats
    s = <<~EOS
      `captive-browser` requires a configuration file to run.
      The application looks for a configuration file at one of these locations:
      - ~/.config/captive-browser.toml
      - $XDG_CONFIG_HOME/captive-browser.toml (if $XDG_CONFIG_HOME is set)

      This software also requires Google Chrome (or a compatible browser specified
      in the config, like 'chromium-browser' on some Linux distros)
      to be installed separately.
    EOS

    if OS.mac?
      s += <<~EOS

        A sample macOS configuration file has been installed to:
          #{opt_pkgshare}/captive-browser-mac.toml
        To get started, copy the sample configuration:
          mkdir -p ~/.config
          cp "#{opt_pkgshare}/captive-browser-mac.toml" ~/.config/captive-browser.toml
        Remember to check if 'en0' in 'dhcp-dns' is your active network interface.
      EOS
    elsif OS.linux?
      s += <<~EOS

        A sample Linux configuration file has been installed to:
          #{opt_pkgshare}/captive-browser-linux.toml
        To get started, copy the sample configuration:
          mkdir -p ~/.config
          cp "#{opt_pkgshare}/captive-browser-linux.toml" ~/.config/captive-browser.toml

        The sample Linux configuration uses 'google-chrome' as the browser and 'nmcli'
        (from network-manager) to detect DNS servers. Ensure these are installed
        and correctly configured on your system.
        You may need to adjust the 'browser' or 'dhcp-dns' commands in
        '~/.config/captive-browser.toml' for your specific Linux distribution and setup
        (e.g., change 'google-chrome' to 'chromium-browser', or specify your network interface
        in the 'dhcp-dns' command).
      EOS
    end
    s
  end

  test do
    # Test if the binary was installed and is executable.
    assert_predicate bin/"captive-browser", :executable?

    # Test that the binary runs and gives an error about missing config, then exits.
    output = shell_output("#{bin}/captive-browser 2>&1", 1)
    assert_match "Error: No config file found", output
  end
end
