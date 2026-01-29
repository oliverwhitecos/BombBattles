local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for the item event from server (optional)
local itemEvent
local success = pcall(function()
	itemEvent = ReplicatedStorage:WaitForChild("UseItemEvent", 2)
end)
if not success or not itemEvent then
	print("Warning: UseItemEvent not found. Item functionality disabled.")
end

-- Configuration
local INVENTORY_CONFIG = {
	ToggleKey = Enum.KeyCode.E,
	BackgroundColor = Color3.fromRGB(20, 20, 30),
	AccentColor = Color3.fromRGB(100, 150, 255),
	TextColor = Color3.fromRGB(255, 255, 255),
	ItemSize = UDim2.new(0, 85, 0, 85),
	CornerRadius = UDim.new(0, 12),
	TweenDuration = 0.3,
}

-- ============================================
-- ITEM DATA - Easy to modify without touching script code
-- ============================================
-- TAB CONFIGURATION - Easy to add more tabs!
local TABS = {
	{
		id = "skins",
		name = "Skins",
		items = nil, -- Will be set to BOMB_SKINS below
	},
	{
		id = "abilities",
		name = "Abilities",
		items = nil, -- Will be set to ABILITIES below
	},
	-- Add more tabs here! Example:
	{
	     id = "consumables",
	     name = "Consumables",
	     items = nil, -- Create CONSUMABLES table above
	},
}

-- BOMB SKINS TAB
local BOMB_SKINS = {
	{
		id = "bomb_default",
		name = "Default Bomb",
		description = "The classic bomb.\n\nStandard explosive device.",
		icon = "rbxasset://textures/Cursor.png",
		rarity = "Common",
		onUse = function() print("Using Default Bomb") end,
	},
	{
		id = "bomb_ice",
		name = "Ice Bomb",
		description = "A frozen bomb.\n\nIce them man",
		icon = "rbxasset://textures/Cursor.png",
		rarity = "Uncommon",
		onUse = function() print("Using Ice Bomb") end,
	},
	{
		id = "bomb_fire",
		name = "Fire Bomb",
		description = "An inferno bomb.\n\nBurn your rivals",
		icon = "rbxasset://textures/Cursor.png",
		rarity = "Uncommon",
		onUse = function() print("Using Fire Bomb") end,
	},
	{
		id = "bomb_nuke",
		name = "Nuke Bomb",
		description = "The ultimate bomb.\n\nYou've peaked",
		icon = "rbxasset://textures/Cursor.png",
		rarity = "Rare",
		onUse = function() print("Using Nuke Bomb") end,
	},
}

-- ABILITIES TAB
local ABILITIES = {
	{
		id = "shield",
		name = "Shield",
		description = "Protects you from damage.\n\nCan't pass what they can't hit",
		icon = "rbxasset://textures/Cursor.png",
		rarity = "Uncommon",
		onUse = function() print("Using Shield") end,
	},
	{
		id = "speed",
		name = "Speed Boost",
		description = "Increases movement speed.\n\nGain 50% speed for 10 seconds",
		icon = "rbxasset://textures/Cursor.png",
		rarity = "Uncommon",
		onUse = function() print("Using Speed Boost") end,
	},
	{
		id = "health",
		name = "Jump Boost",
		description = "Jump higher\n\nJump twice as high for 10 seconds",
		icon = "rbxasset://textures/Cursor.png",
		rarity = "Common",
		onUse = function() print("Using Jump Boost") end,
	},
	{
		id = "power",
		name = "Snowball",
		description = "Throw a snowball\n\nKnockback rivals in battle",
		icon = "rbxasset://textures/Cursor.png",
		rarity = "Rare",
		onUse = function() print("Using Snowball") end,
	},
}

