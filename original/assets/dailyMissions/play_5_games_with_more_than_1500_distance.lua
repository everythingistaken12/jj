local play_games_with_more_than_distance = require("play_games_with_more_than_distance")
local utils = require("utils")
local game_count = 5
local distance_count = 1500

return play_games_with_more_than_distance(game_count, distance_count,
	'textures/menus/missions/iconStar.tex',
	string.format(get_translated_string('PLAY_GAMES_WITH_MORE_THAN_DISTANCE'),
	utils.get_formatted_number(game_count), utils.get_formatted_number(distance_count)))
