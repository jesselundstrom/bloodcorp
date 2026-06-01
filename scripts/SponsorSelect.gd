extends Control

const SPONSORS := [
	{
		"name": "OMNICORP",
		"flavor": "Efficiency through elimination. No witnesses, no complications.",
		"type": "kills",
		"requirement_kills": 3,
		"requirement_rounds": 0,
		"requirement_target": "",
		"reward": 600,
		"penalty": 250,
	},
	{
		"name": "HEXBLADE ARMS",
		"flavor": "We want VOSS. Whatever it takes. Leave nothing to chance.",
		"type": "target",
		"requirement_kills": 0,
		"requirement_rounds": 0,
		"requirement_target": "VOSS",
		"reward": 900,
		"penalty": 150,
	},
	{
		"name": "VITAGEN CORP",
		"flavor": "Fast, clean, spectacular. The crowd demands a show — not a siege.",
		"type": "style",
		"requirement_kills": 0,
		"requirement_rounds": 3,
		"requirement_target": "",
		"reward": 750,
		"penalty": 300,
	},
]

const COLOR_BG := Color(0.04, 0.04, 0.07, 1.0)
const COLOR_BORDER := Color(1.0, 0.133, 0.267, 0.6)
const COLOR_ACCENT := Color(0.0, 1.0, 0.8, 1.0)
const COLOR_AMBER := Color(1.0, 0.667, 0.0, 1.0)
const COLOR_RED := Color(1.0, 0.133, 0.267, 1.0)

var _selected_index: int = -1
var _cards: Array = []
var _btn_deploy: Button


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 0)
	add_child(root)

	# Background
	var bg := ColorRect.new()
	bg.color = COLOR_BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.z_index = -1
	add_child(bg)

	# Top bar
	var top_bar := PanelContainer.new()
	_style_panel(top_bar)
	top_bar.custom_minimum_size = Vector2(0, 56)
	root.add_child(top_bar)

	var top_hbox := HBoxContainer.new()
	top_hbox.add_theme_constant_override("separation", 0)
	top_bar.add_child(top_hbox)

	var title_lbl := Label.new()
	title_lbl.text = "SELECT CONTRACT SPONSOR"
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", UITheme.SIZE_4XL)
	title_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	top_hbox.add_child(title_lbl)

	# Card row
	var cards_container := HBoxContainer.new()
	cards_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cards_container.add_theme_constant_override("separation", 24)
	cards_container.alignment = BoxContainer.ALIGNMENT_CENTER

	# Margin around cards
	var margin := MarginContainer.new()
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_theme_constant_override("margin_left", 48)
	margin.add_theme_constant_override("margin_right", 48)
	margin.add_theme_constant_override("margin_top", 32)
	margin.add_theme_constant_override("margin_bottom", 16)
	margin.add_child(cards_container)
	root.add_child(margin)

	for i in range(SPONSORS.size()):
		var card := _build_sponsor_card(SPONSORS[i], i)
		cards_container.add_child(card)
		_cards.append(card)

	# Bottom bar
	var bottom_bar := PanelContainer.new()
	_style_panel(bottom_bar)
	bottom_bar.custom_minimum_size = Vector2(0, 64)
	root.add_child(bottom_bar)

	var bottom_hbox := HBoxContainer.new()
	bottom_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	bottom_hbox.add_theme_constant_override("separation", 24)
	bottom_bar.add_child(bottom_hbox)

	var back_btn := Button.new()
	back_btn.text = "BACK"
	back_btn.custom_minimum_size = Vector2(140, 40)
	_style_button(back_btn)
	back_btn.pressed.connect(_on_back)
	bottom_hbox.add_child(back_btn)

	_btn_deploy = Button.new()
	_btn_deploy.text = "DEPLOY TO ARENA"
	_btn_deploy.custom_minimum_size = Vector2(200, 40)
	_btn_deploy.disabled = true
	_style_button(_btn_deploy)
	_btn_deploy.pressed.connect(_on_deploy)
	bottom_hbox.add_child(_btn_deploy)


