local collect_actor = require("collect_actor")
local utils = require("utils")
local actor_names = require("actor_names")
local count = 12500

return collect_actor(count, actor_names.ACTOR_COIN,
	'textures/menus/missions/iconStar.tex',
	string.format(get_translated_string('COLLECT_TOTAL_COINS'), 
	utils.get_formatted_number(count)))
