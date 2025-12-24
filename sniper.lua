-- =====================
-- RAYFIELD UI (MOBILE SAFE)
-- =====================
getgenv().SniperEnabled = getgenv().SniperEnabled or false

local Rayfield = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/shlexware/Rayfield/main/source.lua"
))()

local Window = Rayfield:CreateWindow({
    Name = "GOON SNIPER",
    LoadingTitle = "GOON SNIPER",
    LoadingSubtitle = "Mobile Safe Rayfield UI",
    ConfigurationSaving = {
        Enabled = false
    }
})

-- MAIN TAB
local MainTab = Window:CreateTab("Main", 4483362458)

MainTab:CreateToggle({
    Name = "Sniper Enabled",
    CurrentValue = getgenv().SniperEnabled,
    Callback = function(Value)
        getgenv().SniperEnabled = Value
    end
})

local StatusLabel = MainTab:CreateParagraph({
    Title = "Status",
    Content = "IDLE"
})

-- FILTERS TAB
local FiltersTab = Window:CreateTab("Filters", 4483362458)

local SelectedPet = ALL_PETS[1]

FiltersTab:CreateDropdown({
    Name = "Pet",
    Options = ALL_PETS,
    CurrentOption = { SelectedPet },
    Callback = function(Option)
        SelectedPet = Option[1]
    end
})

FiltersTab:CreateInput({
    Name = "Minimum Weight",
    PlaceholderText = "e.g. 25",
    Callback = function(Value)
        Value = tonumber(Value)
        if Value and SelectedPet then
            Config.Pets[SelectedPet] = Config.Pets[SelectedPet] or {}
            Config.Pets[SelectedPet].MinWeight = Value
            SaveConfig()
        end
    end
})

FiltersTab:CreateInput({
    Name = "Maximum Price",
    PlaceholderText = "e.g. 500",
    Callback = function(Value)
        Value = tonumber(Value)
        if Value and SelectedPet then
            Config.Pets[SelectedPet] = Config.Pets[SelectedPet] or {}
            Config.Pets[SelectedPet].MaxPrice = Value
            SaveConfig()
        end
    end
})

-- SAFETY TAB
local SafetyTab = Window:CreateTab("Safety", 4483362458)

SafetyTab:CreateToggle({
    Name = "Safety Mode",
    CurrentValue = Config.SafetyMode,
    Callback = function(Value)
        Config.SafetyMode = Value
        SaveConfig()
    end
})

-- SETTINGS TAB
local SettingsTab = Window:CreateTab("Settings", 4483362458)

SettingsTab:CreateParagraph({
    Title = "Info",
    Content = "Rayfield UI loaded successfully.\nMobile Safe."
})

-- Example status update
StatusLabel:Set({ Content = "SCANNING" })
