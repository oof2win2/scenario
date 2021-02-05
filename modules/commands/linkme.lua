--[[-- Commands Module - Linkme
    - Adds a commands that allow players to link themselves to Discord and get the Members role
    @commands Linkme
]]

local Commands = require 'expcore.commands' --- @dep expcore.commands
local format_chat_player_name = _C.format_chat_player_name --- @dep expcore.common
local write_json = _C.write_json
-- local math = require("math")
-- local DatastoreManager = require 'expcore.datastore' --- @dep expcore.datastore


-- local AwfData = DatastoreManager.connect('AwfData')
-- AwfData:set_serializer(tostring)
Commands.new_command('linkme', 'Get a linking ID for Discord to get the Member role')
:register(function (player)
	local id = math.random(100000, 999999) -- six digit random number for identification
	write_json('ext/awflogging.out',
		{
			type='link',
			playerName=player.name,
			linkID=id
		}
	)
	print(player.name .. id)
	Commands.print('Successfully sent your ID to the Discord bot. Use the linkme command on our Discord (https://awf.yt)')
	return Commands.success('Your ID is '.. id)
end)