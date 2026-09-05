class Qthttpserver < Formula
  desc "Framework for embedding an HTTP server into a Qt application"
  homepage "https://www.qt.io/"
  url "https://download.qt.io/official_releases/qt/6.11/6.11.2/submodules/qthttpserver-everywhere-src-6.11.2.tar.xz"
  mirror "https://qt.mirror.constant.com/archive/qt/6.11/6.11.2/submodules/qthttpserver-everywhere-src-6.11.2.tar.xz"
  mirror "https://mirrors.ukfast.co.uk/sites/qt.io/archive/qt/6.11/6.11.2/submodules/qthttpserver-everywhere-src-6.11.2.tar.xz"
  sha256 "f0f5763b2ba58f20f5cffdfbedb97e62e32b5c639df6d9a6378905028be7bd8e"
  license all_of: [
    "GPL-3.0-only",
    "BSD-3-Clause", # *.cmake
  ]
  compatibility_version 1
  head "https://code.qt.io/qt/qthttpserver.git", branch: "dev"

  livecheck do
    formula "qtbase"
  end

  bottle do
    root_url "https://github.com/fabiomanz/intel-bottles/releases/download/bottles"
    sha256 cellar: :any, tahoe: "d13fd36eab4494b7f2e43552aed33f8118f22ef6f7fb92f68fef5bc535559534"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "ninja" => :build
  depends_on "pkgconf" => :test

  depends_on "qtbase"
  depends_on "qtwebsockets"

  def install
    args = ["-DCMAKE_STAGING_PREFIX=#{prefix}"]
    args << "-DQT_NO_APPLE_SDK_AND_XCODE_CHECK=ON" if OS.mac?

    system "cmake", "-S", ".", "-B", "build", "-G", "Ninja",
                    *args, *std_cmake_args(install_prefix: HOMEBREW_PREFIX, find_framework: "FIRST")
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    # Some config scripts will only find Qt in a "Frameworks" folder
    frameworks.install_symlink lib.glob("*.framework") if OS.mac?
  end

  test do
    (testpath/"CMakeLists.txt").write <<~CMAKE
      cmake_minimum_required(VERSION 4.0)
      project(test VERSION 1.0.0 LANGUAGES CXX)
      find_package(Qt6 REQUIRED COMPONENTS HttpServer)
      add_executable(test main.cpp)
      target_link_libraries(test PRIVATE Qt6::HttpServer)
    CMAKE

    (testpath/"test.pro").write <<~QMAKE
      QT      += httpserver
      TARGET   = test
      CONFIG  += console
      CONFIG  -= app_bundle
      TEMPLATE = app
      SOURCES += main.cpp
    QMAKE

    (testpath/"main.cpp").write <<~CPP
      #undef QT_NO_DEBUG
      #include <QtHttpServer>

      int main(void) {
        QHttpServer httpServer;
        httpServer.route("/", []() { return "Hello world"; });
        return 0;
      }
    CPP

    ENV["LC_ALL"] = "en_US.UTF-8"
    ENV["QT_QPA_PLATFORM"] = "minimal" if OS.linux? && ENV["HOMEBREW_GITHUB_ACTIONS"]

    system "cmake", "-S", ".", "-B", "cmake"
    system "cmake", "--build", "cmake"
    system "./cmake/test"

    ENV.delete "CPATH" if OS.mac?
    mkdir "qmake" do
      system Formula["qtbase"].bin/"qmake", testpath/"test.pro"
      system "make"
      system "./test"
    end

    flags = shell_output("pkgconf --cflags --libs Qt6HttpServer").chomp.split
    system ENV.cxx, "-std=c++17", "main.cpp", "-o", "test", *flags
    system "./test"
  end
end
