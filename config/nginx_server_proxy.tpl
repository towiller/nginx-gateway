lua_package_path "$prefix/lualib/?.lua;;$projectPath/lib/?.lua;;";
lua_package_cpath "$prefix/lualib/?.so;;$projectPath/lib/?.so;;";
lua_code_cache on;
lua_shared_dict nginx_dict_servers 10m;
init_worker_by_lua_file "$prefix/lualib/huimin/public/init_worker.lua";

server{
	listen       8090;

	access_log  logs/server.access.log  main;
#	ssl_certificate     server.crt;
#	ssl_certificate_key  server.key;

	default_type  application/json;
	resolver 8.8.8.8;

	allow 127.0.0.0/24;
	allow 172.17.0.0/24;
	allow 172.2.2.0/24;
	deny all;

	location ^~ /upstream {
		deny all;
		allow 127.0.0.1;
		dyups_interface;	
	}

	location ^~ /server_proxy {
		proxy_redirect off;
		proxy_set_header Host $host;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

		set_by_lua_file $proxy_upstream "$prefix/lualib/huimin/public/upstream_name.lua";
		set_by_lua_file $proxy_request_uri "$prefix/lualib/huimin/public/proxy_request_uri.lua";
		proxy_pass http://$proxy_upstream$proxy_request_uri ;
	}

	location ~* /^(dev|test|pre|prod) {
		content_by_lua_file "/home/work/nginx-lua/lualib/huimin/public/init.lua";	
	}

	location / {
		content_by_lua_file "$prefix/lualib/huimin/public/index.lua";
	}
}
