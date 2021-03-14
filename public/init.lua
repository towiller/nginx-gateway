--[[
-- @author wangx
-- @since 2018-06-08
--]]
local cjson = require("cjson")
local hstring = require("huimin.util.hstring")
local eureka = require("huimin.models.eureka")
local nginxServer = require("huimin.models.nginxServer")
local nginxUpstream = require("huimin.models.nginxUpstream")
local nginxCapture = require('huimin.models.nginxCapture')
local nginxCaptureOption = require('huimin.models.nginxCaptureOption')
local contain = require("huimin.util.contain")

appContain = contain.new()
appContain:register('config', {
	proxyConfig = require('huimin.config.proxy'),
	env = require('huimin.env'),
})

-- 全局变量配置
proxyConfig = require("huimin.config.proxy") 

ngx.req.read_body()
local body = ngx.req.get_body_data()
local getArgs = ngx.req.get_uri_args()
local postArgs = ngx.req.get_post_args()
local headers = ngx.req.get_headers(0, true) 

local uriArr = hstring.split("/", ngx.var.request_uri)
env = uriArr[2]
local serverName = uriArr[3]
local nginxDictServers = ngx.shared.nginx_dict_servers
local mNginxServer = nginxServer:new(proxyConfig)  
local resUpstream = mNginxServer:setUpstream(serverName)

local uri = "/server_proxy"
for k,v in pairs(uriArr) do 
	if k ~= 1 and k ~= 2 then
		uri = uri .. '/' .. v 	
	end 
end

local mNginxCaptureOption = nginxCaptureOption:new(uri)
mNginxCaptureOption:setMethodName(ngx.var.request_method)
				   :setArgs(getArgs)
				   :setHeaders(headers)
				   :setUri(uri)

if methodCode ~= HTTP_GET then 
	mNginxCaptureOption:setBody(body)
end

local res, err = nginxCapture.request(mNginxCaptureOption)
if err or not res then
	ngx.log(ngx.ERR, "[err=" .. err .. "]")
	ngx.exit(res.status)
else
	ngx.say(res.body)
	ngx.exit(200)
end
