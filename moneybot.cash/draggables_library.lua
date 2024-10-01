local VK_LBUTTON = 0x01

local Draggable = {}
Draggable.__index = Draggable
Draggable.__running = false

Draggable.current = nil
Draggable.queue = {}

function Draggable.new(x, y, width, height, draw_func)
    local obj = setmetatable({}, Draggable)

    obj.x = x
    obj.dx = dx
    obj.y = y
    obj.dy = dy
    obj.width = width
    obj.height = height

    obj.draw_func = draw_func or Draggable.DEFAULT_DRAW_FUNC

    Draggable.queue[#Draggable.queue+1] = obj

    return obj
end

function Draggable.DEFAULT_DRAW_FUNC(x, y, width, height)
    render.rectangle_filled(x, y, width, height, color(0, 0, 0, 150))
end

function Draggable:set_draw_function(func)
    self.draw_func = func
end

function Draggable:unpack()
    return self.x, self.y, self.width, self.height
end

function Draggable:contains_point(x, y)
    return x >= self.x and y >= self.y and x <= self.x + self.width 
    and y <= self.y + self.height
end

function Draggable:update()
    local mx, my = input.get_mouse_position()

    if Draggable.current and Draggable.current ~= self then
        return
    end

    if Draggable.current == nil and self:contains_point(mx, my) 
    and input.key_pressed(VK_LBUTTON) then
        Draggable.current = self

        self.dx = mx - self.x
        self.dy = my - self.y

        for i = 2, #Draggable.queue do
            if Draggable.queue[i] == self then
                table.remove(Draggable.queue, i)
                table.insert(Draggable.queue, 1, self)
                break
            end
        end
    elseif Draggable.current == self then
        self.x = mx - self.dx
        self.y = my - self.dy

        if input.key_released(VK_LBUTTON) then
            Draggable.current = nil 
        end
    end
end

function Draggable.run()
    for i = 1, #Draggable.queue do
        Draggable.queue[i]:update()
    end

    -- Drawing the top draggables last makes them appear on top
    for i = #Draggable.queue, 1, -1 do
        Draggable.queue[i].draw_func(Draggable.queue[i]:unpack())
    end
end

setmetatable(Draggable, {
    __call = function(_, ...)
        return Draggable.new(...)
    end
})

if not Draggable.__running then
    Draggable.__running = true

    callbacks.register("paint", Draggable.run)
end

return Draggable