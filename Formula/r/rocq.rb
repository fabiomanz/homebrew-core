class Rocq < Formula
  desc "Proof assistant for higher-order logic"
  homepage "https://rocq-prover.org/"
  license "LGPL-2.1-only"
  revision 1
  compatibility_version 2

  stable do
    url "https://github.com/rocq-prover/rocq/releases/download/V9.2.0/rocq-9.2.0.tar.gz"
    sha256 "a45280ab4fbaac7540b136a6b073b4a6db15739ec1e149bded43fa6f4fc25f20"

    resource "stdlib" do
      url "https://github.com/rocq-prover/stdlib/releases/download/V9.1.0/stdlib-9.1.0.tar.gz"
      sha256 "2d66421c52ed32719a15cb039c368e063c4d85f670e3d142f5eb7415fb427985"
    end
  end

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 arm64_golden_gate: "88fa0ea4292f53016c228cd8aad5327253230d78ed47a370d0fb5304861b832a"
    sha256 arm64_tahoe:       "971777414c19943893343ce424b4d28b2ea6a4539c92d88e61a2a0626b198a22"
    sha256 arm64_sequoia:     "f41488b2e656f2b8a0893f93365eca5e7f5fc72759526511267a6d0aee5a291f"
    sha256 arm64_linux:       "119029ce844dc6a5c715dc50fabae1f2e1aba5ff789b3a9cde50c282634c1e30"
    sha256 x86_64_linux:      "bc71e926808bc01ee1a17ba32b939b6fd2d271aa98e44521000f7338925fcece"
  end

  head do
    url "https://github.com/rocq-prover/rocq.git", branch: "master"

    resource "stdlib" do
      url "https://github.com/rocq-prover/stdlib.git", branch: "master"
    end
  end

  depends_on "dune" => :build
  depends_on "gmp"
  depends_on "ocaml"
  depends_on "ocaml-findlib"
  depends_on "ocaml-zarith"

  uses_from_macos "m4" => :build
  uses_from_macos "unzip" => :build

  def install
    # Work around for https://github.com/Homebrew/homebrew-test-bot/issues/805
    if ENV["HOMEBREW_GITHUB_ACTIONS"] && !(Formula["ocaml-findlib"].etc/"findlib.conf").exist?
      ENV["OCAMLFIND_CONF"] = formula_opt_libexec("ocaml-findlib")/"findlib.conf"
    end
    ENV.prepend_path "OCAMLPATH", formula_opt_lib("ocaml-zarith")/"ocaml"
    ENV.prepend_path "OCAMLPATH", formula_opt_lib("ocaml-findlib")/"ocaml"

    packages = %w[rocq-runtime coq-core rocq-core coqide-server]

    # dune 3.24 deleted the `coq` language extension. The default (rule_gen)
    # build doesn't use it (only the unused `dune.disabled` files do) and the
    # `(coq ...)` env field only sets dev-profile flags, so drop both to keep
    # building until a release adopts the Rocq build language.
    inreplace "dune-project", /^\(using coq [\d.]+\)\n/, ""
    inreplace "dune", /\n\s*\(coq \(flags :standard -w \+default\)\)\)/, ")"

    system "./configure", "-prefix", prefix,
                          "-libdir", HOMEBREW_PREFIX/"lib/ocaml/coq",
                          "-docdir", pkgshare/"latex"
    system "make", "dunestrap"
    system "dune", "build", "-p", packages.join(",")
    system "dune", "install", "--prefix=#{prefix}",
                              "--mandir=#{man}",
                              "--libdir=#{lib}/ocaml",
                              "--docdir=#{doc.parent}",
                              *packages

    resource("stdlib").stage do
      ENV.prepend_path "PATH", bin
      ENV["ROCQLIB"] = lib/"ocaml/coq"
      system "make"
      system "make", "install"
    end
  end

  test do
    # Work around for https://github.com/Homebrew/homebrew-test-bot/issues/805
    if ENV["HOMEBREW_GITHUB_ACTIONS"] && !(Formula["ocaml-findlib"].etc/"findlib.conf").exist?
      ENV["OCAMLFIND_CONF"] = formula_opt_libexec("ocaml-findlib")/"findlib.conf"
    end
    (testpath/"testing.v").write <<~ROCQ
      Require Stdlib.micromega.Lia.
      Require Stdlib.ZArith.ZArith.

      Inductive nat : Set :=
      | O : nat
      | S : nat -> nat.
      Fixpoint add (n m: nat) : nat :=
        match n with
        | O => m
        | S n' => S (add n' m)
        end.
      Lemma add_O_r : forall (n: nat), add n O = n.
      Proof.
      intros n; induction n; simpl; auto; rewrite IHn; auto.
      Qed.

      Import Stdlib.micromega.Lia.
      Import Stdlib.ZArith.ZArith.
      Open Scope Z.
      Lemma add_O_r_Z : forall (n: Z), n + 0 = n.
      Proof.
      intros; lia.
      Qed.
    ROCQ
    system bin/"rocq", "compile", testpath/"testing.v"
    # test ability to find plugin files
    output = shell_output("#{formula_opt_bin("ocaml-findlib")}/ocamlfind query rocq-runtime.plugins.ltac")
    assert_equal "#{HOMEBREW_PREFIX}/lib/ocaml/rocq-runtime/plugins/ltac", output.chomp
  end
end
