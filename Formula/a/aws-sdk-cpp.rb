class AwsSdkCpp < Formula
  desc "AWS SDK for C++"
  homepage "https://github.com/aws/aws-sdk-cpp"
  url "https://github.com/aws/aws-sdk-cpp/archive/refs/tags/1.11.885.tar.gz"
  sha256 "b9fb6d2accb9b27bbe62b168556a8666f3e49deedbfa2d924601b77ecc70b563"
  license "Apache-2.0"
  revision 2
  compatibility_version 3
  head "https://github.com/aws/aws-sdk-cpp.git", branch: "main"

  livecheck do
    throttle 15
  end

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "c8eeff0314665803cda8cfb84d03225e00924d356af2e9a98e436528a4239f0b"
    sha256 cellar: :any, arm64_tahoe:       "3a5be27642db5f59b4e1f501e0bd338bdf4d1accb0af692d9cd530a8219a1638"
    sha256 cellar: :any, arm64_sequoia:     "62ce47da5dce0034b2b26d819c4039e0c66b401e1cc8c2d6d62dd4addf20da58"
    sha256 cellar: :any, arm64_linux:       "5a1e705aa06260df212b53189ce9c3b9481c9bcaadf0cb31107fdf99606bb0be"
    sha256 cellar: :any, x86_64_linux:      "f3d9672d73ac10a796346c12a7b2cc5b05a8f709eb6bc1b1a4ae1a8f595aa7f0"
  end

  depends_on "cmake" => :build
  depends_on "aws-c-auth"
  depends_on "aws-c-common"
  depends_on "aws-c-event-stream"
  depends_on "aws-c-http"
  depends_on "aws-c-io"
  depends_on "aws-c-s3"
  depends_on "aws-crt-cpp"

  uses_from_macos "curl"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  def install
    # Avoid OOM failure on Github runner
    ENV.deparallelize if OS.linux? && ENV["HOMEBREW_GITHUB_ACTIONS"].present?

    linker_flags = ["-Wl,-rpath,#{rpath}"]
    # Avoid overlinking to aws-c-* indirect dependencies
    linker_flags << "-Wl,-dead_strip_dylibs" if OS.mac?

    args = %W[
      -DBUILD_DEPS=OFF
      -DCMAKE_MODULE_PATH=#{formula_opt_lib("aws-c-common")}/cmake/aws-c-common/modules
      -DCMAKE_SHARED_LINKER_FLAGS=#{linker_flags.join(" ")}
      -DENABLE_TESTING=OFF
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <aws/core/Version.h>
      #include <iostream>

      int main() {
          std::cout << Aws::Version::GetVersionString() << std::endl;
          return 0;
      }
    CPP
    system ENV.cxx, "-std=c++11", "test.cpp", "-L#{lib}", "-laws-cpp-sdk-core", "-o", "test"
    system "./test"
  end
end
