; ===========================================================================|80
; CORTEX LABS - 2D Strategic game for x86 processors (and Free/MS-DOS)
;
; Real-time strategy, economic game about extracting and managing resources
; on alien planet. Havely based on building optimized train (pods) lines.
;
; http://smol.p1x.in/assembly/#game12
; http://smol.p1x.in/assembly/cortex-labs/
; ===========================================================================|80
; Copyright (MIT) 2026 Krzysztof Krystian Jankowski
; This is free and open software. See LICENSE for details.
; ===========================================================================|80
;
; Should run on any x86 processor and system that supports legacy BIOS.
; Can boot to baremetal or run on MS-DOS/FreeDOS from COM file.
;
; Target hardware:
; Compaq Contura 430C (FreeDOS & Boot Floppy)
; * CPU: 486 DX4, 100Mhz
; * Graphics: VGA
; * RAM: 24MB
; * Input: PS/2 Mouse
;
; Theoretical minimum requirements:
; * CPU: 386 SX, 16Mhz
; * Graphics: VGA
; * RAM: 512KB
;
; Programs used for production:
;   - Zed IDE
;   - Propiretary P1Xel Tool
;   - bochs / qemu / dosemu
;   - custom tool for RLE image compression
;
; ===========================================================================|80

org 0x0100

BUILD_VER                               equ 0501

; =========================================== MEMORY LAYOUT =================|80

SEGMENT_VGA                             equ 0xA000
SEGMENT_DBUFFER                         equ 0x7000
GAME_STACK_POINTER                      equ 0xFFFE
SEGMENT_SPRITES                         equ 0x5400
SEGMENT_MAP                             equ 0x8000
BG                                      equ 0x0000
FG                                      equ 0x4000
META                                    equ 0x8000
PODS                                    equ 0xC000
RESOURCE                                equ 0xE000

; =========================================== MEMORY ALLOCATION =============|80

_BASE_                    equ _END_OF_CODE_ + 0x100
_GAME_TICK_               equ _BASE_ + 0x00   ; 4 bytes
_GAME_STATE_              equ _BASE_ + 0x04   ; 1 byte
_RNG_                     equ _BASE_ + 0x05   ; 2 bytes
_VIEWPORT_X_              equ _BASE_ + 0x07   ; 2 bytes
_VIEWPORT_Y_              equ _BASE_ + 0x09   ; 2 bytes
_CURSOR_X_                equ _BASE_ + 0x0B   ; 2 bytes
_CURSOR_Y_                equ _BASE_ + 0x0D   ; 2 bytes
_CURSOR_X_OLD_            equ _BASE_ + 0x0F   ; 2 bytes
_CURSOR_Y_OLD_            equ _BASE_ + 0x11   ; 2 bytes
_SCENE_MODE_              equ _BASE_ + 0x13   ; 1 byte
_GAME_TURN_               equ _BASE_ + 0x14   ; 1 bytes
_GAME_STARTED_            equ _BASE_ + 0x15   ; 1 bytes
_ECONOMY_BLUE_RES_        equ _BASE_ + 0x16   ; 2 bytes
_ECONOMY_WHITE_RES_       equ _BASE_ + 0x18   ; 2 bytes
_ECONOMY_GREEN_RES_       equ _BASE_ + 0x1A   ; 2 bytes
_UPGRADES_                equ _BASE_ + 0x1C   ; 2 bytes
_MENU_SELECTION_POS_      equ _BASE_ + 0x1E   ; 1 byte
_MENU_SELECTION_MAX_      equ _BASE_ + 0x1F   ; 1 byte
_SFX_POINTER_             equ _BASE_ + 0x20   ; 2 bytes
_SFX_NOTE_INDEX_          equ _BASE_ + 0x22   ; 1 byte
_SFX_NOTE_DURATION_       equ _BASE_ + 0x23   ; 1 byte
_SFX_IRQ_OFFSET_          equ _BASE_ + 0x24   ; 2 bytes
_SFX_IRQ_SEGMENT_         equ _BASE_ + 0x26   ; 2 bytes
_AUDIO_ENABLED_           equ _BASE_ + 0x28   ; 1 byte
_LAST_ENT_POD_ID_         equ _BASE_ + 0x29   ; 2 bytes
_MOUSE_BUTTONS_           equ _BASE_ + 0x2B   ; 1 byte
_MOUSE_LOCK_              equ _BASE_ + 0x2C   ; 1 byte
_MOUSE_TILE_POS_X_        equ _BASE_ + 0x2D   ; 2 bytes
_MOUSE_TILE_POS_Y_        equ _BASE_ + 0x2F   ; 2 bytes
_PODS_SPAWN_              equ _BASE_ + 0x31   ; 2 byte
_CINE_TIMER_              equ _BASE_ + 0x37   ; 2 bytes
_IDLE_TICK_               equ _BASE_ + 0x39   ; 2 bytes

; =========================================== ENGINE SETTINGS ===============|80
;

TRUE                                    equ 1
FALSE                                   equ 0
SCREEN_WIDTH                            equ 320     ; In pixels
SCREEN_HEIGHT                           equ 200     ; In pixels
MAP_SIZE                                equ 128     ; Map size in cells (tiles)
VIEWPORT_WIDTH                          equ 20      ; In tiles (*SPRITE_SIZE)
VIEWPORT_HEIGHT                         equ 11      ; In tiles
VIEWPORT_GRID_SIZE                      equ 16      ; In pixels
SPRITE_SIZE                             equ 16      ; In pixels
FONT_SIZE                               equ 8       ; In pixels
GAME_TURN_LENGTH                        equ 4       ; in game loops
RADAR_VISIBILITY_RANGE                  equ 32      ; In tiles
TILES_COUNT                             equ 0x4F
MAX_PODS                                equ 500
LANDING_TIMER                           equ 64
CINE_TITLE_TIMER                        equ 14
CINE_BRIEFING_TIMER                     equ 18
CINE_P1X_TIMER                          equ 80
CINE_PMKC_TIMER                         equ 11
CINE_STORY_TIMER                        equ 94
SCREEN_IDLE_TIMER_END                   equ 128

; =========================================== GAME STATES ===================|80

; Check StateJumpTable for functions IDs (n-th in a table)
STATE_INIT_ENGINE                       equ 0
STATE_QUIT                              equ 1
STATE_P1X_SCREEN_CINE                   equ 2
STATE_P1X_SCREEN_INIT                   equ 3
STATE_P1X_SCREEN                        equ 4
STATE_PMKC_SCREEN_CINE_INIT             equ 5
STATE_PMKC_SCREEN_CINE                  equ 6
STATE_PMKC_SCREEN_INIT                  equ 7
STATE_PMKC_SCREEN                       equ 8
STATE_TITLE_SCREEN_INIT                 equ 9
STATE_TITLE_SCREEN                      equ 10
STATE_TITLE_SCREEN_CINE_INIT            equ 11
STATE_TITLE_SCREEN_CINE                 equ 12
STATE_MENU_SCREEN_INIT                  equ 13
STATE_MENU_SCREEN                       equ 14
STATE_BRIEFING_INIT                     equ 15
STATE_BRIEFING                          equ 16
STATE_BRIEFING_CINE_INIT                equ 17
STATE_BRIEFING_CINE                     equ 18
STATE_STORY_SCREEN_INIT                 equ 19
STATE_STORY_SCREEN                      equ 20
STATE_LANDING_INIT                      equ 21
STATE_LANDING                           equ 22
STATE_GAME_NEW                          equ 23
STATE_GAME_INIT                         equ 24
STATE_GAME                              equ 25
STATE_DEBUG_VIEW_INIT                   equ 26
STATE_DEBUG_VIEW                        equ 27
STATE_HELP_INIT                         equ 28
STATE_HELP                              equ 29
STATE_WINDOW_INIT                       equ 30
STATE_WINDOW                            equ 31

SCENE_MODE_ANY                          equ 0x00
SCENE_MODE_MAIN_MENU                    equ 0x00
SCENE_MODE_BASE_BUILDINGS               equ 0x01
SCENE_MODE_REMOTE_BUILDINGS             equ 0x02
SCENE_MODE_STATION                      equ 0x03
SCENE_MODE_BRIEFING                     equ 0x04
SCENE_MODE_UPGRADE_BUILDINGS            equ 0x05
SCENE_MODE_RADAR_VIEW                   equ 0x06
SCENE_MODE_EXTRACTOR_SETUP              equ 0x07
SCENE_MODE_EXTRACTOR_INFO               equ 0x08
SCENE_MODE_RESOURCE_INFO                equ 0x09

; =========================================== TILES NAMES ===================|80

TILE_SOIL_0                             equ 0x00
TILE_SOIL_1                             equ 0x01
TILE_SOIL_2                             equ 0x02
TILE_SOIL_3                             equ 0x03
TILE_SOIL_4                             equ 0x04
TILE_SOIL_5                             equ 0x05
TILE_SOIL_6                             equ 0x06
TILE_ROCKS_0                            equ 0x07
TILE_ROCKS_1                            equ 0x08
TILE_ROCKS_2                            equ 0x09
TILE_ROCKS_3                            equ 0x0A
TILE_STATION_EXTEND                     equ 0x0B
TILE_STATION                            equ 0x0C
TILE_FOUNDATION                         equ 0x0D
TILE_RES_WHITE_LOW                      equ 0x0E
TILE_RES_WHITE_MAX                      equ 0x0F
TILE_RES_GREEN_LOW                      equ 0x10
TILE_RES_GREEN_MAX                      equ 0x11
TILE_RES_BLUE_LOW                       equ 0x12
TILE_RES_BLUE_MAX                       equ 0x13
TILE_RAILS_1                            equ 0x14
TILE_RAILS_2                            equ 0x15
TILE_RAILS_3                            equ 0x16
TILE_RAILS_4                            equ 0x17
TILE_RAILS_5                            equ 0x18
TILE_RAILS_6                            equ 0x19
TILE_RAILS_7                            equ 0x1A
TILE_RAILS_8                            equ 0x1B
TILE_RAILS_9                            equ 0x1C
TILE_RAILS_10                           equ 0x1D
TILE_RAILS_11                           equ 0x1E
TILE_ROCKET_GEAR                        equ 0x1F
TILE_BUILDING_SILOS                     equ 0x20
TILE_BUILDING_EXTRACTOR                 equ 0x21
TILE_BUILDING_COLECTOR                  equ 0x22
TILE_BUILDING_LAB                       equ 0x23
TILE_BUILDING_RAFINERY                  equ 0x24
TILE_BUILDING_RADAR                     equ 0x25
TILE_BUILDING_PODS                      equ 0x26
TILE_BUILDING_POWER                     equ 0x27
TILE_SILO_WHITE                         equ 0x28
TILE_SILO_BLUE                          equ 0x29
TILE_SILO_GREEN                         equ 0x2A
TILE_EXTRACT_WHITE                      equ 0x2B
TILE_EXTRACT_GREEN                      equ 0x2C
TILE_EXTRACT_BLUE                       equ 0x2D
TILE_ROCKET_TOP                         equ 0x2E
TILE_ROCKET_MIDDLE                      equ 0x2F
TILE_ROCKET_BOOSTERS                    equ 0x30
TILE_ROCKET_SMOKE                       equ 0x31
TILE_CART_VERTICAL                      equ 0x32
TILE_CART_HORIZONTAL                    equ 0x33
TILE_SWITCH_LEFT                        equ 0x34
TILE_SWITCH_DOWN                        equ 0x35
TILE_SWITCH_RIGHT                       equ 0x36
TILE_SWITCH_UP                          equ 0x37
TILE_ORE_WHITE_V                        equ 0x38
TILE_ORE_WHITE_H                        equ 0x39
TILE_ORE_BLUE_V                         equ 0x3A
TILE_ORE_BLUE_H                         equ 0x3B
TILE_ORE_GREEN_V                        equ 0x3C
TILE_ORE_GREEN_H                        equ 0x3D
TILE_CURSOR_MOUSE                       equ 0x3E
TILE_CURSOR_BUILD                       equ 0x3F
TILE_CURSOR_EDIT                        equ 0x40
TILE_CURSOR_BUILDING                    equ 0x41
TILE_CURSOR_SELECTOR                    equ 0x42
TILE_WINDOW_4                           equ 0x43
TILE_WINDOW_5                           equ 0x44
TILE_WINDOW_6                           equ 0x45
TILE_UI_HEADER                          equ 0x46
TILE_IO_RIGHT                           equ 0x47
TILE_IO_LEFT                            equ 0x48
TILE_IO_UP                              equ 0x49
TILE_IO_DOWN                            equ 0x4A
TILE_WINDOW_1                           equ 0x4B
TILE_WINDOW_2                           equ 0x4C
TILE_WINDOW_3                           equ 0x4D
TILE_FOG_OF_WAR                         equ 0x4E

; FOREGROUND TILES IDS
TILE_FOREGROUND_SHIFT           equ TILE_RES_WHITE_LOW ; pointer to first FG tile
TILE_ROCKET_BOTTOM_ID           equ TILE_ROCKET_GEAR-TILE_FOREGROUND_SHIFT
TILE_ROCKET_TOP_ID              equ TILE_ROCKET_TOP-TILE_FOREGROUND_SHIFT
TILE_BUILDING_RAFINERY_ID       equ TILE_BUILDING_RAFINERY-TILE_FOREGROUND_SHIFT
TILE_BUILDING_EXTRACTOR_ID      equ TILE_BUILDING_EXTRACTOR-TILE_FOREGROUND_SHIFT
TILE_EXTRACT_WHITE_ID           equ TILE_EXTRACT_WHITE-TILE_FOREGROUND_SHIFT
TILE_EXTRACT_GREEN_ID           equ TILE_EXTRACT_GREEN-TILE_FOREGROUND_SHIFT
TILE_EXTRACT_BLUE_ID            equ TILE_EXTRACT_BLUE-TILE_FOREGROUND_SHIFT
TILE_BUILDING_COLECTOR_ID       equ TILE_BUILDING_COLECTOR-TILE_FOREGROUND_SHIFT
TILE_BUILDING_SILOS_ID          equ TILE_BUILDING_SILOS-TILE_FOREGROUND_SHIFT
TILE_BUILDING_LAB_ID            equ TILE_BUILDING_LAB-TILE_FOREGROUND_SHIFT
TILE_BUILDING_RADAR_ID          equ TILE_BUILDING_RADAR-TILE_FOREGROUND_SHIFT
TILE_BUILDING_PODS_ID           equ TILE_BUILDING_PODS-TILE_FOREGROUND_SHIFT
TILE_BUILDING_POWER_ID          equ TILE_BUILDING_POWER-TILE_FOREGROUND_SHIFT


; SEGMENT BG
; 0 0 0 0 0000
; | | | | |
; | | | | '- background sprite id (16)
; | | | '- terrain traversal (1) (movable or forest/mountains/building)
; | | '- rail (1)
; | '- resource (1)
; '- infrastructure building, station (1)
;
BACKGROUND_SPRITE_MASK                  equ 0xF
TERRAIN_TRAVERSAL_MASK                  equ 0x10
TERRAIN_TRAVERSAL_SHIFT                 equ 0x4
TERRAIN_SECOND_LAYER_DRAW_MASK          equ 0xE0
RAIL_MASK                               equ 0x20
RAIL_SHIFT                              equ 0x5
RESOURCE_MASK                           equ 0x40
RESOURCE_SHIFT                          equ 0x6
INFRASTRUCTURE_MASK                     equ 0x80
INFRASTRUCTURE_SHIFT                    equ 0x7

; SEGMENT FG
; 00 0 00000
; |  | |
; |  | '- sprite id (32) (rails / buildings)
; |  '- draw cart (1)
; '- cursor type (4)
;
FOREGROUND_SPRITE_MASK                  equ 0x1F
CART_DRAW_MASK                          equ 0x20
CURSOR_TYPE_MASK                        equ 0xC0
CURSOR_TYPE_SHIFT                       equ 0x06
CURSOR_TYPE_ROL                         equ 0x02

; SEGMENT META
; 0 00 0 00 00
; | |  | |  |
; | |  | |  |
; | |  | |  '- tile direction (4): switch, building
; | |  | '- resource type (4) (for source/pods cargo/buildings)
; | |  '- switch on rail (or not initialized)
; | '- cart drive direction (4)
; '- visible to radar
;
; if resource/extractor type > 0
; 0 000 00 00
;   | |
;    '- resource/capacity amount (8)

