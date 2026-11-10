class RxvtUnicode < Formula
  desc "Rxvt fork with Unicode support"
  homepage "https://software.schmorp.de/pkg/rxvt-unicode.html"
  url "https://dist.schmorp.de/rxvt-unicode/rxvt-unicode-9.32.tar.bz2"
  sha256 "2f81c16bffb16f97c4633032e08a7ef08c000f81eb05853e950febc6c33328dd"
  license "GPL-3.0-only"

  livecheck do
    url "https://dist.schmorp.de/rxvt-unicode/"
    regex(/href=.*?rxvt-unicode[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/fabiomanz/intel-bottles/releases/download/bottles"
    sha256 tahoe: "556a423612585b0503145190d305cb69751ddb797249a4b2884b0b16b90790d8"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build

  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "libx11"
  depends_on "libxext"
  depends_on "libxft"
  depends_on "libxmu"
  depends_on "libxrender"

  uses_from_macos "perl"

  on_macos do
    depends_on "libxt"
  end

  resource "libptytty" do
    url "https://dist.schmorp.de/libptytty/libptytty-2.0.tar.gz"
    sha256 "8033ed3aadf28759660d4f11f2d7b030acf2a6890cb0f7926fb0cfa6739d31f7"
  end

  # Patches 1 and 2 remove -arch flags for compiling perl support
  # Patch 3 fixes `make install` target on case-insensitive filesystems
  patch do
    file "Patches/rxvt-unicode/9.22.patch"
    type :unofficial
  end

  deny_network_access!

  def install
    ENV.cxx11

    resource("libptytty").stage do
      system "cmake", "-S", ".", "-B", "build", "-DBUILD_SHARED_LIBS=OFF", *std_cmake_args(install_prefix: buildpath)
      system "cmake", "--build", "build"
      system "cmake", "--install", "build"
    end

    ENV.prepend_path "PKG_CONFIG_PATH", buildpath/"lib/pkgconfig"
    ENV.append "LDFLAGS", "-L#{buildpath}/lib"

    args = %W[
      --prefix=#{prefix}
      --enable-256-color
      --with-term=rxvt-unicode-256color
      --with-terminfo=/usr/share/terminfo
      --enable-smart-resize
      --enable-unicode3
    ]

    system "./configure", *args
    system "make", "install"
  end

  test do
    ENV["RXVT_SOCKET"] = testpath/"urxvtd-test"
    daemon = spawn bin/"urxvtd"
    sleep 5
    system bin/"urxvtc", "-k"
    Process.wait daemon
  end
end
