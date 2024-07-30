math.randomseed(12345)

-- List of endpoints
local endpoints = { "/", "/dynamic", "/read", "/write" }

-- Function to generate a random request
request = function()
	-- Select a random endpoint
	local endpoint = endpoints[math.random(#endpoints)]
	-- Return the request object
	return wrk.format("GET", endpoint)
end
