--[[-- Commands Module - Linkme
    - Adds a commands that allow players to link themselves to Discord and get the Members role
    @commands Linkme
]]

local Commands = require 'expcore.commands' --- @dep expcore.commands
local format_chat_player_name = _C.format_chat_player_name --- @dep expcore.common
local write_json = _C.write_json
-- local DatastoreManager = require 'expcore.datastore' --- @dep expcore.datastore


-- local AwfData = DatastoreManager.connect('AwfData')
-- AwfData:set_serializer(tostring)

Commands.new_command('linkme', 'Link yourself to Discord and get the Member role')
:add_param('Discord username without tag (Wumpus, not Wumpus#0001)', false)
:register(function (player, discordUsername)
	if not discordUsername then return Commands.error('Provide a Discord username!') end
	-- local linked = AwFData:get(player.name)
	write_json('ext/awflogging.out',
		{
			type='link',
			playerName=player.name,
			discordName=discordUsername
		}
	)
	return Commands.success('Linking! Expect a DM on Discord (enable DMs from AwF server and make sure you are joined to the server)')
end)