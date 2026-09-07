class Jql < Formula
  desc "JSON query language CLI tool"
  homepage "https://github.com/yamafaktory/jql"
  url "https://github.com/yamafaktory/jql/archive/refs/tags/jql-v8.1.3.tar.gz"
  sha256 "98627a6cca5c66ee6232245a60718e1e1752e011bfda0a0b8563422d1af1c54c"
  license any_of: ["Apache-2.0", "MIT"]
  head "https://github.com/yamafaktory/jql.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "7843adbdb5e15c7acf59988f3939d44366a938b89d4cc653da59b0aeabbf4893"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "9d2d7cff99a9d7b2459b273286a86d4549038158ee2d70dd6d088e19cd03250b"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "7efbe14805c95da7a409b588bf35f472fec4355a747c5d53a5999c051fc95836"
    sha256 cellar: :any,                 arm64_linux:   "6dbb40b982d7dd67196575c1c35d6fb350cb737588e9bdc04759d77ae858072a"
    sha256 cellar: :any,                 x86_64_linux:  "f47153767407cfab924ac3dfbc27306a78fe50903fb65eb964c215418339de2d"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/jql")
  end

  test do
    (testpath/"example.json").write <<~JSON
      {
        "cats": [{ "first": "Pixie" }, { "second": "Kitkat" }, { "third": "Misty" }]
      }
    JSON
    output = shell_output("#{bin}/jql --inline --raw-string '\"cats\" [2:1] [0]' example.json")
    assert_equal '{"third":"Misty"}', output.chomp
  end
end
