-- =====================================================
-- GOON SNIPER — OBSIDIAN UI (ANDROID SAFE)
-- =====================================================

-- ===== MOBILE SAFE BOOT =====
repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
repeat task.wait() until Player
repeat task.wait() until Player:FindFirstChild("PlayerGui")
task.wait(1)

-- ===== SERVICES =====
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- ===== CONSTANTS =====
local TradeWorldID = 129954712878723
local CONFIG_FILE = "goon_sniper_config.json"

-- ===== GLOBAL STATE =====
getgenv().SniperEnabled = getgenv().SniperEnabled or false
local AutoHop = false
local LastHit = os.clock()

-- ===== PET LIST =====
local ALL_PETS = {
	"Koi","Mimic Octopus","Peacock","Raccoon","Kitsune",
	"Rainbow Dilophosaurus","French Fry Ferret","Pancake Mole",
	"Sushi Bear","Spaghetti Sloth","Bagel Bunny","Frog","Mole",
	"Echo Frog","Shiba Inu","Nihonzaru","Tanuki","Tanchozuru",
	"Kappa","Ostrich","Capybara","Scarlet Macaw","Wasp",
	"Tarantula Hawk","Moth","Butterfly","Disco Bee","Bee",
	"Honey Bee","Bear Bee","Petal Bee","Queen Bee"
}

-- ===== CONFIG =====
local Config = {
	Pets = {},        -- [pet] = { MinWeight, MaxPrice }
	SafetyMode = true
}

if isfile and isfile(CONFIG_FILE) then
	local ok, data = pcall(function()
		return HttpService:JSONDecode(readfile(CONFIG_FILE))
	end)
	if ok and data then
		Config = data
	end
end

local function SaveConfig()
	if writefile then
		writefile(CONFIG_FILE, HttpService:JSONEncode(Config))
	end
end

-- ===== HELPERS =====
local EnabledPets = {}

local function IsPetActive(pet)
	local c = Config.Pets[pet]
	return c and c.MinWeight and c.MaxPrice and c.MinWeight > 0 and c.MaxPrice > 0
end

-- ===== LOAD OBSIDIAN UI =====
local Obsidian = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"
))()

-- ===== WINDOW =====
local Window = Obsidian:CreateWindow({
	Title = "GOON SNIPER",
	Footer = "Mobile Safe • Obsidian UI",
	Theme = "Dark",
	Size = UDim2.fromOffset(520, 420)
})

-- ===== TABS =====
local MainTab     = Window:AddTab("Main")
local FiltersTab  = Window:AddTab("Filters")
local SafetyTab   = Window:AddTab("Safety")
local SettingsTab = Window:AddTab("Settings")

-- =====================================================
-- MAIN TAB
-- =====================================================
local StatusLabel = MainTab:AddParagraph({
	Title = "Status",
	Content = "IDLE"
})

MainTab:AddToggle({
	Text = "Sniper Enabled",
	Default = getgenv().SniperEnabled,
	Callback = function(v)
		getgenv().SniperEnabled = v
		StatusLabel:Set({
			Title = "Status",
			Content = v and "SCANNING" or "IDLE"
		})
	end
})

-- =====================================================
-- FILTERS TAB
-- =====================================================
local SelectedPet = ALL_PETS[1]

FiltersTab:AddDropdown({
	Text = "Pets (Multi-Select)",
	List = ALL_PETS,
	Multi = true,
	Callback = function(list)
		EnabledPets = {}
		for _, p in ipairs(list) do
			EnabledPets[p] = true
		end
		RefreshPetStatus()
	end
})

FiltersTab:AddDropdown({
	Text = "Edit Pet",
	List = ALL_PETS,
	Default = SelectedPet,
	Callback = function(p)
		SelectedPet = p
		local c = Config.Pets[p]
		MinWeightBox:SetText(c and tostring(c.MinWeight or "") or "")
		MaxPriceBox:SetText(c and tostring(c.MaxPrice or "") or "")
		RefreshPetStatus()
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
			RefreshPetStatus()
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
			RefreshPetStatus()
		end
	end
})

local StatusList = FiltersTab:AddParagraph({
	Title = "Pet Status",
	Content = "No pets selected"
})

function RefreshPetStatus()
	local lines = {}
	for pet in pairs(EnabledPets) do
		if IsPetActive(pet) then
			table.insert(lines, "🟢 "..pet.." (ACTIVE)")
		else
			table.insert(lines, "🔴 "..pet.." (INACTIVE)")
		end
	end
	StatusList:Set({
		Title = "Pet Status",
		Content = #lines > 0 and table.concat(lines, "\n") or "No pets selected"
	})
end

-- =====================================================
-- SAFETY TAB
-- =====================================================
SafetyTab:AddToggle({
	Text = "Safety Mode",
	Default = Config.SafetyMode,
	Callback = function(v)
		Config.SafetyMode = v
		SaveConfig()
	end
})

-- =====================================================
-- SETTINGS TAB
-- =====================================================
SettingsTab:AddButton({
	Text = "Hop Server Now",
	Callback = function()
		TeleportService:Teleport(TradeWorldID, Player)
	end
})

SettingsTab:AddToggle({
	Text = "Auto Hop (No hits for 60s)",
	Default = false,
	Callback = function(v)
		AutoHop = v
	end
})

SettingsTab:AddParagraph({
	Title = "Info",
	Content = "Obsidian UI loaded successfully."
})

-- =====================================================
-- NOTIFICATIONS
-- =====================================================
local function NotifySnipe(pet, weight, price)
	Obsidian:Notify({
		Title = "SNIPED!",
		Description = pet..
			"\nWeight: "..tostring(weight)..
			"\nPrice: "..tostring(price),
		Duration = 6
	})
end

-- =====================================================
-- MAIN LOOP (HOOK YOUR REAL SNIPER HERE)
-- =====================================================
task.spawn(function()
	while task.wait(1) do
		if getgenv().SniperEnabled then
			StatusLabel:Set({ Title="Status", Content="SCANNING" })

			if AutoHop and os.clock() - LastHit > 60 then
				TeleportService:Teleport(TradeWorldID, Player)
				LastHit = os.clock()
			end
		else
			StatusLabel:Set({ Title="Status", Content="IDLE" })
		end
	end
end)

-- =====================================================
-- ANTI-AFK
-- =====================================================
Player.Idled:Connect(function()
	game:GetService("VirtualUser"):CaptureController()
	game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)
