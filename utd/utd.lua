-- ===== wait game + Horst =====
repeat task.wait() until game:IsLoaded()
repeat task.wait() until _G.Horst_SetDescription and _G.Horst_AccountChangeDone

-- ===== services =====
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local plr = Players.LocalPlayer

-- ===== config (กัน nil) =====
local cfg = getgenv().Config or {}

cfg.GemsTarget   = cfg.GemsTarget   or 0
cfg.GoldTarget   = cfg.GoldTarget   or 0
cfg.RerollTarget = cfg.RerollTarget or 0
cfg.LevelTarget  = cfg.LevelTarget  or 0

cfg.CheckGems   = cfg.CheckGems   ~= false
cfg.CheckGold   = cfg.CheckGold   ~= false
cfg.CheckReroll = cfg.CheckReroll ~= false
cfg.CheckLevel  = cfg.CheckLevel  ~= false

cfg.EnableWordStatus = cfg.EnableWordStatus == true
cfg.CheckDelay = cfg.CheckDelay or 10
cfg.DoneDelay  = cfg.DoneDelay  or 15

-- ===== helper =====
local function getAttr(name)
    local v = plr:GetAttribute(name)
    return typeof(v) == "number" and v or 0
end

local function getWord(percent)
    if percent >= 100 then
        return "lnw"
    elseif percent >= 50 then
        return "kak"
    else
        return "kakmak"
    end
end

-- ===== main loop =====
while true do
    local pass = true
    local logParts = {}
    local sheet = {
        Name = plr.Name
    }

    local Gems   = getAttr("Gems")
    local Gold   = getAttr("Coins") > 0 and getAttr("Coins") or getAttr("Gold")
    local Reroll = getAttr("Rerolls")
    local Level  = getAttr("Level")

    -- ===== percent (กันหาร 0) =====
    local percent = 0
    if cfg.GemsTarget > 0 then
        percent = math.floor((Gems / cfg.GemsTarget) * 100)
        if percent > 100 then percent = 100 end
    end

    local icon = percent >= 100 and "✔️" or "❌"
    local word = cfg.EnableWordStatus and getWord(percent) or ""

    -- Gems
    if cfg.CheckGems then
        table.insert(logParts, ("💎 Gems %d"):format(Gems))
        sheet.Gems = Gems
        if Gems < cfg.GemsTarget then pass = false end
    end

    -- Gold
    if cfg.CheckGold then
        table.insert(logParts, ("💸 Gold %d"):format(Gold))
        sheet.Gold = Gold
        if Gold < cfg.GoldTarget then pass = false end
    end

    -- Reroll
    if cfg.CheckReroll then
        table.insert(logParts, ("🎲 Reroll %d"):format(Reroll))
        sheet.Reroll = Reroll
        if Reroll < cfg.RerollTarget then pass = false end
    end

    -- Level
    if cfg.CheckLevel then
        table.insert(logParts, ("🐔 Lv %d"):format(Level))
        sheet.Level = Level
        if Level < cfg.LevelTarget then pass = false end
    end

    table.insert(logParts, ("%s %s %d%%"):format(icon, word, percent))
    sheet.Status = icon .. " " .. word .. " " .. percent .. "%"

    _G.Horst_SetDescription(
        table.concat(logParts, " , "),
        HttpService:JSONEncode(sheet)
    )

    -- ===== DONE =====
    if pass then
        task.wait(cfg.DoneDelay)
        _G.Horst_AccountChangeDone()
        break
    end

    task.wait(cfg.CheckDelay)
end
