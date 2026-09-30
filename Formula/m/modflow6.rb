class Modflow6 < Formula
  desc "USGS modular hydrologic model"
  homepage "https://www.usgs.gov/software/modflow-6-usgs-modular-hydrologic-model"
  url "https://github.com/MODFLOW-ORG/modflow6/archive/refs/tags/6.8.0.tar.gz"
  sha256 "e031d000eeacba00238421379e98dbcb1d4928fedaa4d9665d92932eb33dbaed"
  license "CC0-1.0"
  head "https://github.com/MODFLOW-ORG/modflow6.git", branch: "develop"

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "5d793adae577831a0516d6d0f5e884f12bb8fd3ad4cc02ff63c092bda7a5c9c8"
    sha256 cellar: :any, arm64_tahoe:       "cb0331c9e7e43563f9aca810a002a8fde3ee943df81ccc5d6c9b15ac7da517d9"
    sha256 cellar: :any, arm64_sequoia:     "112920eeeeb6ce3d91a4c4f91a02ba3e1ca0a2a293d636be8e8c28693706fdb2"
    sha256 cellar: :any, arm64_linux:       "509bf28a14cb4836a3fe3c529bf323dd111000b2b40145f3482615c205ae24f0"
    sha256 cellar: :any, x86_64_linux:      "f97ba9d7f20f9226faada9a78b13d7e136dbe1e0e987f4b538892cdef4a32959"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "gcc" # for gfortran

  deny_network_access!

  def install
    system "meson", "setup", "build", *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
    pkgshare.install ".mf6minsim" => "mf6minsim"

    # zbud6 is a utility built by the default meson targets and is not packaged
    rm bin/"zbud6"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mf6 --version")

    cp_r pkgshare/"mf6minsim/.", testpath
    system bin/"mf6"
    assert_match "Normal termination of simulation", (testpath/"mfsim.lst").read

    # run the same one-step simulation through libmf6
    rm testpath/"mfsim.lst"
    (testpath/"test.c").write <<~C
      int initialize(void), update(void), finalize(void);
      int main(void) { return initialize() || update() || finalize(); }
    C
    system ENV.cc, "test.c", "-L#{lib}", "-lmf6", "-Wl,-rpath,#{lib}", "-o", "test"
    system "./test"
    assert_match "Normal termination of simulation", (testpath/"mfsim.lst").read
  end
end
