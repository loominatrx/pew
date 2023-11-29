local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")

local Knit = require(Packages.Knit)

Knit.AddControllers(script.Parent:WaitForChild('Controllers'))

print("[Client] Starting Knit...")
Knit.Start():andThen(function()
    print("[Client] Knit has been started.")
end)