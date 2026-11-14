class S2n < Formula
  desc "Implementation of the TLS/SSL protocols"
  homepage "https://aws.github.io/s2n-tls/usage-guide/"
  url "https://github.com/aws/s2n-tls/archive/refs/tags/v1.7.14.tar.gz"
  sha256 "8a8b87b890de23c980aa31925241b52ee3fa49167f7c72bd6762e5d43d5fa892"
  license "Apache-2.0"
  compatibility_version 1
  head "https://github.com/aws/s2n-tls.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/fabiomanz/intel-bottles/releases/download/bottles"
    sha256 cellar: :any, tahoe: "310d162d65d5797c2eb98e74bfd45e84622dea07b4598f4b84c506b887baf067"
  end

  depends_on "cmake" => :build
  depends_on "openssl@4"

  def install
    system "cmake", "-S", ".", "-B", "build_static", "-DBUILD_SHARED_LIBS=OFF", *std_cmake_args
    system "cmake", "--build", "build_static"
    system "cmake", "--install", "build_static"

    system "cmake", "-S", ".", "-B", "build_shared", "-DBUILD_SHARED_LIBS=ON", *std_cmake_args
    system "cmake", "--build", "build_shared"
    system "cmake", "--install", "build_shared"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <assert.h>
      #include <s2n.h>
      int main() {
        assert(s2n_init() == 0);
        return 0;
      }
    C
    system ENV.cc, "test.c", "-L#{opt_lib}", "-ls2n", "-o", "test"
    ENV["S2N_DONT_MLOCK"] = "1" if OS.linux?
    system "./test"
  end
end
