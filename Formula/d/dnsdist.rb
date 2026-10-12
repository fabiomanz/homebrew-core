class Dnsdist < Formula
  include Language::Python::Virtualenv

  desc "Highly DNS-, DoS- and abuse-aware loadbalancer"
  homepage "https://www.dnsdist.org/"
  url "https://downloads.powerdns.com/releases/dnsdist-2.1.2.tar.xz"
  sha256 "9fcb469d7a1b5116606f2563761343d1c595523c1fd67808835fa4edc03c24ce"
  license "GPL-2.0-only" # with OpenSSL Exception (non-SPDX)
  revision 1

  livecheck do
    url "https://downloads.powerdns.com/releases/"
    regex(/href=.*?dnsdist[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    rebuild 1
    sha256 arm64_golden_gate: "7bb259871ce5a173c2e7d8d7ace7df4190dc8dcdad3e31afc0c2ad9b948ba966"
    sha256 arm64_tahoe:       "6cfee5c2079be865920fd87d6fddbe2ac88f310543054f37178ccb1e64fa6b01"
    sha256 arm64_sequoia:     "aea3095dd0faa5ce2d979436ec36841cfd38ec994d2db4c6b1bc8dd99ae6dc8d"
    sha256 arm64_linux:       "cc17326dd45e206fa93faf2abe55a95050bbf56e74d8d0cc3c51fda6a8f5f393"
    sha256 x86_64_linux:      "e2279dbecb99b1aec8c440461a9ccaa4212941990bb593360939d2c9d02e59fa"
  end

  depends_on "boost" => :build
  depends_on "libyaml" => :build # for PyYaml
  depends_on "pkgconf" => :build
  depends_on "python@3.15" => :build
  depends_on "fstrm"
  depends_on "libnghttp2"
  depends_on "libsodium"
  depends_on "luajit"
  depends_on "openssl@4"
  depends_on "re2"
  depends_on "tinycdb"

  uses_from_macos "libedit"

  pypi_packages package_name:   "",
                extra_packages: "pyyaml"

  resource "pyyaml" do
    url "https://files.pythonhosted.org/packages/05/8e/961c0007c59b8dd7729d542c61a4d537767a59645b82a0b521206e1e25c2/pyyaml-6.0.3.tar.gz"
    sha256 "d76623373421df22fb4cf8817020cbb7ef15c725b9d5e45f17e189bfc384190f"
  end

  def install
    venv = virtualenv_create(buildpath/"bootstrap", python3)
    venv.pip_install resources
    ENV.prepend_path "PATH", venv.root/"bin"

    # Avoid over-linkage to `abseil`.
    ENV.append "LDFLAGS", "-Wl,-dead_strip_dylibs" if OS.mac?

    system "./configure", "--disable-silent-rules",
                          "--without-net-snmp",
                          "--enable-dns-over-tls",
                          "--enable-dns-over-https",
                          "--enable-dnscrypt",
                          "--with-re2",
                          "--sysconfdir=#{pkgetc}",
                          *std_configure_args
    system "make", "install"
  end

  test do
    (testpath/"dnsdist.conf").write "setLocal('127.0.0.1')"
    output = shell_output("#{bin}/dnsdist -C dnsdist.conf --check-config 2>&1")
    assert_match "Configuration OK", output
  end
end
