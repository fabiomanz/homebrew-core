class S6Rc < Formula
  desc "Process supervision suite"
  homepage "https://skarnet.org/software/s6-rc/"
  url "https://skarnet.org/software/s6-rc/s6-rc-0.8.0.1.tar.gz"
  sha256 "e647a2b828d6aceb68024889a29f6406aaefc85b1853332e0f3982eb5670b331"
  license "ISC"
  head "git://git.skarnet.org/s6-rc.git", branch: "main"

  bottle do
    sha256 arm64_golden_gate: "c7ff903f202f1b5e665af1ed4ffcb9c3add86d7080450cc866c595081112cbb5"
    sha256 arm64_tahoe:       "4690842be185c0acbe3631dc9c6297801c8000fbcc71996465ded00f24c9a181"
    sha256 arm64_sequoia:     "fadd3c4376a2b4b36dbbcc39d59fd988dbc77be29e909473dcd7f88c59068a9b"
    sha256 arm64_linux:       "7636361f6ffe9d6678a2fed45195d5b9365433cba494766fc3fb0d5825a9b642"
    sha256 x86_64_linux:      "bde59fd1de7393f2eb5f36c744aa355b62e3d617cc5c0798dd1d8febcb58ff4b"
  end

  depends_on "pkgconf" => :build
  depends_on "execline"
  depends_on "s6"
  depends_on "skalibs"

  def install
    # Shared libraries are linux targets and not supported on macOS.
    args = %W[
      --disable-silent-rules
      --disable-shared
      --enable-pkgconfig
      --with-pkgconfig=#{formula_opt_bin("pkgconf")}/pkg-config
      --with-sysdeps=#{formula_opt_lib("skalibs")}/skalibs/sysdeps
    ]
    system "./configure", *args, *std_configure_args
    system "make", "install"
  end

  test do
    (testpath/"services/test").mkpath
    (testpath/"services/test/up").write <<~SHELL
      #!/bin/sh
      echo "test"
    SHELL
    (testpath/"services/test/type").write "oneshot"
    (testpath/"services/bundle/contents.d").mkpath
    (testpath/"services/bundle/type").write "bundle"
    touch testpath/"services/bundle/contents.d/test"
    system bin/"s6-rc-compile", testpath/"compiled", testpath/"services"
  end
end
