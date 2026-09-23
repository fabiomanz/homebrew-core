class Srtp < Formula
  desc "Implementation of the Secure Real-time Transport Protocol"
  homepage "https://github.com/cisco/libsrtp"
  url "https://github.com/cisco/libsrtp/archive/refs/tags/v2.8.1.tar.gz"
  sha256 "ef5569220749529d778013aae1178391d972570a2b4f7288dda22effa875b07c"
  license "BSD-3-Clause"
  compatibility_version 1
  head "https://github.com/cisco/libsrtp.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/fabiomanz/intel-bottles/releases/download/bottles"
    sha256 cellar: :any, tahoe: "6f2560ea1ad359dd357a66457ea98bc6fb09c8ffe21423bb84db5895552795c4"
  end

  depends_on "pkgconf" => :build
  depends_on "openssl@3"

  deny_network_access!

  def install
    system "./configure", "--enable-openssl", *std_configure_args
    system "make", "test"
    system "make", "shared_library"
    system "make", "install" # Can't go in parallel of building the dylib
    libexec.install "test/rtpw"
  end

  test do
    system libexec/"rtpw", "-l"
  end
end
