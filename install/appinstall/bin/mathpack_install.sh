#!/bin/bash

# author: zhouzhuo
# create time: 2021/3/31
# update time: 2021/4/10
# description:
# this script use to install common math libs including blas,lapack,openblas,libxc and scalapack
# status: commited

source ./conf/app.cfg
source ./func/func.sh

# scalapack need mpi enviroment
mpi=openmpi/4.0.5

blas_version=3.8.0
blas_tarfile=blas-${blas_version}.tgz
blas_source_dir=$source_dir/BLAS-${blas_version}
blas_install_dir=$install_dir/math/blas-${blas_version}

cblas_tarfile=cblas.tgz
cblas_source_dir=$source_dir/CBLAS
cblas_install_dir=$install_dir/math/CBLAS

lapack_version=3.8.0
lapack_tarfile=lapack-${lapack_version}.tar.gz
lapack_source_dir=$source_dir/lapack-${lapack_version}
lapack_install_dir=$install_dir/math/lapack-${lapack_version}

openblas_install_dir=$install_dir/math/OpenBlas

libxc_version=4.3.4
libxc_tarfile=libxc-${libxc_version}.tar.gz
libxc_source_dir=$source_dir/libxc-${libxc_version}
libxc_build_dir=$build_dir/libxc_${libxc_version}_build
libxc_install_dir=$install_dir/libxc_${libxc_version}

scalapack_version=2.0.2
# need not scalapack build dir
scalapack_tarfile=scalapack-${scalapack_version}.tgz
scalapack_source_dir=$source_dir/scalapack-$scalapack_version
scalapack_install_dir=$install_dir/math/scalapack-$scalapack_version


_check_source_build_dir $blas_source_dir $cblas_source_dir $lapack_source_dir $libxc_source_dir $libxc_build_dir $scalapack_source_dir
_check_install_dir $blas_install_dir $cblas_install_dir $lapack_install_dir $libxc_install_dir  $scalapack_install_dir

_download_file http://www.netlib.org/blas/   									 $blas_tarfile
_download_file http://www.netlib.org/blas/blast-forum/  						 $cblas_tarfile
_download_file http://www.netlib.org/lapack/									 $lapack_tarfile
_download_file https://www.tddft.org/programs/libxc/down/$libxc_version/		 $libxc_tarfile  
_download_file  http://www.netlib.org/scalapack/                                 $scalapack_tarfile


for f in $tarfile_dir/$blas_tarfile  $tarfile_dir/$cblas_tarfile $tarfile_dir/$lapack_tarfile $tarfile_dir/$libxc_tarfile $tarfile_dir/scalapack_tarfile
do
	if [ ! -e $f ];then
		_log_abort "$f not find: $tarfile_dir/$f"
	fi
done

_tips "unzip files"
_unzipfile $source_dir $tarfile_dir/$blas_tarfile
_unzipfile $source_dir $tarfile_dir/$cblas_tarfile
_unzipfile $source_dir $tarfile_dir/$lapack_tarfile
_unzipfile $source_dir $tarfile_dir/$libxc_tarfile
_unzipfile $source_dir $tarfile_dir/$scalapack_tarfile

_tips "start compiling blas-${blas_version}"
cd $blas_source_dir

gfortran -c  -O3  -fPIC  *.f
gcc -shared *.o -fPIC -o  libblas.so
mkdir $blas_install_dir/lib && mv libblas.so $blas_install_dir/lib

make clean >& /dev/null
gfortran -c  -O3 *.f  
ar rv libblas.a *.o 
cp libblas.a $blas_install_dir/lib
l
_logs "blas-${blas_version} compiled at $blas_install_dir"

_tips "start compiling cblas"

cp $blas_install_dir/lib/libblas.a $cblas_source_dir/testing/
cd $cblas_source_dir
cp Makefile.LINUX Makefile.in
make 
cp lib/cblas_LINUX.a lib/libcblas.a
mv lib $cblas_install_dir &&  mv include $cblas_install_dir
_logs "cblas compiled at $cblas_install_dir"

cd $lapack_source_dir
cp make.inc.example  make.inc
make blaslib -j 8
make cblaslib -j 8
make lapacklib -j 8
make lapackelib -j 8
make tmglib -j 8
mkdir $lapack_install_dir/lib && mv *.a  $lapack_install_dir/lib
_logs "lapack compiled at $lapack_install_dir"

_tips "start compiled OpenBlas"
cd $source_dir 
if [ ! -e $source_dir/OpenBLAS ];then
	git clone https://github.com/xianyi/OpenBLAS.git
else
	/bin/rm -rf $source_dir/OpenBLAS
	git clone https://github.com/xianyi/OpenBLAS.git	
fi

cd  $source_dir/OpenBLAS
make && make PREFIX=$openblas_install_dir  install
_logs "OpenBlas install at $openblas_install_dir"

_tips "start compiling libxc-${libxc_version}"
cd $libxc_build_dir
CC=gcc FC=gfortran $libxc_source_dir/configure --prefix=$libxc_install_dir
make -j 8 && make install
_logs "libxc-${libxc_version} compiled at $libxc_install_dir"

if [ ! -e $install_dir/$mpi/activate.sh ];then
    _log_abort "$mpi enviroment not find"
fi
if [ ! -e $blas_install_dir/lib/libblas.a ];then
    _log_abort "libblas.a not find"
fi

if [ ! -e $lapack_install_dir/lib/liblapack.a ];then
    _log_abort "liblapack.a not find"
fi

source $install_dir/$mpi/activate.sh

_tips "start compiling scalapack-$scalapack_version"
cd $scalapack_source_dir
cp  SLmake.inc.example  SLmake.inc
sed -ri '/FCFLAGS[[:space:]]*=[[:space:]]*-O3/cFCFLAGS\t=\t-O3 -fPIC' SLmake.inc
sed -ri '/NOOPT[[:space:]]*=[[:space:]]*-O0/cNOOPT\t=\t-O0 -fPIC' SLmake.inc
sed -ri '/CCFLAGS[[:space:]]*=[[:space:]]*-O3/cCCFLAGS\t=\t-O3 -fPIC' SLmake.inc
sed -ri "/BLASLIB[[:space:]]*=[[:space:]]*-lblas/cBLASLIB=-L$blas_install_dir/lib  -lblas" SLmake.inc
sed -ri '/LAPACKLIB[[:space:]]*=[:space:]]*-llapack/cLAPACKLIB=-Llapack_install_dir/lib -llapack' SLmake.inc
make -j 8 &> make.log
mkdir $scalapack_install_dir/lib && cp libscalapack.a $scalapack_install_dir/lib
_logs "scalapack-$scalapack_version compiled at $$scalapack_install_dir"