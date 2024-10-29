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
local flapsProp = nil
if sasl.getXPVersion() >= 12000 then
    -- not available in X-Plane 11
    flapsProp = globalPropertyf("sim/cockpit2/controls/flap_handle_request_ratio")
else
    flapsProp = globalPropertyf("sim/cockpit2/controls/flap_ratio")
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

local baseFontSize = 24.0

function clamp(x)
    if x > 1 then
        return 1
    elseif x < 0 then
        return 0
    else
        return x
    end
end

function update()
    if get(localState).contextWindow ~= nil and get(localState).setStartScale == false then
        local scale = get(localState).windowScale

        -- sets window size proportionally
        local cP = {0,0,945,540}
        local width = 945*scale
        local height = 540
        local center = { width / 2, height / 2 }
        local scale = math.min(width / cP[3], height / cP[4])
        cP[3] = cP[3] * scale
        cP[4] = cP[4] * scale
        cP[1] = math.floor(center[1] - cP[3] / 2)
        cP[2] = math.floor(center[2] - cP[4] / 2)

        get(localState).contextWindow:setPosition(get(localState).windowStartX, get(localState).windowStartY, cP[3], cP[4])

        get(localState).setStartScale = true
    end
end

--- Drawing callback.
function draw()
    local totalWindowHeight = get(localState).windowHeight
    local totalWindowWidth = get(localState).windowWidth

    -- tall window width
    local airspeedFrameWidth = 150

    -- small window height
    local mainFrameHeight = totalWindowHeight * 0.4
    local mainFrameWidth = totalWindowWidth - 180
    -- our virtual "pixel" unit for drawing independent of window size
    local px = mainFrameHeight * 0.01

     -- draw dark background
     sasl.gl.drawRectangle(0, 0, airspeedFrameWidth, totalWindowHeight*0.85, background)
     sasl.gl.drawRectangle(airspeedFrameWidth, 0, mainFrameWidth, mainFrameHeight, background)
 
     ------------------------------------------------------------------------
     -- airspeed indicator
     ------------------------------------------------------------------------
     local airspeedHeight = totalWindowHeight * 0.65
     local airspeedX = 75
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
     sasl.gl.drawRectangle(airspeedX-12, 75+minGreenRatio * airspeedHeight,
                           27, (maxGreenRatio-minGreenRatio) * airspeedHeight,
                           green)
     sasl.gl.drawRectangle(airspeedX-3, 75, 9, airspeedHeight * maxWhiteRatio, white)
     sasl.gl.drawRectangle(airspeedX-12, 75 + maxGreenRatio * airspeedHeight,
                           27, (maxYellowRatio-maxGreenRatio) * airspeedHeight,
                           yellow)
     sasl.gl.drawRectangle(airspeedX-12, 75 + maxYellowRatio * airspeedHeight - 3, 27, 9, red)
     sasl.gl.drawRectangle(airspeedX, 75, 3, airspeedHeight, white)
     local iasY = 75 + airspeedRatio * airspeedHeight
     sasl.gl.drawTriangle(airspeedX+9, iasY, airspeedX+30, iasY+15, airspeedX+30, iasY-15, airspeedColor)
     sasl.gl.drawTriangle(airspeedX-9, iasY, airspeedX-30, iasY+15, airspeedX-30, iasY-15, airspeedColor)
     sasl.gl.drawText(sourceCodePro, airspeedX, 12, string.format("%.0f KTS", get(airspeedProp)), baseFontSize,
                      false, false, TEXT_ALIGN_CENTER, airspeedColor)
 
     ------------------------------------------------------------------------
     -- trim indicator
     ------------------------------------------------------------------------
     local trimX = airspeedFrameWidth + (mainFrameWidth * 0.10)
     local trimRadius = px * 25
     local lineThickness = 2
      -- draw axes:
    sasl.gl.drawRectangle(trimX, px * 45, lineThickness, 2*trimRadius, white) -- elevator
    sasl.gl.drawRectangle(trimX-trimRadius, px * 45+trimRadius, 2*trimRadius, lineThickness, white) -- aileron
    sasl.gl.drawRectangle(trimX-trimRadius, px * 35, 2*trimRadius, lineThickness, white) -- rudder
    -- draw trim tab:
    sasl.gl.drawRectangle(trimX-px*3+1, px * 45+trimRadius-get(elevatorTrimProp)*trimRadius + px*1, px * 6, px * 2, white)
    sasl.gl.drawRectangle(trimX+get(aileronTrimProp)*trimRadius - px*1 +1, (px * 45)+trimRadius - px * 2 -2, px * 2, px * 6, white)
    sasl.gl.drawRectangle(trimX+get(rudderTrimProp)*trimRadius-1, px * 35 - px *3, px * 2, px * 6, white)
    -- draw control bar:
    sasl.gl.drawRectangle(trimX-1, px * 45+trimRadius, px * 3, get(elevatorControlProp)*trimRadius, white)
    sasl.gl.drawRectangle(trimX, px * 45+trimRadius-1, get(aileronControlProp)*trimRadius, px * 3, white)
    sasl.gl.drawRectangle(trimX-1, px * 35 -1, get(rudderControlProp)*trimRadius, px * 3, white)
    sasl.gl.drawText(sourceCodePro, trimX, 12, "TRIM", baseFontSize, false, false, TEXT_ALIGN_CENTER, white)
 
    
     ------------------------------------------------------------------------
     -- throttle quadrant
     ------------------------------------------------------------------------
     local throttleX = airspeedFrameWidth + (mainFrameWidth * 0.30)
     local throttleHeights = px * 55
     local throttleLineThickness = 2
     local sphereSize = 4*px
     throttleRect = {throttleX-20*px, px*25, 10*px, throttleHeights}
     sasl.gl.drawRectangle(throttleX-15*px, px*25, throttleLineThickness, throttleHeights, white)
     sasl.gl.drawText(sourceCodePro, throttleX-15*px, 12, "T", baseFontSize, false, false, TEXT_ALIGN_CENTER, white)
     sasl.gl.drawCircle(throttleX-15*px, 25 * px + get(throttleProp) * 60*px, sphereSize, true, lightGrey)

     propRect = {throttleX-5*px, px*25, 10*px, throttleHeights}
     sasl.gl.drawRectangle(throttleX, px*25, throttleLineThickness, throttleHeights, white)
     sasl.gl.drawText(sourceCodePro, throttleX, 12, "P", baseFontSize, false, false, TEXT_ALIGN_CENTER, white)
     sasl.gl.drawCircle(throttleX, 25* px + get(propProp) * 60*px, sphereSize, true, lightBlue)

     mixtureRect = {throttleX+10*px, px*25, 10*px, throttleHeights}
     sasl.gl.drawRectangle(throttleX+15*px, px*25, throttleLineThickness, throttleHeights, white)
     sasl.gl.drawText(sourceCodePro, throttleX+15*px, 12, "M", baseFontSize, false, false, TEXT_ALIGN_CENTER, white)
     sasl.gl.drawCircle(throttleX+15*px, 25* px + get(mixtureProp) * 60*px, sphereSize, true, lightRed)
 
    
     ------------------------------------------------------------------------
     -- flaps
     ------------------------------------------------------------------------
     local flapX = airspeedFrameWidth + (mainFrameWidth * 0.40)
     local flapThickness = 2
     flapsRect = {flapX-5*px, 25*px, 10*px, 40*px}
     sasl.gl.drawRectangle(flapX, 25*px, flapThickness, 40*px, white)
     sasl.gl.drawText(sourceCodePro, flapX, 12, "F", baseFontSize, false, false, TEXT_ALIGN_CENTER, white)
     sasl.gl.drawRectangle(flapX-5*px, 25 * px + (1-get(flapsProp)) * 40*px - 2, 10*px, 5*px, white)
 
     
     ------------------------------------------------------------------------
     -- vvi/altitude
     ------------------------------------------------------------------------
     local altimeterX = airspeedFrameWidth + (mainFrameWidth * 0.55)
     local altimeterY = 50*px
     local altitude = get(altitudeProp)
     local minStripAlt = math.floor(altitude/100)*100
     local altRangeMax = 3
     local altRangeMin = -2
     local totalRange = (altRangeMax - altRangeMin) * 100
     for altIdx=altRangeMin, altRangeMax do
         local stripAlt = minStripAlt + altIdx*100
         local altDifference = altitude - stripAlt
         if stripAlt >= 0 then
             sasl.gl.drawText(sourceCodePro, altimeterX, altimeterY-3*px-altDifference/(2*px),
                              string.format("%.0f", stripAlt), baseFontSize, false, false, TEXT_ALIGN_CENTER,
                              {1, 1, 1, 1-math.abs(altDifference)/totalRange})
         end
     end
     sasl.gl.drawRectangle(altimeterX-(30*px), altimeterY-(8*px), 60*px, 16*px, background)
     sasl.gl.drawFrame(altimeterX-(30*px), altimeterY-(8*px), 60*px, 16*px, white)
     sasl.gl.drawText(sourceCodePro, altimeterX, altimeterY-(4*px), string.format("%.0f", altitude), baseFontSize, false, false, TEXT_ALIGN_CENTER, white)
     local vviX = altimeterX+(29*px)
     local vviY = altimeterY + get(vviProp)*0.007
     local vviColor = white
     if vviY < altimeterY-(30*px) then
         vviY = altimeterY-(30*px)
         vviColor = orange
     elseif vviY > altimeterY+(30*px) then
         vviY = altimeterY+(30*px)
         vviColor = orange
     end
     sasl.gl.drawRectangle(vviX, altimeterY-(30*px), 1*px,  60*px, white) -- axis
     sasl.gl.drawPolyLine({vviX, vviY,
                           vviX+(8*px), vviY+(6*px), vviX+(55*px), vviY+(6*px), vviX+(55*px), vviY-(6*px), vviX+(8*px), vviY-(6*px),
                           vviX, vviY}, vviColor)
     sasl.gl.drawText(sourceCodePro, vviX+(10*px), vviY-(4*px), string.format("%+.0f", get(vviProp)), baseFontSize, false, false, TEXT_ALIGN_LEFT, vviColor)
  
     
     ------------------------------------------------------------------------
     -- compass
     ------------------------------------------------------------------------
     local compassX = airspeedFrameWidth + (mainFrameWidth * 0.90)
     local heading = get(compassProp)
     local windDirection = get(windDirectionProp)
     sasl.gl.drawCircle(compassX, (45*px), (20*px), false, white)
     -- draw HDG box with triangle pointing down:
     sasl.gl.drawRectangle(compassX-(18*px), (84*px), (36*px), (14*px), background) -- fill box
     sasl.gl.drawRectangle(compassX-(3*px), (80*px), (6*px), (4*px), background) -- fill triangle
     sasl.gl.drawPolyLine(
    {
        compassX-(18*px), (84*px),
        compassX-(18*px), (98*px),
        compassX+(18*px), (98*px),
        compassX+(18*px), (84*px),
        compassX+(4*px), (84*px),
        compassX, (78*px), compassX-(4*px), -- pointy bit
        (84*px), compassX-(18*px), 
        (84*px)
    }, white)
     sasl.gl.drawText(sourceCodePro, compassX, (86*px), string.format("%.0f°", heading), baseFontSize, false, false, TEXT_ALIGN_CENTER, white)
 
     -- draw compass circle:
     sasl.gl.saveGraphicsContext()
     sasl.gl.setTranslateTransform(compassX, (45*px))
     sasl.gl.setRotateTransform(-heading)
     sasl.gl.drawText(sourceCodePro, 0, (22*px), "N", baseFontSize, false, false, TEXT_ALIGN_CENTER, white)
     sasl.gl.drawText(sourceCodePro, 0, (-30*px), "S", baseFontSize, false, false, TEXT_ALIGN_CENTER, lightGrey)
     sasl.gl.drawText(sourceCodePro, (22*px), (-4*px), "E", baseFontSize, false, false, TEXT_ALIGN_LEFT, lightGrey)
     sasl.gl.drawText(sourceCodePro, (-22*px), (-4*px), "W", baseFontSize, false, false, TEXT_ALIGN_RIGHT, lightGrey)
     -- draw ticks:
     for angle=1,12 do
         sasl.gl.setRotateTransform(30)
         if angle == 3 or angle == 6 or angle == 9 or angle == 12 then
             sasl.gl.drawRectangle(0, (14*px), (1*px), (6*px), white) -- long ticks at cardinals
         else
             sasl.gl.drawRectangle(0, (18*px), (1*px), (5*px), white) -- short ticks elsewhere
         end
     end
 
     -- draw wind indicator
     sasl.gl.setRotateTransform(windDirection)
     local windSpeed = get(windSpeedProp)
     local numTriangles = math.floor(windSpeed/50)
     windSpeed = windSpeed - numTriangles * 50
     local numLong = math.floor(windSpeed/10)
     windSpeed = windSpeed - numLong * 10
     local numShort = math.floor(windSpeed/5)
     local barblength = (26*px)
     if windSpeed < 50 then
         barblength = (20*px)
     end
     sasl.gl.drawRectangle(0, -barblength/2, 1, barblength, greyBlue)
     local currentY = barblength/2
     for triangle=1,numTriangles do
         sasl.gl.drawTriangle(0, currentY, 0, currentY-(5*px), -(6*px), currentY+(2*px), greyBlue)
         currentY = currentY - (6*px)
     end
     currentY = currentY - (2*px)
     for long=1,numLong do
         sasl.gl.drawLine(0, currentY, (-6*px), currentY+(5*px), greyBlue)
         currentY = currentY - (3*px)
     end
     for short=1,numShort do
         sasl.gl.drawLine(0, currentY, -(3*px), currentY+(3*px), greyBlue)
         currentY = currentY - (3*px)
     end
     sasl.gl.restoreGraphicsContext()
     sasl.gl.drawText(sourceCodePro, compassX, 8, string.format("WIND %.0f", windDirection), baseFontSize, false, false, TEXT_ALIGN_CENTER, greyBlue)

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
