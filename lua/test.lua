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

local function split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t={}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

local output = geocode("4.4.4.4")

print(output.country)
print(output.city)
