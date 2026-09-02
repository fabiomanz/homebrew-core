class LibniceGstreamer < Formula
  desc "GStreamer Plugin for libnice"
  homepage "https://wiki.freedesktop.org/nice/"
  url "https://libnice.freedesktop.org/releases/libnice-0.1.24.tar.gz"
  sha256 "cfb5e8e778534f2f5b3c6f4958a1eb057c6b95c537c0f100817a537cf5d64fcc"
  license any_of: ["LGPL-2.1-or-later", "MPL-1.1"]

  livecheck do
    formula "libnice"
  end

  bottle do
    sha256 cellar: :any, arm64_tahoe:   "8c35c126361bae664d0cedd53e2df6115a1303cf2566b9a28a3486b2159731f5"
    sha256 cellar: :any, arm64_sequoia: "0e77dffa693e48f2ba455657fa744c595799b86655b695524c41bd3b983a6c5d"
    sha256 cellar: :any, arm64_sonoma:  "f6ab16d942ef72dccb8278e2b8da25381edd0a6e394020b87d50e1f6a6d7a0b9"
    sha256 cellar: :any, sonoma:        "f78f64870d3d5ec10b8cf25af5ac7ae92c3106b577f1bf13d9cab0dccbe9fbb7"
    sha256               arm64_linux:   "ed30b7a595d0bf0f5798158f4f142af5c71ae72d0e3fe9a4c815beca104df736"
    sha256               x86_64_linux:  "2570d646e3fff87a4227109021740629384f63d27278ae1ec5060278c6169148"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => [:build, :test]
  depends_on "glib"
  depends_on "gnutls"
  depends_on "gstreamer"
  depends_on "libnice"

  on_macos do
    depends_on "gettext"
  end

  def install
    system "meson", "setup", "build", "-Dgstreamer=enabled", "-Dgstreamer-plugin-only=true", *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"

    # Move the gstreamer plugin out of the way to prevent `brew link` conflicts.
    libexec.install lib/"gstreamer-1.0"
  end

  test do
    system "gst-inspect-1.0", "--exists", "nicesrc"
  end
end
