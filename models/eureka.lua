--[[
-- @author wangx 
-- @since 2018-06-08
--]]
local _M = {}

local zhttp = require("resty.http")
local hstring = require("huimin.util.hstring")
local hbase64 = require("huimin.util.hbase64")
local cjson = require("cjson")

local mt = { __index = _M }

function _M.new(self, config, httpOptions)
	config = config or {}
	httpOptions = httpOptions or {
		headers = {
			 ["Content-Type"] = "application/json;charset=UTF-8",
			 ["Accept"] = "application/json;charset=UTF-8" 
		}										
	}
	local httpc = zhttp.new()
	return setmetatable({httpc = httpc, config = config, httpOptions = httpOptions}, mt)
end

-- 获取instance
function _M.getInstance(self, serverName, instanceId)
	local config = self.config
	local httpOptions = self.httpOptions
	self:parseServerUrl(config.serverUrl)
	
	local url = self.serverUrl .. '/eureka/apps/' .. serverName .. "/" .. instanceId 
	httpOptions.method = 'GET'
	local result, err = self:httpProxy(url, turnJson)

	if not result or result.status == 404 or err then 
		return nil				
	end

	return result.body
end

-- 获取eureka服务
function _M.getServer(self, serverName, turnJson)
	local config = self.config
	local httpOptions = self.httpOptions
	self:parseServerUrl(config.serverUrl)
	
	local url = self.serverUrl .. '/eureka/apps/' .. serverName
	httpOptions.method = 'GET'
	local result, err = self:httpProxy(url, turnJson)

	if not result or err then 
		ngx.log(ngx.ERR, url, cjson.encode(httpOptions), err)
		return nil
	end 

	return result.body
end

-- 注册服务
function _M.registerServer(self, serverName, serverParams)
	local config = self.config		
	local httpOptions = self.httpOptions

	local body = {
		instance = {
			instanceId = serverParams.instanceId,
			hostName = serverParams.hostName,
			app = serverParams.appName,
			ipAddr = serverParams.ipAddress,
			vipAddress = serverParams.ipAddress,
			status = "UP",
			port = {
				['$'] = serverParams.port,
				['@enabled'] = true,
			},
			securePort = {
				['$'] = serverParams.securePort,
				['@enabled'] = true,
			},
			homePageUrl = "http://" .. serverParams.ipAddress .. ":" .. serverParams.port,
			statusPageUrl = "http://" .. serverParams.ipAddress .. ":" .. serverParams.port .. "/info",
			healthCheckUrl = "http://" .. serverParams.ipAddress .. ":" .. serverParams.port .. "/health",
			dataCenterInfo = {
				['@class'] = "com.netflix.appinfo.InstanceInfo$DefaultDataCenterInfo",
				name = "MyOwn"
			},
			metadata = {
				instanceId = serverParams.instanceId,
			}
		}	
	}
	
	httpOptions.body = cjson.encode(body)

	self:parseServerUrl(config.serverUrl)
	local url = self.serverUrl .. '/eureka/apps/' .. serverName
	httpOptions.method = 'POST'
	local res, err = self:httpProxy(url, turnJson)
	if res.status == 204 then 
		return true
	else 
		return false
	end
end

-- 保持心跳
function _M.heartbeatServer(self, serverName, instanceId)
	local config = self.config		
	local httpOptions = self.httpOptions

	self:parseServerUrl(config.serverUrl)
	local url = self.serverUrl .. '/eureka/apps/' .. serverName .. '/' .. instanceId
	httpOptions.method = 'PUT'
	local res, err = self:httpProxy(url, turnJson)
	if res.status == 200 then 
		return true
	else
		return false
	end 
end

-- http请求
function _M.httpProxy(self, url)
	local httpc = self.httpc
	local httpOptions = self.httpOptions
	httpc:set_timeout(3000)	

	--ngx.say(url, cjson.encode(httpOptions))
	return httpc:request_uri(url, httpOptions)
end

-- 解析服务url
function _M.parseServerUrl(self, serverUrl)
	local hasParse = self.hasParse
	if hasParse then 
		return true		
	end

	if string.find(serverUrl, '@') == nil then 
		self.serverUrl = serverUrl
		hasParse = true
		return true
	end
	
	local httpOptions = self.httpOptions
	local spServerUrl = hstring.split('@', serverUrl)
	self.serverUrl = spServerUrl[2]
	local auth = hstring.split(":", spServerUrl[1])
	httpOptions.headers["Authorization"] = "Basic " .. hbase64.encode(auth[1] .. ":" .. auth[2])
	hasParse = true
	return true
end

return _M
