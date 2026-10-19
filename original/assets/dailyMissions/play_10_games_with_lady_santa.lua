local play_games_with_costume = require("play_games_with_costume")
local utils = require("utils")
local count = 10
local costume = get_translated_string('CHRISTMAS_LADY_SANTA_HEAD_NAME')

return play_games_with_costume(count, 'CHRISTMAS_LADY_SANTA_HEAD', 'CHRISTMAS_LADY_SANTA_BODY',
	'textures/menus/missions/iconStar.tex',
	string.format(get_translated_string('PLAY_GAMES_WITH_ACTOR'), 
	utils.get_formatted_number(count), costume))