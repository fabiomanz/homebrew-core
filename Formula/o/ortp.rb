class Ortp < Formula
  desc "Real-time transport protocol (RTP, RFC3550) library"
  homepage "https://linphone.org/"
  url "https://gitlab.linphone.org/BC/public/linphone-sdk/-/archive/5.5.35/linphone-sdk-5.5.35.tar.bz2"
  sha256 "365302bc3600ddd4406e52b1b587ec3fe712f910e3b6e25a2dfa1bd5ce4498c5"
  license all_of: ["AGPL-3.0-or-later", "GPL-3.0-or-later"]
  head "https://gitlab.linphone.org/BC/public/linphone-sdk.git", branch: "master"

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "917c334395bc5d5eeec418b0a19d9d3cbf5f6a1b6637c8c6ac8b3aaff0c84a44"
    sha256 cellar: :any, arm64_tahoe:       "b8742ed3a2c12455793f6fd11ba1306db5b228ac92456e28a0a5aec9e526c5be"
    sha256 cellar: :any, arm64_sequoia:     "4311f4fcc651fd673e14e68f9b2e4af5aa2d769612e512b722a51e6a23aa5bce"
    sha256 cellar: :any, arm64_linux:       "c82e9de23aa71dec576f05f4f3f666729658545373f366de6a623090b7e40afd"
    sha256 cellar: :any, x86_64_linux:      "147a7b2f8e08fad6a8b4fa650f7a4f6942c59f3a86e17071faf34f169d55f829"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "openssl@4"

  def install
    args = %w[
      -DBUILD_SHARED_LIBS=ON
      -DENABLE_MBEDTLS=OFF
      -DENABLE_OPENSSL=ON
      -DENABLE_TESTS_COMPONENT=OFF
    ]

    system "cmake", "-S", "bctoolbox", "-B", "build_bctoolbox", *args, *std_cmake_args
    system "cmake", "--build", "build_bctoolbox"
    system "cmake", "--install", "build_bctoolbox"
    prefix.install "bctoolbox/LICENSE.txt" => "LICENSE-bctoolbox.txt"

    args = %w[
      -DBUILD_SHARED_LIBS=ON
      -DENABLE_DOC=OFF
      -DENABLE_UNIT_TESTS=OFF
    ]
    args << "-DCMAKE_INSTALL_RPATH=#{frameworks}" if OS.mac?

    system "cmake", "-S", "ortp", "-B", "build_ortp", *args, *std_cmake_args
    system "cmake", "--build", "build_ortp"
    system "cmake", "--install", "build_ortp"
  end

  test do
    (testpath/"test.c").write <<~C
      #include "ortp/logging.h"
      #include "ortp/rtpsession.h"
      #include "ortp/sessionset.h"
      int main()
      {
        ORTP_PUBLIC void ortp_init(void);
        return 0;
      }
    C
    linker_flags = OS.mac? ? %W[-F#{frameworks} -framework ortp] : %W[-L#{lib} -lortp]
    system ENV.cc, "test.c", "-o", "test", "-I#{include}", *linker_flags
    system "./test"
  end
end
