# Simple Procedural Tune Generator (for `src/sfx.asm` `NoteTable`)

This keeps the system tiny and predictable:

- One shared next-note rule table
- Tiny style profiles for mood (`ENERGETIC`, `SUBTLE`, `LOSE`)
- Front-biased random slot pick (earlier entries happen more)

The runtime note IDs are the same IDs used in `NoteTable` (`NOTE_C2=1` .. `NOTE_D7=63`, `0=REST`).

## 1) Shared rule table: `NextDeltaByPitchClass[12][8]`

Instead of storing absolute next notes for every note, store signed semitone deltas per pitch class.

- 12 rows = pitch class (`C..B`)
- 8 columns = priority slots (`0` highest priority)
- Values are signed semitone moves from current note
- Style filters decide what is finally accepted

Memory cost: `12 * 8 = 96` bytes (if 1 byte per delta).

### Table

Pitch-class order: `C, C#, D, D#, E, F, F#, G, G#, A, A#, B`

```text
; row format: [slot0, slot1, slot2, slot3, slot4, slot5, slot6, slot7]

C :  [ +2,  0, -2, +4, -5, +7, -7, +12 ]
C#: [ +1, -1, +2, -2, +3, -3, +7, -5  ]
D :  [ -2, +2,  0, +3, -4, +5, -7, +12 ]
D#: [ +1, -1, +2, -2, +4, -4, +7, -5  ]
E :  [ -1, +2, -2,  0, +3, -5, +7, -12 ]
F :  [ +2, -2,  0, +3, -4, +5, -7, +12 ]
F#: [ +1, -1, +2, -2, +3, -3, +7, -5  ]
G :  [ +2, -2,  0, +4, -5, +7, -7, +12 ]
G#: [ +1, -1, +2, -2, +3, -4, +7, -5  ]
A :  [ -2, +2,  0, +3, -5, +7, -7, +12 ]
A#: [ +1, -1, +2, -2, +4, -3, +7, -5  ]
B :  [ +1, -2, +2,  0, -1, +5, -7, +12 ]
```

Why this works:

- Early slots mostly step/repeat/small moves (musical and stable)
- Later slots add bigger jumps (more color, less frequent)
- Scale/profile filters remove unwanted notes for each tune type

---

## 2) Tiny style profiles (same table, different feel)

Each profile is a few bytes; no duplicated rule tables needed.

### Profile fields

```text
min_note      ; inclusive NoteTable ID
max_note      ; inclusive NoteTable ID
rest_chance   ; 0..255 (higher = more rests)
max_slot      ; 0..7, highest allowed table slot
dir_bias      ; 0=neutral, 1=up, 2=down
phrase_min    ; min notes in phrase
phrase_max    ; max notes in phrase
dur_mode      ; rhythm preset index (optional)
scale_mask12  ; 12-bit mask for allowed pitch classes
```

Bit mapping for `scale_mask12`:

- bit0=C, bit1=C#, ..., bit11=B
- `1` = allowed pitch class

Useful masks:

- C major / Ionian: `0x0AB5` (`C D E F G A B`)
- C natural minor / Aeolian: `0x05AD` (`C D D# F G G# A#`)

### Example profiles

```text
ENERGETIC:
  min_note=25 (C4)
  max_note=60 (B6)
  rest_chance=12
  max_slot=6
  dir_bias=1 (up)
  phrase_min=8
  phrase_max=16
  dur_mode=0
  scale_mask12=0x0AB5 (major)

SUBTLE:
  min_note=22 (A3)
  max_note=41 (E5)
  rest_chance=40
  max_slot=3
  dir_bias=0 (neutral)
  phrase_min=8
  phrase_max=12
  dur_mode=1
  scale_mask12=0x0AB5 (major)

LOSE_NEGATIVE:
  min_note=13 (C3)
  max_note=36 (B4)
  rest_chance=64
  max_slot=4
  dir_bias=2 (down)
  phrase_min=6
  phrase_max=10
  dur_mode=2
  scale_mask12=0x05AD (natural minor)
```

Notes:

- `max_slot` is a very strong mood control (small = safe, large = jumpy)
- `dir_bias` plus lower range gives easy "sad/falling" behavior for lose stingers

---

## 3) ASM-ish pseudocode (selection + fallback)

This is straight-line logic designed for tiny runtime code.

```text
; Input:
;   cur_note (1..63)
;   profile ptr
; Output:
;   next_note (0..63)

gen_next_note:
  ; 1) Optional rest gate
  r = rand8()
  if r < profile.rest_chance:
    return NOTE_REST

  ; 2) Front-biased slot pick: min(rand, rand)
  a = rand8() & 7
  b = rand8() & 7
  slot = (a < b) ? a : b
  if slot > profile.max_slot:
    slot = profile.max_slot

  ; 3) Pitch class row
  pc = cur_note % 12        ; if using note IDs where C2=1, adjust by -1 first if needed

  ; 4) Try chosen slot, then fallback toward slot 0
try_slot:
  delta = NextDeltaByPitchClass[pc][slot]

  ; optional direction bias
  if profile.dir_bias == UP and delta < 0:
    if slot > 0: slot--; goto try_slot
  if profile.dir_bias == DOWN and delta > 0:
    if slot > 0: slot--; goto try_slot

  cand = cur_note + delta

  ; range check
  if cand < profile.min_note or cand > profile.max_note:
    if slot > 0: slot--; goto try_slot
    cand = cur_note

  ; scale check
  cand_pc = cand % 12
  if ((profile.scale_mask12 >> cand_pc) & 1) == 0:
    if slot > 0: slot--; goto try_slot
    cand = cur_note

  return cand
```

Implementation note for your note IDs:

- In `src/sfx.asm`, `NOTE_C2 = 1` (not `0`), so for pitch class math you may prefer:
  - `pc = (note - 1) % 12`
  - and same for `cand_pc`
  - This maps `C*` notes to pitch class `0` cleanly.

---

## Why this fits your goals

- Smaller than a full per-note absolute table
- Fixed-size row per pitch class (8 entries)
- "Earlier entries = higher weight" achieved naturally via slot selection
- Mood changes come from profile bytes, not duplicated composition logic