TILE_DIRECTION_MASK                     equ 0x3
SWITCH_DATA_MASK                        equ 0x13
RESOURCE_TYPE_MASK                      equ 0xC
RESOURCE_TYPE_SHIFT                     equ 0x2
SWITCH_MASK                             equ 0x10
CART_DIRECTION_MASK                     equ 0x60
CART_DIRECTION_SHIFT                    equ 0x5
RADAR_VISIBILITY_MASK                   equ 0x80
RESOURCE_AMOUNT_MASK                    equ 0x70
RESOURCE_AMOUNT_SHIFT                   equ 0x4
RESOURCE_RES1_MASK                      equ 0x4
RESOURCE_RES2_MASK                      equ 0x8
RESOURCE_RES3_MASK                      equ 0xC


; MISC

CART_LEFT                       equ 0x00
CART_DOWN                       equ 0x01
CART_RIGHT                      equ 0x02
CART_UP                         equ 0x03
TERRAIN_RULES_CROP              equ 0x07
CURSOR_ICON_POINTER             equ 0x00
CURSOR_ICON_PLACE_RAIL          equ 0x01
CURSOR_ICON_EDIT                equ 0x02
CURSOR_ICON_PLACE_BUILDING      equ 0x03

UI_STATS_POS                    equ SPRITE_SIZE
UI_STATS_TXT_POS                equ 0x04
UI_FOOTER_POS                   equ SCREEN_WIDTH*176
UI_FOOTER_HEIGHT                equ 14

; =========================================== COLORS / DB16 =================|80

COLOR_BLACK         equ 0x00
COLOR_DEEP_PURPLE   equ 0x01
COLOR_NAVY_BLUE     equ 0x02
COLOR_DARK_GRAY     equ 0x03
COLOR_BROWN         equ 0x04
COLOR_DARK_GREEN    equ 0x05
COLOR_RED           equ 0x06
COLOR_LIGHT_GRAY    equ 0x07
COLOR_BLUE          equ 0x08
COLOR_ORANGE        equ 0x09
COLOR_STEEL_BLUE    equ 0x0A
COLOR_GREEN         equ 0x0B
COLOR_PINK          equ 0x0C
COLOR_CYAN          equ 0x0D
COLOR_YELLOW        equ 0x0E
COLOR_WHITE         equ 0x0F

; =========================================== KEYBOARD/MOUSE CODES ==========|80

KB_ESC      equ 0x01
KB_UP       equ 0x48
KB_DOWN     equ 0x50
KB_LEFT     equ 0x4B
KB_RIGHT    equ 0x4D
KB_ENTER    equ 0x1C
KB_SPACE    equ 0x39
KB_DEL      equ 0x53
KB_BACK     equ 0x0E
KB_Q        equ 0x10
KB_W        equ 0x11
KB_R        equ 0x13
KB_M        equ 0x32
KB_TAB      equ 0x0F
KB_F1       equ 0x3B
KB_F2       equ 0x3C
KB_F3       equ 0x3D
KB_F4       equ 0x3E
KB_F5       equ 0x3F
KB_1        equ 0x02
KB_2        equ 0x03
KB_3        equ 0x04
KB_4        equ 0x05
KB_5        equ 0x06
KB_6        equ 0x07
KB_7        equ 0x08
KB_8        equ 0x09
KB_9        equ 0x0A
KB_0        equ 0x0B
MOUSE_LEFT_BUTTON               equ 0xFF
MOUSE_RIGHT_BUTTON              equ 0xFE

; =========================================== INITIALIZATION ================|80

init:

  if INCLUDE_MOUSE_DRIVER               ; Pure MS-DOS build skips this part
  .detect_mouse:
    xor ax, ax
    int 0x33                            ; Call MS-DOS mouse driver
    cmp ax, 0xFFFF                      ; Check if driver installed
    jz .skip_mouse_driver
    call install_mouse_driver           ; Bare-metal -> install ps2 driver
    .skip_mouse_driver:                 ; We are in MS-DOS
  end if

  mov ax, 0x13                          ; Init 320x200, 256 colors mode
  int 0x10                              ; Video BIOS interrupt
  cld                                   ; Clear DF to ensure forward string ops

  push SEGMENT_DBUFFER                  ; Double buffer memory segment
  pop es                                ; Set ES to buffer memory segment
  xor di, di                            ; Set DI to 0

  push cs                               ; GAME CODE SEGMENT
  pop ss
  mov sp, GAME_STACK_POINTER

  push SEGMENT_MAP
  pop fs

  call initialize_custom_palette
  mov byte [_GAME_STATE_], STATE_INIT_ENGINE
  mov word [_MOUSE_BUTTONS_], 0         ; clears both buttons and lock

; =========================================== GAME LOOP =====================|80
main_loop:

; =========================================== GAME STATES ===================|80

  movzx bx, byte [_GAME_STATE_]         ; Load state into BX
  shl bx, 1                             ; Multiply by 2 (word size)
  call word [StateJumpTable + bx]       ; Jump to handle

game_state_satisfied:

; =========================================== KEYBOARD INPUT ================|80

check_mouse_click:

  test byte [_MOUSE_BUTTONS_], 1        ; Test bit 0 (Left Button)
  jnz .clicked_left
  test byte [_MOUSE_BUTTONS_], 2        ; Test bit 1 (Right Button)
  jnz .clicked_right
  jmp check_keyboard
  .clicked_left:
    mov ah, MOUSE_LEFT_BUTTON
    jmp check_keyboard.fake_keyboard
  .clicked_right:
    mov ah, MOUSE_RIGHT_BUTTON
    jmp check_keyboard.fake_keyboard

check_keyboard:
  mov ah, 01h                           ; BIOS keyboard status function
  int 16h                               ; Call BIOS interrupt
  jz .keyboard_done

  mov ah, 00h                           ; BIOS keyboard read function
  int 16h

  .fake_keyboard:

  ; ========================================= STATE TRANSITIONS ============|80
  ; Main state game changer. Changes states like intro, menu, game.
  mov si, StateTransitionTable
  mov cx, (StateTransitionTableEnd-StateTransitionTable)/3
  .check_transitions:
    mov bl, [_GAME_STATE_]
    cmp bl, [si]                        ; Check current state
    jne .next_entry

    cmp ah, [si+1]                      ; Check key press
    jne .next_entry

    mov bl, [si+2]                      ; Get new state
    mov [_GAME_STATE_], bl
    jmp .transitions_done

  .next_entry:
    add si, 3                           ; Move to next entry
    loop .check_transitions

.transitions_done:

; ========================================= GAME LOGIC INPUT =============|80

  mov si, InputTable
  mov cx, (InputTableEnd-InputTable)/5
  .check_input:
    mov bl, [_GAME_STATE_]
    cmp bl, [si]                        ; Check current state
    jne .next_input

    cmp byte [si+1], SCENE_MODE_ANY
    je .check_keypress
    mov bl, [_SCENE_MODE_]
    cmp bl, [si+1]                      ; Check current mode
    jne .next_input

    .check_keypress:
    cmp ah, [si+2]                      ; Check key press
    jne .next_input

    mov bx, [si+3]
    call bx
    jmp .keyboard_done

  .next_input:
    add si, 5                           ; Move to next entry
  loop .check_input

.keyboard_done:

call ui.calculate_mouse_cursor

.update_game_logic:
  cmp byte [_GAME_STATE_], STATE_GAME
  jnz .skip_turn
  dec byte [_GAME_TURN_]
  cmp byte [_GAME_TURN_], 0x0
  jg .skip_turn
    call game_logic.calculate_pods
    mov byte [_GAME_TURN_], GAME_TURN_LENGTH
  .skip_turn:

; =========================================== GAME TICK =====================|80

cmp byte [_GAME_STATE_], STATE_GAME
jne .skip_mouse_boudries
  call game_logic.check_mouse_boudries
.skip_mouse_boudries:

.vga_blit:
  push es
  push ds

  push SEGMENT_VGA                      ; Set VGA memory
  pop es                                ; as target
  push SEGMENT_DBUFFER                  ; Set doublebuffer memory
  pop ds                                ; as source
  mov cx,0x7D00                         ; Half of 320x200 pixels
  xor si,si                             ; Clear SI
  xor di,di                             ; Clear DI
  rep movsw                             ; Push words (2x pixels)

  pop ds
  pop es

cmp byte [_GAME_STATE_], STATE_GAME
jne .skip_game_ui
  call game_render.draw_front_elements
  call ui.draw_game_cursor
.skip_game_ui:

call ui.draw_mouse_cursor


.cpu_delay:
  xor ax, ax                            ; 00h: Read system timer counter
  int 0x1a                              ; Returns tick count in CX:DX
  mov bx, dx                            ; Store low word of tick count
  mov si, cx                            ; Store high word of tick count
  .wait_loop:
    hlt
    xor ax, ax
    int 0x1a
    cmp cx, si                          ; Compare high word
    jne .tick_changed
    cmp dx, bx                          ; Compare low word
    je .wait_loop                       ; If both are the same, keep waiting
  .tick_changed:

.update_system_tick:
  inc dword [_GAME_TICK_]               ; overflow naturally

; =========================================== ESC OR LOOP ===================|80

jmp main_loop

; =========================================== EXIT TO DOS ===================|80

exit:
  call audio.destroy
  mov ax, 0x0003                        ; Set video mode to 80x25 text mode
  int 0x10                              ; Call BIOS interrupt
  mov si, QuitText                      ; Draw message after exit
  xor dx, dx                            ; At 0/0 position
  call terminal.draw_text

  mov ax, 0x4c00                        ; Exit to DOS
  int 0x21                              ; Call DOS
ret                                     ; Return to DOS

; =========================================== GAME LOGIC ====================|80

game_logic:

; =========================================== VIEWPORT MOVE =================|80
  .check_mouse_boudries:
    cmp word [_MOUSE_TILE_POS_Y_], 1
    jl .move_viewport_up
    cmp word [_MOUSE_TILE_POS_Y_], VIEWPORT_HEIGHT-2
    jg .move_viewport_down
    cmp word [_MOUSE_TILE_POS_X_], 1
    jl .move_viewport_left
    cmp word [_MOUSE_TILE_POS_X_], VIEWPORT_WIDTH-2
    jg .move_viewport_right
  ret

  .move_cursor_up:
    mov ax, [_VIEWPORT_Y_]              ; viewport top position
    inc ax                              ; one tile before
    cmp word [_CURSOR_Y_], ax           ; check if cursor at the top edge
    je .move_viewport_up                ; try move the viewport up
    dec word [_CURSOR_Y_]               ; or just move the cursor up
    jmp .redraw_old_tile

  .move_cursor_down:
    mov ax, [_VIEWPORT_Y_]              ; viewport top position
    add ax, VIEWPORT_HEIGHT-2           ; get viewport bottom
    cmp word [_CURSOR_Y_], ax           ; check if cursro at the bottom
    jae .move_viewport_down             ; try to move viewport down

    inc word [_CURSOR_Y_]               ; or just move the cursor down
    jmp .redraw_old_tile

  .move_cursor_left:
    mov ax, [_VIEWPORT_X_]              ; viewport left position
    inc ax                              ; one tile before
    cmp word [_CURSOR_X_], ax           ; check if cursor at the left edge
    je .move_viewport_left              ; try to move viewport left

    dec word [_CURSOR_X_]               ; or just move the cursor left
    jmp .redraw_old_tile

  .move_cursor_right:
    mov ax, [_VIEWPORT_X_]              ; viewport left position
    add ax, VIEWPORT_WIDTH-2            ; get viewport right
    cmp word [_CURSOR_X_], ax           ; check if cursor at the right edge
    jae .move_viewport_right            ; try to move viewport right

    inc word [_CURSOR_X_]               ; or just move the cursor right
    jmp .redraw_old_tile

  .move_viewport_up:
    cmp word [_VIEWPORT_Y_], 0          ; check if viewport at the top edge
    je .done                            ; do nothing if on edge
    dec word [_VIEWPORT_Y_]             ; move viewport up
    dec word [_CURSOR_Y_]               ; move cursor up
    mov bx, [_CURSOR_Y_]
    mov word [_CURSOR_Y_OLD_], bx
    jmp .redraw_terrain

  .move_viewport_down:
    cmp word [_VIEWPORT_Y_], MAP_SIZE-VIEWPORT_HEIGHT ; check if viewport at the bottom edge of ma26p
    jae .done                           ; do nothing if on edge
    inc word [_VIEWPORT_Y_]             ; move viewport down
    inc word [_CURSOR_Y_]               ; move cursor down
    mov bx, [_CURSOR_Y_]
    mov word [_CURSOR_Y_OLD_], bx
    jmp .redraw_terrain

  .move_viewport_left:
    cmp word [_VIEWPORT_X_], 0          ; check if viewport at the left edge of map
    je .done                            ; do nothing if on edge
    dec word [_VIEWPORT_X_]             ; move viewport left
    dec word [_CURSOR_X_]               ; move cursor left
    mov ax, [_CURSOR_X_]
    mov word [_CURSOR_X_OLD_], ax
    jmp .redraw_terrain

  .move_viewport_right:
    cmp word [_VIEWPORT_X_], MAP_SIZE-VIEWPORT_WIDTH ; check if viewport at the right edge of map
    jae .done                           ; do nothing if on edge
    inc word [_VIEWPORT_X_]             ; move viewport right
    inc word [_CURSOR_X_]               ; move cursor right
    mov ax, [_CURSOR_X_]
    mov word [_CURSOR_X_OLD_], ax
    jmp .redraw_terrain

  .change_action:
    mov bx, SFX_BUILD
    call audio.play_sfx

    mov di, [_CURSOR_Y_]                ; Calculate map position
    shl di, 7   ; Y * 128
    add di, [_CURSOR_X_]               ; For quick random number

    mov al, [fs:di]
    test al, RAIL_MASK
    jnz .switch_change
    test al, INFRASTRUCTURE_MASK
    jnz .building_exit_rotate
    jmp .change_action_done

    .switch_change:
      test byte [fs:di + META], SWITCH_MASK
      jz .change_action_done

      mov bx, SFX_CHANGE_SWITCH
      call audio.play_sfx

      mov al, [fs:di + META]
      and al, TILE_DIRECTION_MASK
      xor al, 0x2                       ; invert swich top-down or left-right
      add al, SWITCH_MASK
      and byte [fs:di + META], 0xFF - SWITCH_DATA_MASK
      add byte [fs:di + META], al
    jmp .change_action_done

    .building_exit_rotate:
      mov bx, SFX_EXIT_ROT
      call audio.play_sfx

      mov al, [fs:di + META]
      and al, TILE_DIRECTION_MASK
      inc al
      and al, 0x3                       ; 0..3
      and byte [fs:di + META], 0xFF - SWITCH_DATA_MASK
      add byte [fs:di + META], al
      mov al,  [fs:di + META]

    jmp .change_action_done

    .change_action_done:
    jmp .redraw_tile

  .build_action:
    mov di, [_CURSOR_Y_]                ; Calculate map position
    shl di, 7   ; Y * 128
    add di, [_CURSOR_X_]

    .decide_on_action:
      test byte [fs:di], RESOURCE_MASK
      jnz .examine_resource

      mov bl, [fs:di + FG]
      and bl, CURSOR_TYPE_MASK
      rol bl, CURSOR_TYPE_ROL

      cmp bl, CURSOR_ICON_PLACE_BUILDING
      jz .place_building
      cmp bl, CURSOR_ICON_PLACE_RAIL
      jz .place_rail
         jmp .build_action_done

    .place_rail:
      mov bx, SFX_BUILD_RAIL
      call audio.play_sfx

      mov al, [_GAME_TICK_]
      and al, 0x1                       ; TILE_SOIL_0 or TILE_SOIL_1
      add al, RAIL_MASK
      mov byte [fs:di], al
      mov byte [fs:di + FG], TILE_RAILS_1-TILE_FOREGROUND_SHIFT

      call recalculate_rails

      dec di
      call recalculate_rails
      add di, 2
      call recalculate_rails
      sub di, MAP_SIZE+1
      call recalculate_rails
      add di, MAP_SIZE*2
      call recalculate_rails

      jmp .redraw_four_tiles

    .place_building:
      mov bx, SFX_BUILD_BUILDING
      call audio.play_sfx

      mov al, [fs:di]
      mov bl, [fs:di + FG]
      and bl, FOREGROUND_SPRITE_MASK

      test al, RAIL_MASK
      jnz .station

      cmp bl, TILE_BUILDING_RADAR_ID
      jz .radar_view

      cmp bl, TILE_BUILDING_EXTRACTOR_ID
      jz .extractor_setup
      cmp bl, TILE_EXTRACT_WHITE_ID
      jz .extractor_info
      cmp bl, TILE_EXTRACT_GREEN_ID
      jz .extractor_info
      cmp bl, TILE_EXTRACT_BLUE_ID
      jz .extractor_info

      test al, INFRASTRUCTURE_MASK
      jnz .upgrade_building

      and al, BACKGROUND_SPRITE_MASK
      cmp al, TILE_STATION_EXTEND
      jz .remote_building

      .base_building:
        mov bx, SCENE_MODE_BASE_BUILDINGS
        jmp .pop_window

      .remote_building:
        mov bx, SCENE_MODE_REMOTE_BUILDINGS
        jmp .pop_window

      .upgrade_building:
        mov bx, SCENE_MODE_UPGRADE_BUILDINGS
        jmp .pop_window

      .station:
        mov bx, SCENE_MODE_STATION
        jmp .pop_window

      .radar_view:
        mov bx, SCENE_MODE_RADAR_VIEW
        jmp .pop_window

      .extractor_setup:
        mov bx, SCENE_MODE_EXTRACTOR_SETUP
        jmp .pop_window

      .extractor_info:
        mov bx, SCENE_MODE_EXTRACTOR_INFO
        jmp .pop_window

    .examine_resource:
      mov bx, SCENE_MODE_RESOURCE_INFO
      jmp .pop_window

    .pop_window:
      mov byte [_GAME_STATE_], STATE_WINDOW_INIT
      mov byte [_SCENE_MODE_], bl
      mov byte [_MENU_SELECTION_POS_], 0x0
      jmp .done

    .build_action_done:
    jmp .redraw_tile

  .calculate_pods:
    xor si, si
    .ent_loop:
      mov di, [fs:si + PODS]
      cmp di, 0x0
      jz .done_ent_loop

      .calculate_cart_direction:
        mov al, [fs:di + META]
        and al, CART_DIRECTION_MASK
        shr al, CART_DIRECTION_SHIFT

        mov cl, al                      ; save initial cart direction
        mov bx, di                      ; Save original position

        .test_forward_move:
          call calculate_directed_tile
          test byte [fs:di], RAIL_MASK
          jnz .check_forward_move

        .test_if_switch:
          mov di, bx                    ; restore position
          mov al, [fs:di + META]
          test al, SWITCH_MASK          ; check if its stay on a switch
          jz .test_other_axis_turn_move ; if not then left or right turn

          mov al, [fs:di + META]
          and al, TILE_DIRECTION_MASK
          call calculate_directed_tile  ; check target position tile
          jmp .check_forward_move       ; try move forward

        .test_other_axis_turn_move:
          mov al, cl
          xor ax, 0x1                   ; rotate target (up-down to left-right)
          call calculate_directed_tile
          test byte [fs:di], RAIL_MASK
          jnz .check_forward_move

          mov di, bx
          xor ax, 0x2                   ; mirror left/right or up/down
          call calculate_directed_tile
          test byte [fs:di], RAIL_MASK
          jnz .check_forward_move

        mov al, cl                      ; restore initial direction
        jmp .revert_move

        .check_forward_move:
          test byte [fs:di + FG], CART_DRAW_MASK  ; check for other cart
          jz .save_pod_move

        .pod_meet:
          mov ah, [fs:di + META]        ; get metadata
          and ah, CART_DIRECTION_MASK   ; keep only diretion
          shr ah, CART_DIRECTION_SHIFT  ; shift to be a number

          cmp al, ah                    ; check if same dir
          je .next_pod                  ; not in collision, wait

          xor ah, 0x2                   ; mirror direction (for check)
          cmp al, ah                    ; check if pointing at each other
        jne .next_pod                   ; not in collision, wait

      .revert_move:
        mov al, cl                      ; restore initial direction
        xor ax, 0x2                     ; mirror direction
        shl al, CART_DIRECTION_SHIFT    ; move to right place
        and byte [fs:bx + META], 0xFF - CART_DIRECTION_MASK  ; clear old direction
        add byte [fs:bx + META], al     ; save the reverted direction
      jmp .next_pod

      .save_pod_move:
        mov word [fs:si + PODS], di            ; update ent pointer to new pos
        and byte [fs:bx + FG], 0xFF - CART_DRAW_MASK  ; remove cart from old pos
        add byte [fs:di + FG], CART_DRAW_MASK  ; draw cart on new pos

        and byte [fs:di + META], 0xFF - CART_DIRECTION_MASK  ; clear new cart direction
        and byte [fs:di + META], 0xFF - RESOURCE_TYPE_MASK ; clear new resources
        shl al, CART_DIRECTION_SHIFT    ; shift new direction to right place
        mov cl, [fs:bx + META]          ; get old metadata
        and cl, RESOURCE_TYPE_MASK      ; keep only resouces data
        add al, cl                      ; merge resources and direction
        add byte [fs:di + META], al     ; save in new position
        and byte [fs:bx + META], 0xFF - RESOURCE_TYPE_MASK ; clear old resources

      .redraw_tiles:
        push si
        push di
        mov di, bx
        mov si, bx
        call draw_single_cell
        pop di
        mov si, di
        call draw_single_cell
        pop si

      .next_pod:
      add si, 0x2
    jmp .ent_loop
    .done_ent_loop:
    jmp .done

  .redraw_four_tiles:
    mov ax, [_CURSOR_X_]
    mov bx, [_CURSOR_Y_]
    dec ax
    call draw_selected_cell

    mov ax, [_CURSOR_X_]
    mov bx, [_CURSOR_Y_]
    inc ax
    call draw_selected_cell

    mov ax, [_CURSOR_X_]
    mov bx, [_CURSOR_Y_]
    inc bx
    call draw_selected_cell

    mov ax, [_CURSOR_X_]
    mov bx, [_CURSOR_Y_]
    dec bx
    call draw_selected_cell
    jmp .redraw_tile

  .redraw_old_tile:
    mov ax, [_CURSOR_X_OLD_]
    mov bx, [_CURSOR_Y_OLD_]
    call draw_selected_cell

  .redraw_tile:
    mov ax, [_CURSOR_X_]
    mov bx, [_CURSOR_Y_]
    mov word [_CURSOR_X_OLD_], ax
    mov word [_CURSOR_Y_OLD_], bx
    call draw_selected_cell
    jmp .done

  .redraw_terrain:
    call draw_terrain
    call ui.draw_stats
    jmp .done

  .done:
    ret

