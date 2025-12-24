-- =====================
-- GOON SNIPER — OBSIDIAN UI (MOBILE SAFE)
-- =====================

-- ===== MOBILE SAFE BOOT =====
repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
repeat task.wait() until Player
repeat task.wait() until Player:FindFirstChild("PlayerGui")
task.wait(1)

-- ===== SERVICES =====
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- ===== CONSTANTS =====
local TradeWorldID = 129954712878723
local CONFIG_FILE = "goon_sniper_config.json"

-- ===== GLOBALS =====
getgenv().SniperEnabled = getgenv().SniperEnabled or false

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
	Pets = {},      -- [pet] = { MinWeight, MaxPrice }
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
local EnabledPets = {} -- [pet] = true
local LastHit = os.clock()
local AutoHop = false

local function IsPetActive(pet)
	local c = Config.Pets[pet]
	return c and type(c.MinWeight)=="number" and type(c.MaxPrice)=="number"
		and c.MinWeight > 0 and c.MaxPrice > 0
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

-- ===== MAIN TAB =====
local StatusLabel = MainTab:AddLabel("Status: IDLE")

MainTab:AddToggle({
	Text = "Sniper Enabled",
	Default = getgenv().SniperEnabled,
	Callback = function(v)
		getgenv().SniperEnabled = v
		StatusLabel:Set("Status: " .. (v and "SCANNING" or "IDLE"))
	end
})

-- ===== FILTERS TAB =====
local SelectedPet = ALL_PETS[1]

FiltersTab:AddDropdown({
	Text = "Pets (Multi-Select)",
	List = ALL_PETS,
	Multi = true,
	Callback = function(selected)
		EnabledPets = {}
		for _, p in ipairs(selected) do
			EnabledPets[p] = true
		end
		RefreshPetStatus()
	end
})

local MinWeightBox = FiltersTab:AddInput({
	Text = "Minimum Weight (Edit Selected Pet)",
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
	Text = "Maximum Price (Edit Selected Pet)",
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

FiltersTab:AddDropdown({
	Text = "Edit Pet",
	List = ALL_PETS,
	Default = SelectedPet,
	Callback = function(v)
		SelectedPet = v
		local c = Config.Pets[v]
		MinWeightBox:SetText(c and tostring(c.MinWeight or "") or "")
		MaxPriceBox:SetText(c and tostring(c.MaxPrice or "") or "")
		RefreshPetStatus()
	end
})

local StatusList = FiltersTab:AddLabel("Pet Status:")

function RefreshPetStatus()
	local lines = {}
	for _, pet in ipairs(ALL_PETS) do
		if EnabledPets[pet] then
			if IsPetActive(pet) then
				table.insert(lines, "🟢 "..pet.." (ACTIVE)")
			else
				table.insert(lines, "🔴 "..pet.." (INACTIVE)")
			end
		end
	end
	StatusList:Set(#lines > 0 and table.concat(lines, "\n") or "No pets selected")
end

-- ===== SAFETY TAB =====
SafetyTab:AddToggle({
	Text = "Safety Mode",
	Default = Config.SafetyMode,
	Callback = function(v)
		Config.SafetyMode = v
		SaveConfig()
	end
})

-- ===== SETTINGS TAB =====
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

SettingsTab:AddLabel("Obsidian UI loaded successfully.")

-- ===== NOTIFICATIONS =====
local function NotifySnipe(pet, weight, price)
	Obsidian:Notify({
		Title = "SNIPED!",
		Description = pet..
			"\nWeight: "..tostring(weight)..
			"\nPrice: "..tostring(price),
		Duration = 6
	})
end

-- ===== SAFETY CHECK =====
local function CanBuy(data, tokens)
	if not Config.SafetyMode then return true end
	if not data then return false end
	if data.Price <= 0 then return false end
	if data.PetMax <= 0 then return false end
	if data.Price > tokens then return false end
	return true
end

-- ===== PLACEHOLDER LOOP (HOOK YOUR REAL SNIPER HERE) =====
task.spawn(function()
	while task.wait(1) do
		if getgenv().SniperEnabled then
			StatusLabel:Set("Status: SCANNING")
			-- Auto hop if enabled
			if AutoHop and os.clock() - LastHit > 60 then
				TeleportService:Teleport(TradeWorldID, Player)
				LastHit = os.clock()
			end
		else
			StatusLabel:Set("Status: IDLE")
		end
	end
end)

-- ===== ANTI-AFK =====
Player.Idled:Connect(function()
	game:GetService("VirtualUser"):CaptureController()
	game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)
