class LovableOj < Formula
  desc "Experimental next generation frontend tooling"
  homepage "https://github.com/lovablelabs/oj"
  url "https://github.com/lovablelabs/oj/archive/refs/tags/v0.2.49.tar.gz"
  sha256 "ba6f08b5cb1aba13c5979a1789d4ffb4b109762119dcc468fbb860e1bc90640d"
  license "MIT"
  head "https://github.com/lovablelabs/oj.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "40cc2f643fdb4c618e74f9f7c7b495d98232fefd476d82ae04a0594ba378d4f2"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "4a4420e558879e316e0d7fc753aa95967337bd2d2c24f159b2e1d225b2bde386"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "f3e8086e449415f7f9fa48701ef48ed1e064a7c7c4dd2ff679d8bc42e6882d26"
    sha256 cellar: :any,                 arm64_linux:       "c6b257b8b39b5dcd1d17453843e497e87fb3471bc1513786342a3c36ecff9393"
    sha256 cellar: :any,                 x86_64_linux:      "521a12d22f4185bdb43d3a5e84e908789aed190f0cf16e17f1f2cf734aded78c"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  uses_from_macos "llvm" => :build # for libclang

  on_linux do
    depends_on "zlib-ng-compat"
  end

  # `v8` crate downloads binaries at build-time
  allow_network_access! :build

  def install
    ENV["LIBCLANG_PATH"] = formula_opt_lib("llvm") if OS.linux?

    system "cargo", "install", *std_cargo_args(path: "crates/oj")
  end

  test do
    (testpath/"index.html").write <<~HTML
      <!doctype html>
      <div id="app"></div>
      <script type="module" src="/src/main.js"></script>
    HTML
    (testpath/"src/main.js").write <<~JS
      document.getElementById("app").textContent = "hello " + "oj";
    JS

    assert_match version.to_s, shell_output("#{bin}/oj --version")
    system bin/"oj", "build"
    assert_match "hello oj", (testpath/"dist/assets").glob("*.js").map(&:read).join
  end
end
