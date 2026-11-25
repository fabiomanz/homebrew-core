class Libyaml < Formula
  desc "YAML Parser"
  homepage "https://github.com/yaml/libyaml"
  url "https://github.com/yaml/libyaml/archive/refs/tags/0.2.7.tar.gz"
  sha256 "7f76964485c67dc4e1537fdfd4ad5c8772bcef501c5451b617e43f831034994e"
  license "MIT"
  compatibility_version 1

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/fabiomanz/intel-bottles/releases/download/bottles"
    sha256 cellar: :any, tahoe: "363ccaa07524550b0bdf803122bb4774de2e833d403ad280905fc571936828b7"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  deny_network_access!

  def install
    system "./bootstrap"
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <yaml.h>

      int main()
      {
        yaml_parser_t parser;
        yaml_parser_initialize(&parser);
        yaml_parser_delete(&parser);
        return 0;
      }
    C
    system ENV.cc, "test.c", "-L#{lib}", "-lyaml", "-o", "test"
    system "./test"
  end
end
