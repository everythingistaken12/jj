local play_games_with_costume = require("play_games_with_costume")
local utils = require("utils")
local count = 10
local costume = get_translated_string('ITEM_ELF_COSTUME')

return play_games_with_costume(count, 'ELF_HEAD', 'ELF_BODY',
	'textures/menus/missions/iconStar.tex',
	string.format(get_translated_string('PLAY_GAMES_WITH_ACTOR'), 
	utils.get_formatted_number(count), costume))