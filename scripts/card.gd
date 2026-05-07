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

	var board = get_tree().get_first_node_in_group("board")
	
	var is_on_board = false
	if board:
		# StaticBody2D não tem get_global_rect(), então calculamos a área manualmente (128x128 centralizado)
		var board_rect = Rect2(board.global_position - Vector2(64, 64), Vector2(128, 128))
		is_on_board = board_rect.has_point(get_global_mouse_position())

	if is_on_board:
		spawn_creature(board)
	else:
		reparent(original_parent)
		position = original_position
		z_index = 0

func spawn_creature(board: Node):
	if not data or not data.card_scene:
		print("Sem dados da carta")
		return

	var spawn_pos = get_global_mouse_position()

	var card = data.card_scene.instantiate()

	board.get_parent().add_child(card)
	card.global_position = spawn_pos
	
	queue_free()

func _process(_delta: float) -> void:
	if is_dragging:
		global_position = get_global_mouse_position() - (size * scale) / 2

	