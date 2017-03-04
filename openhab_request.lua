--------------------------------------
-- Sends the data to an OpenHAB server using REST API.
-- Data is concatenated with ; as a separator. That 
-- allows to send all the data using only one request
-- but requires additional OpenHAB parse rule. Next 
-- OpenHAB rule can be used for splitting:
--
-- rule "Parse Window State"
-- when
-- Item WindowStateRaw received update
-- then
-- 	var String[] buffer = WindowStateRaw.state.toString.split(";")
-- 	if ( buffer.size == 5 ) {
-- 		if ( buffer.get(4) == "1" ) {
--			postUpdate( Window1Contact,	buffer.get(0) )
--			postUpdate( Window1Battery,	buffer.get(2) )
--		} else if ( buffer.get(4) == "2" ) {
--			postUpdate( Window2Contact,	buffer.get(0) )
--			postUpdate( Window2Battery,	buffer.get(2) )
--		} ...
--	}
-- end
--------------------------------------
-- Used Variables:
-- switch     = switch_state  = the state of the switch
-- quality    = quality       = wifi signal strength in %
-- vbat       = vbat          = battery voltage
-- temp       = ds_temp       = ds18b20 temperature
-- sensor_id  = SENSOR_ID     = unique id of the sensor

--------------------------------------
-- for a standalone test uncomment this line:
--switch_pin=6 quality=0 vbat=0 ds_temp=0 SENSOR_ID=0 vreg_shutdown=function()end


--------------------------------------
-- OpenHAB API config
--------------------------------------
-- server ip
API_IP = "openhab"
-- server port
API_PORT = 8080
-- OpenHab item to use
API_ITEM = "WindowStateRaw"


----------------------------------------------------------------------------
----------------------------------------------------------------------------

--------------------------------------
-- read the state of the switch
--------------------------------------
if gpio.read(switch_pin) == 1 then
    switch_state = "OPEN"
else
    switch_state = "CLOSED"
end
print("\n Switch is \"" ..switch_state .."\"")
print(" Updating OpenHAB item: " ..API_ITEM)

--------------------------------------
-- append all the data to single variable
--------------------------------------
data = switch_state..";"..quality ..";"..vbat ..";"..ds_temp ..";"..SENSOR_ID
print(" Data: " ..data)

--------------------------------------
-- measure the time it takes to get a respone
local re_timer = tmr.now()
--------------------------------------
-- flag that checks if the on:receive event already got called
local got_response = false

-- create the connection
local reqConn = net.createConnection(net.TCP, 0)
-- if got a response, parse it...
reqConn:on("receive", function(reqConn, payload)
    -- ...but only if not already done that
    if not got_response then
        got_response = true
        -- search for the "200 OK" status code
        if string.find(payload, "HTTP/1.1 200 OK") or string.find(payload, "HTTP/1.1 202 Accepted") then
            -- stop the retry timer and print SUCCESS
            tmr.stop(0)
            print(string.format(" -> SUCCESS (%.2fs)\n", (tmr.now()-re_timer)/1000/1000))
            -- light up the "ok" led and shut down
            gpio.write(ok_led_pin, 1)
            vreg_shutdown()
        else
            -- if the returned status code is not 200, print the response to see what happened
            -- also light up the "error" led
            gpio.write(error_led_pin, 1)
            print(payload)
            print("\n\n -> FAIL\n")
        end
    end
end)

-- send the request
reqConn:connect(API_PORT, API_IP)
reqConn:on("connection", function(conn, payload)
                        conn:send(
							"PUT /rest/items/" ..API_ITEM .."/state HTTP/1.1\r\n" 
							.."host: "..API_IP..":"..API_PORT.."\r\n" 
							.."Content-Type: text/plain\r\n"
							.."Content-Length: "..string.len(data).."\r\n"
							.."\r\n"
							..data)
                       end)
