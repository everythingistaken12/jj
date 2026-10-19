local run_total_distance = require("run_total_distance")
local utils = require("utils")
local count = 3000
local actor = get_translated_string('ANY_VEHICLE')

return run_total_distance(count, true,
	'textures/menus/missions/iconStar.tex',
	string.format(get_translated_string('RUN_DISTANCE_WITH_ACTOR'), 
	utils.get_formatted_number(count), actor))
