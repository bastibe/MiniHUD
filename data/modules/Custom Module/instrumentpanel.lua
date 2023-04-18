local sourceCodePro = sasl.gl.loadFont("fonts/SourceCodePro.ttf")
local white = {1.0, 1.0, 1.0, 1.0}
local green = {0.2, 0.9, 0.2, 1.0}
local yellow = {0.9, 0.9, 0.2, 1.0}
local red = {0.9, 0.2, 0.2, 1.0}
local lightRed = {0.9, 0.4, 0.4, 1.0}
local lightBlue = {0.4, 0.4, 0.9, 1.0}
local lightGrey = {0.8, 0.8, 0.8, 1.0}
local background = {0.0, 0.0, 0.0, 0.4}

local airspeedProp = globalPropertyf("sim/cockpit2/gauges/indicators/airspeed_kts_pilot")
local vneProp = globalPropertyf("sim/aircraft/view/acf_Vne")
local vfeProp = globalPropertyf("sim/aircraft/view/acf_Vfe")
local vnoProp = globalPropertyf("sim/aircraft/view/acf_Vno")
local vsoProp = globalPropertyf("sim/aircraft/view/acf_Vso")
local vsProp = globalPropertyf("sim/aircraft/view/acf_Vs")
local altitudeProp = globalPropertyf("sim/cockpit2/gauges/indicators/altitude_ft_pilot")
local aoaProp = globalPropertyf("sim/cockpit2/gauges/indicators/AoA_pilot")
local compassProp = globalPropertyf("sim/cockpit2/gauges/indicators/compass_heading_deg_mag")
local vviProp = globalPropertyf("sim/cockpit2/gauges/indicators/vvi_fpm_pilot")
local aileronTrimProp = globalPropertyf("sim/cockpit2/controls/aileron_trim")
local elevatorTrimProp = globalPropertyf("sim/cockpit2/controls/elevator_trim")
local rudderTrimProp = globalPropertyf("sim/cockpit2/controls/rudder_trim")
local rudderControlProp = globalPropertyf("sim/cockpit2/controls/yoke_heading_ratio")
local elevatorControlProp = globalPropertyf("sim/cockpit2/controls/yoke_pitch_ratio")
local aileronControlProp = globalPropertyf("sim/cockpit2/controls/yoke_roll_ratio")
local flapProp = globalPropertyf("sim/cockpit2/controls/flap_handle_request_ratio")
local mixtureProp = globalPropertyf("sim/cockpit2/engine/actuators/mixture_ratio_all")
local propProp = globalPropertyf("sim/cockpit2/engine/actuators/prop_ratio_all")
local throttleProp = globalPropertyf("sim/cockpit2/engine/actuators/throttle_ratio_all")

