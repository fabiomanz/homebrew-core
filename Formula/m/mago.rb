class Mago < Formula
  desc "Toolchain for PHP to help developers write better code"
  homepage "https://github.com/carthage-software/mago"
  url "https://github.com/carthage-software/mago/releases/download/1.51.1/source-code.tar.gz"
  sha256 "1fe50db9a3b25e1311c8d375f10a6e10a3b4b46f2ad451d78b47603b668e535d"
  license any_of: ["Apache-2.0", "MIT"]

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "0bf3191d176ca7eea7b5bfcb189206ba65b1dd29808f19e74e33d832a019f0e4"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "d6ff4caa67b0e5cfadcf9e30d3128fb1f1cda4b7ecf3ffe3e55053f32b5b9cbe"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "32e8e98bd58c8342d3f7e0b2bc942f4a2f56ae1e5b49446d176d387eae0eadaf"
    sha256 cellar: :any,                 arm64_linux:       "b56c793f6e63040f35deaacb3237b47ec9e0c5f6bd2c1e5e262fbe3b8c6eefa0"
    sha256 cellar: :any,                 x86_64_linux:      "5f91a42ead4be9f65560032ee1f325c72de3a9e398dcf9e89f9fc6c8eb4203df"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mago --version")

    (testpath/"example.php").write("<?php echo 'Hello, Mago!';")
    output = shell_output("#{bin}/mago lint . 2>&1")
    assert_match "Missing `declare(strict_types=1);` statement at the beginning of the file", output

    (testpath/"unformatted.php").write("<?php echo 'Unformatted';?>")
    system bin/"mago", "fmt"
    assert_match "<?php echo 'Unformatted';?>", (testpath/"unformatted.php").read
  end
end
