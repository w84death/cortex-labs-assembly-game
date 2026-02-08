Game Design Document for CORTEX LABS (GAME 12)
Krzysztof Krystian Jankowski
(C) 2025.06 - 2026.02 P1X

# Menu flows

- P1X SCREEN
- INTRO SCREEN
- MAIN MENU
    - (if game started) CONTINUE GAME
    - START NEW GAME
    - MANUAL
    - QUIT TO DOS

# Start new game

1. CAMPAIN INTRO
    - background: campain_01, campain_02
    - few pages of introduction text
2. MAP SELECTION
    - background: map_selection
    - live map preview
    - each map is a selected seed
    - selection locked, beat one unlocks two more
    - each map has settings easy to hard
3. START GAME
    - background: start_game
    - map goals 
        - amount of resources to harvest
        - time limit
    - start game button

# Terrain

Tiles type:
- empty
- obstacle (trees, rocks)
- base
- rails
- base secondary
- infrastructure
- resource
- enemy

# Resources

Res 1 - game goal
Res 2 - build infra, rails
Res 3 - upgrades, fuel for running rails
