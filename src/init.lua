local RunService = game:GetService("RunService")

if RunService:IsClient() then
	return require(script:WaitForChild("Client"))
end
return require(script:WaitForChild("Server"))
