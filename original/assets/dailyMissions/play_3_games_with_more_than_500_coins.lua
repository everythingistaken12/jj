local play_games_with_more_than_coins = require("play_games_with_more_than_coins")
local actor_names = require("actor_names")
return play_games_with_more_than_coins(3, 500, actor_names.ACTOR_COIN,
	'textures/menus/missions/iconStar.tex',
	'Play 3 games with more than 500 coins')
