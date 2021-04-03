#!/bin/bash
# author:zhouzhuo
# create time: 2020/3/27
# update time: 2020/4/2

# description:
# this script use to install gcc require components including gmp,mpfr,mpc,isl and binutils
# status: pre-commit

source ./conf/app.cfg
source ./func/func.sh

# define versions
gcc_version=$1
gmp_version=6.1.2
mpfr_version=3.1.4
mpc_version=1.0.3
isl_version=0.18
binutils_version=2.31

# app tarfile 
gmp_tarfile=gmp-${gmp_version}.tar.bz2
mpfr_tarfile=mpfr-${mpfr_version}.tar.bz2
mpc_tarfile=mpc-${mpc_version}.tar.gz
isl_tarfile=isl-${isl_version}.tar.bz2
binutils_tarfile=binutils-${binutils_version}.tar.gz

# app build dir 
gmp_build_dir=$build_dir/gmp_${gmp_version}_build
mpfr_build_dir=$build_dir/mpfr_${mpfr_version}_build
mpc_build_dir=$build_dir/mpc_${mpc_version}_build
isl_build_dir=$build_dir/isl_${isl_version}_build
binutils_build_dir=$build_dir/binutils_${binutils_version}_build

# define app source dir
gmp_source_dir=$source_dir/gmp-${gmp_version}
mpfr_source_dir=$source_dir/mpfr-${mpfr_version}
mpc_source_dir=$source_dir/mpc-${mpc_version}
isl_source_dir=$source_dir/isl-${isl_version}
binutils_source_dir=$source_dir/binutils-${binutils_version}

# test app source dir and build dir 
_check_source_build_dir  $gmp_source_dir $mpfr_source_dir $mpc_source_dir $isl_source_dir $binutils_source_dir $gmp_build_dir $mpfr_build_dir $mpc_build_dir $isl_build_dir $binutils_build_dir

# test app install dir 
gmp_install_dir=$install_dir/gmp/${gmp_version}-gcc_${gcc_version}
mpfr_install_dir=$install_dir/mpfr/${mpfr_version}-gcc_${gcc_version}
mpc_install_dir=$install_dir/mpc/${mpc_version}-gcc_${gcc_version}
isl_install_dir=$install_dir/isl/${isl_version}-gcc_${gcc_version}
binutils_install_dir=$install_dir/binutils/${binutils_version}-gcc_${gcc_version}

_check_install_dir  $gmp_install_dir $mpfr_install_dir $mpc_install_dir $isl_install_dir $binutils_install_dir

# check gcc version
current_gcc_version=`gcc --version | head -1 | awk '{print $3}'`
_tips "Current Gcc version is $current_gcc_version"
if [ "$current_gcc_version" != "$gcc_version" ];then
	if [ ! -e $install_dir/gcc/$gcc_version ];then
		_log_abort "Gcc $gcc_version not find. "
	else
		_tips "source $install_dir/gcc/$gcc_version/activate.sh"
		source $install_dir/gcc/$gcc_version/activate.sh 
		current_gcc_version=`gcc --version | head -1 | awk '{print $3}'`
		_tips "Current Gcc version is $current_gcc_version"
	fi
fi

# download app tarfile 
_download_file https://gmplib.org/download/gmp              $gmp_tarfile
_download_file https://ftp.gnu.org/gnu/mpfr                 $mpfr_tarfile
_download_file http://www.multiprecision.org/downloads      $mpc_tarfile
_download_file ftp://gcc.gnu.org/pub/gcc/infrastructure     $isl_tarfile
_download_file https://ftp.gnu.org/gnu/binutils/			$binutils_tarfile

# check apptarfile 
for f in $gmp_tarfile $mpfr_tarfile $mpc_tarfile $isl_tarfile $binutils_tarfile;
do
	if [ ! -f "$tarfile_dir/$f" ]; then
        _log_abort "tarfile not found: $tarfile_dir/$f"
    fi
done

# unzip app tarfile
_tips "unzip files"
for f in $gmp_tarfile $mpfr_tarfile $mpc_tarfile $isl_tarfile $binutils_tarfile;
do
	_unzipfile $source_dir $tarfile_dir/$f
done

# install gmp
_tips "start install gmp-$gmp_version"
cd $gmp_build_dir
$gmp_source_dir/configure --prefix=$gmp_install_dir
make -j 8 && make install
_logs "gmp-${gmp_version} installed at $gmp_install_dir "

