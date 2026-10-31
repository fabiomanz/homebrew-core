class TreallaProlog < Formula
  desc "Compact and efficient ISO Prolog interpreter written in plain old C"
  homepage "https://github.com/trealla-prolog/trealla-prolog"
  url "https://github.com/trealla-prolog/trealla-prolog/archive/refs/tags/v3.14.25.tar.gz"
  sha256 "54e0a735d0d269ed679c7f8411804efe0683bc17fc4a3854c7d8ab111f984746"
  license "MIT"
  head "https://github.com/trealla-prolog/trealla-prolog.git", branch: "main"

  livecheck do
    throttle 5
  end

  bottle do
    sha256 arm64_golden_gate: "5be646b592cfe2730595e2bc82816d5d2117e3a99ac4dda6cf380096acdbd12c"
    sha256 arm64_tahoe:       "7b39268c57cb358458d9b05a7d61ed72ed35dd3b3c07faa79a4e5cb0f002d1e6"
    sha256 arm64_sequoia:     "1ab560c289ef4044fa61d8d5c74cbe13fc3553bee960c2b272cb4e96bf2762f9"
    sha256 arm64_linux:       "7109d1422b4f334706397cd0d1b35499aaefd4bc52c437e553a7a8f128492a27"
    sha256 x86_64_linux:      "49f39ef5354f2db3a8a2dd977fd5a252a4d41c7fea4a35b9afc662073eb19f36"
  end

  depends_on "openssl@4"

  uses_from_macos "libedit"
  uses_from_macos "libffi"

  deny_network_access!

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
