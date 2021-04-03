#!/bin/bash

# author:zhouzhuo
# create time: 2021/3/20
# update time: 2021/4/2
# description
# this script use to install Gcc compiler, which support 6.+,7.+,8.+,9.+ and 10.+
# status: commited 


source ./conf/app.cfg
source ./func/func.sh

gcc_version=$1
arch_flags="-march=x86-64"
build_target=x86_64-redhat-linux
packageversion="$(whoami)-$(hostname -s)"
gmp_version=6.1.2
mpfr_version=3.1.4
mpc_version=1.0.3
isl_version=0.18
gmp_tarfile=gmp-${gmp_version}.tar.bz2
mpfr_tarfile=mpfr-${mpfr_version}.tar.bz2
mpc_tarfile=mpc-${mpc_version}.tar.gz
isl_tarfile=isl-${isl_version}.tar.bz2
gcc_tarfile=gcc-${gcc_version}.tar.gz
gcc_build_dir=$build_dir/gcc_${gcc_version}_build
gcc_install_dir=$install_dir/gcc/${gcc_version}

_download_file https://gmplib.org/download/gmp              $gmp_tarfile
_download_file https://ftp.gnu.org/gnu/mpfr                 $mpfr_tarfile
_download_file http://www.multiprecision.org/downloads      $mpc_tarfile
_download_file ftp://gcc.gnu.org/pub/gcc/infrastructure     $isl_tarfile
_download_file http://mirror.hust.edu.cn/gnu/gcc/gcc-${gcc_version} $gcc_tarfile

# Check tarfiles are found, if not found, dont proceed
for f in $gmp_tarfile $mpfr_tarfile $mpc_tarfile $isl_tarfile $gcc_tarfile
do
    if [ ! -f "$tarfile_dir/$f" ]; then
        _log_abort "tarfile not found: $tarfile_dir/$f"
    fi
done
_tips " unzip source code "

_unzipfile  "$source_dir"  "$tarfile_dir/$gcc_tarfile"
_unzipfile  "$source_dir/gcc-${gcc_version}"  "$tarfile_dir/$mpfr_tarfile"
mv -v $source_dir/gcc-${gcc_version}/mpfr-${mpfr_version} $source_dir/gcc-${gcc_version}/mpfr
_unzipfile  "$source_dir/gcc-${gcc_version}"  "$tarfile_dir/$mpc_tarfile"
mv -v $source_dir/gcc-${gcc_version}/mpc-${mpc_version} $source_dir/gcc-${gcc_version}/mpc
_unzipfile "$source_dir/gcc-${gcc_version}"  "$tarfile_dir/$gmp_tarfile"
mv -v $source_dir/gcc-${gcc_version}/gmp-${gmp_version} $source_dir/gcc-${gcc_version}/gmp
_unzipfile "$source_dir/gcc-${gcc_version}"  "$tarfile_dir/$isl_tarfile"
mv -v $source_dir/gcc-${gcc_version}/isl-${isl_version} $source_dir/gcc-${gcc_version}/isl

_tips " Cleaning environment"
U=$USER
H=$HOME

for i in $(env | awk -F"=" '{print $1}') ;
do
    unset $i || true   # ignore unset fails
done
# restore
export USER=$U
export HOME=$H
export PATH=/usr/local/bin:/usr/bin:/bin:/sbin:/usr/sbin
echo shell environment follows:
env
_check_install_dir ${gcc_install_dir}
_check_source_build_dir ${gcc_build_dir}
cd ${gcc_build_dir}

CC=gcc
CXX=g++
OPT_FLAGS="-O2 $gflags -Wall  $arch_flags"
CC="$CC" CXX="$CXX" CFLAGS="$OPT_FLAGS" \
    CXXFLAGS="`echo " $OPT_FLAGS " | sed 's/ -Wall / /g'`" \
    $source_dir/gcc-${gcc_version}/configure --prefix=${gcc_install_dir} \
    --enable-bootstrap \
    --enable-shared \
    --enable-threads=posix \
    --enable-checking=release \
    --with-system-zlib \
    --enable-__cxa_atexit \
    --disable-libunwind-exceptions \
    --enable-linker-build-id \
    --enable-languages=c,c++,objc,obj-c++,fortran,go,lto \
    --disable-vtable-verify \
    --with-default-libstdcxx-abi=new \
    --enable-libstdcxx-debug  \
    --without-included-gettext  \
    --enable-plugin \
    --disable-initfini-array \
    --disable-libgcj \
    --enable-plugin  \
    --disable-multilib \
    --with-tune=generic \
    --build=${build_target} \
    --target=${build_target} \
    --host=${build_target} \
    --with-pkgversion="$packageversion"
#numproc=`cat /proc/cpuinfo |grep "processor"|wc -l  `
cd $gcc_build_dir
make -j 8  BOOT_CFLAGS="$OPT_FLAGS" $make_flags bootstrap
make install
_logs "gcc-${gcc_version} install "


# environment
cat << EOF > ${gcc_install_dir}/activate.sh
# source this script to bring gcc ${gcc_version} into your environment
export PATH=${gcc_install_dir}/bin:\$PATH
export LD_LIBRARY_PATH=${gcc_install_dir}/lib:${gcc_install_dir}/lib64:\$LD_LIBRARY_PATH
export LIBRARY_PATH=${gcc_install_dir}/lib:${gcc_install_dir}/lib64:\$LIBRARY_PATH
export C_INCLUDE_PATH=${gcc_install_dir}/include:\$C_INCLUDE_PATH
export MANPATH=${gcc_install_dir}/share/man:\$MANPATH
export INFOPATH=${gcc_install_dir}/share/info:\$INFOPATH
EOF


