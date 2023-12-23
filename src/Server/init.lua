local Main = script.Parent

local StateEvent = Instance.new("RemoteEvent")
StateEvent.Parent = Main
StateEvent.Name = "StateEvent"

local States = require(script:WaitForChild("States"))
local Utility = require(Main:WaitForChild("Utility"))

local LoadedStates = {}

-- StateService3
local StateService3 = {}

function StateService3.LoadStates(Owner)
	-- Error checks
	assert(typeof(Owner) == "Instance", "Owner must be an Instance")

	local self = StateService3.GetStates(Owner)
	if not self then
		self = States.new(Owner)
		LoadedStates[Owner] = self
	end

	return self
end

function StateService3.GetStates(Owner)
	-- Error checks
	assert(typeof(Owner) == "Instance", "Owner must be an Instance")

	if LoadedStates[Owner] then
		return LoadedStates[Owner]
	else
		return LoadedStates[game:GetService("Players"):GetPlayerFromCharacter(Owner)]
	end
end

function StateService3.DestroyStates(Owner)
	-- Error checks
	assert(typeof(Owner) == "Instance", "Owner must be an Instance")

	LoadedStates[Owner] = nil
end

-- Connections
StateEvent.OnServerEvent:Connect(function(Player)
	local States = LoadedStates[Player]
	if not States then
		States = StateService3.LoadStates(Player)
		warn(Player.Name .. " has not loaded. Forced to load states")
	end

	if States._Loaded then
		Player:Kick('Exploit detected. Fired "StateEvent" twice')
	else
		States._Loaded = true
	end
end)

game:GetService("RunService").Heartbeat:Connect(function()
	for Owner, States in pairs(LoadedStates) do
		if States._Loaded then
			for _, Arguments in pairs(States._Queue) do
				StateEvent:FireClient(Owner, unpack(Arguments))
			end
			States._Queue = {}
		end
	end
end)

return StateService3
