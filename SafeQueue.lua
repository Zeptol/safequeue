
-- SafeQueue by Jordon

local SafeQueue = SafeQueue
local L = LibStub("AceLocale-3.0"):GetLocale("SafeQueue")

local CreateFrame = CreateFrame
local DEFAULT_CHAT_FRAME = DEFAULT_CHAT_FRAME
local GetBattlefieldPortExpiration = GetBattlefieldPortExpiration
local GetBattlefieldStatus = GetBattlefieldStatus
local GetBattlefieldTimeWaited = GetBattlefieldTimeWaited
local GetMaxBattlefieldID = GetMaxBattlefieldID
local GetTime = GetTime
local MAX_BATTLEFIELD_QUEUES = MAX_BATTLEFIELD_QUEUES
local PVPReadyDialog = PVPReadyDialog
local PVPReadyDialog_Display = PVPReadyDialog_Display
local SecondsToTime = SecondsToTime
local StaticPopupSpecial_Hide = StaticPopupSpecial_Hide
local StaticPopup_Hide = StaticPopup_Hide
local TOOLTIP_UPDATE_TIME = TOOLTIP_UPDATE_TIME
local WOW_PROJECT_ID = WOW_PROJECT_ID
local WOW_PROJECT_MAINLINE = WOW_PROJECT_MAINLINE
local _G = _G
local format = format
local hooksecurefunc = hooksecurefunc

local function GetNumBattlefieldQueues()
    local maxQueues = MAX_BATTLEFIELD_QUEUES or 0
    local maxBattlefieldID = GetMaxBattlefieldID and GetMaxBattlefieldID() or 0
    if maxBattlefieldID > maxQueues then maxQueues = maxBattlefieldID end
    return maxQueues
end

local function IsBattlefieldConfirm(status)
    return status == "confirm" or status == "confirmed"
end

local function GetPopupTimerText(parent, anchor)
    if not parent.SafeQueueTimerText then
        local timer = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        timer:SetWidth(320)
        timer:SetJustifyH("CENTER")
        parent.SafeQueueTimerText = timer
    end
    return parent.SafeQueueTimerText
end

local function SetPopupTimerLayout(parent, timer)
    timer:ClearAllPoints()
    timer:SetPoint("BOTTOM", parent, "BOTTOM", 0, 62)
end

local function GetMinimizeButton(parent, onClick)
    if not parent.SafeQueueMinimizeButton then
        local button = CreateFrame("Button", nil, parent, "UIPanelCloseButton")
        button:SetNormalTexture("Interface\\Buttons\\UI-Panel-HideButton-Up")
        button:SetPushedTexture("Interface\\Buttons\\UI-Panel-HideButton-Down")
        button:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -3, -3)
        parent.SafeQueueMinimizeButton = button
    end

    parent.SafeQueueMinimizeButton:SetScript("OnClick", onClick)
    parent.SafeQueueMinimizeButton:Show()
    return parent.SafeQueueMinimizeButton
end

local function SaveButtonPoint(button)
    if not button then return end
    local point, relativeTo, relativePoint, xOfs, yOfs = button:GetPoint(1)
    return { point, relativeTo, relativePoint, xOfs, yOfs }
end

local function RestoreButtonPoint(button, point)
    if not button or not point then return end
    button:ClearAllPoints()
    button:SetPoint(point[1], point[2], point[3], point[4], point[5])
end

local function SetPopupButtonLayout(parent, button1, button2)
    if button1 and not parent.SafeQueueButton1Point then parent.SafeQueueButton1Point = SaveButtonPoint(button1) end
    if button2 and parent.SafeQueueButton2Shown == nil then parent.SafeQueueButton2Shown = button2:IsShown() end

    if button2 then button2:Hide() end
    if button1 then
        button1:ClearAllPoints()
        button1:SetPoint("BOTTOM", parent, "BOTTOM", 0, 26)
    end
end

local function RestorePopupButtonLayout(parent, button1, button2)
    if button1 and parent.SafeQueueButton1Point then
        RestoreButtonPoint(button1, parent.SafeQueueButton1Point)
        parent.SafeQueueButton1Point = nil
    end

    if button2 and parent.SafeQueueButton2Shown ~= nil then
        if parent.SafeQueueButton2Shown then button2:Show() else button2:Hide() end
        parent.SafeQueueButton2Shown = nil
    end

    if parent.SafeQueueMinimizeButton then
        parent.SafeQueueMinimizeButton:Hide()
    end
end

function SafeQueue:SetBlizzardPopupExpiresText(text)
    for i = 1, 10 do
        local popup = _G["StaticPopup" .. i]
        if popup and popup:IsShown() and popup.which == "CONFIRM_BATTLEFIELD_ENTRY" then
            local timer = GetPopupTimerText(popup, popup.text or _G["StaticPopup" .. i .. "Text"])
            local button1 = _G["StaticPopup" .. i .. "Button1"] or popup.button1
            local button2 = _G["StaticPopup" .. i .. "Button2"] or popup.button2
            if not popup.SafeQueueOriginalHeight then popup.SafeQueueOriginalHeight = popup:GetHeight() end
            if popup:GetHeight() < 165 then popup:SetHeight(165) end
            SetPopupButtonLayout(popup, button1, button2)
            GetMinimizeButton(popup, function()
                if StaticPopup_Hide then
                    StaticPopup_Hide("CONFIRM_BATTLEFIELD_ENTRY")
                else
                    popup:Hide()
                end
            end)
            SetPopupTimerLayout(popup, timer)
            timer:SetText(text)
            timer:Show()
        end
    end

    if PVPReadyDialog and PVPReadyDialog:IsShown() then
        local timer = GetPopupTimerText(PVPReadyDialog, PVPReadyDialog.text or PVPReadyDialog.label)
        if not PVPReadyDialog.SafeQueueOriginalHeight then PVPReadyDialog.SafeQueueOriginalHeight = PVPReadyDialog:GetHeight() end
        if PVPReadyDialog:GetHeight() < 150 then PVPReadyDialog:SetHeight(150) end
        SetPopupButtonLayout(PVPReadyDialog, PVPReadyDialog.enterButton, PVPReadyDialog.hideButton)
        if PVPReadyDialog.leaveButton then
            if PVPReadyDialog.SafeQueueLeaveButtonShown == nil then PVPReadyDialog.SafeQueueLeaveButtonShown = PVPReadyDialog.leaveButton:IsShown() end
            PVPReadyDialog.leaveButton:Hide()
        end
        GetMinimizeButton(PVPReadyDialog, function()
            if StaticPopupSpecial_Hide then
                StaticPopupSpecial_Hide(PVPReadyDialog)
            else
                PVPReadyDialog:Hide()
            end
        end)
        SetPopupTimerLayout(PVPReadyDialog, timer)
        timer:SetText(text)
        timer:Show()
    end
