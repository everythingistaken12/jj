local clear_actor = require("clear_actor")
local actor_names = require("actor_names")
local utils = require("utils")
local count = 100
local actor = get_translated_string('VEHICLE_TOKENS_NAME')

return clear_actor(count, actor_names.ACTOR_OBSTACLE,
	'textures/menus/missions/iconStar.tex',
	string.format(get_translated_string('MISS_ZAPPERS'), utils.get_formatted_number(count)))
