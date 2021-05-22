#!/usr/bin/bash

# author: zhouzhuo
# create time: 2021/5/21
# update time: 2021/5/22

# description:
# this script use to install curl-7.76.1
# status: commited

# update log:
# 2021/5/22: modified activate.sh file

source ./conf/app.cfg
source ./func/func.sh

curl_version=7.76.1
curl_tarfile=curl-${curl_version}.tar.xz
curl_source_dir=$source_dir/curl-${curl_version}
curl_build_dir=$build_dir/curl-${curl_version}_build
curl_install_dir=$install_dir/curl-${curl_version}

_check_source_build_dir $curl_source_dir $curl_build_dir
_check_install_dir $curl_install_dir
#_download_file https://curl.se/download   $curl_tarfile

if [ ! -e $tarfile_dir/$curl_tarfile ];then
        _log_abort "$curl_tarfile not find"
fi

_tips "unzip files"
_unzipfile $source_dir $tarfile_dir/$curl_tarfile

_tips "start install curl-${curl_version}"
cd $curl_build_dir
$curl_source_dir/configure --prefix=$curl_install_dir
make -j 8 &> make.log
make install &> install.log
_logs "curl-$curl_version installed at $curl_install_dir "

cat >$curl_install_dir/activate.sh <<EOF
# source this script to load curl-$curl_version env
export PATH=$curl_install_dir/bin:\$PATH
export LD_LIBRARY_PATH=$curl_install_dir/lib:\$LD_LIBRARY_PATH
export LIBRARY_PATH=$curl_install_dir/lib:\$LIBRARY_PATH
export C_INCLUDE_PATH=$curl_install_dir/include:\$C_INCLUDE_PATH
export MANPATH=$curl_install_dir/share/man:\$MANPATH
EOF
