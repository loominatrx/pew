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
            local halvedCanvasSize = Game.Canvas.AbsoluteSize / 2
            local direction = HUDController.UI.MovementThumbstick:GetAttribute('MoveDirection')
            local movementSpeed = direction * 5

            local position = self.UIObject.Position + 
                UDim2.fromOffset(
                    movementSpeed.X,
                    movementSpeed.Y
                    
            )
			position = UDim2.new(
				0.5, clamp(position.X.Offset, -halvedCanvasSize.X, halvedCanvasSize.X),
				0.5, clamp(position.Y.Offset, -halvedCanvasSize.Y, halvedCanvasSize.Y)
			)
			self.UIObject.Position = position
			
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

function Player:Move(vector2: Vector2)
    local pos = self.UIObject.AbsolutePosition + vector2
    return self.N2DObject:SetPosition(pos.X, pos.Y)
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