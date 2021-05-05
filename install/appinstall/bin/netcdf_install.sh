#!/bin/bash
# author:zhouzhuo
# create time: 2021/3/29
# update time: 2021/4/9
# desription:
# this scripts use to install netcdf including C/C++/Fortran version
# status: commited

source ./conf/app.cfg
source ./func/func.sh

mpi=openmpi/4.0.5
hdf5=hdf5/1.10.2

pnetcdf_version=1.12.1
pnetcdf_tarfile=pnetcdf-${pnetcdf_version}.tar.gz
pnetcdf_source_dir=$source_dir/pnetcdf-${pnetcdf_version}
pnetcdf_build_dir=$build_dir/pnetcdf_${pnetcdf_version}_build
pnetcdf_install_dir=$install_dir/pnetcdf/${pnetcdf_version}


netcdf_c_version=4.7.4
netcdf_c_tarfile=netcdf-c-${netcdf_c_version}.tar.gz
netcdf_c_source_dir=$source_dir/netcdf-c-${netcdf_c_version}
netcdf_c_build_dir=$build_dir/netcdf_c_${netcdf_c_version}_build
netcdf_c_install_dir=$install_dir/netcdf-c/${netcdf_c_version}

netcdf_cxx_version=4.3.1
netcdf_cxx_tarfile=netcdf-cxx4-${netcdf_cxx_version}.tar.gz
netcdf_cxx_source_dir=$source_dir/netcdf-cxx4-${netcdf_cxx_version}
netcdf_cxx_build_dir=$build_dir/netcdf_cxx_${netcdf_cxx_version}_build
netcdf_cxx_install_dir=$install_dir/netcdf-cxx/${netcdf_cxx_version}

netcdf_fortran_version=4.5.3
netcdf_fortran_tarfile=netcdf-fortran-${netcdf_fortran_version}.tar.gz
netcdf_fortran_source_dir=$source_dir/netcdf-fortran-${netcdf_fortran_version}
netcdf_fortran_build_dir=$build_dir/netcdf_fortran_${netcdf_fortran_version}_build
netcdf_fortran_install_dir=$install_dir/netcdf-fortran/${netcdf_fortran_version}

_check_source_build_dir $netcdf_c_source_dir $netcdf_cxx_source_dir $netcdf_fortran_source_dir $netcdf_c_build_dir $netcdf_cxx_build_dir $netcdf_fortran_build_dir $pnetcdf_source_dir $pnetcdf_build_dir 
_check_install_dir $netcdf_c_install_dir $netcdf_cxx_install_dir $netcdf_fortran_install_dir $pnetcdf_install_dir

_download_file https://www.unidata.ucar.edu/downloads/netcdf/ftp/			$netcdf_c_tarfile
_download_file https://www.unidata.ucar.edu/downloads/netcdf/ftp/			$netcdf_cxx_tarfile
_download_file https://www.unidata.ucar.edu/downloads/netcdf/ftp/			$netcdf_fortran_tarfile
_download_file http://cucis.ece.northwestern.edu/projects/PnetCDF/Release/ 	$pnetcdf_tarfile
for f in $pnetcdf_tarfile $netcdf_c_tarfile  $netcdf_cxx_tarfile  $netcdf_fortran_tarfile 
do
	if [ ! -e $tarfile_dir/$f ];then
		_log_abort "$f not find"
	fi
done	

_tips "unzip file"
for f in $pnetcdf_tarfile $netcdf_c_tarfile  $netcdf_cxx_tarfile  $netcdf_fortran_tarfile
do
	_unzipfile $source_dir  $tarfile_dir/$f
done

_tips "start install pnetcdf-${pnetcdf_version}"
if [ ! -e $install_dir/$mpi/activate.sh ];then
	_log_abort "mpi not find"
fi
source $install_dir/$mpi/activate.sh
cd $pnetcdf_build_dir
CC=mpicc CXX=mpicxx FC=mpif90 $pnetcdf_source_dir/configure --prefix=$pnetcdf_install_dir
make -j 8 && make install
_logs "pnetcdf-${pnetcdf_version} installed at $pnetcdf_install_dir"
cat > $pnetcdf_install_dir/activate.sh << EOF
# source this scripts to load pnetcdf-${pnetcdf_version} env
export C_INCLUDE_PATH=$pnetcdf_install_dir/include:\$C_INCLUDE_PATH
export LD_LIBRARY_PATH=$pnetcdf_install_dir/lib:\$LD_LIBRARY_PATH
export PATH=$pnetcdf_install_dir/bin:\$PATH
export MANPATH=$pnetcdf_install_dir/share/man:\$MANPATH
EOF

