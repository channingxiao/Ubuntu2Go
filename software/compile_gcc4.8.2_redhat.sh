mkdir -p gcc4.8.2
cd gcc4.8.2
wget http://gcc.skazkaforyou.com/releases/gcc-4.8.2/gcc-4.8.2.tar.gz
wget ftp://gcc.gnu.org/pub/gcc/infrastructure/mpfr-2.4.2.tar.bz2
wget ftp://gcc.gnu.org/pub/gcc/infrastructure/gmp-4.3.2.tar.bz2
wget ftp://gcc.gnu.org/pub/gcc/infrastructure/mpc-0.8.1.tar.gz

# uncompressed all the data
tar -xf gcc-4.8.2.tar.gz
tar xjf mpfr-2.4.2.tar.bz2
tar xjf gmp-4.3.2.tar.bz2
tar xzf mpc-0.8.1.tar.gz

mv mpc-0.8.1 gcc-4.8.2
mv gmp-4.3.2 gcc-4.8.2
mv mpfr-2.4.2 gcc-4.8.2

ln -sf mpfr-2.4.2 mpfr
ln -sf gmp-4.3.2 gmp
ln -sf mpc-0.8.1 mpc

mkdir -p build
cd build
../configure --enable-checking=release --enable-languages=c,c++ --disable-multilib --prefix=$HOME/gcc
make & make install

