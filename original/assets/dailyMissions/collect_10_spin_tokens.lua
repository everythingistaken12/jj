local collect_actor = require("collect_actor")
local actor_names = require("actor_names")

return collect_actor(10, actor_names.ACTOR_SLOT_TOKEN,
	'textures/menus/missions/iconStar.tex',
	'Collect 10 spin tokens')