func _build_sponsor_card(sponsor: Dictionary, index: int) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(240, 0)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_card(card, false)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	card.add_child(vbox)

	var name_lbl := Label.new()
	name_lbl.text = sponsor["name"]
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", UITheme.SIZE_3XL)
	name_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	vbox.add_child(name_lbl)

	var sep := HSeparator.new()
	sep.add_theme_color_override("color", COLOR_BORDER)
	vbox.add_child(sep)

	var flavor_lbl := Label.new()
	flavor_lbl.text = sponsor["flavor"]
	flavor_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	flavor_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	flavor_lbl.add_theme_font_size_override("font_size", UITheme.SIZE_BASE)
	flavor_lbl.add_theme_color_override("font_color", Color(0.75, 0.75, 0.8, 1.0))
	vbox.add_child(flavor_lbl)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	vbox.add_child(spacer)

	var req_lbl := Label.new()
	match sponsor.get("type", "kills"):
		"style":
			req_lbl.text = "REQUIREMENT: WIN IN ≤ %d ROUNDS" % sponsor["requirement_rounds"]
		"target":
			req_lbl.text = "REQUIREMENT: EXECUTE %s" % sponsor["requirement_target"]
		_:
			req_lbl.text = "REQUIREMENT: KILL %d" % sponsor["requirement_kills"]
	req_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	req_lbl.add_theme_font_size_override("font_size", UITheme.SIZE_LG)
	req_lbl.add_theme_color_override("font_color", COLOR_ACCENT)
	vbox.add_child(req_lbl)

	var reward_lbl := Label.new()
	reward_lbl.text = "REWARD: +%d CR" % sponsor["reward"]
	reward_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reward_lbl.add_theme_font_size_override("font_size", UITheme.SIZE_BASE)
	reward_lbl.add_theme_color_override("font_color", COLOR_AMBER)
	vbox.add_child(reward_lbl)

	var penalty_lbl := Label.new()
	penalty_lbl.text = "PENALTY: -%d CR" % sponsor["penalty"]
	penalty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	penalty_lbl.add_theme_font_size_override("font_size", UITheme.SIZE_BASE)
	penalty_lbl.add_theme_color_override("font_color", COLOR_RED)
	vbox.add_child(penalty_lbl)

	var spacer2 := Control.new()
	spacer2.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer2)

	var select_btn := Button.new()
	select_btn.text = "SELECT"
	select_btn.custom_minimum_size = Vector2(0, 38)
	_style_button(select_btn)
	select_btn.pressed.connect(_on_select_sponsor.bind(index))
	vbox.add_child(select_btn)

	return card


func _on_select_sponsor(index: int) -> void:
	_selected_index = index
	for i in range(_cards.size()):
		_style_card(_cards[i], i == index)
	_btn_deploy.disabled = false


func _on_deploy() -> void:
	if _selected_index < 0:
		return
	GameState.set_sponsor(SPONSORS[_selected_index])
	get_tree().change_scene_to_file("res://scenes/Battle.tscn")


func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/Management.tscn")


func _style_panel(panel: PanelContainer) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.09, 1.0)
	style.border_color = COLOR_BORDER
	style.set_border_width_all(1)
	panel.add_theme_stylebox_override("panel", style)


func _style_card(card: PanelContainer, selected: bool) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.04, 0.09, 1.0) if selected else Color(0.05, 0.05, 0.09, 1.0)
	style.border_color = COLOR_ACCENT if selected else COLOR_BORDER
	style.set_border_width_all(2 if selected else 1)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	card.add_theme_stylebox_override("panel", style)


func _style_button(btn: Button) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.15, 0.02, 0.04, 1.0)
	normal.border_color = COLOR_RED
	normal.set_border_width_all(2)
	btn.add_theme_stylebox_override("normal", normal)

	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(0.25, 0.04, 0.08, 1.0)
	hover.border_color = COLOR_RED
	hover.set_border_width_all(2)
	btn.add_theme_stylebox_override("hover", hover)

	var disabled := StyleBoxFlat.new()
	disabled.bg_color = Color(0.12, 0.12, 0.14, 1.0)
	disabled.border_color = Color(0.36, 0.36, 0.4, 1.0)
	disabled.set_border_width_all(2)
	btn.add_theme_stylebox_override("disabled", disabled)

	btn.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	btn.add_theme_color_override("font_disabled_color", Color(0.5, 0.5, 0.55, 1.0))
	btn.add_theme_font_size_override("font_size", UITheme.SIZE_BASE)
