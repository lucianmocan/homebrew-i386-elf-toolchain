class I386ElfGcc < Formula
  desc "GNU Compiler Collection targetting i386-elf"
  homepage "https://gcc.gnu.org"
  url "https://mirror.linux-ia64.org/gnu/gcc/gcc-14.1.0/gcc-14.1.0.tar.xz"
  sha512 "0c6ee313c336ebb028aac17ef60bac2dcf0b285f38c99916164c091506c9d56dedf60a96342de1e91e7c4eaf70d936cc0099c850dd5f148f425b05efb30f83eb"
  revision 1

  depends_on "gmp" => :build
  depends_on "mpfr" => :build
  depends_on "libmpc"
  depends_on "nativeos/i386-elf-toolchain/i386-elf-binutils"

  def install
    mkdir "gcc-build" do
      system "../configure", "--prefix=#{prefix}",
                             "--target=i386-elf",
                             "--disable-multilib",
                             "--disable-nls",
                             "--disable-werror",
                             "--without-headers",
                             "--without-isl",
                             "--enable-languages=c,c++"

      system "make", "all-gcc"
      system "make", "install-gcc"
      system "make", "all-target-libgcc"
      system "make", "install-target-libgcc"

      # GCC needs this folder in #{prefix} in order to see the binutils.
      # It doesn't look for i386-elf-as on $PREFIX/bin. Rather, it looks
      # for as on $PREFIX/$TARGET/bin/ ($PREFIX/i386-elf/bin/as).
      binutils = Formula["nativeos/i386-elf-toolchain/i386-elf-binutils"].prefix
      ln_sf "#{binutils}/i386-elf", "#{prefix}/i386-elf"
    end
  end

  test do
    (testpath/"program.c").write <<~DATA
    int sum(int a, int b) {
      return a + b;
    }
    DATA
    system "#{bin}/i386-elf-gcc", "-c", "program.c"
    binutils = Formula["nativeos/i386-elf-toolchain/i386-elf-binutils"].prefix
    assert_match "file format elf32-i386", shell_output("#{binutils}/bin/i386-elf-objdump -D program.o")
  end
end
