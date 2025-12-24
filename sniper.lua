-- =====================================================
-- GOON SNIPER — FINAL STABLE UI (NO LIBRARIES)
-- =====================================================

repeat task.wait() until game:IsLoaded()

-- =====================
-- SERVICES
-- =====================
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")

repeat task.wait() until Player:FindFirstChild("PlayerGui")

-- =====================
-- CONSTANTS
-- =====================
local TradeWorldID = 129954712878723
local CONFIG_FILE = "goon_sniper_config.json"

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
local Config = {
	Pets = {},
	EnabledPets = {},
	SafetyMode = true,
	AutoHop = false
}

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

-- =====================
-- STATE
-- =====================
getgenv().SniperEnabled = false
local SelectedPet = ALL_PETS[1]
local LastHit = os.clock()

local function IsPetActive(pet)
	local c = Config.Pets[pet]
	return c and c.MinWeight and c.MaxPrice and c.MinWeight > 0 and c.MaxPrice > 0
end

-- =====================
-- GUI
-- =====================
if getgenv().GoonGUI then
	getgenv().GoonGUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui", Player.PlayerGui)
ScreenGui.Name = "GoonSniperUI"
getgenv().GoonGUI = ScreenGui

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.fromOffset(300, 360)
Main.Position = UDim2.fromScale(0.05, 0.2)
Main.BackgroundColor3 = Color3.fromRGB(20,20,20)
Main.Active = true
Main.Draggable = true

Instance.new("UICorner", Main).CornerRadius = UDim.new(0,10)

local function Label(text, y)
	local l = Instance.new("TextLabel", Main)
	l.Position = UDim2.fromOffset(10, y)
	l.Size = UDim2.fromOffset(280, 20)
	l.BackgroundTransparency = 1
	l.TextXAlignment = Left
	l.Font = Enum.Font.Code
	l.TextSize = 13
	l.TextColor3 = Color3.new(1,1,1)
	l.Text = text
	return l
end

local function Button(text, y, cb)
	local b = Instance.new("TextButton", Main)
	b.Position = UDim2.fromOffset(10, y)
	b.Size = UDim2.fromOffset(280, 28)
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 13
	b.BackgroundColor3 = Color3.fromRGB(35,35,35)
	b.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
	b.MouseButton1Click:Connect(cb)
	return b
end

local function Box(placeholder, y, cb)
	local t = Instance.new("TextBox", Main)
	t.Position = UDim2.fromOffset(10, y)
	t.Size = UDim2.fromOffset(280, 26)
	t.PlaceholderText = placeholder
	t.Text = ""
	t.BackgroundColor3 = Color3.fromRGB(30,30,30)
	t.TextColor3 = Color3.new(1,1,1)
	t.Font = Enum.Font.Code
	t.TextSize = 13
	Instance.new("UICorner", t).CornerRadius = UDim.new(0,6)
	t.FocusLost:Connect(function()
		cb(t.Text)
	end)
	return t
end

-- =====================
-- UI CONTENT
-- =====================
Label("GOON SNIPER", 10)

local StatusLabel = Label("Status: IDLE", 35)

Button("Sniper Enabled", 60, function()
	getgenv().SniperEnabled = not getgenv().SniperEnabled
	StatusLabel.Text = "Status: " .. (getgenv().SniperEnabled and "SCANNING" or "IDLE")
end)

Button("Switch Pet", 95, function()
	local i = table.find(ALL_PETS, SelectedPet) or 1
	i = i + 1
	if i > #ALL_PETS then i = 1 end
	SelectedPet = ALL_PETS[i]
end)

local MinBox = Box("Min Weight", 130, function(v)
	local n = tonumber(v)
	if n then
		Config.Pets[SelectedPet] = Config.Pets[SelectedPet] or {}
		Config.Pets[SelectedPet].MinWeight = n
		SaveConfig()
	end
end)

local MaxBox = Box("Max Price", 165, function(v)
	local n = tonumber(v)
	if n then
		Config.Pets[SelectedPet] = Config.Pets[SelectedPet] or {}
		Config.Pets[SelectedPet].MaxPrice = n
		SaveConfig()
	end
end)

Button("Toggle Pet Active", 200, function()
	Config.EnabledPets[SelectedPet] = not Config.EnabledPets[SelectedPet]
	SaveConfig()
end)

local PetStatus = Label("Pet Status:", 235)

Button("Hop Server", 265, function()
	TeleportService:Teleport(TradeWorldID, Player)
end)

Button("Toggle Auto Hop", 300, function()
	Config.AutoHop = not Config.AutoHop
	SaveConfig()
end)

-- =====================
-- LOOP
-- =====================
task.spawn(function()
	while task.wait(1) do
		local lines = {}
		for pet, enabled in pairs(Config.EnabledPets) do
			if enabled then
				table.insert(lines,
					(IsPetActive(pet) and "🟢 " or "🔴 ") .. pet
				)
			end
		end
		PetStatus.Text = "Pet Status:\n" .. (#lines > 0 and table.concat(lines,"\n") or "None")

		if getgenv().SniperEnabled and Config.AutoHop and os.clock() - LastHit > 60 then
			TeleportService:Teleport(TradeWorldID, Player)
			LastHit = os.clock()
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
