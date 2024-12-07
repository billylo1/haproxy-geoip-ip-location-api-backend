package.cpath = "/opt/homebew;/Users/billylo/.luarocks/lib/lua/5.4/?.so;/opt/homebrew/lib/lua/5.4/?.so"

print(package.path)
print(package.cpath)

local http = require("http")
local json = require("json")

-- Example usage with a hypothetical weather API
local geoapi_url = "https://iplocationapi.evergreen-labs.org/api/location/8.8.8.8"

local response, err = http.request(geoapi_url)

if err then
  error("Weather API request failed: " .. err)
end

local geodata = json.decode(response)

if not geodata then
  error("geodata JSON parsing failed")
end

print("Country: " .. geodata.city)