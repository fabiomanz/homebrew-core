class OhMyAgent < Formula
  desc "Portable multi-agent harness for .agents-based skills and workflows"
  homepage "https://firstfluke.com/oh-my-agent/"
  url "https://registry.npmjs.org/oh-my-agent/-/oh-my-agent-20.10.5.tgz"
  sha256 "918b80f41ac44935662c4bbf2d972cc8feaf01db2a58a6f3f4d54f22ffb4a4af"
  license "MIT"

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "6539bbd9d0b6f1de2f230f44267b51d0233986f07b6eda0eccb5a75c3c095551"
    sha256 cellar: :any, arm64_tahoe:       "0cf14f31317ce328a270d2b3e246ccfcb55d45f9b574edd92f32a372ef59d0f6"
    sha256 cellar: :any, arm64_sequoia:     "5357b83560b71ca9cf75879f7aafe7276218abdb661b01badd957e93cc8b61d4"
    sha256 cellar: :any, arm64_linux:       "5aec028d8b26cb105de1d04d6ffcd1ccbdb5c678b78dcb18e9a0ee3ff9dc3c1c"
    sha256 cellar: :any, x86_64_linux:      "1c31b88681b7d87f3f875b6db140cac292ecae76eba2d30ad6642be5a224d0c9"
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
