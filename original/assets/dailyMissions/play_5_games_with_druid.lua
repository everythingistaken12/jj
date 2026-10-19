local play_games_with_costume = require("play_games_with_costume")
local utils = require("utils")
local count = 5
local costume = get_translated_string('ITEM_DRUIDBODY_NAME')

return play_games_with_costume(count, 'DRUID_HEAD', 'DRUID_BODY',
	'textures/menus/missions/iconStar.tex',
	string.format(get_translated_string('PLAY_GAMES_WITH_ACTOR'),
	utils.get_formatted_number(count), costume))
