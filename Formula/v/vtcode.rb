class Vtcode < Formula
  desc "CLI Semantic Coding Agent"
  homepage "https://vinhnx.github.io"
  url "https://static.crates.io/crates/vtcode/vtcode-0.178.0.crate"
  sha256 "ae58605f4a1c5fb0e1ef058ccca76285e3905d537b78c60d62cb1fcdc8702493"
  license any_of: ["MIT", "Apache-2.0"]
  head "https://github.com/vinhnx/vtcode.git", branch: "main"

  livecheck do
    throttle 5
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "c200687923777eddb6958b72064cf67f43e9720925ba8dbbc44cf6e79d2b68de"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "f396e157dfdc712806816faff73c3541aea14686bf10e54454e325582ebfca98"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "c1ed0dfd65003b8c726f9a5fd4d4740f2545a07a22a6c2c8496d20678c399334"
    sha256 cellar: :any,                 arm64_linux:       "67892f8ac26cdb457a84a9f708b4a667b62449741e6bd707194f47222cd1d823"
    sha256 cellar: :any,                 x86_64_linux:      "df8084abde8a59f0ee27a782edbfdce9e54e88d7541841755587d7b5d25ab3fd"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "ripgrep"

  on_linux do
    depends_on "openssl@4" => :build
  end

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    ENV["OPENSSL_DIR"] = formula_opt_prefix("openssl@4") if OS.linux?
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/vtcode --version")

    ENV["OPENAI_API_KEY"] = "test"
    output = shell_output("#{bin}/vtcode models list --provider openai")
    assert_match "OPENAI", output
  end
end
