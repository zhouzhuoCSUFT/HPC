#!/bin/bash

# author: zhouzhuo
# create time: 2021/3/21
# update time: 2021/3/21

source ./conf/app.cfg
source ./func/func.sh

now=`date +%m-%d-%H%M`
mkdir $recycle_dir/$now/

version=$1
tarfile=openmpi-${version}.tar.gz
targetdir=$install_dir/openmpi/${version}
builddir=$build_dir/openmpi_${version}_build
support_version="4.0.0 4.0.1 4.0.3 4.0.4 4.0.5"
if [ ! `echo $support_version | grep $version` ];then
	_log_abort "the $version not support. you can intall versions:$support_version"
fi
	
 
for  dir in $targetdir $builddir $source_dir/openmpi-${version}; do
	if [ ! -e $dir ];then
		mkdir -p $dir 
	else
		_tips "$dir already exists,mv $targetdir to $recycle_dir"
		mv $dir $recycle_dir/$now/
   		mkdir -p $dir 
	fi
done


if [ ! -e $tarfile_dir/$tarfile ];then
	 _download_file https://download.open-mpi.org/release/open-mpi/v4.0   $tarfile
else
	_tips "$tarfile already download."
fi

_unzipfile $source_dir $tarfile_dir/$tarfile 

cd $builddir
$source_dir/openmpi-${version}/configure --enable-mpi1-compatibility  --prefix=$targetdir

make -j 8 && make install

_logs "openmpi-${version} install"

cd $targetdir
cat >> activate.sh <<EOF
export PATH=$targetdir/bin:\$PATH
export LD_LIBRARY_PATH=$targetdir/lib:\$LD_LIBRARY_PATH
export C_INCLUDE_PATH=$targetdir/include:\$C_INCLUDE_PATH
export MANPATH=${targetdir}/share/man:\$MANPATH
export INFOPATH=${targetdir}/share/info:\$INFOPATH
EOF

