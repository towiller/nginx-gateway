--[[
-- 操作入口,单入口 
--]]
cjson = require("cjson")
local hstring = require("huimin.util.hstring")
local contain = require("huimin.util.contain")

nginxDictServers = ngx.shared.nginx_dict_servers -- 共享内存

appContain = contain.new()
appContain:register('config', {
	proxyConfig = require('huimin.config.proxy'),
	env = require('huimin.env'),
})

local debugInfo = debug.getinfo(1, 'S')
local currentDir = hstring.sub(debugInfo.source, 2, -1)
local spBaseDir = hstring.split('/', currentDir)
local spBaseDirLen = table.getn(spBaseDir)
local baseDir = {table.unpack(spBaseDir, 1, spBaseDirLen-2)}
local appDir = table.concat(baseDir, '/')
appContain:append({"config", "appDir"}, appDir)

local dispatch = require("huimin.util.dispatch") 
dispatch.dispatch()
