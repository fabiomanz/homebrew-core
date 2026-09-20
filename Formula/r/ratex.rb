class Ratex < Formula
  desc "Fast TeX engine written in Rust"
  homepage "https://github.com/leoliu0/ratex"
  url "https://github.com/leoliu0/ratex/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "bfbcf3fdc34fc9269f6f2f4a523f36e954fe96a1ce3d2f1388e0adb1607b3a6c"
  license any_of: ["MIT", "Apache-2.0"]
  head "https://github.com/leoliu0/ratex.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "51bf0d3e96d537ae8e7c93071a5d3401574b16b22880d19edba0f803335a2393"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "75e6784ec9954b964e68cdb91190fa4449c58e0589627d7676ea528cf52332bb"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "034d39e2d450e6860d27b462a813f6e217b474442b840d2bf7ec1f6c306b85f4"
    sha256 cellar: :any,                 arm64_linux:       "a1fd83a0033a2d2de23509b6abcecd5f90e7958eef16c62711f93c15c4c9dbd3"
    sha256 cellar: :any,                 x86_64_linux:      "98f5f09e029de11adc2482f6e4961e936bffe7f27fb72b2f370803c59b4d38bc"
  end

  depends_on "rust" => :build

  deny_network_access!

  # TODO: add `conflicts_with "texlive"`

  def fetch
    system "cargo", "fetch", "--locked", "--target", "host-tuple"
  end

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/tex-cli")
  end

  test do
    (testpath/"sample.tex").write <<~'LATEX'
      \documentclass{article}

      \title{Test}
      \author{Homebrew}
      \date{\today}

      \begin{document}
        \maketitle

        \section{Example!}

        This is simple \LaTeX file.

      \end{document}
    LATEX

    system bin/"ratex", testpath/"sample.tex"

    assert_path_exists testpath/"sample.pdf"
  end
end