_tips "start install netcdf-c-${netcdf_c_version}"
cd $netcdf_c_build_dir
CC=mpicc FC=mpif90 CPPFLAGS="-I$install_dir/$hdf5/include" \
	LDFLAGS="-L$install_dir/$hdf5/lib" LD_LIBRARY_PATH=$install_dir/$hdf5/lib \
	LIBS="-lhdf5_hl -lhdf5 " $netcdf_c_source_dir/configure --prefix=$netcdf_c_install_dir
make -j 8 && make install
_logs "netcdf-c-${netcdf_c_version} install at $netcdf_c_install_dir"
cat > $netcdf_c_install_dir/activate.sh << EOF
# source this scripts to load netcdf-c-${netcdf_c_version} env
export C_INCLUDE_PATH=$netcdf_c_install_dir/include:\$C_INCLUDE_PATH
export LD_LIBRARY_PATH=$netcdf_c_install_dir/lib:\$LD_LIBRARY_PATH
export LIBRARY_PATH=$netcdf_c_install_dir/lib:\$LIBRARY_PATH
export PATH=$netcdf_c_install_dir/bin:\$PATH
export MANPATH=$netcdf_c_install_dir/share/man:\$MANPATH
EOF

_tips "start install netcdf-fortran-${netcdf_fortran_version}"
source  $netcdf_c_install_dir/activate.sh 
cd $netcdf_fortran_build_dir
CC=mpicc FC=mpif90 CPPFLAGS="-I$install_dir/$hdf5/include" \
	LDFLAGS="-L$install_dir/$hdf5/lib" LD_LIBRARY_PATH=$install_dir/$hdf5/lib:$LD_LIBRARY_PATH \
	LIBS="-lhdf5_hl -lhdf5 " $netcdf_fortran_source_dir/configure --prefix=$netcdf_fortran_install_dir
make -j8 && make install
_logs "netcdf_fortran-${netcdf_fortran_version} install at $netcdf_fortran_install_dir"
cat >$netcdf_fortran_install_dir/activate.sh <<EOF
# source this scripts to load $netcdf_fortran-${netcdf_fortran_version} env
export C_INCLUDE_PATH=$netcdf_fortran_install_dir/include:\$C_INLUDE_PATH
export LD_LIBRARY_PATH=$netcdf_fortran_install_dir/lib:\$LD_LIBRARY_PATH
export PATH=$netcdf_fortran_install_dir/bin:\$PATH
export MANPATH=$netcdf_fortran_install_dir/share/man:\$MANPATH
EOF

_tips "start install netcdf-cxx-${netcdf_cxx_version}"
cd $netcdf_cxx_build_dir
CC=mpicc FC=mpif90 CPPFLAGS="-I$install_dir/$hdf5/include -I$netcdf_c_install_dir/include" LDFLAGS="-L$install_dir/$hdf5/lib" \
	LD_LIBRARY_PATH=$install_dir/$hdf5/lib:$LD_LIBRARY_PATH LIBS="-lhdf5_hl -lhdf5 " \
	$netcdf_cxx_source_dir/configure --prefix=$netcdf_cxx_install_dir
make -j8 && make install
_logs "netcdf-cxx-${netcdf_cxx_version} intall at $netcdf_cxx_install_dir"
cat >$netcdf_cxx_install_dir/activate.sh <<EOF
# source this scripts to load netcdf-cxx-${netcdf_cxx_version} env
export C_INCLUDE_PATH=$netcdf_cxx_install_dir/include:\$C_INLUDE_PATH
export LD_LIBRARY_PATH=$netcdf_cxx_install_dir/lib:\$LD_LIBRARY_PATH
export PATH=$netcdf_cxx_install_dir/bin:\$PATH
export MANPATH=$netcdf_cxx_install_dir/share/man:\$MANPATH
EOF

