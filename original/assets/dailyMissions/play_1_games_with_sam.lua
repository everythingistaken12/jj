local play_games_with_sam = require("play_games_with_sam")
local utils = require("utils")
local count = 1
local sam = get_translated_string('VEHICLE_SKIN_SAM_NAME')

return play_games_with_sam(count,
	'textures/menus/missions/iconStar.tex',
	string.format(get_translated_string('PLAY_GAMES_WITH_ACTOR'), 
	utils.get_formatted_number(count), sam))