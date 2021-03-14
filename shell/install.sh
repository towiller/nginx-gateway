#!/bin/sh

cdir=$(cd `dirname $0`; cd ..; pwd)

PREFIX_CODE=0
OPENRESTYVERSION_CODE=1

installed=$cdir/shell/installed

setArgsKey=("prefix" "openresty-version")
setArgsDefault=("/data/hmprogram/nginx-lua" "1.13.6.2")
getArgs=$*
getArgValue=()

for ((i=0; i<${#setArgsKey[*]}; i++)); do
	setOption="--${setArgsKey[i]}"
	argVal=${setArgsDefault[i]}
		
	for getArg in $getArgs; do 
		argKey=${getArg%=*}

		if [[ "$setOption" == "$argKey" ]]; then 
			argVal=${getArg#*=}
		fi

		echo $argVal
	done
	
	getArgValue[i]=$argVal
done


openrestyVersion=${getArgValue[OPENRESTYVERSION_CODE]}
prefix=${getArgValue[PREFIX_CODE]}

if [ -f "$installed" ]; then 
	cd openresty-${openrestyVersion}
	./configure --prefix=${prefix} --with-http_v2_module --with-openssl=./bundle/openssl-1.0.2l --add-module=./bundle/ngx_http_dyups_module-master --add-module=./bundle/ngx_cache_purge-2.3 --add-module=./bundle/nginx_upstream_check_module-master
	make && make install
	cd $cdir && sh ./shell/build.sh $prefix
	exit
fi

wget https://openresty.org/download/openresty-${openrestyVersion}.tar.gz

tar zxvf openresty-${openrestyVersion}.tar.gz

wget https://www.openssl.org/source/openssl-1.0.2l.tar.gz

tar -zxvf openssl-1.0.2l.tar.gz

cp -rf openssl-1.0.2l openresty-${openrestyVersion}/bundle/ 

wget https://github.com/yzprofile/ngx_http_dyups_module/archive/master.zip -O ngx_http_dyups_module-master.zip

unzip ngx_http_dyups_module-master.zip

cp -rf ngx_http_dyups_module-master openresty-${openrestyVersion}/bundle/ 

wget http://labs.frickle.com/files/ngx_cache_purge-2.3.tar.gz

tar zxvf ngx_cache_purge-2.3.tar.gz 

cp -rf ngx_cache_purge-2.3 openresty-${openrestyVersion}/bundle/

wget https://github.com/yaoweibin/nginx_upstream_check_module/archive/master.zip -O nginx_upstream_check_module_master.zip

unzip nginx_upstream_check_module_master.zip

cp -rf nginx_upstream_check_module-master openresty-${openrestyVersion}/bundle/

cd openresty-${openrestyVersion}

./configure --prefix=${prefix} --with-http_v2_module --with-openssl=./bundle/openssl-1.0.2l --add-module=./bundle/ngx_http_dyups_module-master --add-module=./bundle/ngx_cache_purge-2.3 --add-module=./bundle/nginx_upstream_check_module-master

make && make install

echo 1 > $installed 
cd $cdir && sh ./shell/build.sh $prefix
