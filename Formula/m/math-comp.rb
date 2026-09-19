class MathComp < Formula
  desc "Mathematical Components for the Coq proof assistant"
  homepage "https://math-comp.github.io/math-comp/"
  url "https://github.com/math-comp/math-comp/archive/refs/tags/mathcomp-2.6.0.tar.gz"
  sha256 "b2e8c5c93fdc9bb5ed9b8a06d1c028aa0096a45b1f3ac6c6509d7a6500c72253"
  license "CECILL-B"
  revision 3
  head "https://github.com/math-comp/math-comp.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "c8f36f66fc4614f2df4fb39e1cf14cc00af7a288eaa61b51f44981393ccaa620"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "64497c759c7145136a8eb9baf9c2b407536cb24fce131004270eb08d0f6c7695"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "c2800db82805694e0d5fe86e7c913e116fb0b64fd31cdf3ad344bd445ef41a89"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "ccafea292dc89f8a183ad6a3fadbe94daa63ebaad1999556c9f9bbf281365576"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "902c7e417d5f930bf77109be7c1f1d73bb28d4b3436607f4ecc44dd130243d2f"
  end

  depends_on "ocaml" => :build
  depends_on "ocaml-findlib" => :build
  depends_on "hierarchy-builder"
  depends_on "rocq"
  depends_on "rocq-elpi"
  depends_on "rocq-micromega-plugin"

  def install
    ENV["OCAMLFIND_CONF"] = formula_opt_libexec("rocq-elpi")/"lib/findlib.conf"
    ENV.prepend_path "OCAMLPATH", formula_opt_lib("rocq-micromega-plugin")/"ocaml"

    system "make"
    system "make", "install", "COQLIBINSTALL=#{lib}/ocaml/coq/user-contrib"
  end

  test do
    (testpath/"testing.v").write <<~ROCQ
      From mathcomp Require Import ssreflect seq.

      Parameter T: Type.
      Theorem test (s1 s2: seq T): size (s1 ++ s2) = size s1 + size s2.
      Proof. by elim : s1 =>//= x s1 ->. Qed.

      Check test.
    ROCQ

    ENV["OCAMLFIND_CONF"] = formula_opt_libexec("rocq-elpi")/"lib/findlib.conf"
    ENV.prepend_path "OCAMLPATH", formula_opt_lib("rocq-micromega-plugin")/"ocaml"
    assert_match(/\Atest\s+: forall/, shell_output("#{formula_opt_bin("rocq")}/rocq compile testing.v"))
  end
end
