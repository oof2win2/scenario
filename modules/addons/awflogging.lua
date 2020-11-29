local Event = require 'utils.event' --- @dep utils.event
local Datastore = require 'expcore.datastore' --- @dep expcore.datastore

--- @addon awflogging
--[[
	This is a module for general AwF logging
]]

local AwfData = Datastore.connect('AwfData')
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
	print ("JLOGGER: RESEARCH FINISHED: " .. research_name .. " " .. (event.research.level or "no-level"))
end

local function on_trigger_fired_artillery(event)
	print ("JLOGGER: ARTILLERY: " .. event.entity.name .. (event.source.name or "no source"))
end

local function on_built_entity(event)
	-- get the corresponding data
	local data = AwfData:get(event.player_index)
	if data == nil then
		-- format of array: {entities placed, ticks played}
		data = {1, 0}
		AwfData:set(event.player_index, data)
	else
		data[1] = data[1] + 1 --indexes start with 1 in lua
		AwfData:update(event.player_index, function (_, value)
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
		local pdat = AwfData:get(p.index)
		if (pdat == nil) then
				-- format of array: {entities placed, ticks played}
				pdat = {0, p.online_time}
				print ("JLOGGER: STATS: " .. p.name .. " " .. 0 .. " " .. p.online_time)
				AwfData:set(p.index, pdat)
		else
			if (pdat[1] ~= 0 or (p.online_time - pdat[2]) ~= 0) then
				print ("JLOGGER: STATS: " .. p.name .. " " .. pdat[1] .. " " .. (p.online_time - pdat[2]))
			end
			-- update the data
			AwfData:update(p.index, function (_, value) --messy callback idc
				value[1] = 0 -- reset the number of built entities
				value[2] = p.online_time -- set it back to the time played (currently)
			end)
		end
	end
end

-- Determine if a player is AFK or not when they leave
-- read this instead of [LEAVE] with Jammy
-- doesn't work for now, game logs leaving as an action
-- https://discord.com/channels/139677590393716737/306402592265732098/782324243126812722
local function on_pre_player_left_game(p_index)
	for _, p in pairs(game.players)
	do
		if (p.index == p_index) then
			if (p.afk_time <= 14*60*60+50) then -- 14 minutes 50s
				print ("JLOGGER: PLAYER LEAVE: AFK " .. p.name)
			else 
				print ("JLOGGER: PLAYER LEAVE: NON_AFK " .. p.name)
			end
		end
	end
end

Event.add(defines.events.on_rocket_launched, on_rocket_launched)
Event.add(defines.events.on_pre_player_died, on_pre_player_died)
-- Event.add(defines.events.on_pre_player_left_game, on_pre_player_left_game)
Event.add(defines.events.on_research_finished, on_research_finished)
Event.add(defines.events.on_trigger_fired_artillery, on_trigger_fired_artillery)
Event.add(defines.events.on_built_entity, on_built_entity)
Event.on_nth_tick(54000, logStats)
