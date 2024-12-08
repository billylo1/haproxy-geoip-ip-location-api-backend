local socket = require("socket")
local http = require("socket.http")
local url = require("socket.url")
local ltn12 = require("ltn12")
local json = require("json")

local function geocode(ip)
    -- URL of the JSON web service
    local url = "http://localhost:8087/api/location/" .. ip

    -- Make the HTTP request
    local response_body = {}
    local res, code, headers, status = http.request {
    url = url,
    sink = ltn12.sink.table(response_body)
    }

    -- Check for errors
    if code ~= 200 then
    error("HTTP request failed with code: " .. code)
    end

    -- Concatenate the response body
    local response_text = table.concat(response_body)

    -- Parse the JSON response
    local data, pos, err = json.decode(response_text)

    -- Check for JSON parsing errors
    if not data then
    error("JSON parsing failed: " .. err .. " at position " .. pos)
    end

    return data
end

local function lookup_geoip_country(txn)
    local data = geocode(txn.f:src())
    local country = data['country']
    local region = '' 
    if data['region1_name'] then
    region = data['region1_name']
    else
    region = data['city']
    end
    print('look***' .. country .. region)
    txn.http:req_add_header('cdn-requestcountrycode', country)
    txn.http:req_add_header('cdn-requeststatecode', region)
end

local function copy_real_ip_header(txn)
    local realip = txn.f:hdr('X-Forwarded-For')
    -- print('*** realip = ' .. realip)
    txn.http:req_add_header('X-Real-Ip', realip)
end


-- core.register_action('lookup_geoip_country', {'http-req'}, lookup_geoip_country, 0)
core.register_action('copy_real_ip_header', {'http-req'}, copy_real_ip_header, 0)
