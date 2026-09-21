local ADDON_NAME, NS = ...

local frames
local eventFrame = CreateFrame("Frame")

local function GetGroupOrder()
    -- Match Danders' getter contract: callers receive their own ordered array.
    return { 1, 3, 5, 7, 2, 4, 6, 8 }
end

local function RefreshGroupOrder()
    if InCombatLockdown() then
        eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end

    eventFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
    if not frames.raidPositionHandler then return end

    -- Danders may have built its headers before this companion loaded. Push
    -- the new order, then let its existing secure positioner apply the layout.
    frames:UpdateRaidGroupOrderAttributes()
    frames:TriggerRaidPosition()
end

local handlers = {}

function handlers.ADDON_LOADED(self, loadedAddon)
    if loadedAddon ~= ADDON_NAME then return end
    self:UnregisterEvent("ADDON_LOADED")

    frames = DandersFrames
    if not frames or type(frames.GetEffectiveRaidGroupOrder) ~= "function"
        or type(frames.UpdateRaidGroupOrderAttributes) ~= "function"
        or type(frames.TriggerRaidPosition) ~= "function" then
        print("|cff00cc00" .. ADDON_NAME .. "|r: Danders Frames' group-order interface is unavailable; companion inactive.")
        return
    end

    -- This shared getter feeds header creation, subsequent secure attribute
    -- updates, and preview sorting. A post-hook cannot change its return value.
    -- Supply the order here so Danders continues to own filtering, geometry,
    -- unit sorting, and combat updates without changing any saved settings.
    frames.GetEffectiveRaidGroupOrder = GetGroupOrder
    RefreshGroupOrder()
end

handlers.PLAYER_REGEN_ENABLED = RefreshGroupOrder

eventFrame:SetScript("OnEvent", function(self, event, ...)
    local handler = handlers[event]
    if handler then handler(self, ...) end
end)
eventFrame:RegisterEvent("ADDON_LOADED")
