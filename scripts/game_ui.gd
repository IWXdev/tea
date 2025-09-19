extends Control

@onready var grid = $GridContainer
var sizes = 4

var empty_texture = preload("res://yy/icon/squars/y_64.png")
var queen_texture = preload("res://yy/icon/crown.png")
var path_texture = preload("res://yy/icon/squars/b_64.png")  # ← المسار

func _ready():
	grid.columns = sizes
	_create_board()



func _create_board():
	for i in range(sizes * sizes):
		var cell = TextureButton.new()
		cell.custom_minimum_size = Vector2(64, 64)
		cell.texture_normal = empty_texture
		cell.toggle_mode = true
		cell.connect("toggled", Callable(self, "_on_cell_toggled").bind(i))
		grid.add_child(cell)

func _on_cell_toggled(pressed: bool, index: int):
	var row = index / sizes
	var col = index % sizes
	var cell = grid.get_child(index)

	if pressed:
		cell.texture_normal = queen_texture
		highlight_path(row, col)
	else:
		cell.texture_normal = empty_texture
		reset_board()  # نرجّع textures للأصل
		

func highlight_path(row:int, col:int):
	# لوّن الصف والعمود
	for i in range(sizes):
		if i != col:
			get_cell(row, i).texture_normal = path_texture
		if i != row:
			get_cell(i, col).texture_normal = path_texture

	# لوّن الأقطار
	for i in range(sizes):
		var r1 = row + i; var c1 = col + i
		var r2 = row - i; var c2 = col - i
		var r3 = row + i; var c3 = col - i
		var r4 = row - i; var c4 = col + i

		if is_inside(r1, c1): get_cell(r1, c1).texture_normal = path_texture
		if is_inside(r2, c2): get_cell(r2, c2).texture_normal = path_texture
		if is_inside(r3, c3): get_cell(r3, c3).texture_normal = path_texture
		if is_inside(r4, c4): get_cell(r4, c4).texture_normal = path_texture

func reset_board():
	for i in range(sizes * sizes):
		var cell = grid.get_child(i)
		if not cell.button_pressed:  # إلا ماشي ملكة
			cell.texture_normal = empty_texture

func is_inside(r:int, c:int) -> bool:
	return r >= 0 and r < sizes and c >= 0 and c < sizes

func get_cell(r:int, c:int) -> TextureButton:
	var index = r * sizes + c
	return grid.get_child(index)