end

function SafeQueue:HideBlizzardPopupExpiresText()
    for i = 1, 10 do
        local popup = _G["StaticPopup" .. i]
        if popup and popup.SafeQueueTimerText then
            RestorePopupButtonLayout(popup, _G["StaticPopup" .. i .. "Button1"] or popup.button1, _G["StaticPopup" .. i .. "Button2"] or popup.button2)
            popup.SafeQueueTimerText:Hide()
            if popup.SafeQueueOriginalHeight then
                popup:SetHeight(popup.SafeQueueOriginalHeight)
                popup.SafeQueueOriginalHeight = nil
            end
        end
    end

    if PVPReadyDialog and PVPReadyDialog.SafeQueueTimerText then
        RestorePopupButtonLayout(PVPReadyDialog, PVPReadyDialog.enterButton, PVPReadyDialog.hideButton)
        if PVPReadyDialog.leaveButton and PVPReadyDialog.SafeQueueLeaveButtonShown ~= nil then
            if PVPReadyDialog.SafeQueueLeaveButtonShown then PVPReadyDialog.leaveButton:Show() else PVPReadyDialog.leaveButton:Hide() end
            PVPReadyDialog.SafeQueueLeaveButtonShown = nil
        end
        PVPReadyDialog.SafeQueueTimerText:Hide()
        if PVPReadyDialog.SafeQueueOriginalHeight then
            PVPReadyDialog:SetHeight(PVPReadyDialog.SafeQueueOriginalHeight)
            PVPReadyDialog.SafeQueueOriginalHeight = nil
        end
    end
end

function SafeQueue:SetExpiresText()
    local battlefieldId = self.battlefieldId
    if (not battlefieldId) then return end
    local secs = GetBattlefieldPortExpiration(battlefieldId)
    if secs <= 0 then secs = 1 end
    local color
    if secs > 20 then
        color = "20ff20"
    elseif secs > 10 then
        color = "ffff00"
    else
        color = "ff0000"
    end
    local text = L["SafeQueue expires in |cff%s%s|r"]:format(color, SecondsToTime(secs))
    self.text:SetText(text)
    self:SetBlizzardPopupExpiresText(text)
    if PVPReadyDialog then
        if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            -- retail: just show expiration
            PVPReadyDialog.label:SetText(text)
        elseif PVPReadyDialog.text and self.color and self.battleground then
            text = format("\n%s\n\n|cff%s%s|r", text, self.color, self.battleground)
            PVPReadyDialog.text:SetText(text)
        end
    end
end

function SafeQueue:Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99SafeQueue|r: " .. message)
end

local update = CreateFrame("Frame")
update.timer = TOOLTIP_UPDATE_TIME
update:SetScript("OnUpdate", function(self, elapsed)
    local battlefieldId = SafeQueue.battlefieldId
    if (not battlefieldId) then return end
    local timer = self.timer
    timer = timer - elapsed
    if timer <= 0 then
        if not IsBattlefieldConfirm(GetBattlefieldStatus(battlefieldId)) then
            SafeQueue.battlefieldId = nil
            SafeQueue:HideBlizzardPopupExpiresText()
            if SafeQueue.HidePopup then SafeQueue:HidePopup() end
            return
        end
        SafeQueue:SetExpiresText()
    end
    self.timer = timer
end)

function SafeQueue:UPDATE_BATTLEFIELD_STATUS()
    local isConfirm = nil
    for i = 1, GetNumBattlefieldQueues() do
        local status = GetBattlefieldStatus(i)
        if status == "queued" then
            self.queues[i] = self.queues[i] or GetTime() - (GetBattlefieldTimeWaited(i) / 1000)
        elseif IsBattlefieldConfirm(status) then
            if self.queues[i] then
                local secs = GetTime() - self.queues[i]
                local message
                if secs < 1 then
                    message = L["Queue popped instantly!"]
                else
                    message = L["Queue popped after %s"]:format(SecondsToTime(secs))
                end
                self:Print(message)
                self.queues[i] = nil
            end
            isConfirm = true
        else
            self.queues[i] = nil
        end
    end
    if (not isConfirm) then
        self.battlefieldId = nil
        self:HideBlizzardPopupExpiresText()
        if self.HidePopup then self:HidePopup() end
    end
end

if PVPReadyDialog_Display then
    if PVPReadyDialog.label then PVPReadyDialog.label:SetWidth(250) end
    hooksecurefunc("PVPReadyDialog_Display", function(self, i)
        self = self or PVPReadyDialog
        SafeQueue.battlefieldId = i
        local _, battleground = GetBattlefieldStatus(i)
        SafeQueue.battleground = battleground
        SafeQueue:SetExpiresText()
    end)
end
