local play_games_with_jetpack = require("play_games_with_jetpack")
local utils = require("utils")
local count = 10
local jetpack = get_translated_string('ITEM_DEMON_JETPACK_NAME')

return play_games_with_jetpack(count, 'JETPACK_DEMON',
	'textures/menus/missions/iconStar.tex',
	string.format(get_translated_string('PLAY_GAMES_WITH_ACTOR'), 
	utils.get_formatted_number(count), jetpack))