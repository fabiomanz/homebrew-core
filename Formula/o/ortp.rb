class Ortp < Formula
  desc "Real-time transport protocol (RTP, RFC3550) library"
  homepage "https://linphone.org/"
  url "https://gitlab.linphone.org/BC/public/linphone-sdk/-/archive/5.5.25/linphone-sdk-5.5.25.tar.bz2"
  sha256 "f4f424a00a7bcfe17c8ec36a4096c281733f3c09ab65d42c4a2da854fc3c70ab"
  license all_of: ["AGPL-3.0-or-later", "GPL-3.0-or-later"]
  head "https://gitlab.linphone.org/BC/public/linphone-sdk.git", branch: "master"

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "7bd83d5bc5adc50b21913c338d211b82fcb3aa00a8ef63146b438952909b4954"
    sha256 cellar: :any, arm64_tahoe:       "e29e276c869f72407df5b0f5a6eeee0ae1dd3c5ff8d5c8b72cf590b868df03c5"
    sha256 cellar: :any, arm64_sequoia:     "e3a256d322c267c50f9f82e5051416d5a4677a2decca8f14e17513ba9f3c926a"
    sha256 cellar: :any, arm64_linux:       "87aff39f72c8eb2efd30ce03b4a54aca3ed97fdc4f6d84a51ec93dc9baf86fa9"
    sha256 cellar: :any, x86_64_linux:      "5b5b2be5ec5b383645770959b4dadd65f24ce5184f1fc9fca807fcb9c47c552f"
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
