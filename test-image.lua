package.path = package.path .. ';./controller-host/?/init.lua;./controller-host/?.lua'
local mqtt = require("mqtt")
local socket = require("socket")

local function onConnect(connack)
	if connack.rc ~= 0 then
		print("Connection to broker failed:", connack:reason_string())
		os.exit(1)
	end

	assert(client:publish {
		topic = "spider/telemetry/camfeed",
		payload = string.rep("a", 537726),
		qos = 0
	})

	print("Connected and subscribed")
end

client = mqtt.client {
	uri = "mqtt.seeseepuff.be",
	id = "tool-test-image",
	clean = true,
	reconnect = 5,
	version = mqtt.v311,
}

client:on {
	connect = onConnect,
	message = onMessage,
	error = function(err)
		print("MQTT client error:", err)
	end,
}

mqtt.run_ioloop(client)

