#!/bin/sh

if [[ $1 != "" ]]; then 
	ngxPath=$1
else
	ngxPath=/data/hmprogram/nginx-lua/		
fi

cdir=$(cd `dirname $0`; cd ..; pwd)
flagFile=$cdir/shell/flag 

#if [ -f "$flagFile" ]; then
#	oldFlag=`cat $flagFile` 
#else
#	oldFlag="/home/work/nginx/"	
#fi

nginxConfigFile=$cdir/config/nginx_server_proxy.conf
nginxConfigTpl=$cdir/config/nginx_server_proxy.tpl

#turnOldFlag=`echo $oldFlag|sed 's/\//\\\\\//g'`
turnOldFlag="\$prefix"
turnNgxPath=`echo $ngxPath|sed 's/\//\\\\\//g'`
turnProjectPath=`echo $cdir|sed 's/\//\\\\\//g'`
sedMatch="s/${turnOldFlag}/${turnNgxPath}/g"

sed  "s/${turnOldFlag}/${turnNgxPath}/g" $nginxConfigTpl | sed "s/\$projectPath/${turnProjectPath}/g"  > $nginxConfigFile 

if [ ! -d "$ngxPath/nginx/conf/vhost.d" ]; then 
	mkdir $ngxPath/nginx/conf/vhost.d
fi 

if [ ! -d "${ngxPath}/sbin" ]; then 
	mkdir ${ngxPath}/sbin
fi

matchNewPath=`cat $nginxConfigFile|grep "${turnNgxPath}"`

if [ ! -z "$matchNewPath" ]; then 
	echo $ngxPath > $flagFile
	#mv ${ngxPath}nginx/conf/nginx.conf ${ngxPath}nginx/conf/nginx.conf.bak
	rm -f ${ngxPath}/lualib/huimin && ln -s $cdir ${ngxPath}/lualib/huimin
	rm -f ${ngxPath}/nginx/conf/nginx.conf && ln -fs ${ngxPath}/lualib/huimin/config/nginx.conf ${ngxPath}/nginx/conf/nginx.conf
	rm -f ${ngxPath}/nginx/conf/vhost.d/nginx_server_proxy.conf && ln -fs ${ngxPath}/lualib/huimin/config/nginx_server_proxy.conf ${ngxPath}/nginx/conf/vhost.d/nginx_server_proxy.conf
	cp $cdir/shell/nginx ${ngxPath}/sbin/ && chmod +x ${ngxPath}/sbin/nginx
	#echo ln -fs $nginxConfigFile ${ngxPath}nginx/conf/vhost.d/nginx_server_proxy.conf
	echo "success \n"
else
	echo "error \n"
fi
