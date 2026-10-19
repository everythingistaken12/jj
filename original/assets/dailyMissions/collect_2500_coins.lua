local collect_actor = require("collect_actor")
local actor_names = require("actor_names")

return collect_actor(2500, actor_names.ACTOR_COIN,
	'textures/menus/missions/iconStar.tex',
	'Collect 2500, coins')
