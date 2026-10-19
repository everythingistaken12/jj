local collect_actor = require("collect_actor")
local actor_names = require("actor_names")

return collect_actor(10, actor_names.ACTOR_VEHICLE_PICKUP,
	'textures/menus/missions/iconStar.tex',
	'Pick up 10 vehicle tokens')
