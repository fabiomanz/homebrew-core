class TodoistCli < Formula
  desc "Official command-line interface for Todoist"
  homepage "https://github.com/Doist/todoist-cli"
  url "https://registry.npmjs.org/@doist/todoist-cli/-/todoist-cli-5.5.6.tgz"
  sha256 "4317a740275c7faa8c606e1117cd283913cd0f4f0d73e4930b57b26d7590200f"
  license "MIT"

  bottle do
    sha256 cellar: :any,                 arm64_golden_gate: "7a3e1a23e38f29e0aa16f21a5a4a967b88b65be033c5e2bc597ba4bd0a45b895"
    sha256 cellar: :any,                 arm64_tahoe:       "9247ad68566fd4e4036da0cc528bf8ca565df85ead3a62e6206739142765bf1b"
    sha256 cellar: :any,                 arm64_sequoia:     "5419d39149030419144ecaa816b232c95d282d4df0e80f7d3ac2fe586ea752fc"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "21fbfd868f6fa9d6ba9afa10c7e53a61f1da7121e655ddfe6f0c47782e6a47fe"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "03d75c8b1b3c32cfbbb9414276620bd0773230e77129b46bbb82c90b0bfba215"
  end

  depends_on "rust" => :build
  depends_on "node"

  resource "keyring" do
    url "https://github.com/Brooooooklyn/keyring-node/archive/refs/tags/v2.1.1.tar.gz"
    sha256 "b1f4847eb61306e8c4f1a0418bf9e47231e8fdbc41a88631777d5cfa515eaaaf"

    livecheck do
      url "https://raw.githubusercontent.com/Doist/todoist-cli/v#{LATEST_VERSION}/package-lock.json"
      regex(/^v?(\d+(?:\.\d+)+)$/i)
      strategy :json do |json, regex|
        json.dig("packages", "node_modules/@napi-rs/keyring", "version")&.[](regex, 1)
      end
    end
  end

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")

    return unless OS.mac?

    node_modules = libexec/"lib/node_modules/@doist/todoist-cli/node_modules"

    resource("keyring").stage do
      system "cargo", "build", "--lib", "--release"
      dylib = Pathname.pwd/"target/release/libnapi_keyring.dylib"
      node_modules.glob("@doist/cli-core/node_modules/@napi-rs/keyring-darwin-*/*.node").each do |prebuilt|
        cp dylib, prebuilt
      end
    end

    deuniversalize_machos node_modules/"app-path/main"
  end

  def caveats
    <<~EOS
      Looking for the third-party Go CLI previously published under this
      name (by sachaos)? It has been renamed. Install it with:
        brew install todoist-cli-go
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/td --version")
  end
end
