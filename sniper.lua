-- =====================================================
-- GOON SNIPER — FINAL ANDROID-SAFE UI (NO LIBRARIES)
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

repeat task.wait() until Player and Player:FindFirstChild("PlayerGui")

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
-- GUI RESET
-- =====================
if getgenv().GoonGUI then
	getgenv().GoonGUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GoonSniperUI"
ScreenGui.Parent = Player.PlayerGui
getgenv().GoonGUI = ScreenGui

-- =====================
-- MAIN FRAME
-- =====================
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.fromOffset(300, 360)
Main.Position = UDim2.fromScale(0.05, 0.2)
Main.BackgroundColor3 = Color3.fromRGB(20,20,20)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,10)

-- =====================
-- UI HELPERS
-- =====================
local function Label(text, y)
	local l = Instance.new("TextLabel", Main)
	l.Position = UDim2.fromOffset(10, y)
	l.Size = UDim2.fromOffset(280, 20)
	l.BackgroundTransparency = 1
	l.TextXAlignment = Enum.TextXAlignment.Left -- FIXED
	l.TextYAlignment = Enum.TextYAlignment.Center
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
	b.Back
