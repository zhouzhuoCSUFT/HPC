#!/bin/bash

# author: zhouzhuo
# create time: 2021/4/3
# update time: 2021/4/8
# description:
# this script use to install python3
# status: commited

source ./conf/app.cfg
source ./func/func.sh

python3_version=3.8.8
python3_tarfile=Python-${python3_version}.tar.xz
python3_source_dir=$source_dir/Python-$python3_version
python3_install_dir=$install_dir/python/$python3_version

_check_source_build_dir $python3_source_dir
_check_install_dir $python3_install_dir

_download_file    https://www.python.org/ftp/python/3.8.8/   $python3_tarfile
if [ ! -e $tarfile_dir/$python3_tarfile ];then
    _log_abort "python3_tarfile not find"
fi

if [ ! -e /usr/bin/openssl ];then
    _log_abort "openssl not find."
fi

_tips "unzip file"
_unzipfile $source_dir $tarfile_dir/$python3_tarfile
_tips "start install python3-$python3_version"

cd $python3_source_dir
./configure --prefix=$python3_install_dir  -with-openssl=/usr/bin/openssl &> config.log
make -j 8 &> make.log
make install &> install.log
_logs "python-$python3_version installed at $python3_install_dir "
cat > $python3_install_dir/activate.sh <<EOF
# source this script to load python-$python3_version
export PATH=$python3_install_dir/bin:\$PATH
export INCLUDE_PATH=$python3_install_dir/include:\$INCLUDE_PATH
export LIBRARY_PATH=$python3_install_dir/lib:\$LIBRARY_PATH
export MANPATH=$python3_install_dir/share/man:\$MANPATH
EOF


