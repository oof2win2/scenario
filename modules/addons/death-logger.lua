--- Makes markers on the map where places have died and reclaims items if not recovered
-- @addon Death-Logger

local Event = require 'utils.event' --- @dep utils.event
local Global = require 'utils.global' --- @dep utils.global
local config = require 'config.death_logger' --- @dep config.death_logger
local format_time, move_items = _C.format_time, _C.move_items --- @dep expcore.common

-- Max amount of ticks a corpse can be alive
local corpse_lifetime = 60*60*15

local deaths = {
    archive={} -- deaths moved here after body is gone
    --{player_name='Cooldude2606', time_of_death='15H 15M', position={x=0, y=0}, corpse=LuaEntity, tag=LuaCustomChartTag}
}
Global.register(deaths, function(tbl)
    deaths = tbl
end)

--- Creates a new death marker and saves it to the given death
local function create_map_tag(death)
    local player = game.players[death.player_name]
    local message = player.name..' died'
    if config.include_time_of_death then
        local time = format_time(death.time_of_death, {hours=true, minutes=true, string=true})
        message = message..' at '..time
    end
    death.tag = player.force.add_chart_tag(player.surface, {
        position=death.position,
        icon=config.map_icon,
        text=message
    })
end

--- Checks that all map tags are present and valid
-- adds missing ones, deletes expired ones
local function check_map_tags()
    for index, death in ipairs(deaths) do
        local map_tag = death.tag
        local corpse = death.corpse
        -- Check the corpse is valid
        if corpse and corpse.valid then
            -- Corpse is valid check the map tag
            if not map_tag or not map_tag.valid then
                -- Map tag is not valid make a new one
                create_map_tag(death)
            end
        else
            -- Corpse is not valid so remove the map tag
            if map_tag and map_tag.valid then
                map_tag.destroy()
            end
            -- Move the death to the archive
            death.corpse = nil
            death.tag = nil
            table.insert(deaths.archive, death)
            table.remove(deaths, index)
        end
    end
end

-- when a player dies a new death is added to the records and a map marker is made
Event.add(defines.events.on_player_died, function(event)
    local player = game.players[event.player_index]
    local corpse = player.surface.find_entity('character-corpse', player.position)
    if config.use_chests_as_bodies then
        local items = corpse.get_inventory(defines.inventory.character_corpse).get_contents()
        local chest = move_items(items, corpse.surface, corpse.position)
        chest.destructible = false
        corpse.destroy()
        corpse = chest
    end
    local death = {
        player_name = player.name,
        time_of_death = event.tick,
        position = player.position,
        corpse = corpse
    }
    if config.show_map_markers then
        create_map_tag(death)
    end
    table.insert(deaths, death)

    -- Draw a light attached to the corpse with the player color
    if config.show_light_at_corpse then
        rendering.draw_light{
            sprite = 'utility/light_medium',
            color = player.color,
            target = corpse,
            force = player.force,
            surface = player.surface
        }
    end
end)

-- Draw lines to the player corpse
if config.show_line_to_corpse then
    Event.add(defines.events.on_player_respawned, function(event)
        local player = game.players[event.player_index]

        -- New deaths are added at the end of the deaths array, this is why
        -- we are itterating over the array in reverse. This saves on the amount
        -- of itterations we do.
        for index = #deaths, 1, -1 do
            local death = deaths[index]

            -- If the corpse has already expired break out of the loop because
            -- all the deaths that will follow will be expired.
            if game.tick - death.time_of_death > corpse_lifetime then break end

            -- Check if the death body is from the player
            -- Check if the corpse entity is still valid
            if death.player_name == player.name and death.corpse and death.corpse.valid then
                local line_color = player.color
                line_color.a = .3
                rendering.draw_line{
                    color = line_color,
                    from = player.character,
                    to = death.corpse,
                    players = { event.player_index },
                    width = 2,
                    dash_length = 1,
                    gap_length = 1,
                    surface = player.surface,
                    draw_on_ground = true
                }
            end
        end
    end)
end

-- every 5 min all bodies are checked for valid map tags
if config.show_map_markers then
    local check_period = 60*60*5 -- five minutes
    Event.on_nth_tick(check_period, function()
        check_map_tags()
    end)
end

if config.auto_collect_bodies then
    Event.add(defines.events.on_character_corpse_expired, function(event)
        local corpse = event.corpse
        local items = corpse.get_inventory(defines.inventory.character_corpse).get_contents()
        move_items(items, corpse.surface, {x=0, y=0})
    end)
end

-- this is so other modules can access the logs
return deaths