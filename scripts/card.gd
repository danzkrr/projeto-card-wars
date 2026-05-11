extends Panel

@export var data: CardData = null

@onready var label: Label = $VBoxContainer/TopBar/Label
@onready var sprite: TextureRect = $VBoxContainer/ArtContainer

var is_dragging: bool = false
var original_position: Vector2
var original_parent: Node

func _ready():
	original_position = position
	mouse_filter = Control.MOUSE_FILTER_PASS
	
	if data:
		print("Carta pronta: ", data.card_name)

	setup_card()

func setup_card() -> void:
	if not data:
		print("Sem dados da carta")
		return
	
	label.text = data.card_name
	
	if data.card_texture:
		sprite.texture = data.card_texture

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			start_drag()
		else:
			end_drag()

func start_drag():
	is_dragging = true
	original_position = position
	original_parent = get_parent()

	reparent(get_tree().get_root())
	z_index = 10

func end_drag():
	if not is_dragging: return

	is_dragging = false

	var landed_zone = get_zone_at_mouse()

	if landed_zone:
		if landed_zone.team == BoardZone.Team.PLAYER:
			spawn_creature(landed_zone)
		else:
			print("Essa zona é inimigo!")
			return_to_hand()
	else:
		return_to_hand()

func get_zone_at_mouse() -> BoardZone:
	var mouse = get_global_mouse_position()

	for zone in get_tree().get_nodes_in_group("board_zone"):
		if zone.get_rect().has_point(mouse):
			return zone
	return null

func return_to_hand():
	reparent(original_parent)
	position = original_position
	z_index = 0

func spawn_creature(zone: BoardZone):
	if not data or not data.card_scene:
		print("Sem dados da carta")
		return_to_hand()
		return

	var card = data.card_scene.instantiate()
	zone.get_parent().add_child(card)
	card.global_position = get_global_mouse_position()
	queue_free()

func _process(_delta: float) -> void:
	if is_dragging:
		global_position = get_global_mouse_position() - (size * scale) / 2
