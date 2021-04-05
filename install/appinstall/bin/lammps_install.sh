#!/bin/bash

# author: zhouzhuo
# create time: 2021/3/30
# update time: 2021/3/31

# description:
# this script use to install lammps
# status: commited

source ./conf/app.cfg
source ./func/func.sh

lammps_version=10Mar21
lammps_tarfile=lammps-${lammps_version}.tar.gz
lammps_source_dir=$source_dir/lammps-${lammps_version}
lammps_build_dir=$build_dir/lammps_build_${lammps_version}
lammps_install_dir=$install_dir/lammps/${lammps_version}

cmake=cmake/3.18.5
mpi=openmpi/4.0.5
gcc=
if [ ! -e $install_dir/$cmake/activate.sh ];then
     echo "$install_dir/$cmake/activate.sh"
    _log_abort "cmake $cmake not find"
fi

if [ ! -e $install_dir/$mpi/activate.sh ];then
    _log_abort "$mpi  not find"
fi

_check_source_build_dir $lammps_source_dir $build_dir
_check_install_dir lammps_install_dir

_download_file https://lammps.sandia.gov/tars/           $lammps_tarfile

if [ ! -e $tarfile_dir/$lammps_tarfile ];then
    _log_abort "$lammps_tarfile not find"
fi

_tips "unzip files"
_unzipfile $source_dir $tarfile_dir/$lammps_tarfile
_tips "start install lammps-$lammps_version"
source $install_dir/$cmake/activate.sh
source $install_dir/$mpi/activate.sh
cd $lammps_build_dir
cmake -DCMAKE_INSTALL_PREFIX=$lammps_install_dir $lammps_source_dir/cmake/
cmake --build . && make install
cd $lammps_source_dir/src
make serial -j 8 &> makeserial.log
make mpi -j 8 &> makempi.log
make -j 8 && make yes-all &> make.log

cp lmp_mpi lmp_serial  $lammps_install_dir/bin
_logs "lammps-$lammps_version compiled at $lammps_install_dir"
cat >$lammps_install_dir/activate.sh <<EOF
export PATH=$lammps_install_dir/bin:\$PATH
source $lammps_install_dir/etc/profile.d/lammps.sh
EOF
