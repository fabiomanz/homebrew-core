class TreallaProlog < Formula
  desc "Compact and efficient ISO Prolog interpreter written in plain old C"
  homepage "https://github.com/trealla-prolog/trealla-prolog"
  url "https://github.com/trealla-prolog/trealla-prolog/archive/refs/tags/v3.9.48.tar.gz"
  sha256 "a55e39184c84738ca965758ea18ee1c1e34a28a03d4e1cc6a7857fd3d1c4cc75"
  license "MIT"
  head "https://github.com/trealla-prolog/trealla-prolog.git", branch: "main"

  bottle do
    sha256 arm64_tahoe:   "259dc10f754e59068934e9d271da46997330ac7ef7e3e28594be296dd5ef6b6a"
    sha256 arm64_sequoia: "aeba1bf71dffc37074e8a16c1412d2787ae8de61adb4fa8503952b709d4f7e2d"
    sha256 arm64_sonoma:  "508ac8427973f835780a3cb512bac3d71b1829049798b8b4f0fa352a6a7424bd"
    sha256 arm64_linux:   "2564c13f03632169a3febde608110bdcf92d365f3c1510a7010a434d26eab141"
    sha256 x86_64_linux:  "9ec095826ce45212c278a236956fa6fe12218ae42da5b613869606a9a5646545"
  end

  depends_on "openssl@4"

  uses_from_macos "libedit"
  uses_from_macos "libffi"

  def install
    args = ["PREFIX=#{prefix}", "OPENSSL=openssl@4"]
    # macOS keeps ffi.h in an ffi/ subdirectory, which the build's plain
    # `#include <ffi.h>` misses. TARGET_CFLAGS is the makefile's append hook.
    args << "TARGET_CFLAGS=-I#{MacOS.sdk_path}/usr/include/ffi" if OS.mac?
    system "make", "install", *args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/tpl --version")

    assert_equal "42", shell_output("#{bin}/tpl -g 'X is 6*7, write(X), halt'").chomp

    # library(assoc) is not embedded in the binary, so this also proves the
    # installed library path was baked in correctly.
    goal = "use_module(library(assoc)), list_to_assoc([a-1, b-2], A), " \
           "get_assoc(b, A, V), write(V), halt"
    assert_equal "2", shell_output("#{bin}/tpl -g '#{goal}'").chomp
  end
end
