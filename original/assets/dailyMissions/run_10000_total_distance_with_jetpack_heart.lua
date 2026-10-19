local run_total_distance_with_jetpack = require("run_total_distance_with_jetpack")
local utils = require("utils")
local count = 10000
local jetpack = get_translated_string('ITEM_HEART_JETPACK_NAME')

return run_total_distance_with_jetpack(count, 'JETPACK_HEART',
	'textures/menus/missions/iconStar.tex',
	string.format(get_translated_string('RUN_DISTANCE_WITH_ACTOR'), 
	utils.get_formatted_number(count), jetpack))