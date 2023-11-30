--> Services
local Players = game:GetService('Players')
local replicatedStorage = game:GetService('ReplicatedStorage')
local UserInputService = game:GetService('UserInputService')

--> Packages
local Packages = replicatedStorage.Packages
local Knit = require(Packages:WaitForChild('Knit'))
local Roact = require(Packages:WaitForChild('Roact'))

--> UI
local Interface = replicatedStorage:WaitForChild('Interface')
local Thumbstick = require(Interface.Thumbstick)

--> Knit Controller
local HUD = Knit.CreateController { Name = 'HUDController' }
HUD.UI = nil

function HUD:SetVisible(boolean: boolean)
    HUD.UI.Enabled = boolean
end

--> Fires when Knit is about to initialize
function HUD:KnitInit()
    local tree = Roact.createElement('ScreenGui', {
        Enabled = true,
        DisplayOrder = 2,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
        IgnoreGuiInset = true
    }, {
        PositionTracker = Roact.createElement('TextLabel', {
            AnchorPoint = Vector2.xAxis * 0.5,
            BackgroundTransparency = 1,

            Position = UDim2.fromScale(0.5, 0),
            Size = UDim2.new(1, 0, 0, 36),

            Text = 'Move to start tracking',
            TextColor3 = Color3.new(1, 1, 1)
        }),
        MovementThumbstick = Roact.createElement(Thumbstick, {
            AnchorPoint = Vector2.yAxis,
            Size = UDim2.fromScale(0.3, 0.3),
            Position = UDim2.fromScale(0.05 ,0.9)
        }),
        ShootingThumbstick = Roact.createElement(Thumbstick, {
            AnchorPoint = Vector2.one,
            Size = UDim2.fromScale(0.3, 0.3),
            Position = UDim2.fromScale(0.95 ,0.9)
        }),
    })

    Roact.mount(tree, Players.LocalPlayer.PlayerGui, 'HUD')
    HUD.UI = Players.LocalPlayer.PlayerGui.HUD
end

--> Fires after Knit controllers are initialized
function HUD:KnitStart()
    UserInputService.LastInputTypeChanged:Connect(function(lastInputType)
        HUD.UI.MovementStick.Visible = lastInputType == Enum.UserInputType.Touch
        HUD.UI.ShootingStick.Visible = lastInputType == Enum.UserInputType.Touch
    end)
end

return HUD