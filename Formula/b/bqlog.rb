class Bqlog < Formula
  desc "Cross-language logging library"
  homepage "https://github.com/Tencent/BqLog"
  url "https://github.com/Tencent/BqLog/archive/refs/tags/Release_2.7.2.tar.gz"
  sha256 "7a8071333f3fccdf933f15f15024e370fae5717e076f3d7796de4000a3e47c81"
  license "Apache-2.0"
  head "https://github.com/Tencent/BqLog.git", branch: "main"

  livecheck do
    url :stable
    regex(/^Release[._-]v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "dfbd17a22cfd7e6a3d8d1c6058c81904cbb7b4acead81f9af186890c7f161160"
    sha256 cellar: :any, arm64_tahoe:       "09437a2b1d1b0e763d0d84aa3e8ff5c33af4518d74c7a8c22016805efaca4f4c"
    sha256 cellar: :any, arm64_sequoia:     "86d0d38704111ee62d91a1838f65600269ff7d8ad1f53347ef507e0e5ec4623d"
    sha256 cellar: :any, arm64_linux:       "b5a9e7ade9023cac7d1ab5614a90944b02ab5efa3e077afad36d4ec866093c0c"
    sha256 cellar: :any, x86_64_linux:      "1e5379438ee3acb5ef3b0d9bb84e3691c89404e1cee0a02fcb328cb9bc98166b"
  end

  depends_on "cmake" => :build

  deny_network_access!

  def install
    args = %w[-DBUILD_LIB_TYPE=both -DBQ_WERROR=OFF]
    # Build for the native architecture instead of upstream's universal default
    args << "-DCMAKE_OSX_ARCHITECTURES=#{Hardware::CPU.arch}" if OS.mac?

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    # Each tool installs another copy of the library's docs directory
    rm_r share.glob("doc/BqLog_*/docs")
  end

  test do
    (testpath/"test.cpp").write <<~'CPP'
      #include <bq_log/bq_log.h>

      int main() {
        bq::log log = bq::log::create_log("test",
          "appenders_config.file.type=compressed_file\n"
          "appenders_config.file.file_name=log/test\n"
          "appenders_config.file.levels=[all]");
        if (!log.is_valid()) return 1;
        log.info("Hello Homebrew!");
        log.force_flush();
        return 0;
      }
    CPP
    system ENV.cxx, "test.cpp", "-std=c++17", "-I#{include}", "-L#{lib}", "-lBqLog", "-Wl,-rpath,#{lib}", "-o", "test"
    system "./test"

    log_file = testpath.glob("log/test_*.logcompr").first
    assert_match "Hello Homebrew!", shell_output("#{bin}/BqLog_LogDecoder #{log_file}")
  end
end
