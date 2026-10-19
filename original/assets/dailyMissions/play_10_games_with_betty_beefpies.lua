local play_games_with_costume = require("play_games_with_costume")
local utils = require("utils")
local count = 10
local costume = get_translated_string('ITEM_BETTY_BEEFPIES_HEAD_NAME')

return play_games_with_costume(count, 'BETTY_BEEFPIES_HEAD', 'BETTY_BEEFPIES_BODY',
	'textures/menus/missions/iconStar.tex',
	string.format(get_translated_string('PLAY_GAMES_WITH_ACTOR'), 
	utils.get_formatted_number(count), costume))