local miss_actor = require("miss_actor")
local actor_names = require("actor_names")
local utils = require("utils")
local count = 10
local actor = get_translated_string('VEHICLE_TOKENS_NAME')

return miss_actor(count, actor_names.ACTOR_VEHICLE_PICKUP,
	'textures/menus/missions/iconStar.tex',
	string.format(get_translated_string('MISS_ACTOR'), utils.get_formatted_number(count), actor))
