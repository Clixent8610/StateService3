local Signal = require(script:WaitForChild("Signal"))

function IdentifiersCheck(States)
	-- Error checks
	assert(type(States) == "table", "States must be a table")

	local Identifiers = States._Identifiers
	local IdentifierCount = States._IdentifierCount
	assert(Identifiers and type(Identifiers) == "table", 'States must have the value "_Identifiers" that is a table')
	assert(
		IdentifierCount and type(IdentifierCount) == "number",
		'States must have the value "_Identifiers" that is a number'
	)

	return Identifiers, IdentifierCount
end

-- Utility
local Utility = {
	ExcludeFromReset = {
		-- Important
		"Signals",
		"_Identifiers",
		"_IdentifierCount",
		"_Loaded",
		"_Owner",
		"_Queue",

		"Cooldowns",
	},

	IncludeInReset = {
		-- Important
		"Attacking",
		"_StunCount",
		"Stunned",
	},

	Template = {
		Attacking = false,
		Cooldowns = {},

		Signals = {},

		_StunCount = 0,
		Stunned = false,
	},

	Replicated = {
		-- Important
		"Attacking",
		"Cooldowns",
		"Stunned",
	},
}

function Utility.CloneTemplate()
	local function CloneTable(Table)
		local Clone = table.clone(Table)
		for State, Value in pairs(Clone) do
			if type(Value) == "table" then
				Clone[State] = CloneTable(Value)
			end
		end

		return Clone
	end

	return CloneTable(Utility.Template)
end

function Utility.GetCharacter(States)
	-- Error checks
	assert(type(States) == "table", "States must be a table")

	local Character = States._Owner
	if States._Owner:IsA("Player") then
		Character = States._Owner.Character
	end

	if Character and Character:IsA("Model") then
		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		if Humanoid and Humanoid.Health ~= 0 then
			return Character
		end
	end
end

function Utility.ResetStates(States)
	-- Error checks
	assert(type(States) == "table", "States must be a table")

	for State in pairs(States) do
		if table.find(Utility.IncludeInReset, State) or not table.find(Utility.ExcludeFromReset, State) then
			States[State] = Utility.Template[State]
		end
	end
end

function Utility.SetIdentifier(States, Path, Value)
	-- Error checks
	local Identifiers, IdentifierCount = IdentifiersCheck(States)

	Path = Path or "Default"
	assert(type(Path) == "string", "Path must be a string")

	if IdentifierCount < 1114111 then
		Identifiers[utf8.char(IdentifierCount)] = {
			Path,
			Value,
		}
		States._IdentifierCount += 1
	end
end

function Utility.SetSignal(States, Path)
	-- Error checks
	assert(type(States) == "table", "States must be a table")

	Path = Path or "Default"
	assert(type(Path) == "string", "Path must be a string")

	local Signals = States.Signals
	local signal = Signals[Path]

	if signal then
		return signal
	else
		Signals[Path] = Signal.new()
		return Signals[Path]
	end
end

function Utility.SetStarterIdentifiers(States)
	-- Error checks
	IdentifiersCheck(States)

	for _, State in pairs(Utility.Replicated) do
		local Value = Utility.Template[State]

		if type(Value) == "boolean" then
			Utility.SetIdentifier(States, State, true)
			Utility.SetIdentifier(States, State, false)
		else
			Utility.SetIdentifier(States, State, Utility.Template[State])
		end
	end
end

function Utility.SetState(States, Path, Value)
	-- Error checks
	assert(type(States) == "table", "States must be a table")

	Path = Path or "Default"
	assert(type(Path) == "string", "Path must be a string")
	assert(Path ~= "_Owner", '"_Owner" cannot be set to another value')

	local Ancestor = Path
	local OldValue = States[Path]

	if Path:match(".") then
		local Table = Path:split(".")
		Ancestor = Table[1]

		-- Error checks
		assert(Ancestor ~= "_Owner", '"_Owner" cannot be set to another value')

		local Pointer = States
		for Index = 1, #Table - 1 do
			if type(Pointer[Table[Index]]) ~= "table" then
				Pointer[Table[Index]] = {}
			end
			Pointer = Pointer[Table[Index]]
		end

		OldValue = Pointer[Table[#Table]]
		Pointer[Table[#Table]] = Value
	else
		States[Path] = Value
	end

	local signal = States.Signals[Path]
	if signal then
		signal:Fire(Value)
	end

	return Ancestor, OldValue
end

return Utility
