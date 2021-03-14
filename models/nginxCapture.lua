local _M = {}

local cjson = require("cjson")

--[[
-- 串行请求接口	
--]]
function _M.serialRequests(captureOptions)
	
	if not captureOptions or type(captureOptions) ~= 'table' then 
		return nil	
	end

	local results = {}
	for _, captureOption in pairs(captureOptions) do 
		local res, err = _M:request(captureOption)
		table.insert(results, res)
	end

	return results 
end

--[[
--	请求接口
--
--	@param table captureOption
--	@return table
--]]
function _M.request(captureOption)
	local res, err = ngx.location.capture(captureOption.uri, captureOption.httpOptions)
	if not res or err  then
		return nil, err
	end 

	return res, nil
end

--[[
-- 并行请求 
-- 
-- @param table captureOptions
-- @return table
--]]
function _M.parallelRequests(captureOptions)
	local args = {} 
	for _, captureOption in pairs(captureOptions) do
		local arg = {captureOption.uri, captureOption.httpOptions}	
		table.insert(args, arg)
	end

	return {ngx.location.capture_multi(args)}
end

return _M
