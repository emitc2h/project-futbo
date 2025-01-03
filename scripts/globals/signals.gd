extends Node

# Tell the game to quit.
signal quit_game

# Tell the GameStateManager to go back to the main menu.
signal exit_to_main_menu

# Tell the GameStateManager when the game is over.
signal game_over

# Tell the LevelStateManager to pause the game.
signal pause

# Tell the LevelStateManager to un-pause the game.
signal unpause
