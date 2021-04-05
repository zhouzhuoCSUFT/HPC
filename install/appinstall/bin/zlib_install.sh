#!/bin/bash

# author: zhouzhuo
# create time: 2021/4/4
# update time: 2021/4/4
# description:
# this script use to install zlib-1.2.11
# status: commited

source ./conf/app.cfg
source ./func/func.sh
# only support install zlib-1.2.11

zlib_version=1.2.11
zlib_tarfile=zlib-${zlib_version}.tar.gz
zlib_source_dir=$source_dir/zlib-${zlib_version}
zlib_build_dir=$build_dir/zlib-${zlib_version}_build
zlib_install_dir=$install_dir/zlib/${zlib_version}

_check_source_build_dir $zlib_source_dir $zlib_build_dir
_check_install_dir $zlib_install_dir
_tips "downloading $zlib_tarfile"
_download_file https://nchc.dl.sourceforge.net/project/libpng/zlib/1.2.11/ 	$zlib_tarfile
_tips "unzip file "
_unzipfile $source_dir $tarfile_dir/$zlib_tarfile

cd $zlib_build_dir
$zlib_source_dir/configure --prefix=$zlib_install_dir
make && make install
_logs "zlib-${zlib_version} install at ${zlib_install_dir} "

cat >> $zlib_install_dir/activate.sh <<EOF
# source this scripts to load zlib-${zlib_version} env"
export LD_LIBRARY=$zlib_install_dir/lib:\$LD_LIBRARY
export C_INCLUDE_PATH=$zlib_install_dir/include:\$C_INCLUDE_PATH
export MANPATH=$zlib_install_dir/share/man:\$MANPATH
EOF


