class Cdk8s < Formula
  desc "Define k8s native apps and abstractions using object-oriented programming"
  homepage "https://cdk8s.io/"
  url "https://registry.npmjs.org/cdk8s-cli/-/cdk8s-cli-2.207.59.tgz"
  sha256 "d42d7ecf94d5d7b4001e3d29a2e3c3d6fb80f435bba63c55b23cc5a319cbcd47"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, all: "6dcf5eca71e72d4e77015a12cd314300ebca675ed0bd75c3cc51af3e648c82a9"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")
  end

  test do
    output = shell_output("#{bin}/cdk8s init python-app 2>&1", 1)
    assert_match "Initializing a project from the python-app template", output
  end
end
