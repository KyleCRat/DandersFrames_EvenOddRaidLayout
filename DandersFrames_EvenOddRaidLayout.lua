local ADDON_NAME, NS = ...

local GROUP_ORDER = { 1, 3, 5, 7, 2, 4, 6, 8 }
local frames
local observedPositionHandler
local refreshQueued = false
local eventFrame = CreateFrame("Frame")

local function BuildGroupOrder(highestGroup)
    local lastPairedGroup = highestGroup - highestGroup % 2
    local order = {}
    for _, group in ipairs(GROUP_ORDER) do
        if group <= lastPairedGroup then
            order[#order + 1] = group
        end
    end

    -- Only an odd highest group is unpaired. Inner gaps still count as pairs;
    -- append the remaining groups to preserve the complete eight-group order.
    for group = lastPairedGroup + 1, 8 do
        order[#order + 1] = group
    end
    return order
end

local function GetGroupOrder(self, db)
    db = db or self:GetRaidDB()
    local highestGroup = 0
    local handler = self.raidPositionHandler
    if handler then
        for group = 1, 8 do
            local visible = not db.raidGroupVisible or db.raidGroupVisible[group] ~= false
            -- Use Danders' displayed counts to find the end of the group range.
            if visible and (handler:GetAttribute("group" .. group .. "count") or 0) > 0 then
                highestGroup = group
            end
        end
    end

    -- Header initialization and reverse lookups require a fresh permutation
    -- of all eight groups, even when only some groups occupy display slots.
    return BuildGroupOrder(highestGroup)
end

local function SortActiveGroups(self, activeGroupList)
    local displayed = {}
    local highestGroup = 0
    for _, group in ipairs(activeGroupList) do
        displayed[group] = true
        highestGroup = math.max(highestGroup, group)
    end

    -- Previews supply their own range. Keep Danders' active membership while
    -- sorting it as though every group through the highest one were present.
    local order = BuildGroupOrder(highestGroup)
    local index = 1
    for _, group in ipairs(order) do
        if displayed[group] then
            activeGroupList[index] = group
            index = index + 1
        end
    end
end

local function RefreshGroupOrder()
    if InCombatLockdown() then
        eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end

    eventFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
    local handler = frames.raidPositionHandler
    if not handler or not frames:GetRaidDB().raidUseGroups then return end
    if handler:GetAttribute("suppressreposition") == 1 then return end

    local order = frames:GetEffectiveRaidGroupOrder()
    for position, group in ipairs(order) do
        if handler:GetAttribute("displayorder" .. position) ~= group then
            frames:UpdateRaidGroupOrderAttributes()
            frames:TriggerRaidPosition()
            return
        end
    end
end

local function QueueRefresh()
    if InCombatLockdown() then
        eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end
    if refreshQueued then return end

    -- Let Danders finish its count/visibility batch. Re-read current state in
    -- the callback, including combat if it began after the refresh was queued.
    refreshQueued = true
    C_Timer.After(0, function()
        refreshQueued = false
        RefreshGroupOrder()
    end)
end

local function OnPositionAttributeChanged(self, name, value)
    if name:match("^group[1-8]count$") or name == "flatmodeactive"
        or (name == "suppressreposition" and value == 0) then
        QueueRefresh()
    end
end

local function ObservePositionHandler()
    if InCombatLockdown() then
        eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end

    local handler = frames.raidPositionHandler
    if not handler or handler == observedPositionHandler then return end

    -- Observe counts without replacing the native secure script or its roster
    -- updates. This also catches child visibility changes after a roster pass.
    handler:HookScript("OnAttributeChanged", OnPositionAttributeChanged)
    observedPositionHandler = handler
    QueueRefresh()
end

local handlers = {}

function handlers.ADDON_LOADED(self, loadedAddon)
    if loadedAddon ~= ADDON_NAME then return end
    self:UnregisterEvent("ADDON_LOADED")

    frames = DandersFrames
    if not frames or type(frames.GetEffectiveRaidGroupOrder) ~= "function"
        or type(frames.GetRaidDB) ~= "function"
        or type(frames.SortActiveGroupListByDisplayOrder) ~= "function"
        or type(frames.CreateRaidPositionHandler) ~= "function"
        or type(frames.UpdateRaidGroupOrderAttributes) ~= "function"
        or type(frames.TriggerRaidPosition) ~= "function" then
        print("|cff00cc00" .. ADDON_NAME .. "|r: Danders Frames' group-order interface is unavailable; companion inactive.")
        return
    end

    -- Replace only the returned order; Danders still owns secure positioning.
    -- Its active-list sorter can be post-hooked because it mutates the list.
    frames.GetEffectiveRaidGroupOrder = GetGroupOrder
    hooksecurefunc(frames, "SortActiveGroupListByDisplayOrder", SortActiveGroups)
    hooksecurefunc(frames, "CreateRaidPositionHandler", ObservePositionHandler)
    ObservePositionHandler()
end

function handlers.PLAYER_REGEN_ENABLED()
    ObservePositionHandler()
    QueueRefresh()
end

eventFrame:SetScript("OnEvent", function(self, event, ...)
    local handler = handlers[event]
    if handler then handler(self, ...) end
end)
eventFrame:RegisterEvent("ADDON_LOADED")
