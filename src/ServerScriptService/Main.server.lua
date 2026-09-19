-- Airport Inc - Main Server Script
print("Airport Inc server starting...")

-- Load terrain manager
local terrainManager = require(script.TerrainManager.PlotManager)

-- Initialize game systems
print("Initializing Airport Inc game systems...")
print(string.format("Terrain manager ready with %d slots", #terrainManager))

