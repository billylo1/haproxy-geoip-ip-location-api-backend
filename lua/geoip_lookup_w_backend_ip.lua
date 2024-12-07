local socket = require("socket")
local http = require("socket.http")
local url = require("socket.url")
local ltn12 = require("ltn12")
local json = require("json")

local function geocode(ip)
    -- URL of the JSON web service
    local url = "https://iplocationapi.evergreen-labs.org/api/location/" .. ip

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
    country = data['country']
    city = data['city']
    txn:set_var('txn.geoip_country', country)
    txn:set_var('txn.geoip_city', city)
end

core.register_action('lookup_geoip_country', {'tcp-req', 'http-req'}, lookup_geoip_country, 0)
