-- =====================================================
-- GOON SNIPER — OBSIDIAN UI (STABLE / ANDROID SAFE)
-- =====================================================

repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
repeat task.wait() until Player and Player:FindFirstChild("PlayerGui")

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")

local TradeWorldID = 129954712878723
local CONFIG_FILE = "goon_sniper_config.json"

getgenv().SniperEnabled = false
local AutoHop = false
local LastHit = os.clock()

-- =====================
-- PET LIST
-- =====================
local ALL_PETS = {
	"Koi","Mimic Octopus","Peacock","Raccoon","Kitsune",
	"Rainbow Dilophosaurus","French Fry Ferret","Pancake Mole",
	"Sushi Bear","Spaghetti Sloth","Bagel Bunny","Frog","Mole",
	"Echo Frog","Shiba Inu","Nihonzaru","Tanuki","Tanchozuru",
	"Kappa","Ostrich","Capybara","Scarlet Macaw","Wasp",
	"Tarantula Hawk","Moth","Butterfly","Disco Bee","Bee",
	"Honey Bee","Bear Bee","Petal Bee","Queen Bee"
}

-- =====================
-- CONFIG
-- =====================
local Config = { Pets = {}, SafetyMode = true }
if isfile and isfile(CONFIG_FILE) then
	pcall(function()
		Config = HttpService:JSONDecode(readfile(CONFIG_FILE))
	end)
end

local function SaveConfig()
	if writefile then
		writefile(CONFIG_FILE, HttpService:JSONEncode(Config))
	end
end

local EnabledPets = {}
local SelectedPet = ALL_PETS[1]

local function IsPetActive(p)
	local c = Config.Pets[p]
	return c and c.MinWeight and c.MaxPrice and c.MinWeight > 0 and c.MaxPrice > 0
end

-- =====================
-- LOAD OBSIDIAN (CORRECT API)
-- =====================
local Obsidian = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"
))()

local Window = Obsidian:CreateWindow("GOON SNIPER")

local MainTab     = Window:CreateTab("Main")
local FiltersTab  = Window:CreateTab("Filters")
local SafetyTab   = Window:CreateTab("Safety")
local SettingsTab = Window:CreateTab("Settings")

-- =====================
-- MAIN TAB
-- =====================
local StatusText = MainTab:AddText("Status: IDLE")

MainTab:AddToggle("Sniper Enabled", function(v)
	getgenv().SniperEnabled = v
	StatusText.Text = "Status: " .. (v and "SCANNING" or "IDLE")
end)

-- =====================
-- FILTERS TAB
-- =====================
FiltersTab:AddDropdown("Enabled Pets", ALL_PETS, true, function(list)
	EnabledPets = {}
	for _, p in ipairs(list) do
		EnabledPets[p] = true
	end
end)

FiltersTab:AddDropdown("Edit Pet", ALL_PETS, false, function(p)
	SelectedPet = p
end)

FiltersTab:AddInput("Min Weight", function(v)
	local n = tonumber(v)
	if n then
		Config.Pets[SelectedPet] = Config.Pets[SelectedPet] or {}
		Config.Pets[SelectedPet].MinWeight = n
		SaveConfig()
	end
end)

FiltersTab:AddInput("Max Price", function(v)
	local n = tonumber(v)
	if n then
		Config.Pets[SelectedPet] = Config.Pets[SelectedPet] or {}
		Config.Pets[SelectedPet].MaxPrice = n
		SaveConfig()
	end
end)

local PetStatusText = FiltersTab:AddText("Pet Status:\nNone")

local function RefreshPetStatus()
	local lines = {}
	for p in pairs(EnabledPets) do
		table.insert(lines, (IsPetActive(p) and "🟢 " or "🔴 ") .. p)
	end
	PetStatusText.Text = "Pet Status:\n" .. (#lines > 0 and table.concat(lines, "\n") or "None")
end

-- =====================
-- SAFETY TAB
-- =====================
SafetyTab:AddToggle("Safety Mode", function(v)
	Config.SafetyMode = v
	SaveConfig()
end)

-- =====================
-- SETTINGS TAB
-- =====================
SettingsTab:AddButton("Hop Server Now", function()
	TeleportService:Teleport(TradeWorldID, Player)
end)

SettingsTab:AddToggle("Auto Hop (60s)", function(v)
	AutoHop = v
end)

SettingsTab:AddText("UI loaded successfully.")

-- =====================
-- LOOP
-- =====================
task.spawn(function()
	while task.wait(1) do
		if getgenv().SniperEnabled then
			RefreshPetStatus()
			if AutoHop and os.clock() - LastHit > 60 then
				TeleportService:Teleport(TradeWorldID, Player)
				LastHit = os.clock()
			end
		end
	end
end)

-- =====================
-- ANTI AFK
-- =====================
Player.Idled:Connect(function()
	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.new())
end)
