local play_games_any_mode = require("play_games_any_mode")
local utils = require("utils")
local count = 50

return play_games_any_mode(count, 'textures/menus/missions/iconStar.tex', 
    string.format(get_translated_string('PLAY_GAMES_ANY_MODE'), 
    utils.get_formatted_number(count)))
