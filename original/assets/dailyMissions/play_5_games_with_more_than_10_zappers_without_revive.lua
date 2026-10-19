local play_games_with_more_than_zappers = require("play_games_with_more_than_zappers")
local actor_names = require("actor_names")
local utils = require("utils")
local game_count = 5
local zapper_count = 10
local allow_revive = false

return play_games_with_more_than_zappers(game_count, zapper_count, actor_names.ACTOR_OBSTACLE, allow_revive,
	'textures/menus/missions/iconStar.tex',
	string.format(get_translated_string('PLAY_GAMES_WITH_MORE_THAN_ZAPPERS_WITHOUT_DYING'), 
	utils.get_formatted_number(game_count), utils.get_formatted_number(zapper_count)))
