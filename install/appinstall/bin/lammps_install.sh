#!/bin/bash

# author: zhouzhuo
# create time: 2021/3/30
# update time: 2021/5/22

# description:
# this script use to install lammps
# status: commited

# update log:
# 2021/5/22: add all of offical module

source ./conf/app.cfg
source ./func/func.sh

lammps_version=10Mar21
lammps_tarfile=lammps-${lammps_version}.tar.gz
lammps_source_dir=$source_dir/lammps-${lammps_version}
lammps_build_dir=$build_dir/lammps_build_${lammps_version}
lammps_install_dir=$install_dir/lammps/${lammps_version}

cmake=cmake/3.18.5
mpi=openmpi/4.0.5
python=python/3.8.8
gcc=gcc/8.4.0
hdf5=hdf5/1.10.2
curl=curl-7.76.1

if [ ! -e $install_dir/$cmake/activate.sh ];then
     echo "$install_dir/$cmake/activate.sh"
    _log_abort "cmake $cmake not find"
fi

if [ ! -e $install_dir/$mpi/activate.sh ];then
    _log_abort "$mpi  not find"
fi

if [ ! -e $install_dir/$curl/activate.sh ];then
    _log_abort "$curl  not find"
fi

if [ ! -e $install_dir/$gcc/activate.sh ];then
    _log_abort "$gcc  not find"
fi

if [ ! -e $install_dir/$hdf5/activate.sh ];then
    _log_abort "$hdf5  not find"
fi

_check_source_build_dir $lammps_source_dir $lammps_build_dir
_check_install_dir $lammps_install_dir

_download_file https://lammps.sandia.gov/tars/           $lammps_tarfile

if [ ! -e $tarfile_dir/$lammps_tarfile ];then
    _log_abort "$lammps_tarfile not find"
fi

_tips "unzip files"
_unzipfile $source_dir $tarfile_dir/$lammps_tarfile
_tips "start install lammps-$lammps_version"
source $install_dir/$cmake/activate.sh
source $install_dir/$mpi/activate.sh
#source $install_dir/$python/activate.sh
source $install_dir/$curl/activate.sh
source $install_dir/$gcc/activate.sh
source $install_dir/$hdf5/activate.sh

cd $lammps_build_dir
# Thanks for Yang Yuseng  provide cmake method. 
cmake   -D CMAKE_INSTALL_PREFIX=$lammps_install_dir $lammps_source_dir/cmake/ \
        -D BUILD_OMP=yes \
        -D DOWNLOAD_MSCG=yes \
        -D DOWNLOAD_KIM=yes \
        -D DOWNLOAD_PLUMED=yes \
        -D DOWNLOAD_SCAFACOS=yes \
        -D DOWNLOAD_EIGEN3=yes \
        -D CMAKE_CXX_FLAGS:STRING=-fPIC \
        -D CMAKE_C_FLAGS:STRING=-fPIC \
        -D CMAKE_EXE_LINKER_FLAGS:STRING=-fPIC \
        -D CMAKE_Fortran_FLAGS:STRING=-fPIC \
        -D BUILD_TOOLS:BOOL=yes \
        -D BUILD_MPI:BOOL=yes \
        -D PKG_USER-EFF=yes \
        -D PKG_COMPRESS=yes \
        -D PKG_USER-FEP=yes \
        -D PKG_MESSAGE=yes \
        -D PKG_MPIIO=yes \
        -D PKG_POEMS=yes \
        -D PKG_KIM=yes \
        -D PKG_USER-ATC=yes \
        -D PKG_USER-COLVARS=yes \
        -D PKG_USER-H5MD=yes \
        -D PKG_USER-LB=yes \
        -D PKG_USER-MESONT=yes \
        -D PKG_USER-MOLFILE=yes \
        -D PKG_USER-QMMM=yes \
        -D PKG_USER-SMD=yes \
        -D PKG_USER-AWPMD=yes \
        -D PKG_USER-BOCS=yes \
        -D PKG_USER-CGDNA=yes \
        -D PKG_USER-CGSDK=yes \
        -D PKG_USER-DIFFRACTION=yes \
        -D PKG_USER-DPD=yes \
        -D PKG_USER-DRUDE=yes \
        -D PKG_USER-INTEL=yes \
        -D PKG_USER-MANIFOLD=yes \
        -D PKG_USER-MEAMC=yes \
        -D PKG_USER-MESODPD=yes \
        -D PKG_USER-MGPT=yes \
        -D PKG_USER-MISC=yes \
        -D PKG_USER-MOFFF=yes \
        -D PKG_USER-OMP=yes \
        -D PKG_USER-PHONON=yes \
        -D PKG_USER-PTM=yes \
        -D BUILD_LIB=yes \
        -D BUILD_SHARED_LIBS=yes \
        -D PKG_USER-QTB=yes \
        -D PKG_USER-REACTION=yes \
        -D PKG_USER-REAXC=yes \
        -D PKG_USER-SDPD=yes \
        -D PKG_USER-SMTBQ=yes \
        -D PKG_USER-SPH=yes \
        -D PKG_USER-TALLY=yes \
        -D PKG_USER-UEF=yes \
        -D PKG_USER-YAFF=yes \
        -D PKG_ASPHERE=yes \
        -D PKG_CORESHELL=yes \
        -D PKG_DEPEND=yes \
        -D PKG_BODY=yes \
        -D PKG_DIPOLE=yes \
        -D PKG_CLASS2=yes \
        -D PKG_COLLOID=yes \
        -D PKG_fmt=yes \
        -D PKG_GRANULAR=yes \
        -D PKG_KSPACE=yes \
        -D PKG_MANYBODY=yes \
        -D PKG_MC=yes \
        -D PKG_MISC=yes \
        -D PKG_MLIAP=yes \
        -D PKG_MOLECULE=yes \
        -D PKG_OPT=yes \
        -D PKG_STUBS=yes \
        -D PKG_SRD=yes \
        -D PKG_SPIN=yes \
        -D PKG_SNAP=yes \
        -D PKG_SHOCK=yes \
        -D PKG_RIGID=yes \
        -D PKG_REPLICA=yes \
        -D PKG_QEQ=yes \
        -D PKG_PYTHON=yes \
        -D PKG_PERI=yes  \
         $lammps_source_dir/cmake &> cmake.log

make -j 8 &> make.log
make install &> install.log
#cmake --build . && make install
#cd $lammps_source_dir/src
#make serial -j 8 &> makeserial.log
#make mpi -j 8 &> makempi.log
#make -j 8 && make yes-all &> make.log

#cp lmp_mpi lmp_serial  $lammps_install_dir/bin
_logs "lammps-$lammps_version compiled at $lammps_install_dir"
cat >$lammps_install_dir/activate.sh <<EOF
export LD_LIBRARY_PATH=$lammps_install_dir/lib64:\$LD_LIBRARY_PATH
export C_INCLUDE_PATH=$lammps_install_dir/lib64:\$C_INCLUDE_PATH
export PATH=$lammps_install_dir/bin:\$PATH
source $lammps_install_dir/etc/profile.d/lammps.sh
source $install_dir/$mpi/activate.sh
source $install_dir/$gcc/activate.sh
source $install_dir/$hdf5/activate.sh
EOF
