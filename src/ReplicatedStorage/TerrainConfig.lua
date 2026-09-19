-- TerrainConfig.lua
-- Shared terrain configuration for client and server

local TerrainConfig = {}

-- Plot settings
TerrainConfig.PlotSize = 100
TerrainConfig.PlotHeight = 1
TerrainConfig.MaxPlayers = 16
TerrainConfig.Spacing = 5

-- Terrain materials
TerrainConfig.GroundMaterial = Enum.Material.Grass
TerrainConfig.BoundaryMaterial = Enum.Material.Neon
TerrainConfig.BoundaryTransparency = 0.8

-- Colors
TerrainConfig.GroundColor = Color3.fromRGB(50, 180, 50)
TerrainConfig.BoundaryColor = Color3.fromRGB(255, 255, 255)
TerrainConfig.HighlightColor = Color3.fromRGB(255, 255, 0)

-- Return config
return TerrainConfig
