#!/bin/bash
# author: zhouzhuo
# create time: 2021/1/21
# update time: 2021/3/21

# description:
# this script use to install cmake 3.18.5

# update log:
# 2021/1/21: created

source ./conf/app.cfg
source ./func/func.sh
cmake_version=3.18.5
cmake_tarfile=cmake-${cmake_version}.tar.gz
cmake_source_dir=$source_dir/cmake-${cmake_version}
cmake_build_dir=$build_dir/cmake_${cmake_version}_build
cmake_install_dir=$install_dir/cmake/${cmake_version}

_check_source_build_dir $cmake_source_dir $cmake_build_dir
_check_install_dir $cmake_install_dir
_download_file https://cmake.org/files/v3.18  $cmake_tarfile

_tips "unzip file"
_unzipfile $source_dir $tarfile_dir/$cmake_tarfile

_tips "start install cmake-${cmake_version} "
cd $cmake_build_dir
$cmake_source_dir/configure --prefix=$cmake_install_dir
make -j 8 && make install
_logs "cmake-${cmake_version} install at $cmake_install_dir "

cat >$cmake_install_dir/activate.sh <<EOF
# source this file to load cmake-${cmake_version} env
export PATH=$cmake_install_dir/bin:\$PATH
export LD_LIBRARY_PATH=$cmake_install_dir/lib64:\$LD_LIBRARY_PATH
export C_INLUDE_PTH=$cmake_install_dir/include:\$C_INLUDE_PTH
export MANPATH=$cmake_install_dir/share/man:\$MANPATH
EOF


