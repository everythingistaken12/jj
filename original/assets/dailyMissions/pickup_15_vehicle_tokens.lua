local collect_actor = require("collect_actor")
local utils = require("utils")
local actor_names = require("actor_names")
local count = 15
local actor = get_translated_string('VEHICLE_TOKENS_NAME')

return collect_actor(count, actor_names.ACTOR_VEHICLE_PICKUP,
	'textures/menus/missions/iconStar.tex',
	string.format(get_translated_string('COLLECT_ACTOR'), 
	utils.get_formatted_number(count), actor))
