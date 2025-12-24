-- =====================
-- OBSIDIAN UI (MOBILE SAFE)
-- =====================
local Obsidian = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"
))()
-- =====================
-- OBSIDIAN WINDOW
-- =====================
getgenv().SniperEnabled = getgenv().SniperEnabled or false

local Window = Obsidian:CreateWindow({
    Title = "GOON SNIPER",
    Footer = "Mobile Safe • Obsidian UI",
    Theme = "Dark",
    Size = UDim2.fromOffset(520, 420)
})

-- =====================
-- TABS
-- =====================
local MainTab    = Window:AddTab("Main")
local FiltersTab = Window:AddTab("Filters")
local SafetyTab  = Window:AddTab("Safety")
local SettingsTab= Window:AddTab("Settings")

-- =====================
-- MAIN TAB
-- =====================
local StatusLabel = MainTab:AddLabel("Status: IDLE")

MainTab:AddToggle({
    Text = "Sniper Enabled",
    Default = getgenv().SniperEnabled,
    Callback = function(v)
        getgenv().SniperEnabled = v
        StatusLabel:Set("Status: " .. (v and "SCANNING" or "IDLE"))
    end
})

-- =====================
-- FILTERS TAB
-- =====================
local SelectedPet = ALL_PETS[1]

FiltersTab:AddDropdown({
    Text = "Pet",
    List = ALL_PETS,
    Default = SelectedPet,
    Callback = function(v)
        SelectedPet = v
        local cfg = Config.Pets[SelectedPet]
        if cfg then
            MinWeightBox:SetText(tostring(cfg.MinWeight or ""))
            MaxPriceBox:SetText(tostring(cfg.MaxPrice or ""))
        else
            MinWeightBox:SetText("")
            MaxPriceBox:SetText("")
        end
    end
})

local MinWeightBox = FiltersTab:AddInput({
    Text = "Minimum Weight",
    Placeholder = "e.g. 25",
    Callback = function(v)
        local n = tonumber(v)
        if n and SelectedPet then
            Config.Pets[SelectedPet] = Config.Pets[SelectedPet] or {}
            Config.Pets[SelectedPet].MinWeight = n
            SaveConfig()
        end
    end
})

local MaxPriceBox = FiltersTab:AddInput({
    Text = "Maximum Price",
    Placeholder = "e.g. 500",
    Callback = function(v)
        local n = tonumber(v)
        if n and SelectedPet then
            Config.Pets[SelectedPet] = Config.Pets[SelectedPet] or {}
            Config.Pets[SelectedPet].MaxPrice = n
            SaveConfig()
        end
    end
})

-- =====================
-- SAFETY TAB
-- =====================
SafetyTab:AddToggle({
    Text = "Safety Mode",
    Default = Config.SafetyMode,
    Callback = function(v)
        Config.SafetyMode = v
        SaveConfig()
    end
})

-- =====================
-- SETTINGS TAB
-- =====================
SettingsTab:AddLabel("Obsidian UI loaded successfully.")
SettingsTab:AddButton({
    Text = "Reset Filters (Selected Pet)",
    Callback = function()
        if SelectedPet then
            Config.Pets[SelectedPet] = nil
            SaveConfig()
            MinWeightBox:SetText("")
            MaxPriceBox:SetText("")
        end
    end
})
-- Example inside your loop
if getgenv().SniperEnabled then
    StatusLabel:Set("Status: SCANNING")
else
    StatusLabel:Set("Status: IDLE")
end
