class RocqMicromegaPlugin < Formula
  desc "Micromega decision procedures plugin for the Rocq prover"
  homepage "https://github.com/rocq-community/micromega-plugin"
  url "https://github.com/rocq-community/micromega-plugin/archive/refs/tags/v1.1.1.tar.gz"
  sha256 "5ed46c62dfb7c06ad1df2f744bca5a39282ac9787c57433478a87a706e6e4391"
  license "LGPL-2.1-only"
  revision 1

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "309146c40ed274d5e36973707da75441ca3653d54d84ac9f0c41069495662214"
    sha256 cellar: :any, arm64_tahoe:       "b08cab3724229db236436ded7b6bc584611abc36a0c64eb09220c311afc23cce"
    sha256 cellar: :any, arm64_sequoia:     "f763d1a21ec9bda42e07e7972a0f425b2a4462334b368c822d7b8fae7660b50b"
    sha256 cellar: :any, arm64_linux:       "83ecdf2ecacdedb2c65fe0e1858ae4c5dde30df5be0cc5a308b0ac45b0526c45"
    sha256 cellar: :any, x86_64_linux:      "d16d255cf0b385782db4a4dd07c8d483f635a528398d750787483d136c5c3a25"
  end

  depends_on "dune" => :build
  depends_on "ocaml" => :build
  depends_on "opam" => :build
  depends_on "ocaml-findlib"
  depends_on "rocq"

  # Only used to provide a version number for `opam install` (build-only ppx)
  resource "ppx_optcomp" do
    url "https://raw.githubusercontent.com/janestreet/ppx_optcomp/refs/tags/v0.17.1/ppx_optcomp.opam"
    sha256 "59af9cf06bdc1d2682de3eb95bd179e48659d4dc76bd60e15feb5fbe07d42400"
  end

  def install
    ENV["OPAMROOT"] = buildpath/".opam"
    ENV["OPAMYES"] = "1"
    system "opam", "init", "--compiler=ocaml-system", "--disable-sandboxing", "--no-setup"
    system "opam", "install", "ppx_optcomp.v#{resource("ppx_optcomp").version}", "--no-depexts"

    ENV.prepend_path "OCAMLPATH", buildpath/".opam/ocaml-system/lib"
    ENV.prepend_path "OCAMLPATH", formula_opt_lib("rocq")/"ocaml"
    ENV.prepend_path "OCAMLPATH", formula_opt_lib("ocaml-findlib")/"ocaml"

    # dune 3.24 replaced the Coq build language with the Rocq build language.
    dune_files = buildpath.glob("**/dune") << (buildpath/"dune-project")
    {
      "(lang dune 3.8)" => "(lang dune 3.24)",
      "(using coq 0.8)" => "(using rocq 0.11)",
      "(coq (flags"     => "(rocq (flags",
      "coq.theory"      => "rocq.theory",
      "coq.pp"          => "rocq.pp",
      "%{coq:"          => "%{rocq:",
    }.each do |before, after|
      inreplace dune_files.select { |f| f.read.include?(before) }, before, after
    end

    system "dune", "build", "-p", name, "@install"
    system "dune", "install", name, "--prefix=#{prefix}",
           "--libdir=#{lib}/ocaml",
           "--docdir=#{doc.parent}"
  end

  test do
    (testpath/"test.v").write <<~ROCQ
      From micromega_plugin Require Import PosDef NatDef formula witness.
    ROCQ
    ENV.prepend_path "OCAMLPATH", opt_lib/"ocaml"
    system formula_opt_bin("rocq")/"rocq", "compile", testpath/"test.v"
  end
end
