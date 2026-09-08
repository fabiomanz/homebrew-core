class Dpkg < Formula
  desc "Debian package management system"
  homepage "https://wiki.debian.org/Teams/Dpkg"
  # Please use a mirror as the primary URL as the
  # dpkg site removes tarballs regularly which means we get issues
  # unnecessarily and older versions of the formula are broken.
  url "https://deb.debian.org/debian/pool/main/d/dpkg/dpkg_1.23.8.tar.xz"
  sha256 "cc65ca0928a841001feab4ffe24a2a80b250d28e86490d794e5d1ba8346131a5"
  license "GPL-2.0-or-later"
  compatibility_version 1

  livecheck do
    url "https://deb.debian.org/debian/pool/main/d/dpkg/"
    regex(/href=.*?dpkg[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    sha256 arm64_tahoe:   "a72ea4bfc4a4f4bc9c06d0548ecfd02fc314ecd37caadd2c05c1b5123070b761"
    sha256 arm64_sequoia: "18e59438b48fda653b8fda1e59058560057ed34630bae03e49b83a97ba590bb8"
    sha256 arm64_sonoma:  "b4c70ee0ec6ec4dd3b3efad77864e8fb23e02bc4bf9b73c0779a5b61d092d218"
    sha256 arm64_linux:   "40d2bb29ee216be9c84715e1e522585cc978c27e670ba76f30ba64fcd0bbc15b"
    sha256 x86_64_linux:  "5bed9dd45f5591cb5f8ce6280e23e23c4ffdc2ec60fbb741c41998875da64a07"
  end

  depends_on "pkgconf" => :build
  depends_on "po4a" => :build
  depends_on "gettext"
  depends_on "gnu-tar"
  depends_on "gpatch"
  depends_on "libmd" # for md5.h
  depends_on "perl" # perl >= 5.36.0
  depends_on "xz" # For LZMA

  uses_from_macos "bzip2"

  on_linux do
    keg_only "it conflicts with system dpkg"

    depends_on "zlib-ng-compat"
    depends_on "zstd"
  end

  patch :DATA

  def install
    # We need to specify a recent gnutar, otherwise various dpkg C programs will
    # use the system "tar", which will fail because it lacks certain switches.
    ENV["TAR"] = if OS.mac?
      formula_opt_bin("gnu-tar")/"gtar"
    else
      formula_opt_bin("gnu-tar")/"tar"
    end

    # Since 1.18.24 dpkg mandates the use of GNU patch to prevent occurrences
    # of the CVE-2017-8283 vulnerability.
    # https://www.openwall.com/lists/oss-security/2017/04/20/2
    ENV["PATCH"] = if OS.mac?
      formula_opt_bin("gpatch")/"gpatch"
    else
      formula_opt_bin("gpatch")/"patch"
    end

    # Theoretically, we could reinsert a patch here submitted upstream previously
    # but the check for PERL_LIB remains in place and incompatible with Homebrew.
    # Using an env and scripting is a solution less likely to break over time.
    # Both variables need to be set. One is compile-time, the other run-time.
    ENV["PERL_LIBDIR"] = libexec/"lib/perl5"
    ENV.prepend_create_path "PERL5LIB", libexec/"lib/perl5"

    system "./configure", "--disable-dselect",
                          "--disable-silent-rules",
                          "--disable-start-stop-daemon",
                          "--sysconfdir=#{etc}",
                          "--localstatedir=#{var}",
                          *std_configure_args(prefix: libexec)
    system "make"
    system "make", "install"

    bin.install Dir[libexec/"bin/*"]
    man.install Dir[libexec/"share/man/*"]
    (lib/"pkgconfig").install_symlink Dir[libexec/"lib/pkgconfig/*.pc"]
    bin.env_script_all_files(libexec/"bin", PERL5LIB: ENV["PERL5LIB"])

    (buildpath/"dummy").write "Vendor: dummy\n"
    (pkgetc/"origins").install "dummy"
    (pkgetc/"origins").install_symlink "dummy" => "default"
    (var/"lib/dpkg").mkpath
    (var/"log").mkpath
  end

  def caveats
    <<~EOS
      This installation of dpkg is not configured to install software, so
      commands such as `dpkg -i`, `dpkg --configure` will fail.
    EOS
  end

  test do
    # Do not remove the empty line from the end of the control file
    # All deb control files MUST end with an empty line
    (testpath/"test/data/homebrew.txt").write "brew"
    (testpath/"test/DEBIAN/control").write <<~EOS
      Package: test
      Version: 1.40.99
      Architecture: amd64
      Description: I am a test
      Maintainer: Dpkg Developers <test@test.org>

    EOS
    system bin/"dpkg", "-b", testpath/"test", "test.deb"
    assert_path_exists testpath/"test.deb"

    rm_r("test")
    system bin/"dpkg", "-x", "test.deb", testpath
    assert_path_exists testpath/"data/homebrew.txt"
  end
end

__END__
diff --git a/lib/dpkg/i18n.c b/lib/dpkg/i18n.c
index 4952700..81533ff 100644
--- a/lib/dpkg/i18n.c
+++ b/lib/dpkg/i18n.c
@@ -23,6 +23,11 @@

 #include <dpkg/i18n.h>

+#ifdef __APPLE__
+#include <string.h>
+#include <xlocale.h>
+#endif
+
 #ifdef HAVE_USELOCALE
 static locale_t dpkg_C_locale;
 #endif
