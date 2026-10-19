local collect_actor = require("collect_actor")
local actor_names = require("actor_names")
local utils = require("utils")
local count = 50

return collect_actor(count, actor_names.ACTOR_SLOT_TOKEN,
	'textures/menus/missions/iconStar.tex',
	string.format(get_translated_string('COLLECT_SPIN_TOKENS'), 
	utils.get_formatted_number(count)))
