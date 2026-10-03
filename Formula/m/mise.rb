class Mise < Formula
  desc "Polyglot runtime manager (asdf rust clone)"
  homepage "https://mise.jdx.dev/"
  url "https://github.com/jdx/mise/archive/refs/tags/v2026.9.16.tar.gz"
  sha256 "8dea789491374c17b02f6c516d8e1323b547d4658f9b82eb357cf9e025aeba40"
  license "MIT"
  head "https://github.com/jdx/mise.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "8eb42e8615a9f121f037fda5236c52c4560e32eef427bff84d534cdf0872caee"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "c24e54b0f22492d5cd86bda9fdefd11ebda182d8dbf394452342bb7aaa66159e"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "2d8c2ea3a1cc7e1efec6b35b5d91063971b2eeeaf3ea7e51c913782e700427c5"
    sha256 cellar: :any,                 arm64_linux:       "2fe09c1f92e4b645cbb1d5c035ff30ddc8d417be0cbf577c875afdc9233e79ec"
    sha256 cellar: :any,                 x86_64_linux:      "bb85951a355e0cf13bfcf817604907ff07981ac5c2d62488daf894203cd5f17f"
  end

  depends_on "cmake" => :build
  depends_on "llvm" => :build
  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  uses_from_macos "bzip2"

  on_linux do
    depends_on "openssl@4"
  end

  # downloads crates during install and binaries in the test
  deny_network_access! :postinstall

  def install
    # Ensure that the `openssl` crate picks up the intended library.
    ENV["OPENSSL_DIR"] = formula_opt_prefix("openssl@4") if OS.linux?

    system "cargo", "install", *std_cargo_args
    man1.install "man/man1/mise.1"
    lib.mkpath
    touch lib/".disable-self-update"
    (share/"fish/vendor_conf.d/mise-activate.fish").write <<~FISH
      if [ "$MISE_FISH_AUTO_ACTIVATE" != "0" ]
        #{opt_bin}/mise activate fish | source
      end
    FISH

    # Untrusted config path problem, `generate_completions_from_executable` is not usable
    bash_completion.install "completions/mise.bash" => "mise"
    fish_completion.install "completions/mise.fish"
    zsh_completion.install "completions/_mise"
  end

  def caveats
    <<~EOS
      If you are using fish shell, mise will be activated for you automatically.
    EOS
  end

  test do
    system bin/"mise", "settings", "set", "experimental", "true"
    system bin/"mise", "use", "go@1.23"
    assert_match "1.23", shell_output("#{bin}/mise exec -- go version")
  end
end
