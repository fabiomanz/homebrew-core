class Scc < Formula
  desc "Fast and accurate code counter with complexity and COCOMO estimates"
  homepage "https://github.com/boyter/scc/"
  url "https://github.com/boyter/scc/archive/refs/tags/v4.1.0.tar.gz"
  sha256 "4f3cf36010c542b10d5582afb91c668b26889160b184deee21b4319347030a7c"
  license any_of: ["MIT", "Unlicense"]
  head "https://github.com/boyter/scc.git", branch: "master"

  livecheck do
    url :homepage
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/fabiomanz/intel-bottles/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, tahoe: "fa9157afbc78f6674b83e7c434629ae0300b26fccb147513f339201b66c40889"
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args
    generate_completions_from_executable(bin/"scc", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/scc --version")

    (testpath/"test.c").write <<~C
      #include <stdio.h>
      int main(void) {
        return 0;
      }
    C

    expected_output = <<~CSV
      Language,Lines,Code,Comments,Blanks,Complexity,Bytes,Files,ULOC
      C,4,4,0,0,0,50,1,0
    CSV

    assert_match expected_output, shell_output("#{bin}/scc -fcsv test.c")
  end
end
