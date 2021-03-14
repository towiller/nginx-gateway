local _M = {}

local mt = {__index=_M}
local hstring = require("huimin.util.hstring")
local cjson = require("cjson")

--[[
-- 构造方法
--]]
function _M.new(self, config)
	local config = config or {} 
	return setmetatable({ config = config }, mt)
end

--[[
-- 注册
--
-- @param string var   
-- @param table val
-- @return void
--]]
function _M.register(self, var, val)
	self[var] = val							
	return nil 
end

--[[
-- 追加数据
--
-- @param json varDict 变量配置
-- @param table|string val 值
--]]
function _M.append(self, varDict, val)

	if type(varDict) ~= 'table' then 
		return nil
	end

	local varLen = table.getn(varDict)  
	local tmp = self

	for i, var in pairs(varDict) do
		if varLen == i then 
			tmp[var] = val
		else
			tmp = tmp[var]
		end
	end

	return nil
end

--[[
-- 取消注册
--
-- @return void
--]]
function _M.unRegister(self, var)
	self[var] = nil
	
	return nil
end

--[[
-- 获取注册对象
--
-- @return void
--]]
function _M.get(self, var)
	return self[var]
end

return _M
