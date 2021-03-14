local _M = {}

local request = require("huimin.util.request")

function _M.dispatch()

	local mRequest = request:new()
	mRequest:buildRequest()

	local config = appContain:get('config')
	local appDir = config.appDir

	local controllerPath = appDir .. '/controller' .. '/' .. mRequest.controllerMap.controller .. '.lua'
	local fhandle = io.open(controllerPath)
	if fhandle then 
		fhandle.close()
	end

	if fhandle == nil then 
		ngx.exit(404)						
	end

	local mController = require("huimin.controller." .. mRequest.controllerMap.controller)
	local action = mRequest.controllerMap.action .. 'Action' 
	local res 
	if mController[action] ~= nil then 
		res = mController[action](mRequest)
		ngx.say(res)
		ngx.exit(200)
	else
		ngx.exit(404)		
	end
end

return _M
