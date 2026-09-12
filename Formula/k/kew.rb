class Kew < Formula
  desc "Command-line music player"
  homepage "https://github.com/ravachol/kew"
  url "https://github.com/ravachol/kew/archive/refs/tags/v4.3.3.tar.gz"
  sha256 "9fe0d4feecaa62cff41241f093bb803881ad35eb09f88d1db35cc030486dcf9c"
  license "GPL-2.0-or-later"
  head "https://github.com/ravachol/kew.git", branch: "main"

  bottle do
    sha256 arm64_golden_gate: "81f777c324b216b12798c94c669cb0f6702a967d0c44636ba28addad35b3b2d3"
    sha256 arm64_tahoe:       "e55cd20cbe4beeb70c89afaef1858a72f17a6afcfa20b0d0f8fd950402c3ae42"
    sha256 arm64_sequoia:     "9af0016fbbd80a86e0883bb4d51383ea06bf597380bd3450fac9e76d3e45fed4"
    sha256 arm64_linux:       "a3cfc1b9705125df70a039cc4557d65daaaa654cd1c3443ac1b27556f159f019"
    sha256 x86_64_linux:      "60a34047205774d865bbdaa7360fea177f2b69ba165708f48f455106012a0bae"
  end

  depends_on "pkgconf" => :build
  depends_on "chafa"
  depends_on "faad2"
  depends_on "fftw"
  depends_on "glib"
  depends_on "libogg"
  depends_on "libvorbis"
  depends_on "opus"
  depends_on "opusfile"
  depends_on "taglib"

  uses_from_macos "curl"

  on_macos do
    depends_on "gdk-pixbuf"
    depends_on "gettext"
  end

  on_linux do
    depends_on "libnotify"
  end

  def install
    system "make", "install", "PREFIX=#{prefix}", "LANGDIRPREFIX=#{prefix}"
    man1.install "docs/kew.1"
  end

  test do
    ENV["XDG_CONFIG_HOME"] = testpath/".config"
    ENV["XDG_STATE_HOME"] = testpath/".local/state"

    (testpath/".config/kew").mkpath
    (testpath/".local/state").mkpath
    (testpath/".config/kew/kewrc").write ""

    system bin/"kew", "path", testpath

    output = shell_output("#{bin}/kew song")
    assert_match "No Music found.\nPlease make sure the path is set correctly", output

    assert_match version.to_s, shell_output("#{bin}/kew --version")
  end
end
