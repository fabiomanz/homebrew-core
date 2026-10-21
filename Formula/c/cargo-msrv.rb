class CargoMsrv < Formula
  desc "Find the minimum supported Rust version (MSRV) for your project"
  homepage "https://foresterre.github.io/cargo-msrv"
  url "https://github.com/foresterre/cargo-msrv/archive/refs/tags/v0.19.4.tar.gz"
  sha256 "95a118bf46830bbbd9edbd2281cb141e1082c393fe048d3f288de2ed39ba8364"
  license any_of: ["Apache-2.0", "MIT"]
  head "https://github.com/foresterre/cargo-msrv.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "49aede8bad2c5febe142d4eba459301e3aac69e2b116b62a90bdd47fedaf1ca3"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "ac7b68d836937a6997bc1936701d9e2b4def3e79a9c9cb9a4658dd9dfae2f278"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "3930c076e8777dd80f3f42aeed9753c11a8a7b798b14926987468a9e121e7804"
    sha256 cellar: :any,                 arm64_linux:       "a144d4a6b5383702fb3ea66a802e68428561a11a1b5fc9381fda31b06c2e8df5"
    sha256 cellar: :any,                 x86_64_linux:      "16ca24356374f2d827714ce41b56aeea8a80bef60d114d7e0d2252a8babbb22c"
  end

  depends_on "rust" => :build
  depends_on "rustup" => :test

  allow_network_access! :test

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    ENV["NO_COLOR"] = "1"

    # Show that we can use a different toolchain than the one provided by the `rust` formula.
    # https://github.com/Homebrew/homebrew-core/pull/134074#pullrequestreview-1484979359
    ENV.prepend_path "PATH", formula_opt_bin("rustup")
    system "rustup", "set", "profile", "minimal"
    system "rustup", "default", "beta"

    assert_match version.to_s, shell_output("#{bin}/cargo-msrv --version")

    # Now proceed with creating your crate and calling cargo-msrv
    (testpath/"demo-crate/src").mkpath
    (testpath/"demo-crate/src/main.rs").write "fn main() {}"
    (testpath/"demo-crate/Cargo.toml").write <<~TOML
      [package]
      name = "demo-crate"
      version = "0.1.0"
      edition = "2021"
      rust-version = "1.78"
    TOML

    cd "demo-crate" do
      output = shell_output("#{bin}/cargo-msrv msrv show --output-format human --log-target stdout 2>&1")
      assert_match "name: \"demo-crate\"", output
    end
  end
end
