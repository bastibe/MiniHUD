local sourceCodePro = sasl.gl.loadFont("fonts/SourceCodePro.ttf")
local white = {1.0, 1.0, 1.0, 1.0}
local green = {0.2, 0.9, 0.2, 1.0}
local yellow = {0.9, 0.9, 0.2, 1.0}
local red = {0.9, 0.2, 0.2, 1.0}
local orange = {0.9, 0.5, 0.2, 1.0}
local lightRed = {0.9, 0.4, 0.4, 1.0}
local lightBlue = {0.4, 0.4, 0.9, 1.0}
local lightGrey = {0.8, 0.8, 0.8, 1.0}
local greyBlue = {0.6, 0.6, 0.9, 1.0}
local background = {0.0, 0.0, 0.0, 0.4}

local airspeedProp = globalPropertyf("sim/cockpit2/gauges/indicators/airspeed_kts_pilot")
local vneProp = globalPropertyf("sim/aircraft/view/acf_Vne")
local vfeProp = globalPropertyf("sim/aircraft/view/acf_Vfe")
local vnoProp = globalPropertyf("sim/aircraft/view/acf_Vno")
local vsoProp = globalPropertyf("sim/aircraft/view/acf_Vso")
local vsProp = globalPropertyf("sim/aircraft/view/acf_Vs")
local altitudeProp = globalPropertyf("sim/cockpit2/gauges/indicators/altitude_ft_pilot")
local compassProp = globalPropertyf("sim/cockpit2/gauges/indicators/ground_track_mag_pilot")
local vviProp = globalPropertyf("sim/cockpit2/gauges/indicators/vvi_fpm_pilot")
local altitudeAGLProp = globalPropertyf("sim/flightmodel/position/y_agl")
local aileronTrimProp = globalPropertyf("sim/cockpit2/controls/aileron_trim")
local elevatorTrimProp = globalPropertyf("sim/cockpit2/controls/elevator_trim")
local rudderTrimProp = globalPropertyf("sim/cockpit2/controls/rudder_trim")
local rudderControlProp = globalPropertyf("sim/cockpit2/controls/yoke_heading_ratio")
local elevatorControlProp = globalPropertyf("sim/cockpit2/controls/yoke_pitch_ratio")
local aileronControlProp = globalPropertyf("sim/cockpit2/controls/yoke_roll_ratio")
if sasl.getXPVersion() >= 12 then
    local flapsProp = globalPropertyf("sim/cockpit2/controls/flap_handle_request_ratio")
else
    local flapsProp = globalPropertyf("sim/cockpit2/controls/flap_ratio")
end
local mixtureProp = globalPropertyf("sim/cockpit2/engine/actuators/mixture_ratio_all")
local propProp = globalPropertyf("sim/cockpit2/engine/actuators/prop_ratio_all")
local throttleProp = globalPropertyf("sim/cockpit2/engine/actuators/throttle_ratio_all")
local windDirectionProp = globalPropertyf("sim/cockpit2/gauges/indicators/wind_heading_deg_mag")
local windSpeedProp = globalPropertyf("sim/cockpit2/gauges/indicators/wind_speed_kts")

local throttleRect = {0, 0, 0, 0}
local propRect = {0, 0, 0, 0}
local mixtureRect = {0, 0, 0, 0}
local flapsRect = {0, 0, 0, 0}


function clamp(x)
    if x > 1 then
        return 1
    elseif x < 0 then
        return 0
    else
        return x
    end
end


