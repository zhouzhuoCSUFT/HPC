#!/usr/bin/bash
# author: zhouzhuo
# create time: 2021/5/21
# update time: 2021/5/22

# description:
# this script use to install openssl-1.1.1c
# status: commited
# update log:
# 2021/5/22: modified activate.sh file


source ./conf/app.cfg
source ./func/func.sh

openssl_version=1.1.1c
openssl_tarfile=openssl-${openssl_version}.tar.gz
openssl_source_dir=$source_dir/openssl-${openssl_version}
openssl_build_dir=$build_dir/openssl-${openssl_version}_build
openssl_install_dir=$install_dir/openssl-${openssl_version}

_check_source_build_dir $openssl_source_dir $openssl_build_dir
_check_install_dir $openssl_install_dir
#_download_file https://www.openssl.org/source/    $openssl_tarfile

if [ ! -e $tarfile_dir/$openssl_tarfile ];then
    echo "$tarfile_dir/$openssl_tarfile"
    _log_abort "$openssl_tarfile not find"
fi

_tips "unzip files"
_unzipfile $source_dir $tarfile_dir/$openssl_tarfile

_tips "start install openssl-${openssl_version}"
cd $openssl_build_dir
$openssl_source_dir/config --prefix=$openssl_install_dir &> configure.log
make -j 8 &> make.log
make install &> install.log
_logs "openssl-$openssl_version installed at $openssl_install_dir "

cat >$openssl_install_dir/activate.sh <<EOF
export PATH=$openssl_install_dir/bin:\$PATH
export LD_LIBRARY_PATH=$openssl_install_dir/lib:\$LD_LIBRARY_PATH
export LIBRARY_PATH=$openssl_install_dir/lib:\$LIBRARY_PATH
export C_INCLUDE_PATH=$openssl_install_dir/include:\$C_INCLUDE_PATH
export MANPATH=$openssl_install_dir/share/man:\$MANPATH
EOF
