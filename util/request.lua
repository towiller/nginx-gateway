local _M = {}

local hstring = require("huimin.util.hstring")
local cjson = require("cjson")

local mt = {__index = _M}

function _M.new(self)
	return setmetatable({}, mt)			
end

-- 构建request
function _M.buildRequest(self)
	local this = self
	this.args = ngx.req.get_uri_args()  
	this.headers = ngx.req.get_headers(0, true)
	this.method = ngx.var.request_method
	this.requestUri = ngx.var.request_uri

	local methodName = 'HTTP_' .. string.upper(this.method)
	this.methodCode = ngx[methodName]

	ngx.req.read_body()
	this.body = ngx.req.get_body_data()

	self:parseUri()
end

-- 解析uri
function _M.parseUri(self)
	local this = self
	local requestUri = self.requestUri

	local spUri = hstring.split('?', self.requestUri)
	local spBaseUri = hstring.split('/', spUri[1])
	local dicts = {
		"controller",
		"action"
	}
	
	this.controllerMap = {
		controller = "index",
		action = "index",
	}

	local k = 1
	for i, path in pairs(spBaseUri) do 
		repeat
		if path == '' then 
			break	
		end
	
		if dicts[k] == nil  then 
			break
		end

		local dict = dicts[k]
		this.controllerMap[dict] = path

		k = k + 1
		until true
	end
end

return _M
