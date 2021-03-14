return {

	--eureka服务地址
	eurekaServer = {
		dev = {
			serverUrl = "root:123456@http://127.0.0.1:10020",
		}
	},

	-- eureka服务列表保存时间 
	expireTime = 30,

	-- http 代理地址
	httpCapturePath = "/server_proxy",

	-- 负载地址
	upstreamPath = "/upstream",	
}
