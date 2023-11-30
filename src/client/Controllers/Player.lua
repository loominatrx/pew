--> Services
local replicatedStorage = game:GetService('ReplicatedStorage')
local create = require(replicatedStorage.create)

--> Packages
local Packages = replicatedStorage.Packages
local Knit = require(Packages:WaitForChild('Knit'))
local Trove = require(Packages:WaitForChild('Trove'))

--> math operation
local clamp = math.clamp

--> Essentials
local Game
local HUDController

--> Player Class
local Player = {};
Player.__index = Player

local function init(self)
    --> Listen for position changes
    print('[Client] Listening for changes...')
    self.__Trove:BindToRenderStep('MovementTracker', 1, function()
        local isInteracting = HUDController.UI.MovementThumbstick:GetAttribute('IsInteracting')

        if isInteracting then
            self:Move(HUDController.UI.MovementThumbstick:GetAttribute('MoveDirection'))
            HUDController.UI.PositionTracker.Text = ('Absolute: (%d, %d); Relative: (%.2f, %d) (%.2f, %d);'):format(
                self.UIObject.AbsolutePosition.X, self.UIObject.AbsolutePosition.Y,
                self.UIObject.Position.X.Scale, self.UIObject.Position.X.Offset,
                self.UIObject.Position.Y.Scale, self.UIObject.Position.Y.Offset
            )
        end
    end)

    self.__Trove:Connect(self.UIObject.CollidersTouched.Event, function(hits)
        local enemy = hits[1]
        print(enemy.Name, 'get hit by player')
        enemy:Destroy()
    end)
end

function Player:Move(moveDirection: Vector2)
    local halvedCanvasSize = Game.Canvas.AbsoluteSize / 2
    local direction = moveDirection
    local movementSpeed = direction * 5

    local oldPosition = self.UIObject.Position
    local newPosition = oldPosition + 
        UDim2.fromOffset(
            movementSpeed.X,
            movementSpeed.Y    
        )
    newPosition = UDim2.new(
        0.5, clamp(newPosition.X.Offset, -halvedCanvasSize.X, halvedCanvasSize.X),
        0.5, clamp(newPosition.Y.Offset, -halvedCanvasSize.Y, halvedCanvasSize.Y)
    )
    self.UIObject.Position = newPosition
    return newPosition, oldPosition
end

function Player:Destroy()
    Game.Collision:removeHitter(self.hitterData.index)
    self.__Trove:Destroy()
    self.UIObject:Destroy()

    self.UIObject = nil
    self.__Trove = nil
    self.hitterData = nil
end

--> Knit Controller
local PlayerController = Knit.CreateController { Name = 'PlayerController' }

function PlayerController.new()
    local self = setmetatable({}, Player)
    self.UIObject = create('Frame', Game.Canvas, {
        Name = 'Player',
        BackgroundColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0,

        AnchorPoint = Vector2.one * 0.5,
        Size = UDim2.fromScale(0.1, 0.1),
        Position = UDim2.fromScale(0.5, 0.5),

        ZIndex = 2,
        Visible = true
    }, {
        Corner = create('UICorner', nil, {
            CornerRadius = UDim.new(1)
        }),
        Stroke = create('UIStroke', nil, {
            Thickness = 3,
            Color = Color3.new(1, 1, 1)
        }),
        AspectRatio = create('UIAspectRatioConstraint')
    })
    self.hitterData = Game.Collision:addHitter(self.UIObject, {})
    self.__Trove = Trove.new()

    init(self)

    return self
end

--> Fires when Knit is about to initialize
function PlayerController:KnitInit()
    
end

--> Fires after Knit controllers are initialized
function PlayerController:KnitStart()
    Game = Knit.GetController('GameController')
    HUDController = Knit.GetController('HUDController')
end

return PlayerController