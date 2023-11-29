--> Services
local Players = game:GetService('Players')
local replicatedStorage = game:GetService('ReplicatedStorage')

--> Packages
local Packages = replicatedStorage.Packages
local Knit = require(Packages:WaitForChild('Knit'))
local Roact = require(Packages:WaitForChild('Roact'))

--> UI
local Interface = replicatedStorage:WaitForChild('Interface')
local Thumbstick = require(Interface.Thumbstick)

--> Knit Controller
local HUD = Knit.CreateController { Name = 'HUDController' }

--> Fires when Knit is about to initialize
function HUD:KnitInit()
    
end

--> Fires after Knit controllers are initialized
function HUD:KnitStart()
    local tree = Roact.createElement('ScreenGui', {
        Enabled = true,
        DisplayOrder = 2,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
        IgnoreGuiInset = true
    }, {
        Thumbstick = Roact.createElement(Thumbstick, {
            AnchorPoint = Vector2.yAxis,
            Size = UDim2.fromScale(0.3, 0.3),
            Position = UDim2.fromScale(0.05 ,0.9)
        })
    })

    Roact.mount(tree, Players.LocalPlayer.PlayerGui)
end

return HUD