game_render:
  .draw_front_elements:
    ; todo: calculate proper center map position and clamp
      mov di, SCREEN_WIDTH*(LANDING_TIMER+16) + SCREEN_WIDTH/2
      mov ax, TILE_ROCKET_TOP
      call draw_sprite
  ret

game_cinematic:
  .animate:
  ret

; in:
; DI position
; AL direction
; out:
; DI changed
calculate_directed_tile:
  .check_up:
  cmp al, CART_UP
    jnz .check_left
    sub di, MAP_SIZE
    ret
  .check_left:
  cmp al, CART_LEFT
    jnz .check_down
    dec di
    ret
  .check_down:
  cmp al, CART_DOWN
    jnz .check_right
    add di, MAP_SIZE
    ret
  .check_right:
    inc di
    ret

actions_logic:

  .expand_foundation:
    mov di, [_CURSOR_Y_]    ; Absolute Y map coordinate
    shl di, 7               ; Y * 128 (optimized shl for *128)
    add di, [_CURSOR_X_]    ; + absolute X map coordinate

    mov ax, TILE_FOUNDATION
    mov bx, CURSOR_ICON_PLACE_BUILDING
    ror bl, CURSOR_TYPE_ROL
    test byte [fs:di+1], TERRAIN_TRAVERSAL_MASK
    jz .skip_right
      mov byte [fs:di+1], al
      mov byte [fs:di+1 + FG], bl
    .skip_right:
    test byte [fs:di-1], TERRAIN_TRAVERSAL_MASK
    jz .skip_left
      mov byte [fs:di-1], al
      mov byte [fs:di-1 + FG], bl
    .skip_left:
    test byte [fs:di-MAP_SIZE], TERRAIN_TRAVERSAL_MASK
    jz .skip_up
      mov byte [fs:di-MAP_SIZE], al
      mov byte [fs:di-MAP_SIZE + FG], bl
    .skip_up:
    test byte [fs:di+MAP_SIZE], TERRAIN_TRAVERSAL_MASK
    jz .skip_down
      mov byte [fs:di+MAP_SIZE], al
      mov byte [fs:di+MAP_SIZE + FG], bl
    .skip_down:
    jmp .done

  .place_station:
    mov di, [_CURSOR_Y_]    ; Absolute Y map coordinate
    shl di, 7               ; Y * 128 (optimized shl for *128)
    add di, [_CURSOR_X_]    ; + absolute X map coordinate

    mov al, [fs:di]
    and al, 0xFF - BACKGROUND_SPRITE_MASK
    add al, TILE_STATION
    or al, RAIL_MASK
    mov byte [fs:di], al
    and byte [fs:di + FG], 0xFf - CURSOR_TYPE_MASK

    mov bl, TILE_STATION_EXTEND
    mov cx, CURSOR_ICON_PLACE_BUILDING
    ror cl, CURSOR_TYPE_ROL
    mov al, [fs:di + FG]
    and al, FOREGROUND_SPRITE_MASK
    cmp al, TILE_RAILS_1-TILE_FOREGROUND_SHIFT  ; horizontal
    jz .build_horizontal

    .build_vertical:
      test byte [fs:di-1], TERRAIN_TRAVERSAL_MASK
      jz .skip_left2
        mov [fs:di-1], bl
        mov [fs:di-1 + FG], cl
      .skip_left2:
      test byte [fs:di+1], TERRAIN_TRAVERSAL_MASK
      jz .build_done
        mov [fs:di+1], bl
        mov [fs:di+1 + FG], cl
    jmp .build_done

    .build_horizontal:
      test byte [fs:di-MAP_SIZE], TERRAIN_TRAVERSAL_MASK
      jz .skip_up2
        mov [fs:di-MAP_SIZE], bl
        mov [fs:di-MAP_SIZE + FG], cl
      .skip_up2:
      test byte [fs:di+MAP_SIZE], TERRAIN_TRAVERSAL_MASK
      jz .build_done
        mov [fs:di+MAP_SIZE], bl
        mov [fs:di+MAP_SIZE + FG], cl
    .build_done:
    jmp .done

  .place_building:
    mov di, [_CURSOR_Y_]    ; Absolute Y map coordinate
    shl di, 7               ; Y * 128 (optimized shl for *128)
    add di, [_CURSOR_X_]    ; + absolute X map coordinate

    mov bx, ax                          ; Save sprite parameter
    mov al, [fs:di]
    or al, INFRASTRUCTURE_MASK
    mov byte [fs:di], al

    mov al, CURSOR_ICON_PLACE_BUILDING
    ror al, CURSOR_TYPE_ROL
    add ax, bx
    mov byte [fs:di + FG], al
    cmp bx, TILE_BUILDING_RADAR_ID
    jz .update_radar

    .update_radar:
      call .update_radar_visibility
    jmp .done

  .inspect_building:
    jmp .done

  .update_radar_visibility:
    sub di, MAP_SIZE * (RADAR_VISIBILITY_RANGE / 2)
    ; todo: top edge
    sub di, RADAR_VISIBILITY_RANGE / 2
    ; clip left edge
    mov cx, RADAR_VISIBILITY_RANGE
    .radar_row:
      push cx
      mov cx, RADAR_VISIBILITY_RANGE
      .radar_col:
        or byte [fs:di + META], RADAR_VISIBILITY_MASK
        inc di
        ; clip right edge
      loop .radar_col
      add di, MAP_SIZE - RADAR_VISIBILITY_RANGE
      ; clip bottom edge
      pop cx
    loop .radar_row
    ret

  .update_extractor_targets:
    ; todo: look around for res by type
    ; save it in your metadata?

  ret

  .build_pods_station:
    mov di, [_CURSOR_Y_]    ; Absolute Y map coordinate
    shl di, 7               ; Y * 128 (optimized shl for *128)
    add di, [_CURSOR_X_]    ; + absolute X map coordinate

    mov al, [fs:di + META]
    and al, TILE_DIRECTION_MASK

    call get_target_tile

    test byte [fs:di], TERRAIN_TRAVERSAL_MASK
    jz .skip_station

    .set_rail_tile:
      and al, 0x1                       ; horizontal or vertical initial rails
      mov bl, TILE_RAILS_2-TILE_FOREGROUND_SHIFT
      sub bl, al
      mov byte [fs:di + FG], bl

    .set_station_tile:
      mov al, TILE_STATION + RAIL_MASK
      mov byte [fs:di], al

    .recalculate_near_rails:
      dec di
      call recalculate_rails
      add di, 2
      call recalculate_rails
      dec di
      add di, MAP_SIZE
      call recalculate_rails
      sub di, MAP_SIZE*2
      call recalculate_rails
      jmp .done

    .skip_station:
      test byte [fs:di], RAIL_MASK      ; If target is on rails
      jnz .place_station_on_rails        ; place station
      jmp .done                         ; dont place on other rails
      .place_station_on_rails:
        mov al, [fs:di + FG]
        and al, FOREGROUND_SPRITE_MASK
        cmp al, TILE_RAILS_1-TILE_FOREGROUND_SHIFT  ; horizontal
        jz .correct_rails
        cmp al, TILE_RAILS_2-TILE_FOREGROUND_SHIFT ; vertical
        jz .correct_rails
        jmp .done                       ; no for turns, only diagonal
        .correct_rails:
          mov al, TILE_STATION + RAIL_MASK
          mov byte [fs:di], al
          jmp .done

  .build_pod:
    mov ax, [_LAST_ENT_POD_ID_]         ; How many pods already spawned
    cmp ax, MAX_PODS                    ; If max pods reached, skip
    jge .done


    mov di, [_CURSOR_Y_]    ; Absolute Y map coordinate
    shl di, 7               ; Y * 128 (optimized shl for *128)
    add di, [_CURSOR_X_]    ; + absolute X map coordinate


    mov al, [fs:di + META]
    and al, TILE_DIRECTION_MASK

    call get_target_tile
    .check_for_station:
      mov al, [fs:di]
      and al, BACKGROUND_SPRITE_MASK
      cmp al, TILE_STATION
      jnz .skip_build_pod

    .pod_on_station:
      mov al, [fs:di + FG]
      or al, CART_DRAW_MASK
      mov byte [fs:di + FG], al

      ; TODO: temporary for debug
      call get_random
      and ax, 0x3
      shl al, RESOURCE_TYPE_SHIFT
      and byte [fs:di + META], 0xFF - RESOURCE_TYPE_MASK
      add byte [fs:di + META], al
      ; END TODO

    mov si, [_LAST_ENT_POD_ID_]
    inc word [_LAST_ENT_POD_ID_]
    shl si, 1
    mov [fs:si + PODS], di
    mov word [fs:si + PODS + 2], 0      ; Terminator
    jmp .done

  .set_extractor_mode:
    mov bx, SFX_CHANGE_MODE
    call audio.play_sfx

    mov di, [_CURSOR_Y_]                ; Calculate map position
    shl di, 7   ; Y * 128
    add di, [_CURSOR_X_]

    and byte [fs:di + FG], 0xFF - FOREGROUND_SPRITE_MASK
    add byte [fs:di + FG], al

    cmp al, TILE_BUILDING_EXTRACTOR_ID
    je .reset_extractor

    .update_extractor:
      sub al, TILE_EXTRACT_WHITE_ID     ; Get the nth value (white->green->blue)
      mov bl, al                        ; Save for targets
      inc al                            ; Convert to 1-3 for resource type
      shl al, RESOURCE_TYPE_SHIFT
      and byte [fs:di + META], 0xFF - RESOURCE_TYPE_MASK
      add byte [fs:di + META], al

      call .update_extractor_targets    ; BX has tileID
      jmp .done

    .reset_extractor:
      and byte [fs:di + META], 0xFF - RESOURCE_TYPE_MASK

      ; set dx to 0 for reset
      call .update_extractor_targets
    jmp .done

  .done:
    ret

  .skip_build_pod:
    ret

