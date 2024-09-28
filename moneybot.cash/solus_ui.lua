--[[
  @lordmouse: Still checking out the moneybot LUA API.
  @lordmouse: But a few people told me make a "Solus UI" for moneybot.
  @lordmouse: So why not?
]]

-- @lordmouse: https://docs.moneybot.cash/money-api/examples/draggables-library
local drag = require('draggables_library')

-- @lordmouse: same animations from the asm indicators
local additions, animations = {alpha = 0, width = 0, offset = 0}, {}
additions.lerp = function(name, value, speed, time)
  if animations[name] == nil then
    animations[name] = value
  end
  
  local c = animations[name] + (value - animations[name]) * client.get_absoluteframetime() * (speed or 8) * 1
  animations[name] = math.abs(value - c) < (time or .005) and value or c
  
  return animations[name]
end

local menu, reference = {}, {}
local save_pos_x, save_pos_y = render.get_screen_size()
menu.paint = {
  label = ui.add_label('solus ui'),
  label_2 = ui.add_label('author: lordmouse'),
  label_3 = ui.add_label('p.s \nif you want to change rect \nalpha - change it in \nmenu accent color'),
  style = ui.add_dropdown('style', {'default', 'semi outlined', 'fully outlined', 'left outlined'}),
  glow = ui.add_checkbox('glow', false),
  watermark = ui.add_checkbox('watermark', false),
  watermark_name = ui.add_dropdown('name', {'moneybot', 'moneybot.cash'}),
  keybinds = ui.add_checkbox('keybinds', false),
  keybinds_x = ui.add_slider('keybinds x', 285, 0, save_pos_x),
  keybinds_y = ui.add_slider('keybinds y', 410, 0, save_pos_y),
}

do
  menu.paint.keybinds_x:set_visible(false)
  menu.paint.keybinds_y:set_visible(false)
end

reference.color = ui.get('Misc', 'Other', 'Other', 'Menu Accent Color')

local bind_refs = {
  {name = 'Dormant aimbot', key = ui.get('Rage', 'General', 'Main', 'Default', 'Dormant Aimbot Key'), bool = ui.get('Rage', 'General', 'Main', 'Default', 'Dormant Aimbot')},
  {name = 'Ping spike', key = ui.get('Misc', 'Other', 'Other', 'Ping Spike Key'), bool = ui.get('Misc', 'Other', 'Other', 'Fake Latency')},
  {name = 'Force body aim', key = ui.get('Rage', 'General', 'Main', 'Default', 'Force Body Key'), bool = ui.get('Rage', 'General', 'Main', 'Default', 'Force Body Aim')},
  {name = 'Damage override', key = ui.get('Rage', 'General', 'Main', 'Default', 'Override Damage Key')},
  {name = 'Auto peek', key = ui.get('Misc', 'Other', 'Movement', 'Auto Peek Key'), bool = ui.get('Misc', 'Other', 'Movement', 'Auto Peek')},
  {name = 'Manual left', key = ui.get('Rage', 'Anti-Aim', 'Manual', 'Stand', 'Manual Left Key')},
  {name = 'Manual right', key = ui.get('Rage', 'Anti-Aim', 'Manual', 'Stand', 'Manual Right Key')},
  {name = 'Manual backward', key = ui.get('Rage', 'Anti-Aim', 'Manual', 'Stand', 'Manual Backwards Key')},
  {name = 'Manual forward', key = ui.get('Rage', 'Anti-Aim', 'Manual', 'Move', 'Manual Forward Key')},
  {name = 'Fake walk', key = ui.get('Misc', 'Other', 'Movement', 'Slow Walk Key'), bool = ui.get('Misc', 'Other', 'Movement', 'Fake Walk')}
}

local solus = {} do
  local font = render.create_font('Verdana', 12, 4, 0x10+0x80)
  function solus:rounded_rectangle(x, y, w, h, rounding, r, g, b, a)
    rounding = math.min(w / 2, h / 2, rounding)
    -- @lordmouse: !! WARNING -> shit code !!
    -- @lordmouse: !! the negative segment will crash the game !!
    -- @lordmouse: upper left
    render.push_clip_rect({x, y}, {rounding, rounding})
    render.circle_filled({x + rounding + 1, y + rounding}, rounding, 6, color(r, g, b, a))
    render.pop_clip_rect()
    -- @lordmouse: bottom left
    render.push_clip_rect({x, y + h - rounding}, {rounding, rounding})
    render.circle_filled({x + rounding + 1, y + h - rounding}, rounding, 6, color(r, g, b, a))
    render.pop_clip_rect()
    -- @lordmouse: upper right
    render.push_clip_rect({x + w - rounding, y}, {rounding, rounding})
    render.circle_filled({x + w - rounding - 1, y + rounding}, rounding, 6, color(r, g, b, a))
    render.pop_clip_rect()
    -- @lordmouse: bottom right
    render.push_clip_rect({x + w - rounding, y + h - rounding}, {rounding, rounding})
    render.circle_filled({x + w - rounding - 1, y + h - rounding}, rounding, 6, color(r, g, b, a))
    render.pop_clip_rect()
    -- @lordmouse: upper & bottom rec
    render.rectangle_filled({x + rounding, y}, {w - rounding * 2, rounding}, color(r, g, b, a)) -- @lordmouse: upper
    render.rectangle_filled({x + rounding, y + h - rounding}, {w - rounding * 2, rounding}, color(r, g, b, a)) -- @lordmouse: bottom
    -- @lordmouse: left & right rec
    render.rectangle_filled({x, y + rounding}, {rounding, h - rounding * 2}, color(r, g, b, a)) -- @lordmouse: left
    render.rectangle_filled({x + w - rounding, y + rounding}, {rounding, h - rounding * 2}, color(r, g, b, a)) -- @lordmouse: right
    -- @lordmouse: center rec
    render.rectangle_filled({x + rounding, y + rounding}, {w - rounding * 2, h - rounding * 2}, color(r, g, b, a))
  end

  function solus:outlined_rounded_rectangle(x, y, w, h, rounding, r, g, b, a)
    rounding = math.min(w / 2, h / 2, rounding)
    -- @lordmouse: !! WARNING -> shit code !!
    -- @lordmouse: !! the negative segment in circles will crash the game !!
    if menu.paint.style:get() == 1 then
      -- @lordmouse: upper left
      render.push_clip_rect({x, y}, {rounding, rounding})
      render.circle({x + rounding, y + rounding}, rounding, 6, color(r, g, b, a))
      render.pop_clip_rect()
      -- @lordmouse: upper right
      render.push_clip_rect({x + w - rounding, y}, {rounding, rounding})
      render.circle({x + w - rounding, y + rounding}, rounding, 6, color(r, g, b, a))
      render.pop_clip_rect()
      -- @lordmouse: upper & bottom outlines
      render.rectangle({x + rounding, y}, {w - rounding * 2, 1}, color(r, g, b, a)) -- @lordmouse: upper
      render.push_clip_rect({x + rounding - 10, y + h - 1}, {rounding, rounding})
      render.rectangle({x + rounding, y + h - 1}, {w - rounding * 2, 1}, color(r, g, b, a)) -- @lordmouse: bottom
      render.pop_clip_rect()
      -- @lordmouse: left & right outlines
      render.rectangle({x - 1, y + rounding}, {1, h - rounding * 2}, color(r, g, b, a)) -- @lordmouse: left
      render.rectangle({x + w, y + rounding}, {1, h - rounding * 2}, color(r, g, b, a)) -- @lordmouse: right
    elseif menu.paint.style:get() == 3 then
      -- @lordmouse: upper left
      render.push_clip_rect({x, y}, {rounding, rounding})
      render.circle({x + rounding, y + rounding}, rounding, 6, color(r, g, b, a))
      render.pop_clip_rect()
      -- @lordmouse: bottom left
      render.push_clip_rect({x, y + h - rounding}, {rounding, rounding})
      render.circle({x + rounding, y + h - rounding}, rounding, 6, color(r, g, b, a))
      render.pop_clip_rect()
      -- @lordmouse: left outline
      render.rectangle({x - 1, y + rounding}, {1, h - rounding * 2}, color(r, g, b, a))
    else
      -- @lordmouse: upper left
      render.push_clip_rect({x, y}, {rounding, rounding})
      render.circle({x + rounding, y + rounding}, rounding, 6, color(r, g, b, a))
      render.pop_clip_rect()
      -- @lordmouse: bottom left
      render.push_clip_rect({x, y + h - rounding}, {rounding, rounding})
      render.circle({x + rounding, y + h - rounding}, rounding, 6, color(r, g, b, a))
      render.pop_clip_rect()
      -- @lordmouse: upper right
      render.push_clip_rect({x + w - rounding, y}, {rounding, rounding})
      render.circle({x + w - rounding, y + rounding}, rounding, 6, color(r, g, b, a))
      render.pop_clip_rect()
      -- @lordmouse: bottom right
      render.push_clip_rect({x + w - rounding, y + h - rounding}, {rounding, rounding})
      render.circle({x + w - rounding, y + h - rounding}, rounding, 6, color(r, g, b, a))
      render.pop_clip_rect()
      -- @lordmouse: upper & bottom outlines
      render.rectangle({x + rounding, y}, {w - rounding * 2, 1}, color(r, g, b, a)) -- @lordmouse: upper
      render.rectangle({x + rounding, y + h - 1}, {w - rounding * 2, 1}, color(r, g, b, a)) -- @lordmouse: bottom
      -- @lordmouse: left & right outlines
      render.rectangle({x - 1, y + rounding}, {1, h - rounding * 2}, color(r, g, b, a)) -- @lordmouse: left
      render.rectangle({x + w, y + rounding}, {1, h - rounding * 2}, color(r, g, b, a)) -- @lordmouse: right
    end
  end

  function solus:glow (x, y, w, h, width, rounding, r, g, b, a, a2)
    self:rounded_rectangle(x, y, w, h, rounding, 0, 0, 0, a2)
    for g = 0, width do
      if a * (g / width) ^ (1) > 5 then
        self:outlined_rounded_rectangle(x + (g - width - 1), y + (g - width - 1), w - (g - width - 1) * 2, h - (g - width - 1) * 2, rounding + (width - g + 1), r, g, b, a * (g / width) ^ 2)
      end
    end
  end

  function solus:element (x, y, w, h, a, text, watermark)
    local col, text_w = reference.color:get(), render.get_text_size(font, text)
    local pos_x, rect_w = x - (watermark and text_w or 0), (watermark and text_w or w) + 6
    local glow = menu.paint.glow:get()
    local style = menu.paint.style:get() == 0

    if style then
      render.rectangle_filled({ pos_x, y - 2 }, { rect_w, 2 }, color(col.r, col.g, col.b, a))
      render.rectangle_filled({ pos_x, y }, { rect_w, 20 }, color(0, 0, 0, col.a * (a / 255)))
    else
      if glow then
        -- @lordmouse: use glow only for rounded styles
        self:glow(pos_x, y, rect_w, 20, 8, 4, col.r, col.g, col.b, 9 * (a / 255), col.a * (a / 255))
      else
        self:rounded_rectangle(pos_x, y, rect_w, 20, 4, 0, 0, 0, col.a * (a / 255))
      end
      self:outlined_rounded_rectangle(pos_x, y, rect_w, 20, 4, col.r, col.g, col.b, a)
    end

    if watermark then
      render.text({ x + 3, y + 3 }, color(255, 255, 255, a), font, 1, text)
    else
      render.text({ x + 4 + w / 2 - text_w / 2, y + 3 }, color(255, 255, 255, a), font, text)
    end
  end

  function solus:watermark ()
    additions.alpha = additions.lerp('alpha_watermark', menu.paint.watermark:get() and 255 or 0, 12)
    if additions.alpha == 0 then
      return
    end

    local name = 'moneybot'
    if menu.paint.watermark_name:get() == 1 then
      name = 'moneybot.cash'
    end

    local text = name .. ' [' .. user.get_build() .. '] | ' .. user.get_username() .. ' | delay: ' .. server.get_ping() .. 'ms | ' .. user.get_local_time()
    if menu.paint.style:get() > 0 then
      text = name .. ' ' .. user.get_build() .. ' ' .. user.get_username() .. ' delay: ' .. server.get_ping() .. 'ms ' .. user.get_local_time()
    end

    local x, y = render.get_screen_size()
    solus:element(x - 20, y / 63, 0, 0, additions.alpha, text, true)
  end

  function solus:get_active_binds()
    local binds, types, max_width = {}, {}, 0
    for _, bind in ipairs(bind_refs) do
      if bind.key:get() then
        local cond = bind.key:get_cond()
        local type = (cond == 1 and '[toggled]' or cond == 2 and '[holding]' or cond == 3 and '[off hotkey]' or cond == 4 and '[always on]' or '')
        if not bind.bool or bind.bool:get() then
          table.insert(binds, bind.name)
          table.insert(types, type)
          local bind_width = render.get_text_size(font, bind.name .. type)
          max_width = math.max(max_width, bind_width)
        end
      end
    end
    return binds, types, max_width
  end

  function solus:keybinds (x, y)
    local active_binds, bind_type, bind_width = self:get_active_binds()
    if menu.paint.keybinds:get() and #active_binds > 0 or menu.paint.keybinds:get() and ui.is_open() then
      additions.alpha = additions.lerp('alpha_keybinds', 255, 12)
    else
      additions.alpha = additions.lerp('alpha_keybinds', 0, 12)
    end
    
    if additions.alpha == 0 then
      return
    end
    local w, h = render.get_text_size(font, 'keybinds')

    additions.width = math.ceil(additions.lerp('keybinds_width', math.max(bind_width - 20, 55), 12))
    solus:element(x, y, w + additions.width, h, additions.alpha, 'keybinds')
    -- @lordmouse: TODO: make an fade animation when bind is turning off
    for i, bind_data in ipairs(active_binds) do
      additions.offset = additions.lerp(bind_data .. '_offset', (i - 1) * 17 + 25, 16, .001)
      render.text({ x + 5, y + additions.offset }, color(255, 255, 255, additions.alpha), font, bind_data)
      local type_w = render.get_text_size(font, bind_type[i])
      render.text({ x + (additions.width + type_w / 2 - 20), y + additions.offset }, color(255, 255, 255, additions.alpha), font, bind_type[i])
    end

    menu.paint.keybinds_x:set(x)
    menu.paint.keybinds_y:set(y)
  end

  solus.keybinds_drag = drag(menu.paint.keybinds_x:get(), menu.paint.keybinds_y:get(), 105, 20, function(x, y, width, height)
    solus:keybinds(x, y)
  end)

  -- @lordmouse: TODO: make spectator list.
end

callbacks.register('paint', function ()
  solus:watermark()
end)