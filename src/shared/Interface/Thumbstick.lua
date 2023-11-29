--> Services
local Packages = game:GetService('ReplicatedStorage').Packages

--> Packages
local Roact = require(Packages.Roact)
local Trove = require(Packages.Trove)
local TableUtil = require(Packages.TableUtil)

--> Constants
local STICK_HITBOX_SCALE = 8
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

--> Private Function
local function calculatePos(input: InputObject, self: Thumbstick)
    local thumbstickFrame: Frame = self.frameRef:getValue()
    local stick: Frame = thumbstickFrame.Stick

    local centerPos = thumbstickFrame.AbsolutePosition + thumbstickFrame.AbsoluteSize / 2
    local currentPos = Vector2.new(input.Position.X, input.Position.Y)

    local diff = currentPos - centerPos
    local length = diff.Magnitude

    local maxLength = thumbstickFrame.AbsoluteSize.X / 2
    
    length = math.min(length, maxLength)
    diff = diff.Unit * length

    stick.Position = UDim2.new(
        0.5, diff.X, 0.5, diff.Y
    )
end

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

        [Roact.Event.InputBegan] = function(thumbstickFrame, input: InputObject)
            if not (ACCEPTED_INPUT[input.UserInputType] and not self.hold) then return end
            calculatePos(input, self)
            thumbstickFrame:SetAttribute('IsInteracting', true)
            self.hold = true
        end,

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
            }),
            Hitbox = Roact.createElement('Frame', {
                AnchorPoint = Vector2.one * 0.5,
                BackgroundTransparency = 0.5,

                Size = UDim2.fromScale(STICK_HITBOX_SCALE, STICK_HITBOX_SCALE),
                Position = UDim2.fromScale(0.5, 0.5),

                [Roact.Event.InputChanged] = function(_, input: InputObject)
                    if not (ACCEPTED_MOVEMENT[input.UserInputType] and self.hold) then return end
                    calculatePos(input, self)
                end,

                [Roact.Event.InputEnded] = function(hb, input: InputObject)
                    if ACCEPTED_INPUT[input.UserInputType] and self.hold then
                        hb.Parent.Position = UDim2.fromScale(0.5, 0.5)
                        hb.Parent.Parent:SetAttribute('IsInteracting', false)
                        self.hold = false
                    end
                end
            })
        }),
        Label = Roact.createElement('TextLabel', {
            AnchorPoint = Vector2.yAxis,
            BackgroundTransparency = 1,

            Text = '0, 0',
            TextColor3 = WHITE,

            Size = UDim2.fromScale(1, 0.2)
        })
    })
end

function Thumbstick:didMount()
    local thumbstickFrame: Frame = self.frameRef:getValue()
    local stick: Frame = thumbstickFrame.Stick

    self.__Trove:Connect(stick:GetPropertyChangedSignal('AbsolutePosition'), function()
        local thumbstickPos = thumbstickFrame.AbsolutePosition
        local stickPos = stick.AbsolutePosition
        local stickSize = stick.AbsoluteSize / 2
    
        local direction = -((thumbstickPos - stickPos) + stickSize)
        thumbstickFrame:SetAttribute('MoveDirection', Vector2.new(
            math.round(direction.X), math.round(direction.Y)
        ))
    end)

    self.__Trove:Connect(thumbstickFrame:GetAttributeChangedSignal('MoveDirection'), function()
        local dir = thumbstickFrame:GetAttribute('MoveDirection')
        thumbstickFrame.Label.Text = `{dir.X}, {dir.Y}`
    end)

    thumbstickFrame:SetAttribute('IsInteracting', false)
end

function Thumbstick:willUnmount()
    self.__Trove:Destroy()
end

return Thumbstick