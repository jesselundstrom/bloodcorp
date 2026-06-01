extends Node

# Type scale for all in-game UI text.
# Scene .tscn files cannot reference these constants — update those manually
# when resizing. Scripts must use these constants instead of bare integers.

const SIZE_XXS    := 16   # combat log, HP bar unit names
const SIZE_XS     := 18   # team name chips (top bar)
const SIZE_SM     := 20   # buttons, unit info labels, objective text
const SIZE_MD     := 18   # stat labels (STR/SPD/ARM)
const SIZE_BASE   := 20   # body text, costs, reward/penalty, card buttons
const SIZE_LG     := 22   # requirement text, result reward label
const SIZE_XL     := 24   # card names, result contract label
const SIZE_2XL    := 26   # section headers (YOUR ROSTER, AVAILABLE RECRUITS)
const SIZE_3XL    := 28   # page buttons, sponsor names, credits display
const SIZE_4XL    := 32   # screen titles (SELECT CONTRACT SPONSOR)
const SIZE_5XL    := 40   # page titles (MANAGEMENT)
const SIZE_HERO   := 48   # result overlay (VICTORY / DEFEAT)
const SIZE_DISPLAY := 72  # menu logo (BLOODCORP)
