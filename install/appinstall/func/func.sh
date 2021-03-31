#!/bin/bash

# author: zhouzhuo
# create time: 2021/3/20
# update time: 2021/3/20

# functions
source ./conf/app.cfg
NAMEHOST=$HOSTNAME
_log_info ()
{
DATE_N=`date "+%Y-%m-%d %H:%M:%S"`
USER_N=`whoami`
cd $current_dir
echo "[INFO] ${DATE_N} ${USER_N} execute $0 $@" >> ./logs/info.log

}

_log_error ()
{
DATE_N=`date "+%Y-%m-%d %H:%M:%S"`
USER_N=`whoami`
cd $current_dir
echo -e "[ERROR] ${DATE_N} ${USER_N} execute $0  $* "  >> ./logs/error.log

}

_logs ()  {
if [  $? -eq 0  ]
then
    _log_info "$* sucessfully."
    echo -e "\033[32m $* sucessfully. \033[0m"
else
    _log_error "$* failed."
    echo -e "\033[41;37m $* failed. \033[0m"
    exit
fi
}

_log_abort()
{
	echo $*
	exit 1
}


_tips()
{
	DATE_N=`date "+%Y-%m-%d %H:%M:%S"`
	echo "======================================================================"
	echo $DATE_N
	echo $*
	echo "======================================================================"
	echo -ne "\n"
}

_check_source_build_dir()
{
	directories=$*
    for dir in $directories;do
		if [ ! -e $dir ];then
			_tips "$dir not exists, create it" >> ./logs/info.log
			mkdir -p $dir
		else
			_tips "$dir exists, remove it and create new $dir" >> ./logs/info.log
			/bin/rm -rf $dir && mkdir -p $dir
		fi
	done
}

_check_install_dir()
{
	now=`date +%m-%d-%H%M`
	mkdir -p $recycle_dir/$now/
	install_dirs=$*
    for dir in $install_dirs; do
		if [ ! -e $dir ];then
			_tips "$dir not exists, create it"
			mkdir -p $dir
			_logs "mkdir -p $dir"
		else
			_tips "$dir exists, move it and create new $dir"
			mv $dir $recycle_dir/$now/  && mkdir -p $dir
			_logs "mv $dir $recycle_dir/$now/  && mkdir -p $dir"
		fi
	done
}

_unzipfile()
{
	dir=$1
    file=$2
    case $file in
		*xz)
			tar xJ -C $dir -f $file
			_logs "tar xJ -C $dir -f $file"
		;;
		*gz | *tgz)
			tar xz -C $dir -f $file
			_logs "tar xz -C $dir -f $file"
		;;
		*bz2)
			tar xj -C $dir -f $file
			_logs "tar xj -C $dir -f $file"
		;;
		*zip)
			unzip -d $dir -o $file
			_logs "unzip -d $dir -o $file"
		;;
		*)
			_log_abort "unkown unzip type file: $file"
		;;
	esac
}

_download_file()
{
	urlroot=$1
	tarfile=$2
	if [ ! -e $tarfile_dir/$tarfile ];then
	 	_tips "download $tarfile to $tarfile_dir "
		wget $urlroot/$tarfile  --directory-prefix="$tarfile_dir"
	else
    	echo "$tarfile already downloaded at $tarfile_dir/$tarfile"
	fi

}

_set_dir()
{
	for dir in $source_dir $build_dir  $tarfile_dir $recycle_dir;do
		if [ ! -d $dir ];then
			_tips "mkdir $dir."
			mkdir -p  $dir
		else
			_tips "$dir already exists,nothing to do" >> ./logs/info.log
		fi
	done
}

_set_dir

