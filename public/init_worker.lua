--[[
-- @author wangx
-- @since 2018-08-15
--]]
cjson = require("cjson")
local eureka = require("huimin.models.eureka")
local http = require("resty.http")
local hstring = require("huimin.util.hstring")
local contain = require("huimin.util.contain")

nginxDictServers = ngx.shared.nginx_dict_servers -- 共享内存

appContain = contain.new()
appContain:register('config', {
	proxyConfig = require('huimin.config.proxy'),
	env = require('huimin.env'),
	serversConfig = require('huimin.config.servers'),
})

local debugInfo = debug.getinfo(1, 'S')
local currentDir = hstring.sub(debugInfo.source, 2, -1)
local spBaseDir = hstring.split('/', currentDir)
local spBaseDirLen = table.getn(spBaseDir)
local baseDir = {table.unpack(spBaseDir, 1, spBaseDirLen-2)}
local appDir = table.concat(baseDir, '/')
appContain:append({"config", "appDir"}, appDir)

local delay = 10
local new_timer = ngx.timer.at
local appConfig = appContain:get("config")
local config = appConfig.proxyConfig
local env = appConfig.env.appenv
config.serverUrl = config.eurekaServer[env].serverUrl

local check 
-- load from config
local serversConfig = appConfig.serversConfig  

check = function(premature)
	if not premature then 
		local ok, err = new_timer(delay, check)
		if not ok then
			ngx.log(ngx.ERR, "failed to create timer:", err)
		end

		local time = os.time()
		ngx.log(ngx.NOTICE, "time: " .. time)
	end

	for _, serverConfig in pairs(serversConfig) do 
		local checkUrl = "http://" .. serverConfig.ipAddress .. ":" .. serverConfig.port .. serverConfig.checkUri  
		local httpOptions = {
			method = "GET",
			headers = {}
		}

		if serverConfig.hostName  and serverConfig.hostName ~= '' then 
			httpOptions.headers.Host = serverConfig.hostName
		end

		local httpc = http.new()
		local res, err = httpc:request_uri(checkUrl, httpOptions)
		if err or not res then
			ngx.log(ngx.ERR, checkUrl, cjson.encode(httpOptions), err)
			break
		end 
		
		local mEureka = eureka:new(config)
		local getInstance, err1 = mEureka:getInstance(serverConfig.appName, serverConfig.instanceId)
		local heartbeat = mEureka:heartbeatServer(serverConfig.appName, serverConfig.instanceId)
	
		ngx.log(ngx.ERR, "heartbeat", cjson.encode(serverConfig))
		if not heartbeat then 
			mEureka:registerServer(serverConfig.appName, serverConfig)
			ngx.log(ngx.ERR, "register server", cjson.encode(serverConfig))
		end 
	end
end

if 0 == ngx.worker.id() then 
	local ok, err = new_timer(delay, check)
	if not ok then 
		ngx.log(ngx.ERR, "failed to created timer: ", err)
	end
end
