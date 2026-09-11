class Gts < Formula
  desc "GNU triangulated surface library"
  homepage "https://gts.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/gts/gts/0.7.6/gts-0.7.6.tar.gz"
  sha256 "059c3e13e3e3b796d775ec9f96abdce8f2b3b5144df8514eda0cc12e13e8b81e"
  license "LGPL-2.0-or-later"
  revision 3

  bottle do
    root_url "https://github.com/fabiomanz/intel-bottles/releases/download/bottles"
    sha256 cellar: :any, tahoe: "e1d9b0cd354ee98ad47da26f14ecef2851e27c2cc1e5ab87b21f76e4e31ac546"
  end

  # We regenerate configure to avoid the `-flat_namespace` flag.
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkgconf" => [:build, :test]
  depends_on "glib"
  depends_on "netpbm"

  on_macos do
    depends_on "gettext"
  end

  conflicts_with "pcb", because: "both install a `gts.h` header"

  # Fix for newer netpbm.
  # This software hasn't been updated in seven years
  patch :DATA

  def install
    # GTS uses K&R function definitions, which C23 no longer supports.
    ENV.append "CFLAGS", "-std=gnu17"

    # The `configure` passes `-flat_namespace` but none of our usual patches apply.
    system "autoreconf", "--force", "--install", "--verbose"
    system "./configure", *std_configure_args
    system "make", "install"
  end

  test do
    (testpath/"gtstest.c").write <<~C
      #include "gts.h"
      int main() {
        GtsRange r;
        gts_range_init(&r);

        for (int i = 0; i < 10; ++i)
          gts_range_add_value(&r, i);

        gts_range_update(&r);

        if (r.n == 10) return 0;
        return 1;
      }
    C

    flags = shell_output("pkgconf --cflags --libs gts").strip.split
    system ENV.cc, "gtstest.c", *flags, "-lm", "-o", "gtstest"
    system "./gtstest"
  end
end

__END__
diff --git a/examples/happrox.c b/examples/happrox.c
index 88770a8..11f140d 100644
--- a/examples/happrox.c
+++ b/examples/happrox.c
@@ -21,7 +21,7 @@
 #include <stdlib.h>
 #include <locale.h>
 #include <string.h>
-#include <pgm.h>
+#include <netpbm/pgm.h>
 #include "config.h"
 #ifdef HAVE_GETOPT_H
 #  include <getopt.h>
