local run_total_distance_with_costume = require("run_total_distance_with_costume")
local utils = require("utils")
local count = 10000
local costume = get_translated_string('ITEM_EASTERBUNNYSUIT_NAME')

return run_total_distance_with_costume(count, 'EASTER_BUNNY_HEAD', 'EASTER_BUNNY_SUIT',
	'textures/menus/missions/iconStar.tex',
	string.format(get_translated_string('RUN_DISTANCE_WITH_ACTOR'),
	utils.get_formatted_number(count), costume))
