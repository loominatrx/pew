--> Services
local Players = game:GetService('Players')
local replicatedStorage = game:GetService('ReplicatedStorage')
local StarterGui = game:GetService('StarterGui')

local localPlayer = Players.LocalPlayer
local create = require(replicatedStorage.create)

--> math operation
local random = math.random

--> Packages
local Packages = replicatedStorage.Packages
local Knit = require(Packages:WaitForChild('Knit'))
local GuiCollision = require(Packages:WaitForChild('GuiCollisionService'))

--> 2D canvas
local GameUI = create('ScreenGui', nil, {
    Name = 'Main',
    Enabled = true,
    ScreenInsets = Enum.ScreenInsets.None,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
   },
   {
        Canvas = create('Frame', nil, {
            Name = 'Canvas',
            BackgroundColor3 = Color3.new(),
            BackgroundTransparency = 0,
            BorderSizePixel = 0,

            Size = UDim2.fromScale(1, 1),
        })
    }
)


--> Knit Controller
local PlayerController
local HUDController
local Game = Knit.CreateController { Name = 'GameController' }
Game.UI = GameUI
Game.Collision = GuiCollision.createCollisionGroup()
Game.Canvas = GameUI.Canvas
Game.Player = nil

function Game:StartGame()
    Game.Player = PlayerController.new()
    HUDController:SetVisible(true)

    for i = 1, 10 do
        local enemy = create('Frame', Game.Canvas, {
            Name = `Enemy {i}`,
            BackgroundColor3 = Color3.new(0, 0, 0),
            BorderSizePixel = 0,
    
            AnchorPoint = Vector2.one * 0.5,
            Size = UDim2.fromScale(0.1, 0.1),
            Position = UDim2.fromScale(random(), random()),
    
            ZIndex = 2,
            Visible = true
        }, {
            Corner = create('UICorner', nil, {
                CornerRadius = UDim.new(1)
            }),
            Stroke = create('UIStroke', nil, {
                Thickness = 3,
                Color = Color3.new(1, 0.501960, 0)
            }),
            AspectRatio = create('UIAspectRatioConstraint')
        })
        Game.Collision:addCollider(enemy, false)
    end
end

function Game:StopGame()
    Game.Player:Destroy()
    Game.Player = nil

    for index, enemy in Game.Collision:getColliders() do
        Game.Collision:removeCollider(index)
        enemy:Destroy()
    end

    HUDController:SetVisible(false)
end

--> Fires when Knit is about to initialize
function Game:KnitInit()
    local success, _result do
        print('[Game:Client] Attempting to disable Roblox\'s built-in Topbar')
        while not success do
            success, _result = pcall(StarterGui.SetCore, StarterGui, 'TopbarEnabled', false)
            if not success then
                task.wait(0.1)
            end
        end
        print('[Game:Client] Disabled Roblox\'s built-in Topbar')
    end
end

--> Fires after Knit controllers are initialized
function Game:KnitStart()
    GameUI.Parent = localPlayer.PlayerGui

    HUDController = Knit.GetController('HUDController')
    PlayerController = Knit.GetController('PlayerController')
end

return Game