class Pcapmirror < Formula
  desc "Tool for capturing network traffic on remote host using TZSP or ERSPAN"
  homepage "https://git.freestone.net/cramer/pcapmirror"
  url "https://git.freestone.net/cramer/pcapmirror/-/archive/0.7/pcapmirror-0.7.tar.gz"
  sha256 "e551d567b82465fa4fcf058da117186beb1b7f1073d245ea37e8e443c0ae27c4"
  license "BSD-3-Clause"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "81586bf4b3d4fee4f3b0f7deb980ab54a092c00c90cf55e9d51f1b5746b890e6"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "afe4a6c7a2e13292756895db9e64d29ec2d82333d613a74883ff08df17d11f73"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "4e595e7e0c177cbd4be97feb4d9e9d5784c49c80e642fe7d61f36fa04e51730d"
    sha256 cellar: :any,                 arm64_linux:       "cb176580337441f9e76294af0f7e39742f02cdd63e2c63e022e5fb9dcb9a1f80"
    sha256 cellar: :any,                 x86_64_linux:      "622fcd8444eeead4f3c011d65332aafb4b7c7745e57918fcca84e5f23e6e10ff"
  end

  depends_on "make" => :build
  uses_from_macos "libpcap"

  on_linux do
    depends_on "libpcap"
  end

  def install
    bin.mkpath
    man8.mkpath
    system "make", "install", "BINDIR=#{bin}", "MANDIR=#{man}"
  end

  test do
    assert_match "Available network interfaces:", shell_output("#{bin}/pcapmirror -l")
  end
end
