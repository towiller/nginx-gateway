--[[
-- nginx 子请求
-- 
-- @author wangx 
-- @since 2018-07-27 
--]]
local _M = {}
local mt = { __index = _M } 

local nginxCapture = require('huimin.models.nginxCapture')
local nginxCaptureOption = require('huimin.models.nginxCaptureOption')
local nginxServer = require("huimin.models.nginxServer")

function _M.new(self, capturePath, proxyConfig, ngxDict) 
	local capturePath = capturePath or "/server_proxy"
	local proxyConfig = proxyConfig or {}
	return setmetatable({
			capturePath = capturePath, 
			proxyConfig = proxyConfig,
			ngxDict = ngxDict,
		}, mt)  
end

-- http子请求聚合
function _M.httpCaptureAgg(self, httpRequestAgg)

	self:setAggUpstreams(httpRequestAgg)

	local mHttpOptions = {}
	for k, httpRequest in pairs(httpRequestAgg) do
		local defaultOption = {
			headers = {
				['Content-type'] = 'application/json;charset=utf8',
				['Accept'] = 'application/json',
			}				
		}


		local requestUri = self:getCaptureUri(httpRequest.server_name, httpRequest.uri)
		local mNginxCaptureOption = nginxCaptureOption:new(requestUri, defaultOption)
		mNginxCaptureOption:setMethodName(httpRequest.method):setUri(requestUri)

		if httpRequest.args ~= nil then 
			mNginxCaptureOption:setArgs(httpRequest.args)	
		end
		
		if httpRequest.body ~= nil then 
			mNginxCaptureOption:setBody(httpRequest.body)
		end
			
		if httpRequest.headers ~= nil then 
			mNginxCaptureOption:setHeaders(httpRequest.headers)		
		end
	
		table.insert(mHttpOptions, mNginxCaptureOption)
	end

	local res = nginxCapture.parallelRequests(mHttpOptions)

	return res
end

-- http request请求
function _M.httpRequest(self, requestArgs)
	local defaultOption = {
		headers = {
			['Content-type'] = 'application/json;charset=utf8',
			['Accept'] = 'application/json',
		}
	}

	local mNginxCapture = nginxCapture:new(defaultOption)

	local requestUri = self:getCaptureUri(requestArgs.server_name, requestArgs.uri)
	mNginxCapture:setMethodName(httpRequest.method)
		
	if httpRequest.body ~= nil then 
		mNginxCapture:setBody(httpRequest.body)
	end
			
	if httpRequest.headers ~= nil then 
		mNginxCapture:setHeaders(httpRequest.headers)		
	end

	local response, err = mNginxCapture:capture(requestUri) 

	return response, err
end

-- 设置聚合的负载配置
function _M.setAggUpstreams(self, httpRequestAgg)
	
	local serverNames = {}
	local ngxDict = self.ngxDict
	local proxyConfig = self.proxyConfig
	local mNginxServer = nginxServer:new(proxyConfig, ngxDict)
	for k, httpRequest in pairs(httpRequestAgg) do
		local serverName = httpRequest.server_name
		if serverNames[serverName] == nil then
			mNginxServer:setUpstream(serverName)
			serverNames[serverName] = 1
		end
	end
end

-- 获取子请求URI
function _M.getCaptureUri(self, serverName, uri)
	local requestUri = self.capturePath .. '/' .. serverName .. '/' .. uri 			
	return requestUri
end

return _M
