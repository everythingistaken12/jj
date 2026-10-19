local play_games_with_vehicle_skin = require("play_games_with_vehicle_skin")
local utils = require("utils")
local count = 5
local vehicle = get_translated_string('VEHICLE_SKIN_DULLAHAN_NAME')

return play_games_with_vehicle_skin(count, 'VEHICLE_SKIN_DULLAHAN',
	'textures/menus/missions/iconStar.tex',
	string.format(get_translated_string('PLAY_GAMES_WITH_ACTOR'),
	utils.get_formatted_number(count), vehicle))