--- Drawing callback.
function draw()
    sasl.gl.drawRectangle(0, 0, 60, 200, background)
    sasl.gl.drawRectangle(60, 0, 340, 110, background)

    ------------------------------------------------------------------------
    -- airspeed indicator
    ------------------------------------------------------------------------
    local airspeedHeight = size[2]-35
    local airspeedX = 30
    local maxAirspeed = get(vneProp) * 1.2
    local minAirspeed = get(vsoProp)
    local minGreenRatio = (get(vsProp) - minAirspeed) / (maxAirspeed - minAirspeed)
    local maxWhiteRatio = (get(vfeProp) - minAirspeed) / (maxAirspeed - minAirspeed)
    local maxGreenRatio = (get(vnoProp) - minAirspeed) / (maxAirspeed - minAirspeed)
    local maxYellowRatio = (get(vneProp) - minAirspeed) / (maxAirspeed - minAirspeed)
    local airspeedRatio = (get(airspeedProp) - minAirspeed) / (maxAirspeed - minAirspeed)
    sasl.gl.drawRectangle(26, 25+minGreenRatio * airspeedHeight,
                          9, (maxGreenRatio-minGreenRatio) * airspeedHeight,
                          green)
    sasl.gl.drawRectangle(airspeedX-1, 25, 3, airspeedHeight * maxWhiteRatio, white)
    sasl.gl.drawRectangle(airspeedX-4, 25 + maxGreenRatio * airspeedHeight,
                          9, (maxYellowRatio-maxGreenRatio) * airspeedHeight,
                          yellow)
    sasl.gl.drawRectangle(airspeedX-4, 25 + maxYellowRatio * airspeedHeight - 1, 9, 3, red)
    sasl.gl.drawRectangle(airspeedX, 25, 1, airspeedHeight, white)
    local iasY = 25 + airspeedRatio * airspeedHeight
    sasl.gl.drawTriangle(airspeedX+3, iasY, airspeedX+10, iasY+5, airspeedX+10, iasY-5, white)
    sasl.gl.drawTriangle(airspeedX-3, iasY, airspeedX-10, iasY+5, airspeedX-10, iasY-5, white)
    sasl.gl.drawText(sourceCodePro, airspeedX, 12, string.format("%.0f KTS", get(airspeedProp)), 12, false, false, TEXT_ALIGN_CENTER, white)

    ------------------------------------------------------------------------
    -- trim indicator
    ------------------------------------------------------------------------
    local trimX = 90
    local trimRadius = 25
    -- draw axes:
    sasl.gl.drawRectangle(trimX, 45, 1, 2*trimRadius, white) -- elevator
    sasl.gl.drawRectangle(trimX-trimRadius, 45+trimRadius, 2*trimRadius, 1, white) -- aileron
    sasl.gl.drawRectangle(trimX-trimRadius, 33, 2*trimRadius, 1, white) -- rudder
    -- draw trim tab:
    sasl.gl.drawRectangle(trimX-3, 45+trimRadius-get(elevatorTrimProp)*trimRadius-1, 7, 3, white)
    sasl.gl.drawRectangle(trimX+get(aileronTrimProp)*trimRadius-1, 45+trimRadius-3, 3, 7, white)
    sasl.gl.drawRectangle(trimX+get(rudderTrimProp)*trimRadius-1, 33-3, 3, 7, white)
    -- draw control bar:
    sasl.gl.drawRectangle(trimX-1, 45+trimRadius, 3, get(elevatorControlProp)*trimRadius, white)
    sasl.gl.drawRectangle(trimX, 45+trimRadius-1, get(aileronControlProp)*trimRadius, 3, white)
    sasl.gl.drawRectangle(trimX-1, 33-1, get(rudderControlProp)*trimRadius, 3, white)
    sasl.gl.drawText(sourceCodePro, trimX, 12, "TRIM", 12, false, false, TEXT_ALIGN_CENTER, white)

    ------------------------------------------------------------------------
    -- throttle quadrant
    ------------------------------------------------------------------------
    local throttleX = 155
    sasl.gl.drawRectangle(throttleX-15, 25, 1, 60, white)
    sasl.gl.drawText(sourceCodePro, throttleX-15, 12, "T", 12, false, false, TEXT_ALIGN_CENTER, white)
    sasl.gl.drawCircle(throttleX-15, 25 + get(throttleProp) * 60, 5, true, lightGrey)
    sasl.gl.drawRectangle(throttleX, 25, 1, 60, white)
    sasl.gl.drawText(sourceCodePro, throttleX, 12, "P", 12, false, false, TEXT_ALIGN_CENTER, white)
    sasl.gl.drawCircle(throttleX, 25 + get(propProp) * 60, 5, true, lightBlue)
    sasl.gl.drawRectangle(throttleX+15, 25, 1, 60, white)
    sasl.gl.drawText(sourceCodePro, throttleX+15, 12, "M", 12, false, false, TEXT_ALIGN_CENTER, white)
    sasl.gl.drawCircle(throttleX+15, 25 + get(mixtureProp) * 60, 5, true, lightRed)

    ------------------------------------------------------------------------
    -- flaps
    ------------------------------------------------------------------------
    local flapX = 195
    sasl.gl.drawRectangle(flapX, 25, 1, 40, white)
    sasl.gl.drawText(sourceCodePro, flapX, 12, "F", 12, false, false, TEXT_ALIGN_CENTER, white)
    sasl.gl.drawRectangle(flapX-5, 25 + (1-get(flapProp)) * 40 - 2, 10, 5, white)

    ------------------------------------------------------------------------
    -- vvi/altitude
    ------------------------------------------------------------------------
    local altimeterX = 255
    local altitude = get(altitudeProp)
    local minStripAlt = math.floor(altitude/100)*100
    for altIdx=-3, 3 do
        local stripAlt = minStripAlt + altIdx*100
        local altDifference = altitude - stripAlt
        if stripAlt >= 0 then
            sasl.gl.drawText(sourceCodePro, altimeterX, 60-5-altDifference/7,
                             string.format("%.0f", stripAlt), 12, false, false, TEXT_ALIGN_CENTER,
                             {1, 1, 1, 1-math.abs(altDifference)/400})
        end
    end
    sasl.gl.drawRectangle(altimeterX-30, 60-8, 60, 16, background)
    sasl.gl.drawFrame(altimeterX-30, 60-8, 60, 16, white)
    sasl.gl.drawText(sourceCodePro, altimeterX, 60-5, string.format("%.0f", altitude), 12, false, false, TEXT_ALIGN_CENTER, white)
    local vviX = altimeterX+29
    local vviY = 60 + get(vviProp)*0.007
    sasl.gl.drawRectangle(vviX, 60-30, 1,  60, white) -- axis
    sasl.gl.drawPolyLine({vviX, vviY,
                          vviX+8, vviY+6, vviX+55, vviY+6, vviX+55, vviY-6, vviX+8, vviY-6,
                          vviX, vviY}, white)
    sasl.gl.drawText(sourceCodePro, vviX+10, vviY-4, string.format("%+.0f", get(vviProp)), 12, false, false, TEXT_ALIGN_LEFT, white)

    ------------------------------------------------------------------------
    -- compass
    ------------------------------------------------------------------------
    local compassX = 370
    local heading = get(compassProp)
    sasl.gl.drawCircle(compassX, 60, 20, false, white)
    sasl.gl.drawText(sourceCodePro, compassX, 12, string.format("%.0f", heading), 12, false, false, TEXT_ALIGN_CENTER, white)

    sasl.gl.saveGraphicsContext()
    sasl.gl.setTranslateTransform(compassX, 60)
    sasl.gl.setRotateTransform(-heading)
    sasl.gl.drawRectangle(0, 0, 1, 19, white)
    sasl.gl.drawTriangle(-5, 19-5, 0, 19, 5, 19-5, white)
    sasl.gl.drawText(sourceCodePro, 0, 22, "N", 12, false, false, TEXT_ALIGN_CENTER, white)
    sasl.gl.drawRectangle(16, 0, 8, 1, white)
    sasl.gl.drawRectangle(-24, 0, 8, 1, white)
    sasl.gl.drawRectangle(0, -24, 1, 8, white)
    sasl.gl.restoreGraphicsContext()
end
