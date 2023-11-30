local function create(class: string, parent: Instance?, properties: {[string]: any}?, children: {[string]: Instance}?)
    local object = Instance.new(class)
    if properties then
        for k, v in properties do
            object[k] = v
        end
    end
    object.Parent = parent

    if children then
        for n, inst in children do
            inst.Name = n
            inst.Parent = object
        end
    end

    return object
end

return create