class TreallaProlog < Formula
  desc "Compact and efficient ISO Prolog interpreter written in plain old C"
  homepage "https://github.com/trealla-prolog/trealla-prolog"
  url "https://github.com/trealla-prolog/trealla-prolog/archive/refs/tags/v3.9.69.tar.gz"
  sha256 "5e5e4ca3c706903f3d1c825e978cbc10efdb630b4bc7c224326d673142ebec33"
  license "MIT"
  head "https://github.com/trealla-prolog/trealla-prolog.git", branch: "main"

  bottle do
    sha256 arm64_golden_gate: "9288263ea810ca8cd6b04ea630de8e985d96a8b70483c4c280e9c1cfa1729c7a"
    sha256 arm64_tahoe:       "d77a9e7e22faaca57e3b0e8cc4f97125e7a2ed4138fc985971c2bc1322ff0897"
    sha256 arm64_sequoia:     "e001f09178a662ac8cc1d2dcb0aadfbd12a5e84bbeb1d3f564db587c5d3d083b"
    sha256 arm64_linux:       "765d0167ca092b315b8d46608bc36ab44067b424f6f929a9d08832ed40afd26f"
    sha256 x86_64_linux:      "cf1c04badb459acfb087fd3a8488297941548cda6ff1ff810f8ddaa9d4813c97"
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
