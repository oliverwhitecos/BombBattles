local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

-- Create or get the datastore
local playerDataStore = DataStoreService:GetDataStore("PlayerData")

-- Configuration for leaderstats
local LEADERSTATS_CONFIG = {
	Time = 0,
	Wins = 0,
	GamesPlayed = 0,
}

-- Function to create leaderstats folder for a player
local function createLeaderstats(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	
	-- Create stats
	for statName, defaultValue in pairs(LEADERSTATS_CONFIG) do
		local stat = Instance.new("IntValue")
		stat.Name = statName
		stat.Value = defaultValue
		stat.Parent = leaderstats
	end
	
	return leaderstats
end

-- Function to start tracking player time
local function startTimeTracking(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end
	
	local timeValue = leaderstats:FindFirstChild("Time")
	if not timeValue then return end
	
	-- Spawn a new thread for this player's time tracking
	task.spawn(function()
		while player.Parent and leaderstats.Parent do
			task.wait(1) -- Wait 1 second
			timeValue.Value = timeValue.Value + 1
		end
	end)
end

-- Function to load player data from datastore
local function loadPlayerData(player)
	local success, data = pcall(function()
		return playerDataStore:GetAsync("Player_" .. player.UserId)
	end)
	
	if success and data then
		return data
	else
		-- Return default data if load fails
		return {
			Time = 0,
			Wins = 0,
			GamesPlayed = 0,
		}
	end
end

-- Function to save player data to datastore
local function savePlayerData(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end
	
	local playerData = {
		Time = leaderstats:FindFirstChild("Time").Value,
		Wins = leaderstats:FindFirstChild("Wins").Value,
		GamesPlayed = leaderstats:FindFirstChild("GamesPlayed").Value,
	}
	
	local success, err = pcall(function()
		playerDataStore:SetAsync("Player_" .. player.UserId, playerData)
	end)
	
	if not success then
		warn("Failed to save data for " .. player.Name .. ": " .. tostring(err))
	end
end

-- Handle player joining
Players.PlayerAdded:Connect(function(player)
	-- Create leaderstats
	local leaderstats = createLeaderstats(player)
	
	-- Load player data
	local data = loadPlayerData(player)
	
	-- Set values from loaded data
	leaderstats.Time.Value = data.Time
	leaderstats.Wins.Value = data.Wins
	leaderstats.GamesPlayed.Value = data.GamesPlayed
	
	-- Start tracking time for this player
	startTimeTracking(player)
	
	print("Loaded data for " .. player.Name)
end)

-- Handle player leaving
Players.PlayerRemoving:Connect(function(player)
	savePlayerData(player)
	print("Saved data for " .. player.Name)
end)

-- Auto-save every 5 minutes
while true do
	task.wait(300) -- 5 minutes
	for _, player in pairs(Players:GetPlayers()) do
		savePlayerData(player)
	end
	print("Auto-saved all player data")
end
