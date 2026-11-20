class Iperf3 < Formula
  desc "Update of iperf: measures TCP, UDP, and SCTP bandwidth"
  homepage "https://github.com/esnet/iperf"
  url "https://downloads.es.net/pub/iperf/iperf-3.22.1.tar.gz"
  sha256 "de018b5252e2a7068c89fac8b35a295d83334f2b7814aa9532a2a8107b04a4a9"
  license "BSD-3-Clause"

  livecheck do
    url "https://downloads.es.net/pub/iperf/"
    regex(/href=.*?iperf[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/fabiomanz/intel-bottles/releases/download/bottles"
    sha256 cellar: :any, tahoe: "667ffcfae5980ec1c6dcb81467c8d3ebb5ee8f11e776707bcfb77ab1654359e3"
  end

  head do
    url "https://github.com/esnet/iperf.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "openssl@4"

  allow_network_access! :test

  def install
    system "./bootstrap.sh" if build.head?
    system "./configure", "--disable-silent-rules",
                          "--disable-profiling",
                          "--with-openssl=#{formula_opt_prefix("openssl@4")}",
                          *std_configure_args
    system "make", "clean" # there are pre-compiled files in the tarball
    system "make", "install"
  end

  test do
    port = free_port
    pid = spawn bin/"iperf3", "--server", "--port", port.to_s
    sleep 1
    assert_match "Bitrate", shell_output("#{bin}/iperf3 --client 127.0.0.1 --port #{port} --time 1")
  ensure
    Process.kill("SIGINT", pid)
    Process.wait(pid)
  end
end
