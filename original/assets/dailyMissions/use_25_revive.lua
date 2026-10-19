local use_revive = require("use_revive")
local utils = require("utils")
local count = 25

return use_revive(count, 'textures/menus/missions/iconStar.tex', 
string.format(get_translated_string('USE_REVIVE'), utils.get_formatted_number(count)))
