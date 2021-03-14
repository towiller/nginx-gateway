--[[
-- @author wangx 
-- @since 2018-06-08
--]]
local _M = {}

local mt = { __index = _M }

local eureka = require("huimin.models.eureka")
local cjson = require("cjson")
local nginxUpstream = require("huimin.models.nginxUpstream")

--[[
-- 初始化类
-- global env
--
-- @param table config 配置 
-- @param dict   nginxDictServers 
-- @return object
--]]
function _M.new(self, config, nginxDictServers)
	config = config or proxyConfig
	local appConfig = appContain:get("config")
	local env = appConfig.env.appenv
	local serverUrl = config.eurekaServer[env].serverUrl

	config.serverUrl = serverUrl
	nginxDictServers = nginxDictServers or ngx.shared.nginx_dict_servers 
	return setmetatable({nginxDictServers = nginxDictServers, config = config}, mt) 			
end

--[[
-- 设置负载
-- 
-- @param string serverName
-- @return boolean
--]]
function _M.setUpstream(self, serverName)
	local config = self.config

	local ngxDictServers = self.nginxDictServers
	local serverTimeKey = serverName .. 'time'

	-- 为了防止eureka挂掉，服务数据设置缓存时间，单独储存失效时间
	local serverTimeRes = ngxDictServers:get(serverTimeKey) 
	local ctime = os.time()
	if not serverTimeRes then 
		local mEureka = eureka:new(config)
		local registerServers, err = mEureka:getServer(serverName)
		
		-- 获取不到服务列表时不更新upstream
		if not err and registerServers and string.len(registerServers) > 0 then  
			local objNgxUpstream = nginxUpstream.new(config.upstreamPath)
			local upstreams = self:genrateUpstream(cjson.decode(registerServers))
			
			-- ngx.say(serverName, upstreams)
			objNgxUpstream:set(serverName, upstreams)
		end 

		ngxDictServers:set(serverTimeKey, ctime, config.expireTime)
	end

	return true
end

--[[
-- 生成负载策略 
-- 
-- @param table registerServers 注册的服务列表
-- @return string
--]]
function _M.genrateUpstream(self, registerServers)

	local config = self.config
	
	local upstream = ''
	for k,instance in pairs(registerServers.application.instance) do 
		upstream = upstream .. "  server " .. instance.ipAddr .. ":" .. instance.port['$'] .. ";"
	end
	--upstream = upstream .. " server 127.0.0.1:8080 weight=20;"
	
	upstream = upstream .. " keepalive 1024;" 

	return upstream 
end 

return _M
