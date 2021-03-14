--[[
-- @author wangx 
-- @since 2018-06-08
--]]
local hstring = require("huimin.util.hstring")  

--local uriArr = hstring.split("/", ngx.var.request_uri)
local uriArr = hstring.split('/', ngx.var.document_uri)
local uri =  ""  

for k, v in pairs(uriArr) do 
	if k ~= 1 and k ~= 2 and k ~= 3 then 
		uri = uri .. "/" .. v
	end 
end 

local args = ngx.req.get_uri_args()
if _G.next(args) ~= nil then 
	uri = uri .. "?1=1"
	for akey, aval in pairs(args) do
		uri = uri .. "&" .. akey .. '=' .. aval
	end
end

return uri