--- Drawing callback.
function draw()
    -- draw dark background
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
    local airspeedColor = white
    if airspeedRatio > 1 then
        airspeedRatio = 1
        airspeedColor = orange
    elseif airspeedRatio < 0 then
        airspeedRatio = 0
        if get(altitudeAGLProp) > 10 then
            airspeedColor = orange
        end
    end
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
    sasl.gl.drawTriangle(airspeedX+3, iasY, airspeedX+10, iasY+5, airspeedX+10, iasY-5, airspeedColor)
    sasl.gl.drawTriangle(airspeedX-3, iasY, airspeedX-10, iasY+5, airspeedX-10, iasY-5, airspeedColor)
    sasl.gl.drawText(sourceCodePro, airspeedX, 12, string.format("%.0f KTS", get(airspeedProp)), 12,
                     false, false, TEXT_ALIGN_CENTER, airspeedColor)

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
    throttleRect = {throttleX-15-5, 25, 10, 60}
    sasl.gl.drawRectangle(throttleX-15, 25, 1, 60, white)
    sasl.gl.drawText(sourceCodePro, throttleX-15, 12, "T", 12, false, false, TEXT_ALIGN_CENTER, white)
    sasl.gl.drawCircle(throttleX-15, 25 + get(throttleProp) * 60, 5, true, lightGrey)
    propRect = {throttleX-5, 25, 10, 60}
    sasl.gl.drawRectangle(throttleX, 25, 1, 60, white)
    sasl.gl.drawText(sourceCodePro, throttleX, 12, "P", 12, false, false, TEXT_ALIGN_CENTER, white)
    sasl.gl.drawCircle(throttleX, 25 + get(propProp) * 60, 5, true, lightBlue)
    mixtureRect = {throttleX+15-5, 25, 10, 60}
    sasl.gl.drawRectangle(throttleX+15, 25, 1, 60, white)
    sasl.gl.drawText(sourceCodePro, throttleX+15, 12, "M", 12, false, false, TEXT_ALIGN_CENTER, white)
    sasl.gl.drawCircle(throttleX+15, 25 + get(mixtureProp) * 60, 5, true, lightRed)

    ------------------------------------------------------------------------
    -- flaps
    ------------------------------------------------------------------------
    local flapX = 195
    flapsRect = {flapX-5, 25, 10, 40}
    sasl.gl.drawRectangle(flapX, 25, 1, 40, white)
    sasl.gl.drawText(sourceCodePro, flapX, 12, "F", 12, false, false, TEXT_ALIGN_CENTER, white)
    sasl.gl.drawRectangle(flapX-5, 25 + (1-get(flapsProp)) * 40 - 2, 10, 5, white)

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
    local vviColor = white
    if vviY < 60-30 then
        vviY = 60-30
        vviColor = orange
    elseif vviY > 60+30 then
        vviY = 60+30
        vviColor = orange
    end
    sasl.gl.drawRectangle(vviX, 60-30, 1,  60, white) -- axis
    sasl.gl.drawPolyLine({vviX, vviY,
                          vviX+8, vviY+6, vviX+55, vviY+6, vviX+55, vviY-6, vviX+8, vviY-6,
                          vviX, vviY}, vviColor)
    sasl.gl.drawText(sourceCodePro, vviX+10, vviY-4, string.format("%+.0f", get(vviProp)), 12, false, false, TEXT_ALIGN_LEFT, vviColor)

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

    -- draw wind indicator
    sasl.gl.setRotateTransform(get(windDirectionProp))
    local windSpeed = get(windSpeedProp)
    local numTriangles = math.floor(windSpeed/50)
    windSpeed = windSpeed - numTriangles * 50
    local numLong = math.floor(windSpeed/10)
    windSpeed = windSpeed - numLong * 10
    local numShort = math.floor(windSpeed/5)
    local barblength = 26
    if windSpeed < 50 then
        barblength = 20
    end
    sasl.gl.drawRectangle(0, -barblength/2, 1, barblength, greyBlue)
    local currentY = barblength/2
    for triangle=1,numTriangles do
        sasl.gl.drawTriangle(0, currentY, 0, currentY-5, -6, currentY+2, greyBlue)
        currentY = currentY - 6
    end
    currentY = currentY - 2
    for long=1,numLong do
        sasl.gl.drawLine(0, currentY, -6, currentY+5, greyBlue)
        currentY = currentY - 3
    end
    for short=1,numShort do
        sasl.gl.drawLine(0, currentY, -3, currentY+3, greyBlue)
        currentY = currentY - 3
    end
    sasl.gl.restoreGraphicsContext()
end


function onMouseDown(comp, x, y, button, parentX, parentY)
    if button ~= MB_LEFT then
        return false  -- allow other callbacks to run (e.g. moving the HUD window)
    end
    if isInRect(throttleRect, x, y) then
        set(throttleProp, clamp((y-throttleRect[2])/throttleRect[4]))
    elseif isInRect(propRect, x, y) then
        set(propProp, clamp((y-propRect[2])/propRect[4]))
    elseif isInRect(mixtureRect, x, y) then
        set(mixtureProp, clamp((y-mixtureRect[2])/mixtureRect[4]))
    elseif isInRect(flapsRect, x, y) then
        set(flapsProp, clamp((y-flapsRect[2])/flapsRect[4]))
    else
        return false
    end
    return true
end


function onMouseHold(comp, x, y, button, parentX, parentY)
    if button ~= MB_LEFT then
        return false  -- allow other callbacks to run (e.g. moving the HUD window)
    end
    if isInRect(throttleRect, x, y) then
        set(throttleProp, clamp((y-throttleRect[2])/throttleRect[4]))
    elseif isInRect(propRect, x, y) then
        set(propProp, clamp((y-propRect[2])/propRect[4]))
    elseif isInRect(mixtureRect, x, y) then
        set(mixtureProp, clamp((y-mixtureRect[2])/mixtureRect[4]))
    elseif isInRect(flapsRect, x, y) then
        set(flapsProp, 1-clamp((y-flapsRect[2])/flapsRect[4]))
    else
        return false
    end
    return true
end
