local function run(event)
	local player = game.get_player(event.player_index)
	local bp = player.blueprint_to_setup
	for k, v in pairs(bp.get_blueprint_entities()) do
			print(tostring(k) ..  tostring(v))
	end
end
local lib = {}
lib.events = {
	[defines.events.on_player_configured_blueprint] = run
}
return lib