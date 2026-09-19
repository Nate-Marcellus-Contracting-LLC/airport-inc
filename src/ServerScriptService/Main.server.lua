-- Airport Inc - Main Server Script
print("Airport Inc server starting...")

-- Load terrain manager
require(script.Parent.Parent.ReplicatedStorage.TerrainConfig)
require(script:FindFirstChild("TerrainManager") or script)

-- Initialize game systems
print("Initializing Airport Inc game systems...")

