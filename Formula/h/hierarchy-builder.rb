class HierarchyBuilder < Formula
  desc "High level commands to declare a hierarchy based on packed classes"
  homepage "https://github.com/math-comp/hierarchy-builder"
  url "https://github.com/math-comp/hierarchy-builder/releases/download/v1.10.3/hierarchy-builder-1.10.3.tar.gz"
  sha256 "577597528f25d217baee91040cc5d7e5f621be7e7a629cccf295e337f73a6d45"
  license "MIT"
  revision 4
  compatibility_version 1

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "10bebd6c000dbcf18e86c2c78ab6c58d92daa166bed3423c670dee3166dbb79a"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "c2ff44a7b03cd18f67492b5644f63628c027a6c6a0abfdcdc1050845d16eb05f"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "56f58863bb75ded2783d73488762acbe5f0e017e051198b4a4e9bedfbf8d0314"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "9bb5af0dda20bbe6523264c38f97942b25442ebadc0e1ac4523c1d509b113522"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "d9fa7585e6c61c18b321f465e55d04833cecf1f6bf95ec76b66961888b51d0fb"
  end

  depends_on "rocq"
  depends_on "rocq-elpi"

  def install
    ENV["OCAMLFIND_CONF"] = formula_opt_libexec("rocq-elpi")/"lib/findlib.conf"
    system "make", "build"
    system "make", "install", "COQLIB=#{lib}/ocaml/coq"
  end

  test do
    (testpath/"test.v").write <<~ROCQ
      From HB Require Import structures.
      From Stdlib Require Import ssreflect ZArith.

      HB.mixin Record IsAddComoid A := {
        zero : A;
        add : A -> A -> A;
        addrA : forall x y z, add x (add y z) = add (add x y) z;
        addrC : forall x y, add x y = add y x;
        add0r : forall x, add zero x = x;
      }.

      HB.structure Definition AddComoid := { A of IsAddComoid A }.

      Notation "0" := zero.
      Infix "+" := add.

      Check forall (M : AddComoid.type) (x : M), x + x = 0.
    ROCQ

    ENV["OCAMLFIND_CONF"] = formula_opt_libexec("rocq-elpi")/"lib/findlib.conf"
    assert_equal <<~ROCQ, shell_output("#{formula_opt_bin("rocq")}/rocq compile test.v")
      forall (M : AddComoid.type) (x : M), x + x = 0
           : Prop
    ROCQ
  end
end