-- CONSUMABLES TAB
local CONSUMABLES = {
	{
		id = "xp_potion",
		name = "Experience Potion",
		description = "Extra levels\n\nGain 20% more XP for 30 minutes",
		icon = "rbxasset://textures/Cursor.png",
		rarity = "Common",
		onUse = function() print("Using Experience Potion") end,
	},
	{
		id = "gold_potion",
		name = "Gold Potion",
		description = "Get more money\n\nGet 20% more gold for 30 minutes",
		icon = "rbxasset://textures/Cursor.png",
		rarity = "Common",
		onUse = function() print("Using Gold Potion") end,
	},
	{
		id = "time_potion",
		name = "Time Boost",
		description = "Increase time gain\n\nGain double the time for 15 minutes",
		icon = "rbxasset://textures/Cursor.png",
		rarity = "Uncommon",
		onUse = function() print("Using Time Boost") end,
	},
}

-- Assign items to tabs
TABS[1].items = BOMB_SKINS
TABS[2].items = ABILITIES
TABS[3].items = CONSUMABLES

-- Current displayed items (switches between tabs)
local ITEMS = BOMB_SKINS

-- Debounce for inventory toggle
local lastToggleTime = 0
local TOGGLE_DEBOUNCE = 0.5

-- Store current selected item (declare globally)
local selectedItem = nil

-- Tween Info
local TWEEN_IN = TweenInfo.new(
	INVENTORY_CONFIG.TweenDuration,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.Out
)

local TWEEN_OUT = TweenInfo.new(
	INVENTORY_CONFIG.TweenDuration,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.In
)

-- Create main GUI container
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InventoryGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Create mobile button for opening backpack
local mobileButton = Instance.new("ImageButton")
mobileButton.Name = "MobileBackpackButton"
mobileButton.Size = UDim2.new(0, 50, 0, 50)
mobileButton.Position = UDim2.new(0, 10, 0.5, -25)
mobileButton.BackgroundColor3 = INVENTORY_CONFIG.AccentColor
mobileButton.Image = "rbxasset://textures/Cursor.png" -- Change this to your custom icon
mobileButton.ScaleType = Enum.ScaleType.Fit
mobileButton.BorderSizePixel = 0
mobileButton.Parent = screenGui

-- Add corner radius to mobile button
local mobileCorner = Instance.new("UICorner")
mobileCorner.CornerRadius = UDim.new(0, 10)
mobileCorner.Parent = mobileButton

-- Add stroke to mobile button
local mobileStroke = Instance.new("UIStroke")
mobileStroke.Color = Color3.fromRGB(255, 255, 255)
mobileStroke.Thickness = 1
mobileStroke.Parent = mobileButton

-- Mobile button hover effect
mobileButton.MouseEnter:Connect(function()
	mobileButton.BackgroundColor3 = Color3.fromRGB(150, 180, 255)
	mobileStroke.Thickness = 2
end)

mobileButton.MouseLeave:Connect(function()
	mobileButton.BackgroundColor3 = INVENTORY_CONFIG.AccentColor
	mobileStroke.Thickness = 1
end)

-- Create background frame with blur effect
local inventoryFrame = Instance.new("Frame")
inventoryFrame.Name = "InventoryFrame"
inventoryFrame.Size = UDim2.new(0, 900, 0, 550)
inventoryFrame.Position = UDim2.new(0.5, -450, 0.5, -275)
inventoryFrame.BackgroundColor3 = INVENTORY_CONFIG.BackgroundColor
inventoryFrame.BorderSizePixel = 0
inventoryFrame.Visible = false
inventoryFrame.Parent = screenGui

-- Add corner radius to main frame
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = INVENTORY_CONFIG.CornerRadius
mainCorner.Parent = inventoryFrame

-- Add stroke for sleek border
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = INVENTORY_CONFIG.AccentColor
mainStroke.Thickness = 2
mainStroke.Parent = inventoryFrame

-- Create title bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = INVENTORY_CONFIG.AccentColor
titleBar.BorderSizePixel = 0
titleBar.Parent = inventoryFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = INVENTORY_CONFIG.CornerRadius
titleCorner.Parent = titleBar

