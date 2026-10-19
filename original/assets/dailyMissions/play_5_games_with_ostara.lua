local play_games_with_costume = require("play_games_with_costume")
local utils = require("utils")
local count = 5
local costume = get_translated_string('ITEM_OSTARA_HEAD_NAME')

return play_games_with_costume(count, 'OSTARA_HEAD', 'OSTARA_BODY',
	'textures/menus/missions/iconStar.tex',
	string.format(get_translated_string('PLAY_GAMES_WITH_ACTOR'),
	utils.get_formatted_number(count), costume))
