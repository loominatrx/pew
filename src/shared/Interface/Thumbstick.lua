--> Services
local Packages = game:GetService('ReplicatedStorage').Packages
local UserInputService = game:GetService('UserInputService')

--> Packages
local Roact = require(Packages.Roact)
local Trove = require(Packages.Trove)
local TableUtil = require(Packages.TableUtil)

--> Constants
local WHITE = Color3.new(1, 1, 1)
local BLACK = Color3.new(0, 0, 0)

local ACCEPTED_MOVEMENT = {
    [Enum.UserInputType.Touch] = true,
    [Enum.UserInputType.MouseMovement] = true,
}

local ACCEPTED_INPUT = {
    [Enum.UserInputType.Touch] = true,
    [Enum.UserInputType.MouseButton1] = true,
}

local DEFAULTS = {
    AnchorPoint = Vector2.zero,
    Size = UDim2.fromOffset(100, 100),
    Position = UDim2.new()
}

--> Component
local Thumbstick = Roact.Component:extend('Thumbstick')

function Thumbstick:init()
    self.props = TableUtil.Reconcile(self.props, DEFAULTS)
    self.__Trove = Trove.new()
    self.lastPos = Vector2.zero
    self.frameRef = Roact.createRef()
end

function Thumbstick:render()
    return Roact.createElement('Frame', {
        BackgroundTransparency = 1,
        AnchorPoint = self.props.AnchorPoint,
        Size = self.props.Size,
        Position = self.props.Position,

        [Roact.Ref] = self.frameRef
    }, {
        Constraint = Roact.createElement('UIAspectRatioConstraint'),
        Background = Roact.createElement('Frame', {
            AnchorPoint = Vector2.one * 0.5,
            BackgroundTransparency = 0.5,
            BackgroundColor3 = BLACK,

            Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromScale(0.5, 0.5),
        }, {
            Outline = Roact.createElement('UIStroke', {
                Thickness = 5,
                Color = WHITE
            }),
            Corner = Roact.createElement('UICorner', {
                CornerRadius = UDim.new(1)
            })
        }),
        Stick = Roact.createElement('Frame', {

            AnchorPoint = Vector2.one * 0.5,
            BackgroundTransparency = 0,
            BackgroundColor3 = BLACK,

            Size = UDim2.fromScale(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),

            ZIndex = 2,
        }, {
            Outline = Roact.createElement('UIStroke', {
                Thickness = 3,
                Color = WHITE
            }),
            Corner = Roact.createElement('UICorner', {
                CornerRadius = UDim.new(1)
            })
        }),
    })
end

function Thumbstick:didMount()
    local thumbstickFrame: Frame = self.frameRef:getValue()
    local stick: Frame = thumbstickFrame.Stick
    self.__Trove:Connect(thumbstickFrame.InputBegan, function(input: InputObject)
        if ACCEPTED_INPUT[input.UserInputType] and not self.hold then
            local centerPos = thumbstickFrame.AbsolutePosition + thumbstickFrame.AbsoluteSize / 2
            local x, y = input.Position.X, input.Position.Y
            stick.Position = UDim2.new(
                0.5, (x - (centerPos.X)), 0.5, (y - (centerPos.Y))
            )

            self.lastPos = Vector2.new(x, y)
            self.hold = true
        end
    end)
    self.__Trove:Connect(UserInputService.InputChanged, function(input: InputObject)
        if ACCEPTED_MOVEMENT[input.UserInputType] and self.hold then
            local currentPos = Vector2.new(input.Position.X, input.Position.Y)

            local diff = currentPos - self.lastPos
            local length = diff.Magnitude

            local maxLength = thumbstickFrame.AbsoluteSize.X / 2
            
            length = math.min(length, maxLength)
            diff = diff.Unit * length

            stick.Position = UDim2.new(
                0.5, diff.X, 0.5, diff.Y
            )
        end
    end)
    self.__Trove:Connect(UserInputService.InputEnded, function(input: InputObject)
        if ACCEPTED_INPUT[input.UserInputType] and self.hold then
            stick.Position = UDim2.fromScale(0.5, 0.5)
            self.hold = false
        end
    end)
end

function Thumbstick:willUnmount()
    self.__Trove:Destroy()
end

return Thumbstick