-- set up SASL preferences:
sasl.options.setAircraftPanelRendering(false)
sasl.options.set3DRendering(false)
sasl.options.setInteractivity(false)

local miniHUDVersionProp = createGlobalPropertys("miniHUD/version", "v1.2.0")
sasl.logInfo("Version:", get(miniHUDVersionProp))

local instrumentPanel = loadComponent("instrumentpanel")
local instrumentWindow = contextWindow {
    name = "Instrument HUD";
    position = { 50, 50, 450, 200 };
    saveState = false;
    noDecore = true;
    noBackground = true;
    noResize = true;
    visible = true;
    proportional = false;
    gravity = {0, 0, 0, 0}; -- stick to the left bottom
    vrAuto = true;
    layer = SASL_CW_LAYER_FLIGHT_OVERLAY;
    components = {
        instrumentPanel {
            position = { 0, 0, 450, 200 };
        }
    }
}


-- create a command for toggling the HUD on and off
local toggleHUDCommand = sasl.createCommand("miniHUD/toggleHUD", "show/hide miniHUD")
sasl.registerCommandHandler(toggleHUDCommand, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        instrumentWindow:setIsVisible(not instrumentWindow:isVisible())
    end
    return 0 -- don't allow other callbacks to run
end)