# write env 
cat >> $gmp_install_dir/activate.sh <<EOF
# source this scripts to load gmp_$gmp_version env.
export LD_LIBRARY_PATH=$gmp_install_dir/lib:\$LD_LIBRARY_PATH
export INCLUDE_PATH=$gmp_install_dir/include:\$INCLUDE_PATH
EOF
_tips "end install gmp_${gmp_version}"

# install mpfr
_tips "start install mpfr_${mpfr_version}"
if [ ! -e $gmp_install_dir/lib ];then
	_log_abort "gmp_$gmp_version not installed"
fi
cd $mpfr_build_dir
$mpfr_source_dir/configure  --with-gmp=$gmp_install_dir  --prefix=$mpfr_install_dir
make -j 8 && make install
_logs "mpfr-${mpfr_version} installed at $mpfr_install_dir "

#wirte env
cat >> $mpfr_install_dir/activate.sh <<EOF
# source this scripts to load mpfr_$mpfr_version env.
export LD_LIBRARY_PATH=$mpfr_install_dir/lib:$LD_LIBRARY_PATH
export INCLUDE_PATH=$mpfr_install_dir/include:$INCLUDE_PATH
EOF
_tips "end install mpfr_${mpfr_version}"

# install mpc
_tips "start install mpc_${mpc_version}"
if [ ! -e $mpfr_install_dir/lib ];then
	_log_abort "mpfr_$mpfr_version not installed"
fi
cd $mpc_build_dir 
$mpc_source_dir/configure --with-gmp=$gmp_install_dir  --with-mpfr=$mpfr_install_dir --prefix=$mpc_install_dir
make -j 8 && make install
_logs "mpc-${mpc_version} installed at $mpc_install_dir "
# write env
cat >> $mpc_install_dir/activate.sh <<EOF
# source this scripts to load mpc_$mpc_version env.
export LD_LIBRARY_PATH=$mpc_install_dir/lib:$LD_LIBRARY_PATH
export INCLUDE_PATH=$mpc_install_dir/include:$INCLUDE_PATH
EOF
_tips "end install mpc_${mpc_version}"

# install isl
_tips "start install isl_${isl_version}"
if [ ! -e $gmp_install_dir ];then
	_log_abort "gmp_$gmp_version not installed"
fi
cd $isl_build_dir 
$isl_source_dir/configure --with-gmp=gmp_install_dir  --prefix=$isl_install_dir
make -j 8 && make install
_logs "isl-${isl_version} installed at $isl_install_dir "
# wirte env
cat >> $isl_install_dir/activate.sh <<EOF
# source this scripts to load isl_$isl_version env.
export LD_LIBRARY_PATH=$isl_install_dir/lib:$LD_LIBRARY_PATH
export INCLUDE_PATH=$isl_install_dir/include:$INCLUDE_PATH
EOF
_tips "end install mpc_${mpc_version}"

# install binutils
_tips "start install binutils_${binutils_version}"
if [ ! -e $isl_install_dir ];then
	_log_abort "isl_${isl_version} not installed"
fi
unset LD_LIBRARY_PATH
unset C_INCLUDE_PATH
unset PATH
export PATH=/usr/local/bin:/usr/bin:/bin:/sbin:/usr/sbin

current_gcc_version=`gcc --version | head -1 | awk '{print $3}'`
_tips "current gcc version is $current_gcc_version"

cd $binutils_build_dir
$binutils_source_dir/configure --with-gmp=$gmp_install_dir --with-mpfr=$mpfr_install_dir --with-mpc=$mpc_install_dir --with-isl=$isl_install_dir --prefix=$binutils_install_dir

# note: binutils use `make -j N	` may cause compiling  fail
make && make install
_logs "binutils-${binutils_version} installed at $binutils_install_dir "
# write env
cat >> $binutils_install_dir/activate.sh <<EOF
# source this scripts to load mpfr_$binutils_version env.
export LD_LIBRARY_PATH=$binutils_install_dir/lib:$LD_LIBRARY_PATH
export INCLUDE_PATH=$binutils_install_dir/include:$INCLUDE_PATH
export PATH=$binutils_install_dir/bin:\$PATH
export MANPATH=$binutils_install_dir/share/man:\$MANPATH
export INFOPATH=$binutils_install_dir/share/info:\$INFOPATH
EOF
_tips "end install binutils_${binutils_version}"
_logs "Gcc requires component installed "