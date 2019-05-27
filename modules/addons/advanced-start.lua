--- Adds a better method of player starting items based on production levels.
local Event = require 'utils.event'
local Game = require 'utils.game'
local config = require 'config.advanced_start'
local items = config.items

Event.add(defines.events.on_player_created, function(event)
    local player = Game.get_player_by_index(event.player_index)
    -- game init settings
    if event.player_index == 1 then
        player.force.friendly_fire = config.friendly_fire
        game.map_settings.enemy_expansion.enabled = config.enemy_expansion
        local r = config.chart_radius
        local p = player.position
        player.force.chart(player.surface, {{p.x-r, p.y-r}, {p.x+r, p.y+r}})
    end
    -- spawn items
    for item,callback in pairs(items) do
        if type(callback) == 'function' then
            local stats = player.force.item_production_statistics
            local made = stats.get_input_count(item)
            local success,count = pcall(callback,made,stats.get_input_count,player)
            if success and count > 0 then
                player.insert{name=item,count=count}
            end
        end
    end
end)

Event.on_init(function()
    remote.call('freeplay','set_created_items',{})
    remote.call('freeplay','set_chart_distance',0)
    remote.call('freeplay','set_skip_intro',config.skip_intro)
end)