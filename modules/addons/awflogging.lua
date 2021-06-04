local Event = require 'utils.event' --- @dep utils.event
local DatastoreManager = require 'expcore.datastore' --- @dep expcore.datastore
local write_json = _C.write_json

--- @addon awflogging
--[[
	This is a module for general AwF logging
]]

local AwfData = DatastoreManager.connect('AwfData')
AwfData:set_serializer(tostring)

local function on_rocket_launched(event)
	print ("JLOGGER: ROCKET: " .. "ROCKET LAUNCHED")
end

local function on_pre_player_died(event)
	if event.cause and event.cause.type == "character" then --PvP death
		print("JLOGGER: DIED: PLAYER: " .. game.get_player(event.player_index).name .. " " .. (game.get_player(event.cause.player.index).name or "no-cause"))
	elseif (event.cause) then
		print ("JLOGGER: DIED: " .. game.get_player(event.player_index).name .. " " .. (event.cause.name or "no-cause"))
	else
		print ("JLOGGER: DIED: " .. game.get_player(event.player_index).name .. " " .. "no-cause") --e.g. poison damage
	end
end

local function get_infinite_research_name(name) --gets the name of infinite research (without numbers)
  return string.match(name, "^(.-)%-%d+$") or name
end

local function on_research_finished(event)
	local research_name = get_infinite_research_name(event.research.name)
	local level = 
	print ("JLOGGER: RESEARCH FINISHED: " .. research_name .. " " .. (event.research.level or "no-level"))
end

local function on_trigger_fired_artillery(event)
	print ("JLOGGER: ARTILLERY: " .. event.entity.name .. (event.source.name or "no source"))
end

local function on_built_entity(event)
	-- get the corresponding data
	local player = game.get_player(event.player_index)
	local data = AwfData:get(player.name)
	if data == nil then
		-- format of array: {entities placed, ticks played}
		data = {1, 0}
		AwfData:set(player.name, data)
	else
		data[1] = data[1] + 1 --indexes start with 1 in lua
		AwfData:update(player.name, function (_, value)
			value[1] = value[1] + 1
		end)
	end
end

-- function not used anymore due to logStats
local function printPlayerBuilds()
        -- prints player name and player online time
        for _, p in pairs(game.players)
        do
				if global[p.index] ~= nil
				then -- ~= is lua's != operator
						print ("JLOGGER: BUILT ENTITY: " .. p.name .. " " .. global[p.index][1])
						global[p.index][1] = 0
                end
        end
end

-- function not used anymore due to logStats
local function logPlayerTime()
	for _, p in pairs(game.players)
	do
		if global[p.index] == nil then
				-- format of array: {entities placed, ticks played}
				global[p.index] = {0, p.online_time}
				print ("JLOGGER: TIME PLAYED: " .. p.name .. " " .. p.online_time)
		else
			local playerStats = global[p.index]
			print ("JLOGGER: TIME PLAYED: " .. p.name .. " " .. (p.online_time - playerStats[2]))
			playerStats[2] = p.online_time --set it back to the time played (currently)
			global[p.index] = playerStats
		end
	end
end

local function logStats()
	for _, p in pairs(game.players)
	do
		local pdat = AwfData:get(p.name)
		if (pdat == nil) then
				-- format of array: {entities placed, ticks played}
				pdat = {0, p.online_time}
				print ("JLOGGER: STATS: " .. p.name .. " " .. 0 .. " " .. p.online_time)
				AwfData:set(p.name, pdat)
		else
			if (pdat[1] ~= 0 or (p.online_time - pdat[2]) ~= 0) then
				print ("JLOGGER: STATS: " .. p.name .. " " .. pdat[1] .. " " .. (p.online_time - pdat[2]))
			end
			-- update the data
			AwfData:update(p.name, function (_, value) --messy callback idc
				value[1] = 0 -- reset the number of built entities
				value[2] = p.online_time -- set it back to the time played (currently)
			end)
		end
	end
end

-- Determines and logs a leave reason for a player leaving, logs it to script-output/ext/awflogging.out
local function on_player_left_game(event)
	local player = game.get_player(event.player_index)
	local reason
	if event.reason == defines.disconnect_reason.quit then
		reason = "quit"
	elseif event.reason == defines.disconnect_reason.dropped then
		reason = "dropped"
	elseif event.reason == defines.disconnect_reason.reconnect then
		reason = "reconnect"
	elseif event.reason == defines.disconnect_reason.wrong_input then
		reason = "wrong_input"
	elseif event.reason == defines.disconnect_reason.desync_limit_reached then
		reason = "desync_limit_reached"
	elseif event.reason == defines.disconnect_reason.cannot_keep_up then
		reason = "cannot_keep_up"
	elseif event.reason == defines.disconnect_reason.afk then
		reason = "afk"
	elseif event.reason == defines.disconnect_reason.kicked then
		reason = "kicked"
	elseif event.reason == defines.disconnect_reason.kicked_and_deleted then
		reason = "kicked_and_deleted"
	elseif event.reason == defines.disconnect_reason.banned then
		reason = "banned"
	elseif event.reason == defines.disconnect_reason.switching_servers then
		reason = "switching_servers"
	else
		reason = "other"
	end
	write_json('ext/awflogging.out',
		{
			type='leave',
			playerName=player.name,
			reason=reason
		}
	)
end
local function on_player_joined_game(event)
	local player = game.get_player(event.player_index)
	write_json('ext/awflogging.out',
		{
			type='join',
			playerName=player.name
		}
	)
end
local function checkEvolution(event)
	print("JLOGGER: EVOLUTION: " .. string.format("%.4f", game.forces["enemy"].evolution_factor))
end

Event.add(defines.events.on_rocket_launched, on_rocket_launched)
Event.add(defines.events.on_pre_player_died, on_pre_player_died)
-- Event.add(defines.events.on_pre_player_left_game, on_pre_player_left_game)
Event.add(defines.events.on_research_finished, on_research_finished)
Event.add(defines.events.on_trigger_fired_artillery, on_trigger_fired_artillery)
Event.add(defines.events.on_built_entity, on_built_entity)
Event.add(defines.events.on_player_left_game, on_player_left_game)
Event.add(defines.events.on_player_joined_game, on_player_joined_game)
Event.on_nth_tick(54000, logStats)
Event.on_nth_tick(3600, checkEvolution) -- log evolution every