; DI current
; al direction
; out di of target
get_target_tile:
  .test_right:
  cmp al, 0x0
  jnz .test_up
    inc di
    jmp .test_done
  .test_up:
  cmp al, 0x1
  jnz .test_left
    sub di, MAP_SIZE
    jmp .test_done
  .test_left:
  cmp al, 0x2
  jnz .test_down
    dec di
    jmp .test_done
  .test_down:
    add di, MAP_SIZE
  .test_done:
  ret

window_logic:
  .create_window:

  .redraw_window:
    mov si, WindowDefinitionsArray
    xor ax, ax
    mov al, [_SCENE_MODE_]
    imul ax, 0xA
    add si, ax

    mov bx, [si]                        ; height:width
    mov ax, [si+2]                      ; y:x

    call draw_window

    mov ax, [si+4]
    mov dx, [si+2]
    push si
    mov si, ax

    add dl, 0x2
    mov bl, COLOR_WHITE
    call font.draw_string

    pop si
    mov ax, [si+6]
    mov dx, [si+2]
    mov si, ax
    add dh, 0x2
    add dl, 0x2

    xor cx, cx
    .menu_array:

      cmp byte [si], 0x00
      jz .done_menu_array

      mov bl, COLOR_WHITE
      cmp byte [_MENU_SELECTION_POS_], cl
      jne .skip_color_highlight
        mov bl, COLOR_YELLOW
      .skip_color_highlight:
      push cx
      call font.draw_string
      pop cx
      inc dh
      inc dh
      inc cx
    jmp .menu_array
    .done_menu_array:
    dec cl
    mov byte [_MENU_SELECTION_MAX_], cl
    jmp .done

  .done:
    ret

menu_logic:
  .check_cursor_over:
    mov si, WindowDefinitionsArray
    xor ax, ax
    mov al, [_SCENE_MODE_]
    imul ax, 0xA
    add si, ax

    mov bx, [si]                        ; height:width
    mov ax, [si+2]                      ; y:x
    shr al, 1                           ; convert from windows 8x8
    shr ah, 1                           ; to tiles 16x16
    add bl, al                          ; right
    add bh, ah                          ; bottom

    mov cx, [_MOUSE_TILE_POS_X_]
    mov dx, [_MOUSE_TILE_POS_Y_]

    cmp dl, ah                          ; mouse y vs top
    jl .mouse_outside
    cmp dl, bh                          ; mouse y vs bottom
    jge .mouse_outside

    cmp cl, al                          ; mouse x vs left
    jl .mouse_outside
    cmp cl, bl                          ; mouse x vs right
    jge .mouse_outside

    movzx bx, ah                        ; window y
    sub dx, bx                          ; cursor y - window y
    dec dx                              ; skip header

    cmp dx, 0
    jl .mouse_outside
    cmp byte dl, [_MENU_SELECTION_MAX_]
    jg .mouse_outside
    jmp .mouse_inside

    .mouse_outside:
      cmp byte [_GAME_STATE_], STATE_MENU_SCREEN
      jz .move_to_top
      cmp byte [_GAME_STATE_], STATE_BRIEFING
      jz .move_to_top
      .move_to_bottom:
        mov dl, [_MENU_SELECTION_MAX_]
        mov byte [_MENU_SELECTION_POS_], dl
        jmp .redraw
      .move_to_top:
        mov byte [_MENU_SELECTION_POS_], 0x0
        jmp .redraw

    .mouse_inside:
      cmp byte [_MENU_SELECTION_POS_], dl
      jz .no_change
        mov byte [_MENU_SELECTION_POS_], dl
     .redraw:
      call window_logic.redraw_window
    .no_change:
    ret

  .selection_up:
    cmp byte [_MENU_SELECTION_POS_], 0x0
    je .done
    dec byte [_MENU_SELECTION_POS_]
    mov bx, SFX_MENU_UP
    call audio.play_sfx
    jmp window_logic.redraw_window

  .selection_down:
    mov al, [_MENU_SELECTION_POS_]
    cmp al, [_MENU_SELECTION_MAX_]
    je .done
    inc byte [_MENU_SELECTION_POS_]
    mov bx, SFX_MENU_DOWN
    call audio.play_sfx
    jmp window_logic.redraw_window

  .game_menu_enter:
    mov byte [_GAME_STATE_], STATE_GAME_INIT

  .main_menu_enter:
    mov bx, SFX_MENU_ENTER
    call audio.play_sfx
    mov si, WindowDefinitionsArray
    xor ax, ax
    mov al, [_SCENE_MODE_]
    imul ax, 0xA
    add si, ax

    mov si, [si+8]                      ; Get menu def data
    mov al, [_MENU_SELECTION_POS_]      ; Get current selection
    shl al, 2                           ; Aling with data
    add si, ax                          ; Set as target function to call
    mov ax, [si+2]                      ; Pass last argument from def.
    call word [si]                      ; Call target function
    jmp .done

  .start_game:
    mov byte [_GAME_STATE_], STATE_LANDING_INIT
    jmp .done

  .start_story:
    mov byte [_GAME_STATE_], STATE_STORY_SCREEN_INIT
    mov byte [_SCENE_MODE_], 0x0
    jmp .done

  .generate_new_map:
    mov byte [_GAME_STATE_], STATE_GAME_NEW
    jmp .done

  .tailset_preview:
    mov byte [_GAME_STATE_], STATE_DEBUG_VIEW_INIT
    jmp .done

  .help:
    mov byte [_GAME_STATE_], STATE_HELP_INIT
    jmp .done

  .quit:
    mov byte [_GAME_STATE_], STATE_QUIT
    jmp .done

  .close_window:
    mov byte [_GAME_STATE_], STATE_GAME_INIT
    jmp .done

  .show_brief:
    mov byte [_GAME_STATE_], STATE_BRIEFING_CINE_INIT
    jmp .done

  .back_to_menu:
    mov byte [_GAME_STATE_], STATE_MENU_SCREEN_INIT
    jmp .done

  .done:
    ret

; ======================================= PROCEDURES FOR GAME STATES ========|80

init_engine:
  call reset_to_default_values
  call audio.init
  call decompress_all_tiles
  call generate_map
  mov word [_CINE_TIMER_], CINE_P1X_TIMER
  mov byte [_GAME_STATE_], STATE_P1X_SCREEN_CINE
ret

reset_to_default_values:
  mov dword [_GAME_TICK_], 0x0
  mov word [_IDLE_TICK_], 0x0
  mov byte [_GAME_TURN_], 0x0
  mov byte [_GAME_STARTED_], 0x0
  mov word [_RNG_], 0x42

  mov word [_VIEWPORT_X_], MAP_SIZE/2-VIEWPORT_WIDTH/2
  mov word [_VIEWPORT_Y_], MAP_SIZE/2-VIEWPORT_HEIGHT/2
  mov word [_CURSOR_X_], MAP_SIZE/2
  mov word [_CURSOR_Y_], MAP_SIZE/2
  mov word [_CURSOR_X_OLD_], MAP_SIZE/2
  mov word [_CURSOR_Y_OLD_], MAP_SIZE/2

  mov word [_SFX_POINTER_], SFX_NULL

  mov word [_LAST_ENT_POD_ID_], 0
  xor ax, ax
  mov di, PODS            ; 0xC000
  mov cx, (0x10000 - PODS) / 2   ; words to clear = 0x2000
  rep stosw

  mov word [_ECONOMY_BLUE_RES_], 0xF
  mov word [_ECONOMY_WHITE_RES_], 0xF
  mov word [_ECONOMY_GREEN_RES_], 0xF

  mov word [_CINE_TIMER_], 0
ret

init_p1x_screen:
  mov al, COLOR_BLACK
  call clear_screen

  mov si, stars_image
  xor di, di
  call draw_rle_image

  mov si, p1x1_image
  mov di, SCREEN_WIDTH*22
  call draw_rle_image
  mov si, p1x2_image
  mov di, SCREEN_WIDTH*22
  call draw_rle_image
  mov si, p1x3_image
  mov di, SCREEN_WIDTH*22
  call draw_rle_image

  mov bx, INTRO_JINGLE
  call audio.play_sfx

  mov byte [_GAME_STATE_], STATE_P1X_SCREEN
ret

init_pmkc_screen_cine:
  mov word [_CINE_TIMER_], CINE_PMKC_TIMER
  mov byte [_GAME_STATE_], STATE_PMKC_SCREEN_CINE
  mov byte [_SCENE_MODE_], SCENE_MODE_ANY
ret

init_pmkc_screen:
  mov al, COLOR_BLACK
  call clear_screen

  mov si, stars_image
  xor di, di
  call draw_rle_image

  mov si, pmkc_image
  mov di, SCREEN_WIDTH*18
  call draw_rle_image

  mov si, PMKCText
  mov dx, 0x1003
  mov bl, COLOR_WHITE
  call font.draw_string

  ;mov bx, INTRO_JINGLE
  ;call audio.play_sfx

  mov byte [_GAME_STATE_], STATE_PMKC_SCREEN
ret

init_title_screen:
  mov al, COLOR_BLACK
  call clear_screen

  mov si, stars_image
  xor di, di
  call draw_rle_image

  mov si, planet_image
  mov di, SCREEN_WIDTH*96
  call draw_rle_image

  mov si, clouds_image
  mov di, SCREEN_WIDTH*46
  call draw_rle_image

  mov si, city_image
  mov di, SCREEN_WIDTH*100
  call draw_rle_image

  mov si, logo_image
  mov di, SCREEN_WIDTH*50
  call draw_rle_image

  mov si, CreatedByText
  mov dx, 0x1408
  mov bl, COLOR_WHITE
  call font.draw_string

  mov si, KKJText
  mov dx, 0x1506
  mov bl, COLOR_WHITE
  call font.draw_string

  ;mov bx, INTRO_JINGLE
  ;call audio.play_sfx

  mov byte [_GAME_STATE_], STATE_TITLE_SCREEN
ret

init_title_screen_cine:
  mov word [_CINE_TIMER_], CINE_TITLE_TIMER
  mov byte [_GAME_STATE_], STATE_TITLE_SCREEN_CINE
ret

init_briefing:
  mov al, COLOR_BLACK
  call clear_screen

  mov si, stars_image
  xor di, di
  call draw_rle_image

  mov si, planet_image
  mov di, SCREEN_WIDTH*84
  call draw_rle_image

  mov si, brief_image
  mov di, SCREEN_WIDTH*56
  call draw_rle_image

  mov si, logo_image
  mov di, SCREEN_WIDTH*22
  call draw_rle_image

  mov byte [_GAME_STATE_], STATE_BRIEFING
  mov byte [_SCENE_MODE_], SCENE_MODE_BRIEFING
  call window_logic.create_window
ret

init_briefing_cine:
  mov word [_CINE_TIMER_], CINE_BRIEFING_TIMER
  mov byte [_GAME_STATE_], STATE_BRIEFING_CINE
ret

init_story:
  mov word [_CINE_TIMER_], CINE_STORY_TIMER
  mov byte [_GAME_STATE_], STATE_STORY_SCREEN
  mov byte [_SCENE_MODE_], 0x0
ret

init_help:
  mov byte [_SCENE_MODE_], 0x0
  call draw_help_page
  mov byte [_GAME_STATE_], STATE_HELP
ret

init_menu:
  mov al, COLOR_BLACK
  call clear_screen

  mov si, stars_image
  xor di, di
  call draw_rle_image

  mov si, planet_image
  mov di, SCREEN_WIDTH*12
  call draw_rle_image

  mov si, logo_image
  mov di, SCREEN_WIDTH*22
  call draw_rle_image

  mov byte [_GAME_STATE_], STATE_MENU_SCREEN
  mov byte [_SCENE_MODE_], SCENE_MODE_MAIN_MENU
  mov byte [_MENU_SELECTION_POS_], 0x0
  call window_logic.create_window

  mov si, VerText
  mov bl, COLOR_WHITE
  call font.draw_string

  mov si, BUILD_VER
  mov bl, COLOR_BLUE
  add dl, 0xF
  mov cx, 1000
  call font.draw_number

  ;mov bx, MENU_JINGLE
  ;call audio.play_sfx
ret

init_landing:
  call ui.draw_footer
  mov di, MAP_SIZE * (MAP_SIZE/2) + (MAP_SIZE/2)
  call actions_logic.update_radar_visibility
  mov word [_CINE_TIMER_], LANDING_TIMER
  mov byte [_GAME_STATE_], STATE_LANDING
  mov byte [_SCENE_MODE_], SCENE_MODE_ANY
ret

live_briefing:
  call menu_logic.check_cursor_over
ret

live_p1x_screen_cine:
  dec word [_CINE_TIMER_]
  mov bx, [_CINE_TIMER_]
  cmp bx, 0
  jle .cine_end

  mov al, COLOR_BLACK
  call clear_screen

  mov si, stars_image
  xor di, di
  call draw_rle_image

  cmp bx, 60
  jge .done
  .draw_p:
  mov si, p1x1_image
  mov di, SCREEN_WIDTH*22
  call draw_rle_image

  cmp bx, 40
  jge .done
  .draw_1:
  mov si, p1x2_image
  mov di, SCREEN_WIDTH*22
  call draw_rle_image

  cmp bx, 20
  jge .done
  .draw_x:
  mov si, p1x3_image
  mov di, SCREEN_WIDTH*22
  call draw_rle_image

  .done:
    ret

 .cine_end:
    mov byte [_GAME_STATE_], STATE_P1X_SCREEN_INIT
    mov byte [_SCENE_MODE_], SCENE_MODE_ANY
    ret


live_pmkc_screen:
live_p1x_screen:
  inc word [_IDLE_TICK_]
  cmp word [_IDLE_TICK_], SCREEN_IDLE_TIMER_END
  jle .idling
    inc byte [_GAME_STATE_]
    mov word [_IDLE_TICK_], 0x0
  .idling:
live_title_screen:
  mov si, PressEnterText
  mov dx, 0x170F
  mov bl, COLOR_WHITE
  test word [_GAME_TICK_], 0x4
  je .blink
    mov bl, COLOR_BLACK
  .blink:
  call font.draw_string
ret

live_title_screen_cine:
  mov ax, CINE_TITLE_TIMER
  call cine.calc_next_frame
  jc .cine_end

  mov al, COLOR_BLACK
  call clear_screen

  mov si, stars_image
  xor di, di
  call draw_rle_image

  mov si, planet_image
  mov di, SCREEN_WIDTH*96 ; 11 - 80
  sub di, bx
  sub di, bx
  sub di, bx
  call draw_rle_image

  mov si, clouds_image
  mov di, SCREEN_WIDTH*46 ; 200 - 54
  add di, bx
  add di, bx
  add di, bx
  add di, bx
  add di, bx
  call draw_rle_image

  mov si, city_image
  mov di, SCREEN_WIDTH*100 ; 200 - 100
  add di, bx
  add di, bx
  add di, bx
  call draw_rle_image

  mov si, logo_image
  mov di, SCREEN_WIDTH*50 ; 22 - 20
  sub di, bx
  call draw_rle_image

  ret
  .cine_end:
    mov byte [_GAME_STATE_], STATE_MENU_SCREEN_INIT
    mov byte [_SCENE_MODE_], SCENE_MODE_ANY
ret

live_menu:
  call menu_logic.check_cursor_over
ret

live_pmkc_screen_cine:
  mov ax, CINE_PMKC_TIMER
  call cine.calc_next_frame
  jc .cine_end

  shl bx, 3

  mov al, COLOR_BLACK
  call clear_screen

  mov si, stars_image
  xor di, di
  call draw_rle_image

  mov si, pmkc_image
  mov di, SCREEN_WIDTH*200
  sub di, bx
  call draw_rle_image

  ret
  .cine_end:
    mov byte [_GAME_STATE_], STATE_PMKC_SCREEN_INIT
    mov byte [_SCENE_MODE_], SCENE_MODE_ANY
  ret



live_briefing_cine:
  mov ax, CINE_BRIEFING_TIMER
  call cine.calc_next_frame
  jc .cine_end

  shl bx, 1

  mov al, COLOR_BLACK
  call clear_screen

  mov si, stars_image
  xor di, di
  call draw_rle_image

  mov si, planet_image
  mov di, SCREEN_WIDTH*12
  add di, bx
  call draw_rle_image

  mov si, logo_image
  mov di, SCREEN_WIDTH*22
  call draw_rle_image

  mov si, brief_image
  mov di, SCREEN_WIDTH*200
  sub di, bx
  sub di, bx
  call draw_rle_image

