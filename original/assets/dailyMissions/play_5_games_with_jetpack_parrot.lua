local play_games_with_jetpack = require("play_games_with_jetpack")
local utils = require("utils")
local count = 5
local jetpack = get_translated_string('ITEM_JETPACK_PARROT_NAME')

return play_games_with_jetpack(count, 'JETPACK_PARROT',
	'textures/menus/missions/iconStar.tex',
	string.format(get_translated_string('PLAY_GAMES_WITH_ACTOR'),
	utils.get_formatted_number(count), jetpack))
