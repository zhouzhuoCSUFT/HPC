#!/bin/bash
# author: zhouzhuo
# create time:2021/3/22
# update time:2021/4/6
# description:
# this script use to install gromacs-2020.4
# status: commited

source ./conf/app.cfg
source ./func/func.sh

mpi=openmpi/4.0.5
gcc=gcc/6.2.0
fftw=fftw/3.3.8
cmake=cmake/3.18.5
gromacs_version=2020.4
gromacs_tarfile=gromacs-${gromacs_version}.tar.gz
gromacs_source_dir=$source_dir/gromacs-${gromacs_version}
gromacs_build_dir=$build_dir/gromacs_${gromacs_version}_build
gromacs_install_dir=$install_dir/gromacs/${gromacs_version}

if [ ! -e $install_dir/$mpi/activate.sh ];then
    _log_abort "$mpi not find"
fi

if [ ! -e $install_dir/$gcc/activate.sh ];then
	echo "$install_dir/$gcc/activate.sh"
    _log_abort "$gcc not find"
fi

if [ ! -e $install_dir/$fftw/activate.sh ];then
    _log_abort "$fftw not find"
fi

if [ ! -e $install_dir/$cmake/activate.sh ];then
    _log_abort "$cmake not find"
fi

_check_source_build_dir $gromacs_source_dir $gromacs_build_dir
_check_install_dir $gromacs_install_dir

_download_file https://ftp.gromacs.org/gromacs/			$gromacs_tarfile

if [ ! -e $tarfile_dir/$gromacs_tarfile ];then
   _log_abort "$gromacs_tarfile  not find"
fi

_tips "unzip file"

_unzipfile $source_dir $tarfile_dir/$gromacs_tarfile
_tips "start install gromacs_${gromacs_version}"


source $install_dir/$mpi/activate.sh
source $install_dir/$gcc/activate.sh
source $install_dir/$fftw/activate.sh
source $install_dir/$cmake/activate.sh
echo $install_dir/$mpi/activate.sh
echo "cmake dir is $install_dir/$cmake"
which mpicc

cd $gromacs_build_dir
cmake $gromacs_source_dir -DGMX_BUILD_OWN_FFTW=ON -DREGRESSIONTEST_DOWNLOAD=ON \
		 -DCMAKE_C_COMPILER=mpicc -DCMAKE_CXX_COMPILER=mpicxx \
         -DGMX_MPI=on    \
		 -DCMAKE_PREFIX_PATH=$install_dir/$cmake \
         -DCMAKE_INSTALL_PREFIX=$gromacs_install_dir \
		 -DBUILD_SHARED_LIBS=on  -DGMX_FFT_LIBRARY=fftw3

make -j 8 && make install
_logs "gromacs-${gromacs_version} install at $gromacs_install_dir "

cat >$gromacs_install_dir/activate.sh <<EOF
# source this file to load gromacs-${gromacs_version} env
export PATH=$gromacs_install_dir/bin:\$PATH
export LD_LIBRARY_PATH=$gromacs_install_dir/lib64:\$LD_LIBRARY_PATH
export C_INLUDE_PTH=$gromacs_install_dir/include:\$C_INLUDE_PTH
export MANPATH=$gromacs_install_dir/share/man:\$MANPATH
EOF