ret
  .cine_end:
    mov byte [_GAME_STATE_], STATE_BRIEFING_INIT
    mov byte [_SCENE_MODE_], SCENE_MODE_ANY
ret

live_help:
ret

live_story:
  test word [_GAME_TICK_], 1            ; skip odd frames
  jz .done

  mov ax, CINE_STORY_TIMER
  call cine.calc_next_frame
  jnc .cine_live

  mov bx, CINE_STORY_TIMER*SCREEN_WIDTH*2
  .cine_live:

  mov al, COLOR_BLACK
  call clear_screen

  mov si, stars_image
  xor di, di
  call draw_rle_image

  mov si, earth_image
  mov di, SCREEN_WIDTH*58
  call draw_rle_image

  mov si, planet_big_image
  mov di, SCREEN_WIDTH*200
  sub di, bx
  call draw_rle_image

  mov si, rocket_image
  mov di, SCREEN_WIDTH*12
  add di, bx
  call draw_rle_image
  mov si,StoryLinesText
  mov bl, COLOR_WHITE
  mov dx, 0x0101
  movzx cx, byte [_SCENE_MODE_]
  .line:
    cmp byte [si], 0x00
    jz .end
    call font.draw_string
    inc dh
  loop .line
  .end:


  cmp byte [_SCENE_MODE_], 21
  jl .done
  test word [_GAME_TICK_], 0xF
  jz .done
  inc byte [_SCENE_MODE_]
  .done:
ret


live_landing:
  call draw_terrain
  cmp word [_CINE_TIMER_], 0
  je .landed
  dec word [_CINE_TIMER_]
  ;call draw_rocket

  mov di, SCREEN_WIDTH*(LANDING_TIMER) + SCREEN_WIDTH/2
  mov bx, [_CINE_TIMER_]
  imul bx, SCREEN_WIDTH
  sub di, bx
  mov ax, TILE_ROCKET_TOP
  call draw_sprite
  add di, SCREEN_WIDTH*SPRITE_SIZE
  mov ax, TILE_ROCKET_GEAR
  call draw_sprite
  add di, SCREEN_WIDTH*SPRITE_SIZE
  mov ax, TILE_ROCKET_SMOKE
  call draw_sprite

ret
  .landed:
    call build_initial_base
    mov byte [_GAME_STATE_], STATE_GAME_INIT
    mov byte [_SCENE_MODE_], SCENE_MODE_ANY
ret

live_game:
  call ui.draw_footer
  call ui.draw_stats
ret

draw_help_page:
  mov al, COLOR_BLACK
  call clear_screen

  mov si, stars_image
  xor di, di
  call draw_rle_image

  mov di, HelpArrayText
  call font.draw_text_array

  mov bl, COLOR_WHITE
  mov dx, 0x1502
  mov si, HelpFooter1Text
  call font.draw_string
  mov si, HelpFooter2Text
  inc dh
  call font.draw_string

ret

ror_help_page:
  inc byte [_SCENE_MODE_]
  and byte [_SCENE_MODE_], 0x07
  call draw_help_page
ret

new_game:
  call generate_map
  call reset_to_default_values

  mov byte [_GAME_STATE_], STATE_BRIEFING_INIT
  mov byte [_SCENE_MODE_], SCENE_MODE_BRIEFING
ret

init_game:
  call draw_terrain
  call ui.draw_stats
  mov byte [_GAME_STATE_], STATE_GAME
  mov byte [_SCENE_MODE_], SCENE_MODE_ANY

  ;mov bx, GAME_JINGLE
  ;call audio.play_sfx
ret

init_window:
  call window_logic.create_window
  mov byte [_GAME_STATE_], STATE_WINDOW
ret

live_window:
  call menu_logic.check_cursor_over

  mov si, WindowDefinitionsArray
  xor ax, ax
  mov al, [_SCENE_MODE_]
  imul ax, 0xA
  add si, ax

  mov bx, [si]                          ; Get windows size height:width
  mov ax, [si+2]                        ; Get windows position y:x
  mov dx, ax                            ; Save windows position
  add dh, bh                            ; Move position to bottom of the window
  add dh, 0x3                           ; ...and line bleow...
  add dl, 0x2                           ; ...padding left.

  mov si, [_CURSOR_Y_]                  ; Calculate map position
  shl si, 7   ; Y * 128
  add si, [_CURSOR_X_]

  .get_position:
    add ah, 4
    shl al, 3
    shl ah, 3
    movzx di, ah
    imul di, 320
    xor ah,ah
    add di, ax

    sub bl, 2
    shl bl, 4
    xor bh, bh
    add di, bx


  .select_widget:
    cmp byte [_SCENE_MODE_], SCENE_MODE_UPGRADE_BUILDINGS
    je .widget_rotate
    cmp byte [_SCENE_MODE_], SCENE_MODE_RADAR_VIEW
    je .widget_radar
    cmp byte [_SCENE_MODE_], SCENE_MODE_EXTRACTOR_SETUP
    je .widget_extractor
    cmp byte [_SCENE_MODE_], SCENE_MODE_EXTRACTOR_INFO
    je .widget_extractor_info
    cmp byte [_SCENE_MODE_], SCENE_MODE_RESOURCE_INFO
    je .widget_resource_info
    jmp .done

  .widget_rotate:
    mov al, [fs:si + META]
    and al, TILE_DIRECTION_MASK
    add al, TILE_IO_RIGHT
    call draw_sprite
    jmp .done

  .widget_radar:
    call ui.draw_radar_map
    jmp .done

  .widget_extractor:
    mov al, TILE_RES_WHITE_MAX
    call draw_sprite
    add di, SCREEN_WIDTH*SPRITE_SIZE
    mov al, TILE_RES_GREEN_MAX
    call draw_sprite
    add di, SCREEN_WIDTH*SPRITE_SIZE
    mov al, TILE_RES_BLUE_MAX
    call draw_sprite
    add di, SCREEN_WIDTH*SPRITE_SIZE
    jmp .done


  .widget_resource_info:

    push si
    mov si, ResourceAmountText
    mov bx, COLOR_WHITE
    call font.draw_string
    pop si

    call draw_resource_sprite_from_si
    jmp .draw_amount

  .widget_extractor_info:
    push si
    mov si, ExtractedText
    mov bx, COLOR_WHITE
    call font.draw_string
    pop si

    call draw_resource_sprite_from_si

    .draw_amount:
      add dl, 0x0D                        ; Move to right
      xor ax, ax                          ; Clear AH just to be safe
      mov al, [fs:si + META]
      and al, RESOURCE_AMOUNT_MASK
      shr al, RESOURCE_AMOUNT_SHIFT
      mov si, ax
      mov cx, 0x10
      call font.draw_number

    jmp .done
     .done:
ret

init_debug_view:
  mov al, COLOR_BLACK
  call clear_screen

  .draw_loaded_sprites:
  mov di, 320*16+16                     ; Position on screen
  xor ax, ax                            ; Sprite ID 0
  mov cx, TILES_COUNT
  .spr:
    call draw_sprite
    inc ax                              ; Next prite ID

    .test_new_line:
    mov bx, ax
    and bx, 0xF
    cmp bx, 0
    jne .skip_new_line
      add di, SCREEN_WIDTH*SPRITE_SIZE-SPRITE_SIZE*18 + 320*2 ; New line + 2px
    .skip_new_line:

    add di, 18                          ; Move to next slot + 2px
  loop .spr


  mov si, Fontset1Text
  mov bl, COLOR_WHITE
  mov dx, 0x1002
  call font.draw_string

  mov si, Fontset2Text
  mov bl, COLOR_RED
  mov dx, 0x1102
  call font.draw_string

  mov si, Fontset3Text
  mov bl, COLOR_BLUE
  mov dx, 0x1202
  call font.draw_string

  .draw_color_palette:
  mov di, SCREEN_WIDTH*160+32           ; Position on screen
  mov cx, 16                            ; 16 lines
  .colors_loop:
    push cx
    xor ax, ax

    mov cx, 16                          ; 16 colors
    .line_loop:
      push cx
      mov cx, 8
      rep stosw
      inc al
      inc ah
      pop cx
    loop .line_loop

    add di, SCREEN_WIDTH-(SPRITE_SIZE*SPRITE_SIZE)  ; wrap to next line
    pop cx
  loop .colors_loop

  mov byte [_GAME_STATE_], STATE_DEBUG_VIEW
ret

live_debug_view:
  nop
ret


; =========================================== PROCEDURES ====================|80

draw_resource_sprite_from_si:
  mov al, [fs:si + META]
  and al, RESOURCE_TYPE_MASK
  jz .done
  shr al, RESOURCE_TYPE_SHIFT       ; 1..3
  dec al                            ; 0..2
  shl al, 1                         ; 0,2,4
  add al, TILE_RES_WHITE_MAX        ; white/green/blue
  call draw_sprite
  .done:
ret


cine:
  ; AX - cine timer value
  .calc_next_frame:
    cmp word [_CINE_TIMER_], 0          ; Check if timer ended
    jle .cine_end                       ; Less or equal 0 to end

    dec word [_CINE_TIMER_]             ; Decrement cinemati timer

    mov bx, [_CINE_TIMER_]
    sub ax, bx                          ; current timer in AX, sub end timer
    mov bx, ax                          ; move result to bx
    shl bx, 1                           ; Multiply by 2 (for interlaced rle)
    imul bx, SCREEN_WIDTH               ; Multiply by screen line (move Y)
    clc                                 ; No carry flag - proceed with animation
  ret
    .cine_end:
    stc                                 ; Carry flag - animation ended
  ret














; =========================================== CUSTOM PALETTE ================|80
; IN: Palette data in RGB format
; OUT: VGA palette initialized
initialize_custom_palette:
  mov si, CustomPalette                 ; Palette data pointer
  mov dx, 03C8h                         ; DAC Write Port (start at index 0)
  xor al, al                            ; Start with color index 0
  out dx, al                            ; Send color index to DAC Write Port
  mov dx, 03C9h                         ; DAC Data Port
  mov cx, 16*3                          ; 16 colors × 3 bytes (R, G, B)
  rep outsb                             ; Send all RGB values
ret

CustomPalette:
; DawnBringer 16 color palette
; https://github.com/geoffb/dawnbringer-palettes
; Converted from 8-bit to 6-bit for VGA
db  0,  0,  0                           ; #000000 - Black
db 17,  8, 13                           ; #442434 - Deep purple
db 12, 13, 27                           ; #30346D - Navy blue
db 19, 18, 19                           ; #4E4A4E - Dark gray
db 33, 19, 12                           ; #854C30 - Brown
db 13, 25,  9                           ; #346524 - Dark green
db 52, 17, 18                           ; #D04648 - Red
db 29, 28, 24                           ; #757161 - Light gray
db 22, 31, 51                           ; #597DCE - Blue
db 52, 31, 11                           ; #D27D2C - Orange
db 33, 37, 40                           ; #8595A1 - Steel blue
db 27, 42, 11                           ; #6DAA2C - Green
db 52, 42, 38                           ; #D2AA99 - Pink/Beige
db 27, 48, 50                           ; #6DC2CA - Cyan
db 54, 53, 23                           ; #DAD45E - Yellow
db 55, 59, 53                           ; #DEEED6 - White

terminal:
  ; =========================================== DRAW TEXT ===================|80
  ;  SI - Pointer to text
  ;  DL - X position
  ;  DH - Y position
  ;  BX - Color
  .draw_text:
    mov ah, 0x02                          ; Set cursor
    xor bh, bh                            ; Page 0
    int 0x10

    .next_char:
      lodsb                               ; Load next character from SI into AL
      test al, al                         ; Check for string terminator
      jz .done                            ; If terminator, we're done

      mov ah, 0x0E                        ; Teletype output
      mov bh, 0                           ; Page 0
      int 0x10                            ; BIOS video interrupt

      jmp .next_char                      ; Process next character

    .done:
  ret


; =========================================== FONT SUBSYSTEM ================|80
font:
  ; =========================================== DRAW STRING =================|80
  ;  SI - Pointer to text string
  ;  DL - X position (in character font size)
  ;  DH - Y position (in character font size)
  ;  BX - Color
  .draw_string:
    call .calculate_vga_pointer

    .next_char_loop:
      xor ax, ax                        ; Clear leftover in ax
      lodsb
      test al, al                       ; Test for 0x0 terminator in text string
      jz .done
      cmp ax, 32                        ; space
      jnz .is_not_space
        add di,FONT_SIZE
        jmp .next_char_loop
      .is_not_space:
      push si                             ; Save string pointer
      push di

      call font.draw_character

      pop di
      pop si                              ; Restore string pointer
      add di,FONT_SIZE                    ; Next char
    jmp .next_char_loop
    .done:
  ret

  .draw_character:
    .calculate_character_font_pointer:
      sub ax, ' '                       ; Char index
      shl ax, 3                         ; Font offset (8 bytes)
      mov si, Font
      add si, ax

    mov bh, 0x0
    mov cx, FONT_SIZE
    .char_line:
      lodsb                             ; Load font byte
      push cx
      mov cx, FONT_SIZE
      .pixel:
        shl al, 1
        jc .draw_px                     ; Transparent
        inc di                          ; Skip pixel
      loop .pixel
        jmp .next_line                  ; Jump to next line on last pixel
        .draw_px:
        mov word [es:di], bx            ; Color pixel
        inc di
      loop .pixel                       ; Next pixel
      .next_line:
      add di, SCREEN_WIDTH-FONT_SIZE
      pop cx
    loop .char_line
  ret

  ; =========================================== DRAW TEXT ARRAY =============|80
  ; IN:
  ;   DI - Array pointe
  .draw_text_array:
    movzx ax, byte [_SCENE_MODE_]
    shl ax, 1
    add di, ax
    mov si, [di]

    mov bl, COLOR_WHITE
    mov dx, 0x0002
    call font.draw_string
    mov dx, 0x0101
    .line:
      cmp byte [si], 0x00
      jz .end
      call font.draw_string
      inc dh
    jmp .line
    .end:
    ret

  ; =========================================== DRAW NUMBER =================|80
  ; IN:
  ;   SI - Value to display (decimal)
  ;   DL - X position
  ;   DH - Y position
  ;   BX - Color
  ;   CX - digits length
  .draw_number:
    pusha
    call .calculate_vga_pointer
    mov ax, si                            ; Copy the number to AX for division
    .next_digit:
      xor dx, dx                          ; Clear DX for division
      div cx                              ; Divide, remainder in DX
      add al, '0'                         ; Convert to ASCII

      push dx                             ; Save remainder
      push cx                             ; Save divisor
      push di
      call .draw_character
      pop di
      add di, FONT_SIZE
      pop cx                              ; Restore divisor
      pop dx                              ; Restore remainder

      mov ax, dx                          ; Save remainder to AX

      push ax                             ; Save current remainder
      mov ax, cx                          ; Get current divisor in AX
      xor dx, dx                          ; Clear DX for division
      push bx
      mov bx, 10                          ; Divide by 10
      div bx                              ; AX = AX/10
      pop bx
      mov cx, ax                          ; Set new divisor
      pop ax                              ; Restore current remainder

      cmp cx, 0                           ; If divisor is 0, we're done
      jne .next_digit
    popa
    ret

  .calculate_vga_pointer:
    push bx                             ; Save color
    push cx
    movzx ax, dl                        ; Extract X
    movzx bx, dh                        ; Extract Y
    shl ax, 3                           ; X * 8
    shl bx, 3                           ; Y * 8
    mov cx, bx                          ; make copy of Y
    shl bx, 8                           ; Y * 256
    shl cx, 6                           ; Y * 64
    add bx, cx                          ; BX = Y * 320
    add bx, ax                          ; Y * 8 * 320 + X * 8
    mov di, bx                          ; Move result to DI
    add di, SCREEN_WIDTH*(SPRITE_SIZE/4)+(SPRITE_SIZE/4)
    pop cx
    pop bx                              ; Restore color
    ret

; =========================================== GET RANDOM ====================|80
; OUT: AX - Random number
get_random:
  push es
  push si
  push di

  push cs                               ; GAME CODE SEGMENT
  pop es

  mov si, _RNG_
  mov di, _GAME_TICK_

  mov ax, [es:si]
  inc ax
  rol ax, 1
  xor ax, 0x1337
  add ax, [es:di]
  mov si, _RNG_
  mov [es:si], ax

  pop di
  pop si
  pop es
ret

