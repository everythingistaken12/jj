local collect_actor = require("collect_actor")
local utils = require("utils")
local actor_names = require("actor_names")
local count = 500
local actor = get_translated_string('GENERIC_EVENT_TOKENS')

return collect_actor(count, actor_names.ACTOR_EVENT_TOKEN,
	'textures/menus/missions/iconStar.tex',
	string.format(get_translated_string('COLLECT_ACTOR'), 
	utils.get_formatted_number(count), actor))
