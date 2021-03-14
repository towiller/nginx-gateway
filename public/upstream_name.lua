local hstring = require("huimin.util.hstring") 
--local cjson = require("cjson")

--local uriArr = hstring.split("/", ngx.var.request_uri)
local uriArr = hstring.split('/', ngx.var.document_uri)
--ngx.say(ngx.req.get_body_data())
--local args = ngx.req.get_uri_args()

--ngx.say(ngx.var.document_uri)
--ngx.say(ngx.var.posted_requests)

return uriArr[3]