; =========================================== CLEAR SCREEN ==================|80
; IN:
;   AL - Color
clear_screen:
  mov ah, al
  mov cx, SCREEN_WIDTH*SCREEN_HEIGHT/2  ; Number of pixels
  xor di, di                            ; Start at 0
  rep stosw                             ; Write to the VGA memory
ret

; =========================================== DRAW GRADIENT =================|80
; IN:
;   DI - Position
;   AL - Color
draw_gradient:
  mov ah, al
  mov dl, 0xD                           ; Number of bars to draw
  .draw_gradient:
    mov cx, SCREEN_WIDTH*4              ; Number of pixels high for each bar
    rep stosw                           ; Write to the VGA memory
    cmp dl, 0x8                         ; Check if we are in the middle
    jl .down                            ; If not, decrease
    inc al                              ; Increase color in right pixel
    jmp .up
    .down:
    dec al                              ; Decrease color in left pixel
    .up:
   xchg al, ah                         ; Swap colors (left/right pixel)
    dec dl                              ; Decrease number of bars to draw
    jg .draw_gradient                   ; Loop until all bars are drawn
ret

; =========================================== DRAW RLE IMAGE ================|80
; IN:
;   SI - Image data address
;   DI - Position
draw_rle_image:
  push es
  push ds

  push cs                               ; Code segment
  pop ds

  push SEGMENT_DBUFFER
  pop es

  xor dx, dx
  .image_loop:
    lodsb                               ; Load number of pixels to repeat
    cmp ax, 0                           ; Check if end of image
    je .done                            ; Exit if end
    cmp di, SCREEN_WIDTH*SCREEN_HEIGHT
    jae .done

    mov cx, ax                          ; Save to CX
    add dx, ax                          ; Add to line pixel counter

    lodsb                               ; Load pixel color
    cmp ax, 0
    je .skip_pixels

    rep stosb                           ; Push pixels (CX times)
    jmp .copied
    .skip_pixels:
      add di, cx
    .copied:
    cmp dx, SCREEN_WIDTH                ; Check if we fill full line
    jl .continue                        ; Continue if not
    add di, SCREEN_WIDTH                ; Jump interlaced line
    xor dx, dx                          ; Zero line counter
    .continue:

    jmp .image_loop                      ; Continu if not
    .done:
    pop ds
    pop es
ret

; =========================================== DRAW WINDOW ===================|80
; AX - Position of top/left corner; high:Y, low:X
; BX - Size of window; high: height, low: width
; Window is drown over 8x8 grid in sprites size (16px each). Uses 9 tiles for
; drawing the window.
draw_window:
  pusha

  push bx

  xor di, di
  xor bx, bx
  mov bl, ah                            ; Y coord from high bits
  shl bx, 0x3                           ; Y * 8 (grid size)
  mov dx, bx                            ; make copy of Y
  shl bx, 8                             ; Y * 256
  shl dx, 6                             ; Y * 64
  add bx, dx                            ; BX = Y * 320
  and ax, 0x00FF                        ; X, remove high bits, keep low bits
  shl ax, 0x3                           ; X * 8 (grid size)
  add bx, ax                            ; Add X to coords
  add di, bx                            ; Move to destination index

  pop bx
  movzx cx, bl                    ; CX = width
  movzx dx, bh                    ; DX = height

  mov si, Patch9Dict

  ; top part

  ; corner
  mov al, [si]
  call draw_sprite
  add di, SPRITE_SIZE

  ; middle
  mov al, [si+1]
  mov bx, cx
  dec bx
  dec bx
  jle .no_top_fill
  .top_loop:
    call draw_sprite
    add di, SPRITE_SIZE
    dec bx
    jg .top_loop
  .no_top_fill:

  ; corner
  mov al, [si+2]
  call draw_sprite
  add di, SPRITE_SIZE

  add di, SCREEN_WIDTH*SPRITE_SIZE
  mov bx, cx
  shl bx, 4
  sub di, bx

  ; middle part
  mov bx, dx
  dec bx
  dec bx
  jle .no_middle

  .middle_row_loop:
    mov al, [si+3]
    call draw_sprite
    add di, SPRITE_SIZE

    mov al, [si+4]
    push cx
    dec cx
    dec cx
    jle .no_mid_fill
    .mid_loop:
      call draw_sprite
      add di, SPRITE_SIZE
    loop .mid_loop
    .no_mid_fill:
    pop cx

    mov al, [si+5]
    call draw_sprite
    add di, SPRITE_SIZE

    push cx
    add di, SCREEN_WIDTH*SPRITE_SIZE
    shl cx, 4
    sub di, cx
    pop cx

    dec bx
    jg .middle_row_loop
  .no_middle:


  ; corner
  mov al, [si+6]
  call draw_sprite
  add di, SPRITE_SIZE

  ; middle
  mov al, [si+7]
  dec cx
  dec cx
  jle .no_bottom_fill
  .bottom_loop:
    call draw_sprite
    add di, SPRITE_SIZE
    loop .bottom_loop
  .no_bottom_fill:

  ; corner
  mov al, [si+8]                        ; corner
  call draw_sprite

  popa
  ret

; =========================================== GENERATE MAP ==================|80
; Generates the procedural map using simple rules (TerrainRules)
; Rules defines what type of tiles can be generated next to each other
; Fore each tile type 4 corresponding types are defined.
; For 10 tiles, 10 entries are defined (each holding 4 bytes)
; Algorithm selects for each cell up or left tile next to it and checks in the
; defined array what can be placed. Selects randomly new tile. Moves to next.
; First tile in a colum is selected randomely as there is nothing on the left.
; Same for the first top row of tiles.
; Lastly it goes thru newely generated map and sets metadata (traversal cells)
; and clears other data layers for safety (if generated on populated memory)
generate_map:
  push es

  push cs                               ; GAME CODE SEGMENT
  pop es

  xor di, di
  mov si, TerrainRules
  mov cx, MAP_SIZE                      ; Height
  .next_row:
    mov dx, MAP_SIZE                    ; Width
    .next_col:
      push cx
      call get_random                   ; AX is random value
      pop cx                            ; restore loop counter
      and ax, TERRAIN_RULES_CROP        ; Crop to 0-7
      mov [fs:di], al                   ; Save terrain tile
      cmp dx, MAP_SIZE                  ; Check if first col
      je .skip_cell
      cmp cx, MAP_SIZE                  ; Check if first row
      je .skip_cell
      movzx bx, [fs:di-1]               ; Get left tile
      test al, 0x1                      ; If odd value skip checking top
      jz .skip_top
      movzx bx, [fs:di-MAP_SIZE]        ; Get top tile
      .skip_top:
      shl bx, 3                         ; Mul by 4 to fit rules table
      add bx, ax                        ; Get random rule for the tile ID
      mov al, [es:si+bx]                ; Get the tile ID from rules table
      mov [fs:di], al                   ; Save terrain tile
      .skip_cell:
      inc di                            ; Next map tile cell
      dec dx                            ; Next column (couner is top-down)
    jnz .next_col
  loop .next_row

  .set_metadata:
    xor di, di
    xor bx, bx
    mov cx, MAP_SIZE*MAP_SIZE
    .background_cell:
      mov byte [fs:di + FG], 0x0        ; Clear foreground data
      mov byte [fs:di + META], 0x0      ; Clears metadata
      mov bl, byte [fs:di]

      cmp bl, TILE_ROCKS_0    ; Last traversal sprite id
      jge .skip_traversal               ; If greater, skip
      or byte [fs:di], TERRAIN_TRAVERSAL_MASK
      .skip_traversal:

      .add_resource:
      test cx, 0xF
      jz .skip_resource
      .boundary_check:
        mov ax, di
        mov dx, ax
        and ax, 0x7F                  ; AX = column (di % 128)
        shr dx, 7                     ; DX = row (di / 128)
        cmp ax, 2                     ; col < 2?
        jl .skip_resource
        cmp ax, MAP_SIZE-2            ; col > MAP_SIZE-2?
        jg .skip_resource
        cmp dx, 2                     ; row < 2?
        jl .skip_resource
        cmp dx, MAP_SIZE-2            ; row > MAP_SIZE-2?
        jg .skip_resource

      push cx
      call get_random
      pop cx
      and ax, 0x3f                      ; 0..63
      cmp ax, 0x1                       ; if random is 1 to 63, skip resource
      jge .skip_resource

      cmp bl, TILE_SOIL_2               ; Check the soil to decide on resouce
      jle .spawn_res1
      cmp bl, TILE_SOIL_4
      jle .spawn_res2
      cmp bl, TILE_ROCKS_1
      jle .spawn_res3
      jmp .skip_resource                ; skip if not suitable

      .spawn_res1:
        mov bl, RESOURCE_RES1_MASK
        jmp .spawn_res
      .spawn_res2:
        mov bl, RESOURCE_RES2_MASK
        jmp .spawn_res
      .spawn_res3:
        mov bl, RESOURCE_RES3_MASK

      .spawn_res:
        push cx
        push di

        mov al, 0x7                     ; Add initial 7 amount of resource
        shl al, RESOURCE_AMOUNT_SHIFT
        add bl, al

        sub di, MAP_SIZE*2+2            ; set pointer to 2 tiles left and up
        mov cx, 2                       ; 4 rows
        .spray_row:
          push cx
          call get_random
          mov cx, 2                     ; by 4 columns
          .spray_col:
            test byte [fs:di], RESOURCE_MASK
            jnz .skip_spray             ; Skip if other resource is here
            test ax, cx                 ; cheap pseudo-randominess
            jnz .skip_spray
              mov byte [fs:di + META], bl       ; set resource type + amount
              or byte [fs:di], RESOURCE_MASK    ; set resource mask
            .skip_spray:
            inc di
          loop .spray_col
          add di, MAP_SIZE-2
        pop cx
        loop .spray_row
        pop di
        pop cx

      .skip_resource:
      inc di
    dec cx
    jnz .background_cell

  pop es
  ret

; =========================================== BUILD INITIAL BASE FOUNDATIONS |80
; Sets up initial base foundations, rocket
build_initial_base:
  .set_center_position:
  mov di, MAP_SIZE*MAP_SIZE/2 + MAP_SIZE/2  ; Center of the map

  .build_base:
  mov ax, TILE_FOUNDATION
  mov byte [fs:di], al
  mov byte [fs:di+1], al
  mov byte [fs:di-1], al
  mov byte [fs:di+MAP_SIZE], al
  mov byte [fs:di-MAP_SIZE], al

  add ax, INFRASTRUCTURE_MASK
  mov byte [fs:di], al

  mov ax, CURSOR_ICON_PLACE_BUILDING
  ror al, CURSOR_TYPE_ROL
  mov byte [fs:di+1 + FG], al
  mov byte [fs:di-1 + FG], al
  mov byte [fs:di+MAP_SIZE + FG], al
  mov byte [fs:di-MAP_SIZE + FG], al

  .place_rocket:
  mov ax, CURSOR_ICON_POINTER
  ror al, CURSOR_TYPE_ROL
  mov bx, ax
  add ax, TILE_ROCKET_BOTTOM_ID
  mov byte [fs:di + FG], al

  call actions_logic.update_radar_visibility

  ret

; =========================================== DRAW TERRAIN ==================|80
; Draw part of the terrain visible in a viewport
; Set by VIEWPORT_WIDTH, VIEWPORT_HEIGHT
draw_terrain:
  mov si, [_VIEWPORT_Y_]                ; Y coordinate
  shl si, 7                             ; Y * 128
  add si, [_VIEWPORT_X_]                ; Y * 128 + X

  xor di, di

  mov cx, VIEWPORT_HEIGHT
  .draw_line:
    rept VIEWPORT_WIDTH {
      call draw_cell
      add di, SPRITE_SIZE
      inc si
    }

    add di, SCREEN_WIDTH*(SPRITE_SIZE-1)
    add si, MAP_SIZE-VIEWPORT_WIDTH
    dec cx
  jnz .draw_line

  ret

draw_selected_cell:
  push si
  push di

  mov si, bx                ; Calculate map position
  shl si, 7   ; Y * 128
  add si, ax

  sub bx, [_VIEWPORT_Y_]  ; Y - Viewport Y
  shl bx, 4               ; Y * 16
  sub ax, [_VIEWPORT_X_]  ; X - Viewport X
  shl ax, 4               ; X * 16
  mov dx, bx      ; make copy of Y
  shl bx, 8       ; Y * 256
  shl dx, 6       ; Y * 64
  add bx, dx      ; BX = Y * 320
  add bx, ax              ; Y * 16 * 320 + X * 16
  mov di, bx              ; Move result to DI

  call draw_cell

  pop di
  pop si
  ret

draw_single_cell:
  push si
  push di

  .calculate_position:
    mov ax, di
    mov bx, di
    shr bx, 7
    push bx
    shl bx, 7
    sub ax, bx ; ax = x
    pop bx  ; bx = y

  .clip_viewport:
    cmp ax, [_VIEWPORT_X_]
    jb .skip_drawing                    ; x < viewport x
    cmp bx, [_VIEWPORT_Y_]
    jb .skip_drawing                    ; y < viewport y
    mov cx, [_VIEWPORT_X_]
    add cx, VIEWPORT_WIDTH
    cmp ax, cx
    jae .skip_drawing                    ; x >= viewport x
    mov cx, [_VIEWPORT_Y_]
    add cx, VIEWPORT_HEIGHT
    cmp bx, cx
    jae .skip_drawing                    ; y >= viewport y

  .calculate_memory_position:
    sub bx, [_VIEWPORT_Y_]
    shl bx, 4
    sub ax, [_VIEWPORT_X_]
    shl ax, 4
    mov dx, bx      ; make copy of Y
    shl bx, 8       ; Y * 256
    shl dx, 6       ; Y * 64
    add bx, dx      ; BX = Y * 320
    add bx, ax
    mov di, bx

  call draw_cell

  .skip_drawing:
  pop di
  pop si
  ret

draw_cell:
  test byte [fs:si + META], RADAR_VISIBILITY_MASK
  jnz .radar_visible
    mov ax, TILE_FOG_OF_WAR
    call draw_tile
    ret
  .radar_visible:
  mov al, [fs:si]
  mov bl, al
  and al, BACKGROUND_SPRITE_MASK
  call draw_tile
  and bl, TERRAIN_SECOND_LAYER_DRAW_MASK
  cmp bl, 0x0
  jz .skip_foreground
  .draw_forground:

    .draw_foreground_sprite:
      mov al, [fs:si + FG]
      and al, FOREGROUND_SPRITE_MASK
      add al, TILE_FOREGROUND_SHIFT
      call draw_sprite

    mov dl, [fs:si]
    test dl, INFRASTRUCTURE_MASK
    jnz .skip_resource

    test dl, RESOURCE_MASK
    jz .skip_resource
      call draw_resource_sprite_from_si
      jmp .skip_foreground
    .skip_resource:

    .draw_rails_stuff:
      test dl, RAIL_MASK                ; DL - Background layer
      jz .skip_rails_stuff

    .draw_switch:
      mov al, [fs:si + META]
      test al, SWITCH_MASK
      jz .skip_switch
        and al, TILE_DIRECTION_MASK
        add al, TILE_SWITCH_LEFT
        call draw_sprite
      .skip_switch:

    .draw_cart:
      test byte [fs:si + FG], CART_DRAW_MASK
      jz .skip_cart
        mov bl, [fs:si + META]
        and bl, CART_DIRECTION_MASK
        shr bl, CART_DIRECTION_SHIFT
        mov al, TILE_CART_HORIZONTAL
        test bl, 1
        jz .skip_vertical
        mov al, TILE_CART_VERTICAL
        .skip_vertical:

        call draw_sprite

        .draw_cart_resource:
          mov al, [fs:si + META]
          and al, RESOURCE_TYPE_MASK
          jz .skip_cart_resource
            shr al, RESOURCE_TYPE_SHIFT ; 1..3
            dec al                      ; 0..2
            shl al, 1                   ; 0,2,4
            mov ah, bl                  ; ver/hor
            and ah, 1                   ; 1 ver, 0 horizontal
            xor ah, 1                   ; 0 ver, 1 horizontal
            add al, ah                  ; correct sprite
            add al, TILE_ORE_WHITE_V    ; first of ore sprite
            call draw_sprite
          .skip_cart_resource:
      .skip_cart:
    .skip_rails_stuff:

  .skip_foreground:
  ret

