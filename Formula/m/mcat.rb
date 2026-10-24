class Mcat < Formula
  desc "Terminal image, video, directory, and Markdown viewer"
  homepage "https://github.com/Skardyy/mcat"
  url "https://github.com/Skardyy/mcat/archive/refs/tags/v0.6.6.tar.gz"
  sha256 "f5fc7043ed5b5c467383ba1e2e62f493e629ad729a910d46202cfaa16d58b80a"
  license "MIT"
  head "https://github.com/Skardyy/mcat.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "f652b1aa23fc267b3f90880ab0559f9a192dd58e8b0be937b0a15e83198020c3"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "bcf8153c2c50fef0cab5959f560c9f81c72359d9c0faa6af3364c09f7b1b70e4"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "56ddcbd82cd9ead637451f7e490705e327084e8fc11ba9030b9770e9075ffe4f"
    sha256 cellar: :any,                 arm64_linux:       "d4efd3ffa64f55810f950cfbd39f3a91cfd213072d12ce967fabff6c0b331f8f"
    sha256 cellar: :any,                 x86_64_linux:      "125a94ff52566152a4202f699fefba2f3cd1859570a65104852ce9cf244320dc"
  end

  depends_on "rust" => :build

  conflicts_with "mtools", because: "both install `mcat` binaries"

  # Avoid hanging when probing a terminal that does not answer: macOS poll(2) does
  # not support ttys, and a background process group is stopped by SIGTTOU/SIGTTIN
  # Upstream PR ref: https://github.com/Skardyy/mcat/pull/109
  patch do
    url "https://github.com/Skardyy/mcat/commit/1dcf9b3cca130086d17641d73811535c3826b29b.patch?full_index=1"
    sha256 "559307c6ddbd0217495b05024a374791aa591dcb174807efea52074cea2090ad"
    type :unofficial
    resolves "https://github.com/Skardyy/mcat/pull/109"
  end

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/core")

    generate_completions_from_executable(bin/"mcat", "--generate", shells: [:bash, :zsh, :fish, :pwsh])
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mcat --version")

    (testpath/"test.md").write <<~MD
      # Hello World

      This is a **test** of _mcat_!
    MD

    output = shell_output("#{bin}/mcat #{testpath}/test.md")
    assert_match "# Hello World\n\nThis is a **test** of _mcat_!", output
  end
end
