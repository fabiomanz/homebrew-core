class Sdb < Formula
  desc "Ondisk/memory hashtable based on CDB"
  homepage "https://www.radare.org/"
  url "https://github.com/radareorg/sdb/archive/refs/tags/2.5.4.tar.gz"
  sha256 "144bab31e04af36ed93174ea5b67e8714eb36eb2c53913f6c045f577f8bc710f"
  license "MIT"
  head "https://github.com/radareorg/sdb.git", branch: "master"

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "69866d890e9619bf99867e5104519d5c05c5b6db4523376ff3679f8ca743e4f1"
    sha256 cellar: :any, arm64_tahoe:       "a9e51e4b3693c15325b760bec73b72d6fce3f3b8a69d7b20947cba090f2c7309"
    sha256 cellar: :any, arm64_sequoia:     "c3744d08af6afab55b6cbbcb9686048e13bfb53380790d43bd5d045847ce136c"
    sha256 cellar: :any, arm64_linux:       "1321f1970080e0b3d4a754c22a70862e5b81294a63c0a2f6e9426947c422b839"
    sha256 cellar: :any, x86_64_linux:      "7580c6486f62a9331b8e6b45a475fa9cf8ee4188b4ec95ae85abd693dc781ea1"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "vala" => :build
  depends_on "glib"

  conflicts_with "snobol4", because: "both install `sdb` binaries"

  deny_network_access!

  def install
    system "meson", "setup", "build", *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    system bin/"sdb", testpath/"d", "hello=world"
    assert_equal "world", shell_output("#{bin}/sdb #{testpath}/d hello").strip
  end
end
