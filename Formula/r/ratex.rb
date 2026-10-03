class Ratex < Formula
  desc "Fast TeX engine written in Rust"
  homepage "https://github.com/leoliu0/ratex"
  url "https://github.com/leoliu0/ratex/archive/refs/tags/v0.4.5.tar.gz"
  sha256 "1edd8dd7b9a40a4a1473b1fa631ad50e88ebceec53d2022ec1ec61dd03f13191"
  license any_of: ["MIT", "Apache-2.0"]
  head "https://github.com/leoliu0/ratex.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "ca4acd6aac6e587dc99c664ee4912d90895e489b0e35d54d0c548dd1d8f66aea"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "76ae82434e373456b9d7df68e19f23ef02f746aa70626fa393240daa733d8005"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "87d5a65e49d389d758d8a7ee530b5e0205d50c625f7b5a85dd4786994d4b0220"
    sha256 cellar: :any,                 arm64_linux:       "2c0b6c9b5b86d5137eb56a3fa310076a3443643bbcc4874e140ce6ecf3d8cd7d"
    sha256 cellar: :any,                 x86_64_linux:      "2285b28e458593af454df54d3224fb8051f03d6763dff3a8fadb998ac2d7ce0c"
  end

  depends_on "rust" => :build

  conflicts_with "texlive", because: "both install `lualatex`, `pdflatex`, `xelatex` binaries"

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    # TODO: Remove these settings once a release includes upstream's embedded-archive memory fix.
    # https://github.com/leoliu0/ratex/issues/16
    ENV.deparallelize
    ENV["CARGO_PROFILE_RELEASE_LTO"] = "false"
    ENV["CARGO_PROFILE_RELEASE_CODEGEN_UNITS"] = "1"

    # Every bin embeds the package archive, so linking them all OOMs; `ratex` dispatches aliases by name.
    system "cargo", "install", "--bin", "ratex", *std_cargo_args(path: "crates/tex-cli")
    %w[latexdiff lualatex pdflatex tex-bibtex texmk xelatex].each { |cmd| bin.install_symlink "ratex" => cmd }
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
