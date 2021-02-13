--[[-- Commands Module - Quickbar
    - Adds a command that allows players to load Quickbar presets
    @data Quickbar
]]

local Commands = require 'expcore.commands' --- @dep expcore.commands
local config = require 'config.preset_player_quickbar' --- @dep config.preset_player_quickbar

--- Stores the quickbar filters for a player
local PlayerData = require 'expcore.player_data' --- @dep expcore.player_data
local PlayerFilters = PlayerData.Settings:combine('QuickbarFilters')
PlayerFilters:set_metadata{
    permission = 'command/save-quickbar',
    stringify = function(value)
        if not value then return 'No filters set' end
        local count = 0
        for _ in pairs(value) do count = count + 1 end
        return count..' filters set'
    end
}

--- Loads your quickbar preset
PlayerFilters:on_load(function(player_name, filters)
    if not filters then filters = config[player_name] end
    if not filters then return end
    local player = game.players[player_name]
    for i, item_name in pairs(filters) do
        if item_name ~= nil and item_name ~= '' then
            player.set_quick_bar_slot(i, item_name)
        end
    end
end)

--- Saves your quickbar preset to the script-output folder
-- @command save-quickbar
Commands.new_command('save-quickbar', 'Saves your Quickbar preset items to file')
:add_alias('save-toolbar')
:register(function(player)
    local filters = {}
    local ignoredItems = {
        "blueprint",
        "blueprint-book",
        "deconstruction-planner",
        "spidertron-remote",
        "upgrade-planner"
    }
    local function contains(list, x)
        for _, v in pairs(list) do
            if v == x then return true end
        end
        return false
    end

    for i = 1, 100 do
        local slot = player.get_quick_bar_slot(i)
        -- Need to filter out blueprint and blueprint books because the slot is a LuaItemPrototype and does not contain a way to export blueprint data
        if slot ~= nil then
            local ignored = contains(ignoredItems, slot.name)
            if ignored == false then
                filters[i] = slot.name
            end
        end
    end

    if next(filters) then
        PlayerFilters:set(player, filters)
    else
        PlayerFilters:remove(player)
    end

    return {'quickbar.saved'}
end)

    local player = game.players[player_name]
    for i, item_name in pairs(filters) do
        if (item_name ~= nil and ignoredItems[item_name] ~= true) then
            local ignored = contains(ignoredItems, item_name)
            if ignored == false then
                game.print(item_name)
                game.print(ignoredItems[item_name])
                player.set_quick_bar_slot(i, item_name)
            end
        end
    end