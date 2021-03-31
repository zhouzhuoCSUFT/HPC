#!/bin/bash

# author: zhouzhuo
# create time: 2021/3/23
# update time: 2021/3/23

# this scripts use to install fftw 3.3.8

source ./conf/app.cfg
source ./func/func.sh
fftw_version=3.3.8
fftw_tarfile=fftw-${fftw_version}.tar.gz
fftw_source_dir=$source_dir/fftw-${fftw_version}
fftw_build_dir=$build_dir/fftw-${fftw_version}_build
fftw_install_dir=$install_dir/fftw/${fftw_version}

mpi=openmpi/4.0.5

_check_source_build_dir $fftw_source_dir $fftw_build_dir
_check_install_dir  $fftw_install_dir

_download_file http://www.fftw.org/			$fftw_tarfile

if [ ! -e $tarfile_dir/$fftw_tarfile ];then
	_log_abort "$fftw_tarfile not find"
fi
_tips "unzip file"

_unzipfile $source_dir $tarfile_dir/$fftw_tarfile 

if [ ! -e $install_dir/$mpi/activate.sh ];then
    _log_abort "mpi not find"
fi

source $install_dir/$mpi/activate.sh

_tips "start install fftw-${fftw_version}"

cd $fftw_build_dir
$fftw_source_dir/configure --prefix=$fftw_install_dir  --enable-openmp --enable-mpi --enable-shared  &> config_fftw.log
make -j 8 &> make_fftw.log
make install &> install_fftw.log
_logs "fftw-${fftw_version} install at $fftw_install_dir"

cat > $fftw_install_dir/activate.sh << EOF
# source this scripts to load fftw-${fftw_version} env
export C_INCLUDE_PATH=$fftw_install_dir/include:\$C_INCLUDE_PATH
export LD_LIBRARY_PATH=$fftw_install_dir/lib:\$LD_LIBRARY_PATH
export PATH=$fftw_install_dir/bin:\$PATH
export INFOPATH=$fftw_install_dir/share/info:\$INFOPATH
export MANPATH=$fftw_install_dir/share/man:\$MANPATH

EOF