; =================================== RECALCULATE RAILS =====================|80
; DI - Position on map
recalculate_rails:
  xor ax, ax
  test byte [fs:di], RAIL_MASK
  jz .update_cursor

  .test_up:
    test byte [fs:di-MAP_SIZE], RAIL_MASK
    jz .test_right
    add al, 0x8
  .test_right:
    test byte [fs:di+1], RAIL_MASK
    jz .test_down
    add al, 0x4
  .test_down:
  test byte [fs:di+MAP_SIZE], RAIL_MASK
  jz .test_left
    add al, 0x2
  .test_left:
  test byte [fs:di-1], RAIL_MASK
  jz .done_calculating
    add al, 0x1
  .done_calculating:
  mov dl, al                            ; Save connection pattern for switch

  .get_correct_rail_sprite:
    push ds
    push cs                             ; GAME CODE SEGMENT
    pop ds
    mov bx, RailroadsDict
    xlatb                               ;  DS:[BX + AL]
    pop ds
    add al, TILE_RAILS_1                ; Shift to first railroad tiles
    sub al, TILE_FOREGROUND_SHIFT

  .save_rail_sprite:
    and byte [fs:di + FG], 0xFF - FOREGROUND_SPRITE_MASK
    add byte [fs:di + FG], al

  .calculate_correct_switch:
    cmp dl, 0x7
    je .prepare_switch_horizontal
    cmp dl, 0xB
    je .prepare_switch_vertical
    cmp dl, 0x0D
    je .prepare_switch_horizontal
    cmp dl, 0x0E
    je .prepare_switch_vertical
    cmp dl, 0x05
    je .prepare_station
    cmp dl, 0x0A
    je .prepare_station
    jmp .prepare_no_switch

  .prepare_switch_horizontal:
    mov dl, SWITCH_MASK                 ; 0 for left switch ID + enable switch
    mov ax, CURSOR_ICON_EDIT
    jmp .save_switch
  .prepare_switch_vertical:
    mov dl, 1                           ; down switch ID
    add dl, SWITCH_MASK                 ; enable switch
    mov ax, CURSOR_ICON_EDIT
    jmp .save_switch
  .prepare_station:
    cmp byte [fs:di], TILE_STATION + RAIL_MASK  ; Check for station
    jz .done
    mov dl, 0                           ; No switch
    mov ax, CURSOR_ICON_PLACE_BUILDING
    test byte [fs:di], INFRASTRUCTURE_MASK  ; Check if its a station
    jz  .save_switch
    mov ax, CURSOR_ICON_EDIT
    jmp .save_switch
  .prepare_no_switch:
    mov dl, 0                           ; No switch, or last rail (no station)
    mov ax, CURSOR_ICON_POINTER

  .save_switch:
    and byte [fs:di + META], 0xFF - SWITCH_DATA_MASK
    add byte [fs:di + META], dl
    and byte [fs:di + FG], 0xFF - CURSOR_TYPE_MASK  ; clear cursor
    ror al, CURSOR_TYPE_ROL
    add byte [fs:di + FG], al
    jmp .done

  .update_cursor:
    mov al, [fs:di]
    test al, TERRAIN_TRAVERSAL_MASK
    jz .done
    mov bl, al
    and bl, TERRAIN_SECOND_LAYER_DRAW_MASK
    cmp bl, 0x0
    jnz .done

    mov ax, CURSOR_ICON_PLACE_RAIL
    ror al, CURSOR_TYPE_ROL
    mov byte [fs:di + FG], al

  .done:
    or byte [fs:di + META], RADAR_VISIBILITY_MASK
  ret

; =========================================== DECOMPRESS SPRITE ============|80
; SI - Compressed sprite data address
; DI - sprites memory data address
; Sprite decompression to memory at SEGMENT_SPRITES
decompress_sprite:
  lodsb
  movzx dx, al   ; save palette
  shl dx, 2      ; multiply by 4 (palette size)

  mov cx, SPRITE_SIZE   ; Sprite width
  .plot_line:
    push cx           ; Save lines
    lodsw             ; Load 16 pixels

    mov cx, SPRITE_SIZE      ; 16 pixels in line
    .draw_pixel:
      cmp cx, SPRITE_SIZE/2
      jnz .cont
        lodsw
      .cont:
      rol ax, 2        ; Shift to next pixel

      mov bx, ax     ; Saves word
      and bx, 0x3    ; Cut last 2 bits
      add bx, dx     ; add palette shift
      mov byte bl, [Palettes+bx] ; get color from palette
      push es
      push SEGMENT_SPRITES
      pop es
      mov byte [es:di], bl  ; Write pixel color
      inc di
      pop es      ; Move destination to next pixel
    loop .draw_pixel

  pop cx                   ; Restore line counter
  loop .plot_line
  ret

; =========================================== DECOMPRESS ALL TILES ==========|80
; Decompressing all tiles and sprites (transparent pixel)
decompress_all_tiles:
  push es
  push cs                               ; GAME CODE SEGMENT
  pop es
  mov si, Tiles
  .decompress_next:
    cmp byte [es:si], 0xFF
    jz .done
    call decompress_sprite
  jmp .decompress_next
  .done:
  pop es
  ret

; =========================================== DRAW TILE =====================|80
; IN: SI - Tile data
; AL - Tile ID
; DI - Position
; Drawing opaque tile on screen
draw_tile:
  pusha
  push ds

  push SEGMENT_SPRITES
  pop ds

  mov ah, al                            ; Quick multiply by 256 by copying
                                        ; low byte to highbyte and then clean
                                        ; low byte. Same as shifting 8 times.
  xor al, al                            ; Clear low nibble
  mov si, ax                            ; Point to tile data
  mov bx, SPRITE_SIZE
  .draw_tile_line:
    movsd                               ; Move 4px at a time
    movsd
    movsd
    movsd
    add di, SCREEN_WIDTH-SPRITE_SIZE    ; Next line
    dec bx
  jnz .draw_tile_line

  pop ds
  popa
  ret

; =========================================== DRAW SPRITE ===================|80
; AL - Sprite ID
; DI - Position
; Drawing transparent sprite on screen
draw_sprite:
  pusha
  push ds

  push SEGMENT_SPRITES
  pop ds

  mov ah, al        ; Multiply by 256 (tile size in array) by swapping nibles
  xor al, al        ; clear low nibble
  mov si, ax        ; Point to tile data
  mov bx, SPRITE_SIZE
  .draw_tile_line:
    rept SPRITE_SIZE/2 {                ; Half the width as we draw 2 pixels
      lodsw                             ; Read two pixels
      test al, al                       ; test if color is transparent (0)
      jz $+5
      mov byte [es:di], al              ; Draw first pixel
      inc di                            ; Next pixel pos
      test ah, ah                       ; Test if color is transparent (0)
      jz $+5
      mov byte [es:di], ah              ; Draw second pixel
      inc di                            ; Next pixel pos
    }
    add di, SCREEN_WIDTH-SPRITE_SIZE ; Next line
    dec bx
  jnz .draw_tile_line

  pop ds
  popa
  ret

; =========================================== UI SUBSYSTEM ==================|80
ui:
    .draw_footer:
    mov di, UI_FOOTER_POS

    mov cx, 320
    mov al, COLOR_WHITE
    mov ah, al
    rep stosw

    mov dx, UI_FOOTER_HEIGHT-2
    .stripes_loop:
      mov cx, 320/2
      mov al, COLOR_DEEP_PURPLE
      mov ah, al
      rep stosw
      mov cx, 320/2
      mov al, COLOR_NAVY_BLUE
      mov ah, al
      rep stosw
    dec dx
    jnz .stripes_loop
    ret

  .draw_stats:
    mov di, UI_STATS_POS
    mov al, TILE_UI_HEADER
    mov cx, 4
    .bg1:
      call draw_sprite
      add di, SPRITE_SIZE
    loop .bg1

    mov di, UI_STATS_POS
    mov al, TILE_RES_WHITE_MAX
    call draw_sprite
    mov si, [_ECONOMY_WHITE_RES_]       ; White resource count
    mov dx, UI_STATS_TXT_POS
    mov bl, COLOR_WHITE
    mov cx, 10000
    call font.draw_number

    add di, 80
    push di
    mov al, TILE_UI_HEADER
    mov cx, 4
    .bg2:
      call draw_sprite
      add di, SPRITE_SIZE
    loop .bg2
    mov al, TILE_RES_BLUE_MAX
    pop di
    call draw_sprite
    mov si, [_ECONOMY_BLUE_RES_]       ; Blue resource count
    add dl, 0xA
    mov bl, COLOR_WHITE
    mov cx, 10000
    call font.draw_number

    add di, 80
    push di
    mov al, TILE_UI_HEADER
    mov cx, 4
    .bg3:
      call draw_sprite
      add di, SPRITE_SIZE
    loop .bg3
    mov al, TILE_RES_GREEN_MAX
    pop di
    call draw_sprite
    mov si, [_ECONOMY_GREEN_RES_]       ; Green resource count
    add dl, 0xA
    mov bl, COLOR_WHITE
    mov cx, 10000
    call font.draw_number

    ret

  .calculate_mouse_cursor:
    mov ax, 0x0003
    int 0x33

    .check_buttons_clicks:
      cmp byte [_MOUSE_LOCK_], 1
      jz .check_if_lock_needed

      cmp bl, 0
      jz .mouse_done

      .mouse_new_click:
        mov byte [_MOUSE_BUTTONS_], bl      ; Save mouse button state
        mov byte [_MOUSE_LOCK_], 1
        jmp .mouse_done

      .check_if_lock_needed:
        cmp bl, 0
        jnz .reset_mouse_click
        mov byte [_MOUSE_LOCK_], 0
        .reset_mouse_click:
        mov byte [_MOUSE_BUTTONS_], 0
    .mouse_done:

    .clamp_cursor_position:
      cmp cx, 0
      jl .not_update
      cmp cx, SCREEN_WIDTH-1
      jge .not_update
      cmp dx, 0
      jl .not_update
      cmp dx, SCREEN_HEIGHT-1
      jge .not_update

    .convert_to_grid:
      add dx, 0x03                        ; Shift cursor center
      add cx, 0x02
      shr dx, 4
      shr cx, 4
      mov word [_MOUSE_TILE_POS_X_], cx
      mov word [_MOUSE_TILE_POS_Y_], dx

    cmp byte [_GAME_STATE_], STATE_GAME
    jnz .not_update

    .update_values:
      add cx, [_VIEWPORT_X_]
      add dx, [_VIEWPORT_Y_]
      mov ax, [_CURSOR_X_]
      mov bx, [_CURSOR_Y_]
      mov word [_CURSOR_X_OLD_], ax
      mov word [_CURSOR_Y_OLD_], bx
      mov [_CURSOR_X_], cx
      mov [_CURSOR_Y_], dx
    .not_update:
  ret

  .draw_mouse_cursor:
    mov ax, 0x0003
    int 0x33

    cmp cx, 0
    jl .outside_left
    cmp cx, SCREEN_WIDTH-SPRITE_SIZE
    jge .outside_right
    cmp dx, 0
    jl .outside_top
    cmp dx, SCREEN_HEIGHT-SPRITE_SIZE
    jge .outside_bottom
    jmp .fixed_clipping

    .outside_left:
      xor cx, cx
      jmp .fixed_clipping
    .outside_right:
      mov cx, SCREEN_WIDTH-SPRITE_SIZE
      jmp .fixed_clipping
    .outside_top:
      xor dx, dx
      jmp .fixed_clipping
    .outside_bottom:
      mov dx, SCREEN_HEIGHT-SPRITE_SIZE
      jmp .fixed_clipping

    .fixed_clipping:

    mov bx, dx
    shl bx, 8                           ; Y * 256
    shl dx, 6                           ; Y * 64
    add bx, dx                          ; BX = Y * 320
    add bx, cx                          ; Y * 16 * 320 + X * 16
    mov di, bx                          ; Move result to DI

    mov al, TILE_CURSOR_MOUSE

    push es
    push SEGMENT_VGA
    pop es
    call draw_sprite
    pop es
  ret

  .draw_game_cursor:
    cmp word [_MOUSE_TILE_POS_Y_], 1
    jl .done
    cmp word [_MOUSE_TILE_POS_Y_], VIEWPORT_HEIGHT-2
    jg .done
    cmp word [_MOUSE_TILE_POS_X_], 1
    jl .done
    cmp word [_MOUSE_TILE_POS_X_], VIEWPORT_WIDTH-2
    jg .done

    mov si, [_CURSOR_Y_]    ; Absolute Y map coordinate
    shl si, 7               ; Y * 128 (optimized shl for *128)
    add si, [_CURSOR_X_]    ; + absolute X map coordinate

    mov bx, [_CURSOR_Y_]    ; Y coordinate
    sub bx, [_VIEWPORT_Y_]  ; Y - Viewport Y
    shl bx, 4               ; Y * 16
    mov ax, [_CURSOR_X_]    ; X coordinate
    sub ax, [_VIEWPORT_X_]  ; X - Viewport X
    shl ax, 4               ; X * 16
    mov dx, bx      ; make copy of Y
    shl bx, 8       ; Y * 256
    shl dx, 6       ; Y * 64
    add bx, dx      ; BX = Y * 320
    add bx, ax              ; Y * 16 * 320 + X * 16
    mov di, bx              ; Move result to DI

    mov al, [fs:si + FG]
    and al, CURSOR_TYPE_MASK
    rol al, CURSOR_TYPE_ROL
    add al, TILE_CURSOR_MOUSE
    mov bl, al

    test byte [fs:si], INFRASTRUCTURE_MASK ; If not a building then skip arrows
    jz .no_infra

    test byte [fs:si + FG], CURSOR_TYPE_MASK   ; If it's a pointer then skip arrows
    jz .no_infra

    mov al, [fs:si + META]
    and al, TILE_DIRECTION_MASK
    add al, TILE_IO_RIGHT

    push es
    push SEGMENT_VGA
    pop es
    call draw_sprite                      ; draw the in/out arrow
    pop es

    jmp .done

    .no_infra:
      test byte [fs:si + FG], CURSOR_TYPE_MASK
      jz .done                          ; skip default cursor
      push es
      push SEGMENT_VGA
      pop es
      call draw_sprite                    ; draw cursor
      pop es
    .done:
    ret

  .draw_radar_map:
    push es

    push SEGMENT_DBUFFER
    pop es

    mov ax, 0x0402
    mov bx, 0x0909
    call draw_window

    mov si, WindowMinimapText
    mov dx, 0x0403
    mov bl, COLOR_WHITE
    call font.draw_string

    .draw_mini_map:
    xor si, si
    mov di, SCREEN_WIDTH*48+24          ; Map position on screen
    xor bx,bx
    mov cx, MAP_SIZE                    ; Columns
    .draw_loop:
      push cx

      mov cx, MAP_SIZE                  ; Rows
      .draw_row:
        mov al, [fs:si]                 ; Load map cell

        and al, BACKGROUND_SPRITE_MASK
        mov bl, al
        mov al, COLOR_BLACK             ; Invisible terrain color
        test byte [fs:si + META], RADAR_VISIBILITY_MASK
        jz .radar_invisible
          mov al, [RadarTerrainColors + bx]
          test byte [fs:si + BG], RAIL_MASK
          jz .skip_rail_color
            mov al, COLOR_WHITE         ;  Rails color
          .skip_rail_color:
        .radar_invisible:
          mov [es:di], al               ; Draw 1 pixels

          inc si
        .next_column:
          add di, 1
      loop .draw_row
      pop cx
      add di, 320-MAP_SIZE              ; Move to next row
    loop .draw_loop

    pop es
    ret

