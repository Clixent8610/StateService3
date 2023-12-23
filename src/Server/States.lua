local Utility = require(script.Parent.Parent:WaitForChild("Utility"))

-- States
local States = {}
States.__index = States

function States.new(Owner)
	-- Error checks
	assert(typeof(Owner) == "Instance", "Owner must be an Instance")

	local self = setmetatable(Utility.CloneTemplate(), States)
	self._Owner = Owner

	if Owner:IsA("Player") then
		self._Identifiers = {}
		self._IdentifierCount = 0
		Utility.SetStarterIdentifiers(self)

		self._Queue = {}
	end

	return self
end

function States:ResetStates()
	Utility.ResetStates(self)

	local Queue = self._Queue
	if Queue then
		table.insert(Queue, {})
	end
end

function States:SetCooldown(Name, Duration)
	-- Error checks
	Name = Name or "Default"
	assert(type(Name) == "string", "Name must be a string")

	Duration = Duration or 3
	assert(type(Duration) == "number" and Duration > 0, "Duration must be a number that is greater than 0")

	local Cooldowns = self.Cooldowns
	self:SetState("Cooldowns." .. Name, (Cooldowns[Name] or 0) + 1)

	task.delay(Duration, function()
		if Cooldowns[Name] then
			if Cooldowns[Name] <= 1 then
				self:SetState("Cooldowns." .. Name, nil)
			else
				self:SetState("Cooldowns." .. Name, Cooldowns[Name] - 1)
			end
		end
	end)
end

function States:_SetIdentifier(Path, Value)
	-- Error checks
	Path = Path or "Default"
	assert(type(Path) == "string", "Path must be a string")

	Utility.SetIdentifier(self, Path, Value)
end

function States:SetSignal(Path)
	-- Error checks
	Path = Path or "Default"
	assert(type(Path) == "string", "Path must be a string")

	return Utility.SetSignal(self, Path)
end

function States:SetState(Path, Value)
	-- Error checks
	Path = Path or "Default"
	assert(type(Path) == "string", "Path must be a string")
	assert(Path ~= "_Owner", '"_Owner" cannot be set to another value')

	local Ancestor, OldValue = Utility.SetState(self, Path, Value)

	local Queue = self._Queue
	if Queue and table.find(Utility.Replicated, Ancestor) and OldValue ~= Value then
		local Arguments = {
			nil,
			Path,
			Value,
		}

		for Identifier, arguments in pairs(self._Identifiers) do
			if Arguments[2] == arguments[1] and Arguments[3] == arguments[2] then
				Arguments = { Identifier }
			end
		end
		if not Arguments[1] then
			self:_SetIdentifier(Path, Value)
		end

		table.insert(Queue, Arguments)
	end
end

function States:SetStun(Duration)
	-- Error checks
	Duration = Duration or 0.5
	assert(type(Duration) == "number" and Duration > 0, "Duration must be a number that is greater than 0")

	local Character = Utility.GetCharacter(self)
	if Character then
		self:SetState("Stunned", true)
		self._StunCount += 1

		task.delay(Duration, function()
			if Character and self.Stunned then
				self._StunCount -= 1
				if self._StunCount < 1 then
					self:SetState("Stunned", false)
				end
			end
		end)
	end
end

return States
