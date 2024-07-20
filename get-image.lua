package.path = package.path .. ';./controller-host/?/init.lua;./controller-host/?.lua'
local mqtt = require("mqtt")
local client

function printTable(table, indentation)
	indentation = indentation or ""
	for name, value in pairs(table) do
		print(indentation .. tostring(name) .. ": " .. tostring(value))
	end
end

local count = 0
local function onMessage(data)
	--print("Got payload on topic " .. data.topic)
	local fh = io.open("spider-image.bin", "wb")
	fh:write(data.payload)
	fh:close()
	count = count + 1
	print("Wrote image " .. count .. " of length " .. #data.payload)
end

local function onConnect(connack)
	print("Connected")
	if connack.rc ~= 0 then
		print("Connection to broker failed:", connack:reason_string())
		os.exit(1)
	end

	assert(client:subscribe{
		topic = "spider/telemetry/#"
	})

	print("Subscribed")
end

client = mqtt.client {
	uri = "mqtt.seeseepuff.be",
	id = "tool-get-image",
	reconnect = 5,
	version = mqtt.v311,
	clean = "first"
}

client:on {
	connect = onConnect,
	message = onMessage,
	error = function(err)
		print("MQTT client error:", err)
	end,
}

client:subscribe {
	topic = 'spider/controller/#'
}

mqtt.run_ioloop(client)
