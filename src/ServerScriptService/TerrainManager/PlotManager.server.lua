-- PlotManager.server.lua
-- Manages persistent flat grass plots for multiple players
-- Each player gets their own plot that persists across rounds

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Configuration
local PLOT_SIZE = 200 -- studs (huge left-to-right)
local PLOT_HEIGHT = 2 -- thicker layer
local PLOT_OFFSET = 220 -- spacing between plots (size + buffer)
local MAX_PLAYERS = 16
local TERRAIN_MATERIAL = Enum.Material.Grass

-- Plot data stored in ServerStorage
local Plots = {}
local PlotGrid = {} -- 2D grid of occupied plots

-- Initialize plot grid
local function InitPlotGrid()
    for y = 0, MAX_PLAYERS // 2 - 1 do
        PlotGrid[y] = {}
        for x = 0, MAX_PLAYERS // 2 - 1 do
            PlotGrid[y][x] = nil
        end
    end
end

-- Get plot position based on player index
-- Grid: 4 wide x 4 tall (VERTICAL orientation - up/down is longest)
local function GetPlotPosition(playerIndex)
    local plotsPerRow = 4  -- 4 plots across (left-right)
    local plotsPerCol = MAX_PLAYERS // plotsPerRow  -- 4 plots down (up-down)
    local x = playerIndex % plotsPerRow
    local y = playerIndex // plotsPerRow
    
    -- Center the grid
    local gridWidth = plotsPerRow * PLOT_OFFSET
    local gridHeight = plotsPerCol * PLOT_OFFSET
    
    return Vector3.new(
        x * PLOT_OFFSET - gridWidth / 2 + PLOT_SIZE / 2,
        0,
        y * PLOT_OFFSET - gridHeight / 2 + PLOT_SIZE / 2
    ), x, y
end

-- Create a single plot mesh
local function CreatePlot(position)
    -- Collision part - this is what players stand on
    local plot = Instance.new("Part")
    plot.Name = "PlayerPlot"
    plot.Anchored = true
    plot.CanCollide = true  -- Enable collision so players don't phase through
    plot.Size = Vector3.new(PLOT_SIZE, PLOT_HEIGHT, PLOT_SIZE)
    plot.Position = position
    plot.Material = Enum.Material.Grass
    plot.Color = Color3.fromRGB(50, 180, 50)
    
    -- Add boundary markers (subtle)
    local boundary = Instance.new("Part")
    boundary.Name = "Boundary"
    boundary.Anchored = true
    boundary.CanCollide = false
    boundary.Size = Vector3.new(PLOT_SIZE + 2, 2, 2)
    boundary.Material = Enum.Material.Neon
    boundary.Transparency = 0.8
    boundary.Color = Color3.fromRGB(255, 255, 255)
    boundary.Position = position + Vector3.new(0, 1, 0)
    
    -- Parent to workspace
    plot.Parent = workspace
    boundary.Parent = workspace
    
    return {
        Plot = plot,
        Boundary = boundary
    }
end

-- Spawn handler - creates plot for new player
local function OnPlayerAdded(player)
    local playerIndex = #Plots + 1
    if playerIndex > MAX_PLAYERS then
        player:Kick("Server is full")
        return
    end
    
    Plots[player.UserId] = {
        Player = player,
        Position = GetPlotPosition(playerIndex - 1),
        PlotData = nil
    }
    
    -- Create the plot
    local position, x, y = GetPlotPosition(playerIndex - 1)
    Plots[player.UserId].Position = position
    local plotData = CreatePlot(position)
    Plots[player.UserId].PlotData = plotData
    PlotGrid[x][y] = player.UserId
    
    -- Teleport player to their plot
    player.CharacterAdded:Connect(function(character)
        task.wait(0.5) -- Wait for character to load
        if character and Plots[player.UserId] then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                -- Spawn directly on the plot surface
                local spawnY = Plots[player.UserId].Position.Y + PLOT_HEIGHT / 2 + 2
                character:SetPrimaryPartCFrame(CFrame.new(
                    Plots[player.UserId].Position.X,
                    spawnY,
                    Plots[player.UserId].Position.Z
                ))
            end
        end
    end)
    
    print(string.format("Player %s assigned to plot at %s", player.Name, tostring(Plots[player.UserId].Position)))
end

-- Cleanup on player removal
local function OnPlayerRemoving(player)
    if Plots[player.UserId] then
        local plotData = Plots[player.UserId].PlotData
        if plotData then
            plotData.Plot:Destroy()
            plotData.Boundary:Destroy()
        end
        Plots[player.UserId] = nil
        print(string.format("Player %s removed their plot", player.Name))
    end
end

-- Initialize
InitPlotGrid()

for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(OnPlayerAdded, player)
end

Players.PlayerAdded:Connect(OnPlayerAdded)
Players.PlayerRemoving:Connect(OnPlayerRemoving)

return Plots
