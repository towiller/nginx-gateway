--[[
-- upstream操作
-- 
-- @author wangx 
-- @since 2018-06-08
--]]
local _M = {}

local mt = { __index = _M }

function _M.new(self, upstreamPath)
	upstreamPath = upstreamPath or "/upstream"
	return setmetatable({upstreamPath = upstreamPath}, mt)
end

-- 设置upstream
function _M.set(self, upstreamName, upstreams)
	if not upstreamName then 
		return 
	end

	local upstreamPath = self.upstreamPath
	local uri = upstreamPath .. "/" .. upstreamName 
	
	local res, err = ngx.location.capture(uri, {
		method = ngx.HTTP_POST,
		body = upstreams,	
	}) 	

	return res.body, err
end


-- 获取upstream
function _M.get(self, upstreamName)
	if not upstreamName then 
		return 
	end

	local upstreamPath = self.upstreamPath
	local uri = upstreamPath .. "/" .. upstreamName 

	local res, err = ngx.location.capture(uri, {
		method = ngx.HTTP_GET
	})

	return res.body
end 

-- 删除upstream
function _M.del(self, upstreamName)
	if not upstreamName then 
		return 
	end
	
	local upstreamPath = self.upstreamPath
	local uri = upstreamPath .. "/" .. upstreamName 
	local res,err = ngx.location.capture(uri, {
		method = ngx.HTTP_DELETE
	})
	
	return res.body, err
end

return _M