; =========================================== AUDIO SYSTEM ==================|80
audio:
  .init:
    push es
    push bx

    mov byte [_SFX_NOTE_INDEX_], 0
    mov byte [_SFX_NOTE_DURATION_], 0
    mov byte [_AUDIO_ENABLED_], TRUE
    mov word [_SFX_POINTER_], SFX_NULL

    mov al, 182                          ; Binary mode, square wave, 16-bit divisor
    out 43h, al                          ; Write to PIT command register

    xor ax, ax
    mov es, ax
    mov bx, [es:08h*4]                  ; Get offset
    mov [_SFX_IRQ_OFFSET_], bx
    mov bx, [es:08h*4+2]                ; Get segment
    mov [_SFX_IRQ_SEGMENT_], bx

    cli                                  ; Disable interrupts
    mov word [es:08h*4], audio.irq_handler
    mov [es:08h*4+2], cs
    sti                                  ; Enable interrupts

    pop bx
    pop es
    ret

  .destroy:
    call audio.stop_sound_irq

    xor ax, ax
    mov es, ax
    cli                                   ; Atomic operation
      mov ax, [_SFX_IRQ_OFFSET_]
      mov [es:08h*4], ax
      mov ax, [_SFX_IRQ_SEGMENT_]
      mov [es:08h*4+2], ax
    sti
    ret

  .irq_handler:
    push ds

    push cs
    pop ds

    cmp byte [_AUDIO_ENABLED_], FALSE
    je .skip_audio
      call audio.irq_update
    .skip_audio:
      pop ds

      jmp far [cs:_SFX_IRQ_OFFSET_]

  .irq_update:
    push ax
    push bx
    push si

    mov si, [_SFX_POINTER_]
    cmp si, SFX_NULL
    je .stop_all_sound

    mov bl, [_SFX_NOTE_INDEX_]
    xor bh, bh
    add si, bx
    mov al, [si]

    test al, al
    jz .end_sfx

  .play_note:
    test al, al
    jz .rest

    movzx bx, al
    shl bx, 1                             ; Multiply by 2 (word size)
    mov si, NoteTable
    add si, bx
    mov ax, [si]

    cmp ax, 0xFFFF
    je .rest

    push ax
    mov al, 182                           ; Prepare timer
    out 43h, al
    pop ax

    out 42h, al                           ; Low byte
    mov al, ah
    out 42h, al                           ; High byte

    in al, 61h
    or al, 00000011b
    out 61h, al
    jmp .done_play

    .rest:
      call audio.stop_sound_irq

    .done_play:

    inc byte [_SFX_NOTE_INDEX_]
    jmp .done_irq_update

    .end_sfx:
      mov word [_SFX_POINTER_], SFX_NULL
      mov byte [_SFX_NOTE_INDEX_], 0

    .stop_all_sound:
      call audio.stop_sound_irq

    .done_irq_update:
    pop si
    pop bx
    pop ax
    ret

  .stop_sound_irq:
    in al, 61h
    and al, 11111100b                    ; Clear bits 0-1
    out 61h, al
    ret

  .play_sfx:
    cli                                  ; Atomic operation
    mov [_SFX_POINTER_], bx
    mov byte [_SFX_NOTE_INDEX_], 0
    mov byte [_SFX_NOTE_DURATION_], 0
    sti
    ret

; =========================================== LOGIC FOR GAME STATES =========|80

; This table needs to corespond to the STATE_ variables IDs
StateJumpTable:
  dw init_engine
  dw exit
  dw live_p1x_screen_cine
  dw init_p1x_screen
  dw live_p1x_screen
  dw init_pmkc_screen_cine
  dw live_pmkc_screen_cine
  dw init_pmkc_screen
  dw live_pmkc_screen
  dw init_title_screen
  dw live_title_screen
  dw init_title_screen_cine
  dw live_title_screen_cine
  dw init_menu
  dw live_menu
  dw init_briefing
  dw live_briefing
  dw init_briefing_cine
  dw live_briefing_cine
  dw init_story
  dw live_story
  dw init_landing
  dw live_landing
  dw new_game
  dw init_game
  dw live_game
  dw init_debug_view
  dw live_debug_view
  dw init_help
  dw live_help
  dw init_window
  dw live_window

; Transition between major states
StateTransitionTable:

  db STATE_P1X_SCREEN_CINE,     KB_ESC,   STATE_QUIT
  db STATE_P1X_SCREEN_CINE,     KB_ENTER, STATE_P1X_SCREEN_INIT
  db STATE_P1X_SCREEN_CINE,     MOUSE_LEFT_BUTTON, STATE_P1X_SCREEN_INIT
  db STATE_P1X_SCREEN,          KB_ESC,   STATE_QUIT
  db STATE_P1X_SCREEN,          KB_ENTER, STATE_PMKC_SCREEN_CINE_INIT
  db STATE_P1X_SCREEN,          MOUSE_LEFT_BUTTON, STATE_PMKC_SCREEN_CINE_INIT
  db STATE_PMKC_SCREEN_CINE,    KB_ESC,   STATE_QUIT
  db STATE_PMKC_SCREEN_CINE,    KB_ENTER, STATE_PMKC_SCREEN_INIT
  db STATE_PMKC_SCREEN_CINE,    MOUSE_LEFT_BUTTON, STATE_PMKC_SCREEN_INIT
  db STATE_PMKC_SCREEN,         KB_ESC,   STATE_QUIT
  db STATE_PMKC_SCREEN,         KB_ENTER, STATE_TITLE_SCREEN_INIT
  db STATE_PMKC_SCREEN,         MOUSE_LEFT_BUTTON, STATE_TITLE_SCREEN_INIT
  db STATE_TITLE_SCREEN,        KB_ESC,   STATE_QUIT
  db STATE_TITLE_SCREEN,        KB_ENTER, STATE_TITLE_SCREEN_CINE_INIT
  db STATE_TITLE_SCREEN,        MOUSE_LEFT_BUTTON, STATE_TITLE_SCREEN_CINE_INIT
  db STATE_TITLE_SCREEN_CINE,   KB_ESC,   STATE_QUIT
  db STATE_TITLE_SCREEN_CINE,   KB_ENTER, STATE_MENU_SCREEN_INIT
  db STATE_TITLE_SCREEN_CINE,   MOUSE_LEFT_BUTTON, STATE_MENU_SCREEN_INIT
  db STATE_STORY_SCREEN,        KB_ESC,   STATE_MENU_SCREEN_INIT
  db STATE_STORY_SCREEN,        KB_ENTER, STATE_LANDING_INIT
  db STATE_STORY_SCREEN,        MOUSE_LEFT_BUTTON, STATE_LANDING_INIT
  db STATE_LANDING,             KB_ESC,   STATE_MENU_SCREEN_INIT
  db STATE_LANDING,             MOUSE_RIGHT_BUTTON,   STATE_MENU_SCREEN_INIT
  db STATE_MENU_SCREEN,         KB_ESC,   STATE_TITLE_SCREEN_INIT
  db STATE_BRIEFING,            KB_ESC,   STATE_MENU_SCREEN_INIT
  db STATE_BRIEFING_CINE,       MOUSE_LEFT_BUTTON,   STATE_BRIEFING_INIT
  db STATE_BRIEFING,            MOUSE_RIGHT_BUTTON,   STATE_MENU_SCREEN_INIT
  db STATE_HELP,                KB_ESC,   STATE_MENU_SCREEN_INIT
  db STATE_GAME,                KB_ESC,   STATE_MENU_SCREEN_INIT
  db STATE_DEBUG_VIEW,          KB_ESC,   STATE_MENU_SCREEN_INIT
  db STATE_MENU_SCREEN,         MOUSE_RIGHT_BUTTON,   STATE_TITLE_SCREEN_INIT
  db STATE_HELP,                MOUSE_RIGHT_BUTTON,   STATE_MENU_SCREEN_INIT
  db STATE_DEBUG_VIEW,          MOUSE_RIGHT_BUTTON,   STATE_MENU_SCREEN_INIT
  db STATE_STORY_SCREEN,        MOUSE_RIGHT_BUTTON,   STATE_MENU_SCREEN_INIT
StateTransitionTableEnd:

; In state keyboard handling
InputTable:
  db STATE_GAME,                        SCENE_MODE_ANY, KB_UP
  dw game_logic.move_viewport_up
  db STATE_GAME,                        SCENE_MODE_ANY, KB_DOWN
  dw game_logic.move_viewport_down
  db STATE_GAME,                        SCENE_MODE_ANY, KB_LEFT
  dw game_logic.move_viewport_left
  db STATE_GAME,                        SCENE_MODE_ANY, KB_RIGHT
  dw game_logic.move_viewport_right
  db STATE_GAME,                        SCENE_MODE_ANY, MOUSE_LEFT_BUTTON
  dw game_logic.build_action
  db STATE_GAME,                        SCENE_MODE_ANY, MOUSE_RIGHT_BUTTON
  dw game_logic.change_action
  db STATE_GAME,                        SCENE_MODE_ANY, KB_ENTER
  dw game_logic.change_action

  db STATE_MENU_SCREEN,                        SCENE_MODE_ANY, KB_UP
  dw menu_logic.selection_up
  db STATE_MENU_SCREEN,                        SCENE_MODE_ANY, KB_DOWN
  dw menu_logic.selection_down
  db STATE_MENU_SCREEN,                        SCENE_MODE_ANY, KB_ENTER
  dw menu_logic.main_menu_enter
  db STATE_MENU_SCREEN,                        SCENE_MODE_ANY, MOUSE_LEFT_BUTTON
  dw menu_logic.main_menu_enter

  db STATE_WINDOW,                      SCENE_MODE_ANY, KB_UP
  dw menu_logic.selection_up
  db STATE_WINDOW,                      SCENE_MODE_ANY, KB_DOWN
  dw menu_logic.selection_down
  db STATE_WINDOW,                      SCENE_MODE_ANY, KB_ENTER
  dw menu_logic.game_menu_enter
  db STATE_WINDOW,                      SCENE_MODE_ANY, MOUSE_LEFT_BUTTON
  dw menu_logic.game_menu_enter
  db STATE_WINDOW,                      SCENE_MODE_ANY, MOUSE_RIGHT_BUTTON
  dw menu_logic.close_window
  db STATE_WINDOW,                      SCENE_MODE_ANY, KB_ESC
  dw menu_logic.close_window

  db STATE_BRIEFING,                    SCENE_MODE_ANY, KB_UP
  dw menu_logic.selection_up
  db STATE_BRIEFING,                    SCENE_MODE_ANY, KB_DOWN
  dw menu_logic.selection_down
  db STATE_BRIEFING,                    SCENE_MODE_ANY, KB_ENTER
  dw menu_logic.game_menu_enter
  db STATE_BRIEFING,                    SCENE_MODE_ANY, MOUSE_LEFT_BUTTON
  dw menu_logic.game_menu_enter

  db STATE_HELP,                        SCENE_MODE_ANY, KB_ENTER
  dw ror_help_page
  db STATE_HELP,                        SCENE_MODE_ANY, MOUSE_LEFT_BUTTON
  dw ror_help_page
InputTableEnd:

; =========================================== WINDOWS DEFINITIONS ===========|80



; height/width, Y/X, title, menu entry array, corresponding logic array
WindowDefinitionsArray:
dw 0x050C, 0x0C09, WindowMainMenuText, MainMenuSelectionArrayText, MainMenuLogicArray
dw 0x090C, 0x0408, WindowBaseBuildingsText, WindowBaseSelectionArrayText, WindowBaseLogicArray
dw 0x050C, 0x0C08, WindowRemoteBuildingsText, WindowRemoteSelectionArrayText, WindowRemoteLogicArray
dw 0x030A, 0x100A, WindowStationText, WindowStationSelectionArrayText, WindowStationLogicArray
dw 0x040B, 0x0E08, WindowBriefingText, WindowBriefingSelectionArrayText, WindowBriefingLogicArray
dw 0x050D, 0x0C08, WindowPODsText, WindowPODsSelectionArrayText, WindowPODsSelectionArray
dw 0x0109, 0x1215, WindowAntennaText, WindowAntennaSelectionArrayText, WindowAntennaSelectionArray
dw 0x050C, 0x0C08, WindowExtractorText, WindowExtractorSelectionArrayText, WindowExtractorSelectionArray
dw 0x030C, 0x1008, WindowExtractInfoText, WindowExtractInfoSelectionArrayText, WindowExtractInfoSelectionArray
dw 0x030C, 0x1008, WindowResourceInfoText, WindowResourceInfoSelectionArrayText, WindowResourceInfoSelectionArray

MainMenuLogicArray:
dw menu_logic.show_brief, 0x0
dw menu_logic.tailset_preview, 0x0
dw menu_logic.help, 0x0
dw menu_logic.quit, 0x0

WindowBaseLogicArray:
dw actions_logic.expand_foundation, 0x0
dw actions_logic.place_building, TILE_BUILDING_COLECTOR_ID
dw actions_logic.place_building, TILE_BUILDING_PODS_ID
dw actions_logic.place_building, TILE_BUILDING_SILOS_ID
dw actions_logic.place_building, TILE_BUILDING_RAFINERY_ID
dw actions_logic.place_building, TILE_BUILDING_LAB_ID
dw actions_logic.place_building, TILE_BUILDING_RADAR_ID
dw menu_logic.close_window, 0x0

WindowRemoteLogicArray:
dw game_logic.change_action, 0x0
dw actions_logic.place_building, TILE_BUILDING_EXTRACTOR_ID
dw actions_logic.place_building, TILE_BUILDING_RADAR_ID
dw menu_logic.close_window, 0x0

WindowStationLogicArray:
dw actions_logic.place_station, 0x0
dw menu_logic.close_window, 0x0

WindowBriefingLogicArray:
dw menu_logic.start_story, 0x0
dw new_game, 0x0
dw menu_logic.back_to_menu, 0x0

WindowPODsSelectionArray:
dw game_logic.change_action, 0x0
dw actions_logic.build_pods_station, 0x0
dw actions_logic.build_pod, 0x0
dw menu_logic.close_window, 0x0

WindowAntennaSelectionArray:
dw menu_logic.close_window, 0x0

WindowExtractorSelectionArray:
dw actions_logic.set_extractor_mode, TILE_EXTRACT_WHITE_ID
dw actions_logic.set_extractor_mode, TILE_EXTRACT_GREEN_ID
dw actions_logic.set_extractor_mode, TILE_EXTRACT_BLUE_ID
dw menu_logic.close_window, 0x0

WindowExtractInfoSelectionArray:
dw actions_logic.set_extractor_mode, TILE_BUILDING_EXTRACTOR_ID
dw menu_logic.close_window, 0x0

WindowResourceInfoSelectionArray:
dw menu_logic.close_window, 0x0

; =========================================== TERRAIN GEN RULES =============|80

; ==============================================================
; TERRAIN RULES – 8 entries per tile (weighted!)
; Random: and ax, 0x07 → 0–7 → pick one of 8 pre-weighted tiles
; More duplicates = higher chance
; Result: ~28% mud, ~52% grass/mudgrass, ~18% bush/trees, ~2% mountains
; ==============================================================

TerrainRules:
db 0,0,1,1, 0,0,1,1
db 1,0,1,0, 1,2,1,2
db 2,0,1,2, 1,2,3,3
db 3,2,1,3, 2,1,4,4
db 4,3,2,4, 3,4,5,5
db 5,5,3,4, 4,6,6,7
db 6,5,5,6, 6,7,6,7
db 7,6,7,7, 7,8,8,8
db 8,7,7,8, 8,9,9,9
db 9,7,8,8, 9,9,9,9
db 10,9,9,10, 10,10,10,10

RadarTerrainColors:
db 0x4          ; soil 0
db 0x4          ; 1
db 0x4          ; 2
db 0x4          ; 3
db 0x4          ; 4
db 0x4          ; 5
db 0x4          ; 6
db 0x9          ; rock 0
db 0x9          ; 1
db 0x9          ; 2
db 0x9         ; 3

; =========================================== DICTS =========================|80

RailroadsDict:
db 0, 0, 1, 4, 0, 0, 3, 9, 1, 6, 1, 10, 5, 7, 8, 2

Patch9Dict:
  db TILE_WINDOW_1, TILE_WINDOW_2, TILE_WINDOW_3   ; top
  db TILE_WINDOW_4, TILE_WINDOW_5, TILE_WINDOW_6   ; middle
  db TILE_WINDOW_1, TILE_WINDOW_2, TILE_WINDOW_3  ; bottom

; =========================================== INCLUDES ======================|80

if INCLUDE_MOUSE_DRIVER
include 'mouse_driver.asm'
end if

include 'text_en.asm'
include 'font.asm'
include 'sfx.asm'
include 'tiles.asm'
include 'img_p1x1.asm'
include 'img_p1x2.asm'
include 'img_p1x3.asm'
include 'img_stars.asm'
include 'img_clouds.asm'
include 'img_planet.asm'
include 'img_planet_big.asm'
include 'img_earth.asm'
include 'img_rocket.asm'
include 'img_city.asm'
include 'img_logo.asm'
include 'img_pmkc.asm'
include 'img_brief.asm'

; =========================================== THE END =======================|80
; Thanks for reading the source code!
; Visit http://smol.p1x.in/assembly/ for more.

BitLogo:
db "P1X"    ; Use HEX viewer to see P1X at the end of binary

; Label marking the end of all code and data
_END_OF_CODE_:
