--[[
  @lordmouse: Checking out the moneybot LUA API.
  @lordmouse: Honestly, this code could have been better. But as they say, if it works, it's fine.
  @lordmouse: Special thanks for Liberty and his video where he got banned on HVH server with *hidden*. I couldn't have made an exact replica without this video. Also the font may be not accurate.
]]

local additions, animations = {}, {}
additions.alpha = 0
additions.bind = 0
additions.offset = 0
additions.lerp = function(name, value, speed, time)
  if animations[name] == nil then
    animations[name] = value
  end
  
  local c = animations[name] + (value - animations[name]) * client.get_absoluteframetime() * (speed or 8) * 1
  animations[name] = math.abs(value - c) < (time or .005) and value or c
  
  return animations[name]
end

local menu, reference = {}, {}
menu.paint = {
  label = ui.add_label('assembly ~ replica'),
  label_2 = ui.add_label('author: lordmouse'),
  watermark = ui.add_checkbox('watermark', false),
  indicators = ui.add_checkbox('side indicators', false),
}

reference.color = ui.get('Misc', 'Other', 'Other', 'Menu Accent Color')
reference.dormant_aimbot = ui.get('Rage', 'General', 'Main', 'Default', 'Dormant Aimbot')
reference.dormant_aimbot_key = ui.get('Rage', 'General', 'Main', 'Default', 'Dormant Aimbot Key')
reference.body_aim = ui.get('Rage', 'General', 'Main', 'Default', 'Force Body Aim')
reference.body_aim_key = ui.get('Rage', 'General', 'Main', 'Default', 'Force Body Key')
reference.override_damage = ui.get('Rage', 'General', 'Main', 'Default', 'Override Damage Key')
reference.fake_latency = ui.get('Misc', 'Other', 'Other', 'Fake Latency')
reference.ping_spike_key = ui.get('Misc', 'Other', 'Other', 'Ping Spike Key')
reference.ping_spike_amount = ui.get('Misc', 'Other', 'Other', 'Ping Spike Amount')
-- @lordmouse: i dont care about filters (if you are then make it by yourself for each state)
reference.fake_flick = ui.get('Rage', 'Anti-Aim', 'General', 'Stand', 'Fake Flick')
reference.fake_flick_key = ui.get('Rage', 'Anti-Aim', 'General', 'Stand', 'Fake Flick Key')
reference.freestanding = ui.get('Rage', 'Anti-Aim', 'General', 'Stand', 'Auto Direction')
reference.freestanding_key = ui.get('Rage', 'Anti-Aim', 'General', 'Stand', 'Auto Direction Key')
reference.manual_left = ui.get('Rage', 'Anti-Aim', 'Manual', 'Stand', 'Manual Left Key')
reference.manual_right = ui.get('Rage', 'Anti-Aim', 'Manual', 'Stand', 'Manual Right Key')
reference.manual_backwards = ui.get('Rage', 'Anti-Aim', 'Manual', 'Stand', 'Manual Backwards Key')
reference.manual_forwards = ui.get('Rage', 'Anti-Aim', 'Manual', 'Move', 'Manual Forward Key')
-- @lordmouse: i think that is enought (if you want more add more by yourself)

local assembly = {} do
  local font = render.create_font('Calibri Bold', 28, 4, 0x10)
  local font_2 = render.create_font('Verdana', 12, 4, 0x10+0x80+0x100)

  function assembly:watermark ()
    additions.alpha = additions.lerp('alpha_watermark', menu.paint.watermark:get() and 255 or 0, 12, .001)
    if additions.alpha == 0 then
      return
    end

    local col = reference.color:get()
    local x, y = render.get_screen_size()
    local half_w, half_h = render.get_text_size(font, 'MONEYBOT') / 2
    local build = user.get_build() .. ' - '
    local time = ' - ' .. user.get_local_time()
    local name = user.get_username()

    local watermark_data = {
      { text = 'MONEYBOT', font = font, x_offset = -130 - half_w, y_offset = y / 50, color = color(col.r, col.g, col.b, additions.alpha), align = nil },
      { text = '.cash', font = font_2, x_offset = -130 + half_w, y_offset = y / 32, color = color(255, 255, 255, additions.alpha), align = nil },
      { text = build, font = font_2, x_offset = -164 - render.get_text_size(font_2, name) + 26, y_offset = y / 21, color = color(255, 255, 255, additions.alpha), align = nil },
      { text = name, font = font_2, x_offset = -92 - render.get_text_size(font_2, time) / 2 + render.get_text_size(font_2, build) / 2, y_offset = y / 21, color = color(col.r, col.g, col.b, additions.alpha), align = 1 },
      { text = time, font = font_2, x_offset = -164 + half_w, y_offset = y / 21, color = color(255, 255, 255, additions.alpha), align = nil },
    }

    render.gradient({ x - 185 - half_w, y / 57 }, { 150 + half_w, 55 }, color(0, 0, 0, 0), color(0, 0, 0, 200 * (additions.alpha / 255)), true)
    render.rectangle_filled({ x - 35, y / 57 }, { 4, 55 }, color(col.r, col.g, col.b, additions.alpha))
    
    for _, data in ipairs(watermark_data) do
      if data.align then
        render.text({ x + data.x_offset, data.y_offset }, data.color, data.font, data.align, data.text)
      else
        render.text({ x + data.x_offset, data.y_offset }, data.color, data.font, data.text)
      end
    end
  end

  function assembly:indicator_overlay (text, ...)
    local args = { ... }
    local second_text, offset, r, g, b, a

    if type(args[1]) == 'string' then
      second_text, offset, r, g, b, a = args[1], args[2], args[3], args[4], args[5], args[6]
    else
      offset, r, g, b, a = args[1], args[2], args[3], args[4], args[5]
    end

    local x, y = render.get_screen_size()
    local w, h = second_text and render.get_text_size(font_2, second_text) / 2 or render.get_text_size(font, text) / 2

    render.gradient({ x / 63 - 8, y / 2.088 + offset }, { 100 + w, 50 }, color(0, 0, 0, 200 * (a / 255)), color(0, 0, 0, 0), true)
    render.rectangle_filled({ x / 60 - 13, y / 2.088 + offset }, { 4, 50 }, color(r, g, b, a))
    if second_text then
      render.text({ x / 60, y / 2.075 + offset }, color(r, g, b, a), font, text)
      render.text({ x / 60, y / 2.075 + 28 + offset }, color(200, 200, 200, a), font_2, second_text)
    else
      render.text({ x / 60, y / 2.05 + offset }, color(r, g, b, a), font, text)
    end
  end

  function assembly:indicators ()
    additions.alpha = additions.lerp('alpha_indicators', menu.paint.indicators:get() and 255 or 0, 12, .001)
    if additions.alpha == 0 then
      return
    end

    local me = entity_list.get_local_player()
    if not me or not client.is_alive() then
      return
    end

    local height = 0

    local function process_indicator (text, active, ...)
      local args = { ... }
      local second_text, r, g, b
      if type(args[1]) == 'string' then
        second_text, r, g, b = args[1], args[2], args[3], args[4]
      else
        r, g, b = args[1], args[2], args[3]
      end

      additions.bind = additions.lerp(text .. '_bind', active and 1 or 0, 18, .001)
      additions.offset = additions.lerp(text .. '_offset', active and 70 or 0, 12, .001)
      if second_text then
        assembly:indicator_overlay(text, second_text, height, r, g, b, additions.alpha * additions.bind)
      else
        assembly:indicator_overlay(text, height, r, g, b, additions.alpha * additions.bind)
      end
      height = height + math.ceil(additions.offset)
    end

    local lc_r, lc_g, lc_b = 232, 167, 159
    if client.is_lc_broken() then
      lc_r, lc_g, lc_b = 160, 220, 154
    end

    local lby_r, lby_g, lby_b = 232, 167, 159
    if client.get_lby_state() > 0 then
      lby_r, lby_g, lby_b = 160, 220, 154
    end
    
    process_indicator('DORMANT AIM', reference.dormant_aimbot:get() and reference.dormant_aimbot_key:get(), 'Aimbotting enemies through the dormant', 255, 255, 255)
    process_indicator('LC', client.is_lc_broken(), 'You are currently breaking LC', lc_r, lc_g, lc_b)
    process_indicator('LBY', client.get_lby_state() > 0 and not reference.fake_flick_key:get(), lby_r, lby_g, lby_b)
    process_indicator('DEATOMIZER', reference.fake_flick:get() and reference.fake_flick_key:get(), 'Unleashing the power of deatomizer!', 199, 202, 249)
    process_indicator('FREESTANDING', reference.freestanding:get() and reference.freestanding_key:get() and not reference.manual_left:get() and not reference.manual_right:get() and not reference.manual_backwards:get() and not reference.manual_forwards:get(), 'Your anti-aim is currently freestanding', 255, 255, 255)
    process_indicator('BODY', reference.body_aim:get() and reference.body_aim_key:get(), 'Enemies cannot remain unkilled under this force', 255, 255, 255)
    process_indicator('PING', reference.fake_latency:get() and reference.ping_spike_key:get(), 'Your ping is spiking to ' .. reference.ping_spike_amount:get() .. 'ms', 160, 220, 154)
    process_indicator('LEFT', reference.manual_left:get(), 'Your anti-aim is currently facing left', 255, 255, 255)
    process_indicator('RIGHT', reference.manual_right:get(), 'Your anti-aim is currently facing right', 255, 255, 255)
    process_indicator('BACK', reference.manual_backwards:get(), 'Your anti-aim is currently facing back', 255, 255, 255)
    process_indicator('FORWARDS', reference.manual_forwards:get(), 'Your anti-aim is currently facing forwards', 255, 255, 255)
    process_indicator('DAMAGE', reference.override_damage:get(), 'You are currently overriding minimum damage', 255, 255, 255)
  end
end

callbacks.register('paint', function ()
  assembly:watermark()
  assembly:indicators()
end)
