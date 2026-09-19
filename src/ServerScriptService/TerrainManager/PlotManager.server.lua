-- PlotManager.server.lua
-- Manages persistent flat grass plots for multiple players
-- Each player gets their own plot that persists across rounds

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Configuration
local PLOT_SIZE = 100 -- studs
local PLOT_HEIGHT = 1 -- thin layer
local PLOT_OFFSET = 5 -- spacing between plots
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
local function GetPlotPosition(playerIndex)
    local plotsPerRow = MAX_PLAYERS // 2
    local x = playerIndex % plotsPerRow
    local y = playerIndex // plotsPerRow
    return Vector3.new(
        x * PLOT_SIZE - (plotsPerRow - 1) * PLOT_SIZE / 2,
        0,
        y * PLOT_SIZE - (plotsPerRow - 1) * PLOT_SIZE / 2
    ), x, y
end

-- Create a single plot mesh
local function CreatePlot(position)
    local plot = Instance.new("Part")
    plot.Name = "PlayerPlot"
    plot.Anchored = true
    plot.CanCollide = false
    plot.Transparency = 1 -- invisible collision surface
    plot.Size = Vector3.new(PLOT_SIZE, PLOT_HEIGHT, PLOT_SIZE)
    plot.Position = position
    
    -- Add visible grass surface on top
    local grass = Instance.new("Part")
    grass.Name = "GrassSurface"
    grass.Anchored = true
    grass.CanCollide = false
    grass.Size = Vector3.new(PLOT_SIZE + 0.5, 0.5, PLOT_SIZE + 0.5)
    grass.Position = position + Vector3.new(0, PLOT_HEIGHT / 2, 0)
    grass.Color = Color3.fromRGB(50, 180, 50)
    
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
    grass.Parent = workspace
    boundary.Parent = workspace
    
    return {
        Plot = plot,
        Grass = grass,
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
        task.wait(1) -- Wait for character to load
        if character and Plots[player.UserId] then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.RootPart.CFrame = CFrame.new(
                    Plots[player.UserId].Position.X,
                    Plots[player.UserId].Position.Y + 10,
                    Plots[player.UserId].Position.Z
                )
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
            plotData.Grass:Destroy()
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
