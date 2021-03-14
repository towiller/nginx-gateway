--[[
-- http请求参数
--
-- @author wangx 
--]]
local _M = {}

local mt = { __index = _M }

function _M.new(self, uri, httpOptions)
	local httpOptions = httpOptions or {}
	local uri = uri or ''
	return setmetatable({httpOptions = httpOptions, uri = uri}, mt)
end

-- 设置参数集合
function _M.setArgs(self, args)
	local options = self.httpOptions
	options.args = args
	return self	
end

-- 追加参数
function _M.setArg(self, key, val)
	local options = self.httpOptions
	if options.arg == nil then
		options.args = {}
	end
	options.args[key] = val
	return self
end

-- 设置请求方法名称
function _M.setMethodName(self, methodName)
	methodName = 'HTTP_' .. string.upper(methodName)
	local methodCode = ngx[methodName]
	self:setMethod(methodCode)
	return self	
end

-- 设置请求方法code
function _M.setMethod(self, method)
	local options = self.httpOptions
	options.method = method
	return self
end

-- 设置头信息
function _M.setHeaders(self, headers)
	local options = self.httpOptions
	options.headers = headers
	return self
end

function _M.setServername(serverName)
	self.serverName = serverName
	return self
end

function _M.setBody(self, body)
	local options = self.httpOptions
	options.body = body
	return self
end

function _M.setUri(self, uri)
	self.uri = uri
	return self
end

return _M