-- Add title text
local titleText = Instance.new("TextLabel")
titleText.Name = "Title"
titleText.Size = UDim2.new(1, -20, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.BackgroundTransparency = 1
titleText.TextColor3 = INVENTORY_CONFIG.TextColor
titleText.TextSize = 24
titleText.Font = Enum.Font.GothamBold
titleText.Text = "INVENTORY"
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- Create tab bar below title
local tabBar = Instance.new("Frame")
tabBar.Name = "TabBar"
tabBar.Size = UDim2.new(1, 0, 0, 40)
tabBar.Position = UDim2.new(0, 0, 0, 50)
tabBar.BackgroundColor3 = INVENTORY_CONFIG.BackgroundColor
tabBar.BorderSizePixel = 0
tabBar.Parent = inventoryFrame

local tabBarCorner = Instance.new("UICorner")
tabBarCorner.CornerRadius = INVENTORY_CONFIG.CornerRadius
tabBarCorner.Parent = tabBar

-- Store tab buttons for easy reference
local tabButtons = {}

-- Create tab buttons dynamically from TABS config
local tabWidth = 1 / #TABS
for index, tabConfig in ipairs(TABS) do
	local tabButton = Instance.new("TextButton")
	tabButton.Name = tabConfig.id .. "Tab"
	tabButton.Size = UDim2.new(tabWidth, 0, 1, 0)
	tabButton.Position = UDim2.new(tabWidth * (index - 1), 0, 0, 0)
	tabButton.BackgroundColor3 = (index == 1) and INVENTORY_CONFIG.AccentColor or Color3.fromRGB(35, 35, 50)
	tabButton.TextColor3 = INVENTORY_CONFIG.TextColor
	tabButton.Font = Enum.Font.GothamBold
	tabButton.TextSize = 14
	tabButton.Text = tabConfig.name
	tabButton.BorderSizePixel = 0
	tabButton.Parent = tabBar
	
	-- Add corner radius to tab button
	local tabCorner = Instance.new("UICorner")
	tabCorner.CornerRadius = UDim.new(0, 8)
	tabCorner.Parent = tabButton
	
	-- Add stroke for sleek look
	local tabStroke = Instance.new("UIStroke")
	tabStroke.Color = Color3.fromRGB(255, 255, 255)
	tabStroke.Thickness = 0
	tabStroke.Parent = tabButton
	
	-- Store reference
	tabButtons[tabConfig.id] = tabButton
	
	-- Add hover effect
	tabButton.MouseEnter:Connect(function()
		if currentTab ~= tabConfig.id then
			tabButton.BackgroundColor3 = Color3.fromRGB(60, 80, 120)
			tabStroke.Thickness = 1
		end
	end)
	
	tabButton.MouseLeave:Connect(function()
		if currentTab ~= tabConfig.id then
			tabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
			tabStroke.Thickness = 0
		end
	end)
end

-- Store current active tab
currentTab = "skins"

-- Forward declarations for switchTab dependencies
scrollFrame = nil
detailsTitle = nil
detailsRarity = nil
detailsDescription = nil
populateInventory = nil
gridLayout = nil
tabHeaderText = nil

-- Function to switch tabs
local function switchTab(tabName)
	print("DEBUG: switchTab called with:", tabName)
	if currentTab == tabName then 
		print("DEBUG: Already on tab:", tabName)
		return 
	end
	
	-- Find the tab config
	local tabConfig = nil
	for _, tab in ipairs(TABS) do
		if tab.id == tabName then
			tabConfig = tab
			break
		end
	end
	
	if not tabConfig then
		print("DEBUG: Tab not found:", tabName)
		return
	end
	
	currentTab = tabName
	print("DEBUG: Switching to tab:", tabName)
	
	-- Update tab header text
	tabHeaderText.Text = tabConfig.name
	
	-- Update all tab button colors
	for tabId, tabButton in pairs(tabButtons) do
		if tabId == tabName then
			tabButton.BackgroundColor3 = INVENTORY_CONFIG.AccentColor
			tabButton:FindFirstChild("UIStroke").Thickness = 0
		else
			tabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
			tabButton:FindFirstChild("UIStroke").Thickness = 0
		end
	end
	
	-- Set items to the selected tab's items
	ITEMS = tabConfig.items
	
	-- Clear current items
	for _, child in ipairs(scrollFrame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	
	-- Reload items
	populateInventory()
	
	-- Reset details panel
	detailsTitle.Text = "Select an item"
	detailsRarity.Text = ""
	detailsDescription.Text = ""
	selectedItem = nil
end

-- Create close button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 40, 0, 40)
closeButton.Position = UDim2.new(1, -45, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
closeButton.TextColor3 = INVENTORY_CONFIG.TextColor
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 20
closeButton.Text = "×"
closeButton.BorderSizePixel = 0
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

-- Create tab header (shows current tab name)
local tabHeader = Instance.new("Frame")
tabHeader.Name = "TabHeader"
tabHeader.Size = UDim2.new(0, 440, 0, 35)
tabHeader.Position = UDim2.new(0, 10, 0, 100)
tabHeader.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
tabHeader.BorderSizePixel = 0
tabHeader.Parent = inventoryFrame

local tabHeaderCorner = Instance.new("UICorner")
tabHeaderCorner.CornerRadius = UDim.new(0, 6)
tabHeaderCorner.Parent = tabHeader

tabHeaderText = Instance.new("TextLabel")
tabHeaderText.Name = "TabName"
tabHeaderText.Size = UDim2.new(1, -10, 1, 0)
tabHeaderText.Position = UDim2.new(0, 10, 0, 0)
tabHeaderText.BackgroundTransparency = 1
tabHeaderText.TextColor3 = INVENTORY_CONFIG.TextColor
tabHeaderText.TextSize = 16
tabHeaderText.Font = Enum.Font.GothamBold
tabHeaderText.Text = "Skins"
tabHeaderText.TextXAlignment = Enum.TextXAlignment.Left
tabHeaderText.Parent = tabHeader

-- Create scroll frame for items
scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ItemScroll"
scrollFrame.Size = UDim2.new(0, 440, 1, -150)
scrollFrame.Position = UDim2.new(0, 10, 0, 140)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollBarThickness = 8
scrollFrame.ScrollBarImageColor3 = INVENTORY_CONFIG.AccentColor
scrollFrame.Parent = inventoryFrame

-- Create grid layout for items
gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = INVENTORY_CONFIG.ItemSize
gridLayout.CellPadding = UDim2.new(0, 12, 0, 12)
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
gridLayout.FillDirection = Enum.FillDirection.Horizontal
gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
gridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
gridLayout.Parent = scrollFrame

-- Create details panel on the right
local detailsPanel = Instance.new("Frame")
detailsPanel.Name = "DetailsPanel"
detailsPanel.Size = UDim2.new(0, 430, 1, -110)
detailsPanel.Position = UDim2.new(0, 460, 0, 100)
detailsPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
detailsPanel.BorderSizePixel = 0
detailsPanel.Parent = inventoryFrame

local detailsCorner = Instance.new("UICorner")
detailsCorner.CornerRadius = UDim.new(0, 8)
detailsCorner.Parent = detailsPanel

local detailsStroke = Instance.new("UIStroke")
detailsStroke.Color = INVENTORY_CONFIG.AccentColor
detailsStroke.Thickness = 1
detailsStroke.Parent = detailsPanel

-- Details panel content
detailsTitle = Instance.new("TextLabel")
detailsTitle.Name = "Title"
detailsTitle.Size = UDim2.new(1, -20, 0, 40)
detailsTitle.Position = UDim2.new(0, 10, 0, 10)
detailsTitle.BackgroundTransparency = 1
detailsTitle.TextColor3 = INVENTORY_CONFIG.AccentColor
detailsTitle.TextSize = 20
detailsTitle.Font = Enum.Font.GothamBold
detailsTitle.Text = "Select an item"
detailsTitle.TextXAlignment = Enum.TextXAlignment.Left
detailsTitle.Parent = detailsPanel

detailsRarity = Instance.new("TextLabel")
detailsRarity.Name = "Rarity"
detailsRarity.Size = UDim2.new(1, -20, 0, 20)
detailsRarity.Position = UDim2.new(0, 10, 0, 50)
detailsRarity.BackgroundTransparency = 1
detailsRarity.TextColor3 = Color3.fromRGB(150, 150, 150)
detailsRarity.TextSize = 14
detailsRarity.Font = Enum.Font.Gotham
detailsRarity.Text = ""
detailsRarity.TextXAlignment = Enum.TextXAlignment.Left
detailsRarity.Parent = detailsPanel

detailsDescription = Instance.new("TextLabel")
detailsDescription.Name = "Description"
detailsDescription.Size = UDim2.new(1, -20, 0, 150)
detailsDescription.Position = UDim2.new(0, 10, 0, 80)
detailsDescription.BackgroundTransparency = 1
detailsDescription.TextColor3 = INVENTORY_CONFIG.TextColor
detailsDescription.TextSize = 14
detailsDescription.Font = Enum.Font.Gotham
detailsDescription.Text = ""
detailsDescription.TextWrapped = true
detailsDescription.TextXAlignment = Enum.TextXAlignment.Left
detailsDescription.TextYAlignment = Enum.TextYAlignment.Top
detailsDescription.Parent = detailsPanel

local useButton = Instance.new("TextButton")
useButton.Name = "UseButton"
useButton.Size = UDim2.new(1, -20, 0, 40)
useButton.Position = UDim2.new(0, 10, 1, -50)
useButton.BackgroundColor3 = INVENTORY_CONFIG.AccentColor
useButton.TextColor3 = INVENTORY_CONFIG.TextColor
useButton.Font = Enum.Font.GothamBold
useButton.TextSize = 16
useButton.Text = "USE ITEM"
useButton.BorderSizePixel = 0
useButton.Parent = detailsPanel

local useCorner = Instance.new("UICorner")
useCorner.CornerRadius = UDim.new(0, 6)
useCorner.Parent = useButton

-- Store current selected item
local selectedItem = nil

-- Function to update details panel
local function updateDetailsPanel(item)
	selectedItem = item
	detailsTitle.Text = item.name
	detailsRarity.Text = item.rarity
	detailsDescription.Text = item.description
	useButton.Visible = true
end

-- Function to create an item button
local function createItemButton(itemData)
	local itemButton = Instance.new("TextButton")
	itemButton.Name = itemData.name
	itemButton.Size = INVENTORY_CONFIG.ItemSize
	itemButton.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	itemButton.BorderSizePixel = 0
	itemButton.Text = ""
	itemButton.Parent = scrollFrame
	
	-- Add corner radius
	local itemCorner = Instance.new("UICorner")
	itemCorner.CornerRadius = UDim.new(0, 8)
	itemCorner.Parent = itemButton
	
	-- Add stroke
	local itemStroke = Instance.new("UIStroke")
	itemStroke.Color = INVENTORY_CONFIG.AccentColor
	itemStroke.Thickness = 1
	itemStroke.Parent = itemButton
	
	-- Add item icon/image
	local itemImage = Instance.new("ImageLabel")
	itemImage.Name = "Icon"
	itemImage.Size = UDim2.new(0, 50, 0, 50)
	itemImage.Position = UDim2.new(0.5, -25, 0, 5)
	itemImage.BackgroundTransparency = 1
	itemImage.Image = itemData.icon or "rbxasset://textures/Cursor.png"
	itemImage.Parent = itemButton
	
	-- Add item name label
	local itemNameLabel = Instance.new("TextLabel")
	itemNameLabel.Name = "ItemName"
	itemNameLabel.Size = UDim2.new(1, -4, 0, 25)
	itemNameLabel.Position = UDim2.new(0, 2, 0, 55)
	itemNameLabel.BackgroundTransparency = 1
	itemNameLabel.TextColor3 = INVENTORY_CONFIG.TextColor
	itemNameLabel.Font = Enum.Font.Gotham
	itemNameLabel.TextSize = 12
	itemNameLabel.Text = itemData.name
	itemNameLabel.TextWrapped = true
	itemNameLabel.TextXAlignment = Enum.TextXAlignment.Center
	itemNameLabel.Parent = itemButton
	
	-- Hover effect
	itemButton.MouseEnter:Connect(function()
		itemStroke.Color = Color3.fromRGB(200, 200, 255)
		itemStroke.Thickness = 2
	end)
	
	itemButton.MouseLeave:Connect(function()
		itemStroke.Color = INVENTORY_CONFIG.AccentColor
		itemStroke.Thickness = 1
	end)
	
	-- Click event - show details
	itemButton.MouseButton1Click:Connect(function()
		updateDetailsPanel(itemData)
	end)
	
	return itemButton
end

-- Function to populate inventory with sample items
populateInventory = function()
	for _, itemData in ipairs(ITEMS) do
		createItemButton(itemData)
	end
	
	-- Update canvas size after items are added
	task.wait(0.1)
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, gridLayout.AbsoluteContentSize.Y)
end

-- Function to toggle inventory visibility with tweening
local function toggleInventory()
	-- Check debounce
	local currentTime = tick()
	if currentTime - lastToggleTime < TOGGLE_DEBOUNCE then
		return
	end
	lastToggleTime = currentTime
	
	if inventoryFrame.Visible then
		-- Tween out
		local tweenOut = TweenService:Create(inventoryFrame, TWEEN_OUT, {
			Size = UDim2.new(0, 900, 0, 0),
			Position = UDim2.new(0.5, -450, 0.5, 0),
			BackgroundTransparency = 1,
		})
		tweenOut:Play()
		tweenOut.Completed:Connect(function()
			inventoryFrame.Visible = false
		end)
	else
		-- Tween in
		inventoryFrame.Visible = true
		inventoryFrame.Size = UDim2.new(0, 900, 0, 0)
		inventoryFrame.Position = UDim2.new(0.5, -450, 0.5, 0)
		inventoryFrame.BackgroundTransparency = 1
		
		local tweenIn = TweenService:Create(inventoryFrame, TWEEN_IN, {
			Size = UDim2.new(0, 900, 0, 550),
			Position = UDim2.new(0.5, -450, 0.5, -275),
			BackgroundTransparency = 0,
		})
		tweenIn:Play()
	end
end

-- Input handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == INVENTORY_CONFIG.ToggleKey then
		toggleInventory()
	end
end)

