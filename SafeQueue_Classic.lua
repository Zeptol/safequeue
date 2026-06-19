if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then return end

local SafeQueue = SafeQueue

local CreateFrame = CreateFrame
local ENTER_BATTLE = ENTER_BATTLE
local GetBattlefieldPortExpiration = GetBattlefieldPortExpiration
local GetBattlefieldStatus = GetBattlefieldStatus
local GetMapInfo = C_Map and C_Map.GetMapInfo
local GetMaxBattlefieldID = GetMaxBattlefieldID
local InCombatLockdown = InCombatLockdown
local MAX_BATTLEFIELD_QUEUES = MAX_BATTLEFIELD_QUEUES
local PVPReadyDialog = PVPReadyDialog
local PlaySound = PlaySound
local REQUIRES_RELOAD = REQUIRES_RELOAD
local SOUNDKIT = SOUNDKIT
local StaticPopupSpecial_Hide = StaticPopupSpecial_Hide
local StaticPopup_Hide = StaticPopup_Hide
local _G = _G
local format = format
local hooksecurefunc = hooksecurefunc
local issecurevariable = issecurevariable
local tostring = tostring
local tonumber = tonumber

local function GetNumBattlefieldQueues()
    local maxQueues = MAX_BATTLEFIELD_QUEUES or 0
    local maxBattlefieldID = GetMaxBattlefieldID and GetMaxBattlefieldID() or 0
    if maxBattlefieldID > maxQueues then maxQueues = maxBattlefieldID end
    return maxQueues
end

local function IsBattlefieldConfirm(status)
    return status == "confirm" or status == "confirmed"
end

local function GetBattlegroundMapName(mapID, fallback)
    local info = GetMapInfo and GetMapInfo(mapID)
    return (info and info.name) or fallback
end

local ALTERAC_VALLEY = GetBattlegroundMapName(1459, "Alterac Valley")
local WARSONG_GULCH = GetBattlegroundMapName(1460, "Warsong Gulch")
local ARATHI_BASIN = GetBattlegroundMapName(1461, "Arathi Basin")

local BATTLEGROUND_COLORS = {
    default = "ffd100",
    [ALTERAC_VALLEY] = "007fff",
    [WARSONG_GULCH] = "00ff00",
    [ARATHI_BASIN] = "ffd100",
}

hooksecurefunc("StaticPopup_Show", function(name, _,_, i)
    if name ~= "CONFIRM_BATTLEFIELD_ENTRY" then return end
    SafeQueue.battlefieldId = i
    if SafeQueue.SetExpiresText then SafeQueue:SetExpiresText() end
end)

SafeQueue:RegisterEvent("ADDON_ACTION_FORBIDDEN")

function SafeQueue:ADDON_ACTION_FORBIDDEN(_, func)
    if (not self:IsVisible()) then return end
    if func == "AcceptBattlefieldPort()" then self.popupTainted = true end
    if func == "func()" then self.minimapTainted = true end
    if (not self.popupTainted) or (not self.minimapTainted) then return end
    StaticPopup_Hide("ADDON_ACTION_FORBIDDEN")
    self:SetMacroText()
end

function SafeQueue:HideBlizzardPopup()
end

SafeQueue:SetScript("OnShow", function(self)
    if (not self.battlefieldId) then return end
    if InCombatLockdown() then
        self.showPending = true
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end

    local status, battleground = GetBattlefieldStatus(self.battlefieldId)

    if not IsBattlefieldConfirm(status) then return end

    self.showPending = nil
    self.hidePending = nil

    self:SetExpiresText()
    self.SubText:SetText(format("|cff%s%s|r", self.color, battleground))
    local color = self.color and self.color.rgb
    if color then self.SubText:SetTextColor(color.r, color.g, color.b) end

    self:SetMacroText()
end)

SafeQueue:SetScript("OnHide", function(self)
    self.battleground = nil
    self.battlefieldId = nil
    self.EnterButton:SetAttribute("macrotext", "")
    self.EnterButton:SetText(ENTER_BATTLE)
end)

