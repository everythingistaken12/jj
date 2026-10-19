local run_total_distance = require("run_total_distance")
local utils = require("utils")
local count = 75000

return run_total_distance(count, false,
	'textures/menus/missions/iconStar.tex',
	string.format(get_translated_string('RUN_TOTAL_DISTANCE'), 
	utils.get_formatted_number(count)))
