class BazelDiff < Formula
  desc "Performs Bazel Target Diffing between two revisions in Git"
  homepage "https://github.com/Tinder/bazel-diff/"
  url "https://github.com/Tinder/bazel-diff/archive/refs/tags/v50.3.0.tar.gz"
  sha256 "0294d728f4a0c6ffaf1114025524fd85b73fd8b4d045ae8eaeead851061fd447"
  license "BSD-3-Clause"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "6d901d69d196d6bd2710647fe790f3c4a114d3c0b410c587cb980d2c54c5845d"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "fcc93775d7ddd5d5db026a18b03dc7c32add14591de199272680bc3c1404ed37"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "73bde48bac068a6ae57d7c97ff43f1b6633fc57c71264a3afda782da177658a6"
    sha256 cellar: :any,                 arm64_linux:       "fcfaf963ba35d9718485044df4effabf6f68859fcbd106b4a1b4e0d6e83a4f32"
    sha256 cellar: :any,                 x86_64_linux:      "5dec7befc4f9961f3afa31703eee72c26289201dffc86ed8aa16a5c5058df5d6"
  end

  depends_on "protobuf" => :build
  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    # Use our protoc rather than the prebuilt one from `protoc-bin-vendored`
    ENV["PROTOC"] = formula_opt_bin("protobuf")/"protoc"
    system "cargo", "install", *std_cargo_args
  end

  test do
    (testpath/"from.json").write <<~JSON
      {"//app:leaf": "Rule#old~old", "//app:top": "Rule#top~same"}
    JSON
    (testpath/"to.json").write <<~JSON
      {"//app:leaf": "Rule#new~new", "//app:top": "Rule#top~same"}
    JSON

    output = shell_output("#{bin}/bazel-diff get-impacted-targets --startingHashes from.json " \
                          "--finalHashes to.json --workspacePath #{testpath}")
    assert_equal "//app:leaf\n", output
  end
end
