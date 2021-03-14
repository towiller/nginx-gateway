--[[
-- @author wangx 
-- @since 2018-06-08
--]]
local hstring = require("huimin.util.hstring") 

--local uriArr = hstring.split("/", ngx.var.request_uri)
local uriArr = hstring.split('/', ngx.var.document_uri)

return uriArr[3]
