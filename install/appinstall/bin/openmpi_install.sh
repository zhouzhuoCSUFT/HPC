#!/bin/bash

# author: zhouzhuo
# create time: 2021/3/21
# update time: 2021/4/1
#
# update log:
# 2021/3/30: add configure parameter: --enable-mpi1-compatibility
# 2021/4/1: add configure parameter: --without-verbs
# note:
# In openmpi 4+,  there may be a warning such as:
# Open MPI 4.0 and later, infiniband ports on a device are not used by default.
# The intent is to use UCX for these devices.
# You can override this policy by setting the btl_openib_allow_ib MCA parameter to true.
# 1、use --without-verbs will prevent building the openib BTL in the first place
# 2、use `mpirun --mca btl '^openib' ...` instead of  `mpirun ...`

source ./conf/app.cfg
source ./func/func.sh

now=`date +%m-%d-%H%M`
mkdir $recycle_dir/$now/

openmpi_version=$1
opempi_tarfile=openmpi-${openmpi_version}.tar.gz
openmpi_source_dir=$source_dir/openmpi-$openmpi_version
openmpi_bulid_dir=$build_dir/openmpi_${openmpi_version}_build
openmpi_install_dir=$install_dir/openmpi/${openmpi_version}

support_version="4.0.0 4.0.1 4.0.3 4.0.4 4.0.5"
if [ !`echo $support_version | grep $openmpi_version` ];then
	_log_abort "the $openmpi_version not support. you can intall versions:$support_version"
fi

echo $openmpi_source_dir
_check_source_build_dir $openmpi_source_dir $openmpi_bulid_dir
_check_install_dir $openmpi_install_dir

if [ ! -e $tarfile_dir/$tarfile ];then
	 _download_file https://download.open-mpi.org/release/open-mpi/v4.0   $opempi_tarfile
else
	_tips "$tarfile already download."
fi

_unzipfile $source_dir $tarfile_dir/$opempi_tarfile

cd $openmpi_bulid_dir
$openmpi_source_dir/configure --enable-mpi1-compatibility --without-verbs --prefix=$openmpi_install_dir &> config.log

make -j 8 && make install &> make.log

_logs "openmpi-${version} installed at $openmpi_install_dir"

cat >> $openmpi_install_dir/activate.sh <<EOF
export PATH=$targetdir/bin:\$PATH
export LD_LIBRARY_PATH=$targetdir/lib:\$LD_LIBRARY_PATH
export C_INCLUDE_PATH=$targetdir/include:\$C_INCLUDE_PATH
export MANPATH=${targetdir}/share/man:\$MANPATH
export INFOPATH=${targetdir}/share/info:\$INFOPATH
EOF

