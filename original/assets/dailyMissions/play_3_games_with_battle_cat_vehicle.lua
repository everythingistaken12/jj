local play_games_with_vehicle_skin = require("play_games_with_vehicle_skin")
local utils = require("utils")
local count = 3
local vehicle = get_translated_string('VEHICLE_SKIN_MOTU_BATTLE_CAT_NAME')

return play_games_with_vehicle_skin(count, 'BattleCat',
	'textures/menus/missions/iconStar.tex',
	string.format(get_translated_string('PLAY_GAMES_WITH_ACTOR'), 
	utils.get_formatted_number(count), vehicle))