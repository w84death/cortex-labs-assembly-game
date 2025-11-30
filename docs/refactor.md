# Refactor for code optimization
## Initial state
game.asm:         2466 lines
Game COM (raw):   23280 bytes
Game COM (UPX):   13498 bytes (43% reduction)

intro: 233
gen map: 8446
empty map: 1185
move map: 9800

## Memory segmentation

game.asm:         2281
Game COM (raw):   23160 bytes
Game COM (UPX):   13435 bytes (42% reduction)
  
intro: 233
gen map: 8184
empty map: 1184
move map: 9728
