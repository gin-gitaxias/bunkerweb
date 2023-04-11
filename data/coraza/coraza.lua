local _M        = {}
_M.__index      = _M

local utils     = require "utils"
local datastore = require "datastore"
local logger    = require "logger"
local cjson		= require "cjson"
local http		= require "resty.http"

function _M.new()
	local self = setmetatable({}, _M)
    -- Check if Coraza is activated
    local check, err = utils.get_variable("USE_CORAZA")
    Enable = true
    if check == nil then
        Enable = false
        return false, "error while getting variable USE_CORAZA (" .. err .. ")", nil, nil
    end
    if check ~= "yes" then
        Enable = false
		return true, "CORAZA plugin not enabled skipping", nil, nil
	end
    local value, err = utils.get_variable("CORAZA_API", false)
    if not value then
		logger.log(ngx.ERR, "CORAZA", "error while getting CORAZA_API setting : " .. err)
		return nil, "error while getting CORAZA_API setting : " .. err
	end
    self.api = value
	return self, "Init of 'new' successful"
end

function _M:access()
    if Enable == false then
        return true, "CORAZA plugin not enabled skipping"
    end
	local ok, err, status, data = self:request(ngx.var.request_method)
    if not ok then
        return false, "error from request : " .. err, nil, nil
    end
    return true, " CORAZA success", nil, nil
end

function _M:request(method)

    local httpc, err = http.new()
    if not httpc then
        return false, "CORAZA can't instantiate http object : " .. err, nil, nil
    end
    local res = nil
    local err_http = "unknown error"
    
    if method == "GET" then
        res, err_http = httpc:request_uri(self.api, {
            method = method,
        })
    else
        
        local body, err = httpc:get_client_body_reader()
        if not body then
            ngx.req.read_body()
            body = ngx.req.get_body_data()
            
            if not body then
                local body_file = ngx.req.get_body_file()
                if not body_file then
                    return false, "CORAZA can't access client body", nil, nil
                end

                local f, err = io.open(body_file, "rb")
                if not f then
                    return false, "CORAZA can't read body from file " .. body_file .. " : " .. err, nil, nil
                end
                body = function ()
                    return f:read(4096)
                end
            end
        end
    
    res, err_http = httpc:request_uri(self.api, {
    
    method = method,
    headers = ngx.req.get_headers(),
    body = body
    })
    end
    httpc:close()

    

    if not res then
        return false, "CORAZA error while sending request : " .. err_http, nil, nil
    end
    logger.log(ngx.NOTICE, "CORAZA body", res.body )
    --logger.log(ngx.NOTICE, "CORAZA header", res.headers )
    local ok = res.body
    if not ok then
        return false, "CORAZA error while decoding json : " .. res, nil, nil
    end
    return true, "CORAZA success", res.status, res
end
return _M