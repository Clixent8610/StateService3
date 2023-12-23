local Main = script.Parent
local Utility = require(Main:WaitForChild("Utility"))

local StateEvent = Main:WaitForChild("StateEvent")

-- StateService3
local StateService3 = Utility.CloneTemplate()
StateService3._Identifiers = {}
StateService3._IdentifierCount = 0
Utility.SetStarterIdentifiers(StateService3)

function StateService3:SetSignal(Path)
	-- Error checks
	Path = Path or "Default"
	assert(type(Path) == "string", "Path must be a string")

	return Utility.SetSignal(self, Path)
end

-- Connections
StateEvent.OnClientEvent:Connect(function(Identifier, Path, Value)
	if Identifier == nil and Path == nil and Value == nil then
		return Utility.ResetStates(StateService3)
	end

	if Identifier then
		local Identifiers = StateService3._Identifiers

		-- Error checks
		assert(type(Identifier) == "string", "Identifier must be a string")

		local Arguments = Identifiers[Identifier]
		assert(Arguments, Identifier .. " is not an identifier")

		Utility.SetState(StateService3, unpack(Arguments))
	else
		-- Error checks
		Path = Path or "Default"
		assert(type(Path) == "string", "Path must be a string")

		Utility.SetIdentifier(StateService3, Path, Value)
		Utility.SetState(StateService3, Path, Value)
	end
end)

StateEvent:FireServer()
return StateService3
