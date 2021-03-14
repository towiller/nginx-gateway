local _M = {}

local hstring = require("huimin.util.hstring")
local httpCapture = require('huimin.models.httpCapture')
local http = require('resty.http')

function _M.indexAction(request)
	local config = appContain:get('config')  
	local proxyConfig = config.proxyConfig 

	if request.body == nil then 
		ngx.exit(200)
	end

	local requestAggs = cjson.decode(request.body)
	local mHttpCapture = httpCapture:new(proxyConfig.httpCapturePath, proxyConfig, nginxDictServers)
	local results = mHttpCapture:httpCaptureAgg(requestAggs)
	return cjson.encode(results) 
end

-- test 
function _M.testAction(request)
	return ""
	-- return getServers
	-- return res.body
end

return _M
