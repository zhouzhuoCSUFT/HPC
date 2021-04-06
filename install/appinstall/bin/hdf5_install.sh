#!/bin/bash

# author: zhouzhuo
# create time: 2021/3/25
# update time：2021/4/5
# description:
# this script use to install hdf5 base gcc compile
# status: commited

source ./conf/app.cfg
source ./func/func.sh

hdf5_version=1.10.2
hdf5_tarfile=hdf5-${hdf5_version}.tar.gz
hdf5_source_dir=$source_dir/hdf5-${hdf5_version}
hdf5_build_dir=$build_dir/hdf5_${hdf5_vserion}_build
hdf5_install_dir=$install_dir/hdf5/${hdf5_version}

_check_source_build_dir $hdf5_source_dir $hdf5_build_dir
_check_install_dir $hdf5_install_dir

_download_file https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.2/src/	$hdf5_tarfile

if [ ! -e $tarfile_dir/$hdf5_tarfile ];then
	_log_abort "$hdf5_tarfile not find"
fi

_tips "unzip file"
_unzipfile $source_dir $tarfile_dir/$hdf5_tarfile
_tips "start install hdf5"
cd $hdf5_build_dir
$hdf5_source_dir/configure --prefix=$hdf5_install_dir
make -j 8 && make install
_logs "hdf5-$hdf5_version install at $hdf5_install_dir"

cat > $hdf5_install_dir/activate.sh <<EOF
# source this scripts to load hdf5 env
export PATH=$hdf5_install_dir/bin:\$PATH
export LD_LIBRARY_PATH=$hdf5_install_dir/lib:\$LD_LIBRARY_PATH
export C_INCLUDE_PATH=$hdf5_install_dir/include:\$C_INCLUDE_PATH

EOF
