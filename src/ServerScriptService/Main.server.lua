-- Airport Inc - Main Server Script
print("Airport Inc server starting...")

-- Load terrain manager
local terrainManager = require(script.Parent.TerrainManager.PlotManager)

-- Initialize game systems
print("Initializing Airport Inc game systems...")
print(string.format("Terrain manager loaded with %d player slots", #terrainManager > 0 and "ready" or "error"))