-- Close button functionality
closeButton.MouseButton1Click:Connect(function()
	toggleInventory()
end)

-- Tab button functionality
print("DEBUG: Connecting tab button events")
for tabId, tabButton in pairs(tabButtons) do
	print("DEBUG: Connecting tab button:", tabId)
	tabButton.MouseButton1Click:Connect(function()
		print("DEBUG: Tab button clicked:", tabId)
		switchTab(tabId)
	end)
end

-- Mobile button functionality
mobileButton.MouseButton1Click:Connect(function()
	toggleInventory()
end)

-- Use button functionality
useButton.MouseButton1Click:Connect(function()
	if selectedItem then
		print("Using: " .. selectedItem.name)
		-- Send to server if event exists
		if itemEvent then
			itemEvent:FireServer(selectedItem.id)
		end
	end
end)

-- Initialize inventory
inventoryFrame.Visible = false
task.wait(0.1) -- Wait for all UI elements to be created

print("DEBUG: About to populate inventory")
print("DEBUG: scrollFrame exists: ", scrollFrame ~= nil)
print("DEBUG: BOMB_SKINS count: ", #BOMB_SKINS)
print("DEBUG: createItemButton exists: ", createItemButton ~= nil)

populateInventory()

print("DEBUG: Inventory populated")
print("Inventory GUI loaded! Press 'E' to toggle.")