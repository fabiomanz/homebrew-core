class GumboParser < Formula
  desc "C99 library for parsing HTML5"
  homepage "https://codeberg.org/gumbo-parser/gumbo-parser"
  url "https://codeberg.org/gumbo-parser/gumbo-parser/archive/0.14.0.tar.gz"
  sha256 "eac82480b916d520e4c7938cbd593ceda34c9241cba04022a078550d0d324cfe"
  license "Apache-2.0"
  compatibility_version 2

  bottle do
    root_url "https://github.com/fabiomanz/intel-bottles/releases/download/bottles"
    sha256 cellar: :any, tahoe: "3ca92cd4d57edba2ff9e87fca3f2f9c39d6cdc2856bf3773420c5ab3b55e6267"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  def install
    system "./autogen.sh"
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include "gumbo.h"

      int main() {
        GumboOutput* output = gumbo_parse("<h1>Hello, World!</h1>");
        gumbo_destroy_output(&kGumboDefaultOptions, output);
        return 0;
      }
    CPP
    system ENV.cxx, "test.cpp", "-L#{lib}", "-lgumbo", "-o", "test"
    system "./test"
  end
end