function SafeQueue:ShowPopup()
    if self.SetExpiresText then self:SetExpiresText() end
end

function SafeQueue:HidePopup()
    self:Hide()
end

function SafeQueue:PLAYER_REGEN_ENABLED()
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    if self.hidePending then self:Hide() end
    if self.showPending then self:Show() end
end

local function GetDropDownListEnterButton(battlefieldId)
    for i = 1, 20 do
        local button = _G["DropDownList1Button" .. i]
        if button and button:IsShown() and button:GetText() == ENTER_BATTLE then
            return button:GetName()
        end
    end

    local queued = 0
    for i = 1, GetNumBattlefieldQueues() do
        local status = GetBattlefieldStatus(i)
        if i == battlefieldId then return "DropDownList1Button" .. (i * 4 - 2 - queued) end
        if status == "queued" then queued = queued + 1 end
    end
end

local function GetVisibleBattlefieldPopupEnterButton()
    for i = 1, 10 do
        local popup = _G["StaticPopup" .. i]
        if popup and popup:IsShown() and popup.which == "CONFIRM_BATTLEFIELD_ENTRY" then
            local button = _G["StaticPopup" .. i .. "Button1"] or popup.button1
            if button and button:GetName() then return button:GetName() end
        end
    end

    if PVPReadyDialog and PVPReadyDialog:IsShown() then
        local button = PVPReadyDialog.enterButton or _G.PVPReadyDialogEnterBattleButton
        if button and button:GetName() then return button:GetName() end
    end
end

function SafeQueue:GetEnterBattleMacroText()
    local button = GetVisibleBattlefieldPopupEnterButton()
    if button then
        return "/click " .. button
    end

    local battlefieldId = tonumber(self.battlefieldId) or 1
    return format("/run AcceptBattlefieldPort(%d, 1)", battlefieldId)
end

function SafeQueue:SetEnterBattleButtonMacro(button)
    if InCombatLockdown() then return end
    if (not button) or (not self.battlefieldId) then return end
    if (not issecurevariable("CURRENT_BATTLEFIELD_QUEUES")) then self.popupTainted = true end
    if self.popupTainted and self.minimapTainted then
        button:SetText(REQUIRES_RELOAD)
        button:SetAttribute("macrotext", "/reload")
    else
        button:SetText(ENTER_BATTLE)
        button:SetAttribute("macrotext", self:GetEnterBattleMacroText())
    end
end

function SafeQueue:SetMacroText()
    if InCombatLockdown() then return end
    if (not self.battlefieldId) then return end
    self:SetEnterBattleButtonMacro(self.EnterButton)
end

SLASH_SAFEQUEUEDEBUG1 = "/sqdebug"
SlashCmdList.SAFEQUEUEDEBUG = function()
    SafeQueue:Print("Classic fix loaded. battlefieldId=" .. tostring(SafeQueue.battlefieldId))
    SafeQueue:Print("macro=" .. tostring(SafeQueue.EnterButton:GetAttribute("macrotext")))
    for i = 1, GetNumBattlefieldQueues() do
        local status, battleground = GetBattlefieldStatus(i)
        local expires = GetBattlefieldPortExpiration and GetBattlefieldPortExpiration(i) or nil
        SafeQueue:Print(format("queue %d: status=%s battleground=%s expires=%s", i, tostring(status), tostring(battleground), tostring(expires)))
    end
    for i = 1, 20 do
        local button = _G["DropDownList1Button" .. i]
        if button and button:IsShown() then
            SafeQueue:Print(format("dropdown %d: text=%s", i, tostring(button:GetText())))
        end
    end
    for i = 1, 10 do
        local popup = _G["StaticPopup" .. i]
        if popup and popup:IsShown() then
            local button = _G["StaticPopup" .. i .. "Button1"] or popup.button1
            local buttonName = button and button:GetName() or nil
            SafeQueue:Print(format("popup %d: which=%s button1=%s", i, tostring(popup.which), tostring(buttonName)))
        end
    end
end

if SafeQueue.Print then
    SafeQueue:Print("Classic fix loaded.")
end
