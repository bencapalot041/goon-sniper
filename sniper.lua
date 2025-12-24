-- GOON SNIPER — SAFE, GUI-DRIVEN, FULL VERSION

-- =====================
-- SERVICES
-- =====================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer

local TradeWorldID = 129954712878723
local CONFIG_FILE = "goon_sniper_config.json"

-- =====================
-- GUI RESET
-- =====================
if getgenv().GoonGUI then
	pcall(function() getgenv().GoonGUI:Destroy() end)
end

local function IsAlive(i)
	return i and i.Parent ~= nil
end

-- =====================
-- CONFIG
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

local Config = {
	Pets = {},
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

-- =====================
-- GUI
-- =====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GoonSniperUI"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
getgenv().GoonGUI = ScreenGui

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(15,15,15)
MainFrame.Size = UDim2.new(0,260,0,190)
MainFrame.Position = UDim2.new(0.1,0,0.2,0)
MainFrame.Active = true
MainFrame.Draggable = true

local function Corner(i,r)
	local c = Instance.new("UICorner",i)
	c.CornerRadius = UDim.new(0,r)
end
Corner(MainFrame,8)

local Title = Instance.new("TextLabel",MainFrame)
Title.Size = UDim2.new(1,-20,0,30)
Title.Position = UDim2.new(0,10,0,5)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBlack
Title.Text = "GOON SNIPER"
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(80,255,120)
Title.TextXAlignment = Left

local Status = Instance.new("TextLabel",MainFrame)
Status.Position = UDim2.new(0,10,0,40)
Status.Size = UDim2.new(1,-20,0,18)
Status.BackgroundTransparency = 1
Status.Font = Enum.Font.Code
Status.TextSize = 12
Status.TextXAlignment = Left
Status.Text = "STATUS: IDLE"

-- =====================
-- CONFIG PANEL
-- =====================
local ConfigOpen = false
local SelectedPet = nil

local ConfigBtn = Instance.new("TextButton",MainFrame)
ConfigBtn.Position = UDim2.new(0,10,0,65)
ConfigBtn.Size = UDim2.new(1,-20,0,25)
ConfigBtn.Text = "OPEN CONFIG"
ConfigBtn.Font = Enum.Font.GothamBold
Corner(ConfigBtn,6)

local PetBtn = Instance.new("TextButton",MainFrame)
PetBtn.Position = UDim2.new(0,10,0,100)
PetBtn.Size = UDim2.new(1,-20,0,25)
PetBtn.Text = "SELECT PET"
PetBtn.Visible = false
Corner(PetBtn,6)

local PetState = Instance.new("TextLabel",MainFrame)
PetState.Position = UDim2.new(0,10,0,130)
PetState.Size = UDim2.new(1,-20,0,18)
PetState.BackgroundTransparency = 1
PetState.Font = Enum.Font.Code
PetState.TextSize = 12
PetState.Visible = false

local MinBox = Instance.new("TextBox",MainFrame)
MinBox.Position = UDim2.new(0,10,0,150)
MinBox.Size = UDim2.new(1,-20,0,25)
MinBox.PlaceholderText = "Min Weight"
MinBox.Visible = false
Corner(MinBox,6)

local MaxBox = Instance.new("TextBox",MainFrame)
MaxBox.Position = UDim2.new(0,10,0,180)
MaxBox.Size = UDim2.new(1,-20,0,25)
MaxBox.PlaceholderText = "Max Price"
MaxBox.Visible = false
Corner(MaxBox,6)

ConfigBtn.MouseButton1Click:Connect(function()
	ConfigOpen = not ConfigOpen
	ConfigBtn.Text = ConfigOpen and "CLOSE CONFIG" or "OPEN CONFIG"
	PetBtn.Visible = ConfigOpen
	PetState.Visible = ConfigOpen
	MinBox.Visible = ConfigOpen
	MaxBox.Visible = ConfigOpen
	MainFrame.Size = ConfigOpen and UDim2.new(0,260,0,220) or UDim2.new(0,260,0,190)
end)

PetBtn.MouseButton1Click:Connect(function()
	local i = table.find(ALL_PETS, SelectedPet) or 0
	i += 1
	if i > #ALL_PETS then i = 1 end
	SelectedPet = ALL_PETS[i]
	PetBtn.Text = SelectedPet

	local cfg = Config.Pets[SelectedPet]
	if cfg then
		MinBox.Text = tostring(cfg.MinWeight or "")
		MaxBox.Text = tostring(cfg.MaxPrice or "")
	else
		MinBox.Text = ""
		MaxBox.Text = ""
	end
end)

local function RefreshState()
	if not SelectedPet then return end
	local cfg = Config.Pets[SelectedPet]
	if cfg and cfg.MinWeight > 0 and cfg.MaxPrice > 0 then
		PetState.Text = "STATUS: ACTIVE"
		PetState.TextColor3 = Color3.fromRGB(80,255,120)
	else
		PetState.Text = "STATUS: INACTIVE"
		PetState.TextColor3 = Color3.fromRGB(255,80,80)
	end
end

local function UpdatePet()
	if not SelectedPet then return end
	local w = tonumber(MinBox.Text)
	local p = tonumber(MaxBox.Text)
	Config.Pets[SelectedPet] = {MinWeight = w or 0, MaxPrice = p or 0}
	SaveConfig()
	RefreshState()
end

MinBox.FocusLost:Connect(UpdatePet)
MaxBox.FocusLost:Connect(UpdatePet)

-- =====================
-- SNIPER CORE (SAFE)
-- =====================
getgenv().SniperEnabled = true

local function CanBuy(data, tokens)
	if not Config.SafetyMode then return true end
	if not data then return false end
	if data.Price <= 0 then return false end
	if data.PetMax <= 0 then return false end
	if data.Price > tokens then return false end
	return true
end

-- =====================
-- LOOP (PLACEHOLDER)
-- =====================
task.spawn(function()
	while task.wait(1) do
		if getgenv().SniperEnabled then
			Status.Text = "STATUS: SCANNING (SAFE)"
		end
	end
end)

-- =====================
-- ANTI AFK
-- =====================
Player.Idled:Connect(function()
	game:GetService("VirtualUser"):CaptureController()
	game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)
