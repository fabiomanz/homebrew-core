class OhMyAgent < Formula
  desc "Portable multi-agent harness for .agents-based skills and workflows"
  homepage "https://firstfluke.com/oh-my-agent/"
  url "https://registry.npmjs.org/oh-my-agent/-/oh-my-agent-14.14.2.tgz"
  sha256 "1fa2b887af1b0d81387cf7f90cf36fcf8eb2885721385c3b14203a51775dfa29"
  license "MIT"

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "85baf249a127b520fb3adf3e446dcef22384009ce40b6c41faeb12466e30701e"
    sha256 cellar: :any, arm64_tahoe:       "c8197ec90231382a5fc6c71a224835ace307e5e50d5bf5092c43c28ecce6a8d0"
    sha256 cellar: :any, arm64_sequoia:     "8fd2507ab3dbd5ae5f2e13bbb5fbdfaedc36f634fc3d1486c19369b09a817411"
    sha256 cellar: :any, arm64_linux:       "32357a1d9f04bf0a9ac48def3d06424107e1f8ce0ca0aa9ae1f8aa9ad1d94e04"
    sha256 cellar: :any, x86_64_linux:      "83159c03ca8de9454079a42ea56abb293edc836815a92a71f4b96b8ad52b9122"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args

    node_modules = libexec/"lib/node_modules/oh-my-agent/node_modules"
    # Remove incompatible pre-built `bare-fs`/`bare-os`/`bare-path`/`bare-url` binaries
    os = OS.kernel_name.downcase
    arch = Hardware::CPU.intel? ? "x64" : Hardware::CPU.arch.to_s
    node_modules.glob("{bare-fs,bare-os,bare-path,bare-url}/prebuilds/*")
                .each { |dir| rm_r(dir) if dir.basename.to_s != "#{os}-#{arch}" }

    rm_r(node_modules.glob("better-sqlite3/prebuilds/*"))
    cd(node_modules/"better-sqlite3") { system "npm", "run", "build-release" }

    bin.install_symlink Dir[libexec/"bin/*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/oh-my-agent --version")

    output = JSON.parse(shell_output("#{bin}/oh-my-agent memory init --json"))
    assert_empty output["updated"]
    assert_path_exists testpath/".agents/state/memories/orchestrator-session.md"
    assert_path_exists testpath/".agents/state/memories/task-board.md"
  end
end
