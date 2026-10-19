local play_games_with_more_than_coins = require("play_games_with_more_than_coins")
local utils = require("utils")
local actor_names = require("actor_names")
local game_count = 10
local coin_count = 1500

return play_games_with_more_than_coins(game_count, coin_count, actor_names.ACTOR_COIN,
	'textures/menus/missions/iconStar.tex',
	string.format(get_translated_string('PLAY_GAMES_WITH_MORE_THAN_COINS'), 
	utils.get_formatted_number(game_count), utils.get_formatted_number(coin_count)))
