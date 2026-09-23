class Jcode < Formula
  desc "AI coding agent harness for the terminal"
  homepage "https://jcode.sh"
  url "https://github.com/1jehuang/jcode/archive/refs/tags/v0.87.1.tar.gz"
  sha256 "5159f434ff44158dc7acc869b4cb99fa334d0baa616108e0c9b8a43f963d9d81"
  license "MIT"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "188d2cc983b1edc75c25600388ff9a11475af3d189af96657c01de8586b45a64"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "8f1e194a3b034ab6c880bad8bfb34bbe7c83e565955c24b1450afdb971dc83e7"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "ed832077361814aa33b0ef2810a234fbbdefb6ed0a9bacfae761cbfc20f212b3"
    sha256 cellar: :any,                 arm64_linux:       "1ad36aca57059dfb97e097c1b86ab56f2bda5d2e91bba560fe4c54d0da485bfa"
    sha256 cellar: :any,                 x86_64_linux:      "28c796b2ea34acac354583c5a701554623f888516ca6650bd4c3549f50890bc9"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  on_linux do
    depends_on "openssl@3"
  end

  deny_network_access! :build

  def fetch
    system "cargo", "fetch", "--locked"
  end

  def install
    # Disable background auto-update by default
    inreplace "src/cli/args.rs",
              '#[arg(long, global = true, default_value = "true")]',
              '#[arg(long, global = true, default_value = "false")]'

    # Redirect `jcode update` to Homebrew
    inreplace "src/cli/dispatch.rs",
              "hot_exec::run_update()?;",
              'eprintln!("Please update jcode using: brew upgrade jcode");'

    system "cargo", "install", *std_cargo_args
    rm bin/"test_api"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/jcode --version")
    assert_match "Please update jcode using: brew upgrade jcode", shell_output("#{bin}/jcode update 2>&1")

    system bin/"jcode-harness", "--cwd", testpath
    assert_match "alpha2", (testpath/"sample.txt").read
  end
end
