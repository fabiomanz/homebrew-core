class Hyperfine < Formula
  desc "Command-line benchmarking tool"
  homepage "https://github.com/sharkdp/hyperfine"
  url "https://github.com/sharkdp/hyperfine/archive/refs/tags/v1.21.0.tar.gz"
  sha256 "aee01125074fd5a6a556818db7bba0577edae94cbe85165daae0e778aa28348d"
  license any_of: ["Apache-2.0", "MIT"]
  head "https://github.com/sharkdp/hyperfine.git", branch: "master"

  bottle do
    root_url "https://github.com/fabiomanz/intel-bottles/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, tahoe: "90a8d5b893cefa331099de50489854464cc6e565e3214b46689981429878ca0f"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    ENV["SHELL_COMPLETIONS_DIR"] = buildpath

    system "cargo", "install", *std_cargo_args

    bash_completion.install "hyperfine.bash" => "hyperfine"
    fish_completion.install "hyperfine.fish"
    zsh_completion.install "_hyperfine"
    man1.install "doc/hyperfine.1"
  end

  test do
    output = shell_output("#{bin}/hyperfine 'sleep 0.3'")
    assert_match "Benchmark 1: sleep", output
  end
end
