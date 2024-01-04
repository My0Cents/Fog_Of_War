extends Control

const SCALE_DOWN = 4
signal fow_updated 
@onready var fow_tick_timer: Timer  = $fog_tick
@onready var fow_viewport: SubViewport = $SubViewportContainer/SubViewport
@onready var fow_camera: Camera2D = $SubViewportContainer/SubViewport/fow_camera
@onready var fow_sprite2D: Sprite2D = $SubViewportContainer/SubViewport/fow_texture
@onready var fow_units_treenode: Node2D = $SubViewportContainer/SubViewport/fow_units



var fow_explored : Array
var fow_main_image : Image
var fow_main_texture : ImageTexture
var fow_viewport_texture: ImageTexture

var map_rect: Rect2
var world_offset : Vector2

var fow_units_data : Dictionary = {}

var dissolve_sprite:Texture2D = preload("res://fow_sprite.png")


# Called when the node enters the scene tree for the first time.
func _ready():
	# We don't want the fow_sprite to be centered.
	fow_sprite2D.centered = false
	
	fow_tick_timer.timeout.connect(fow_tick_loop)
	fow_tick_timer.start()
	#new_fow(Rect2(0,0,1024,512))


func fow_tick_loop() -> void:
	fow_units_data_process()
	fow_dissolve_all_fow_units()
	fow_viewport_texture = ImageTexture.create_from_image(
		fow_viewport.get_texture().get_image()
	)
	emit_signal("fow_updated")

func new_fow(map_size: Vector2, _world_offset) -> void:
	map_rect = Rect2(Vector2.ZERO, map_size)
	world_offset =  _world_offset
	# Set Viewport and Camera new sizes
	fow_viewport.size = map_rect.size
	(fow_viewport.get_parent() as SubViewportContainer).size = map_rect.size
	fow_camera.position = Vector2.ZERO + map_rect.size*0.5
	
	fow_main_image = Image.create(
		int(map_rect.size.x),
		int(map_rect.size.y),
		false,
		Image.FORMAT_RGBA8)
		
		
	# Fow's main image is just a black image.
	fow_main_image.fill(Color(0.0,0.0,0.0,1.0))
	update_texture()

# Update the texture of fow depending on the unit.

func update_texture() -> void:
	fow_main_texture = ImageTexture.create_from_image(fow_main_image)
	fow_sprite2D.set_texture(fow_main_texture)

func fow_dissolve(dissolve_position: Vector2, dissolve_image:Image) -> void:
	var dissolve_image_used_rect: Rect2 = dissolve_image.get_used_rect()
	dissolve_position -= dissolve_image_used_rect.size * 0.5
	
	fow_main_image.blend_rect(dissolve_image, dissolve_image_used_rect, dissolve_position)
	update_texture()
	
func fow_units_data_process() -> void:
	for unit_id in fow_units_data.keys():
		var unit_data:Array = (fow_units_data[unit_id] as Array)
		
		var position_to_2D:Vector2 = Vector2(
		(unit_data[0] as Node3D).global_position.x - world_offset.x, (unit_data[0] as Node3D).global_position.z - world_offset.y)
		(unit_data[1] as Sprite2D).set_position(position_to_2D)
		
func fow_dissolve_all_fow_units() -> void:
	for fow_sprite in fow_units_treenode.get_children():
		var fow_sprite_image:Image = (fow_sprite as Sprite2D).get_texture().get_image()
		
		var sprite_stored_position_size:Vector3i = Vector3i(
			
			(fow_sprite as Sprite2D).position.x, 
			(fow_sprite as Sprite2D).position.y,
			(fow_sprite as Sprite2D).get_texture().get_size().x)
			
		if !sprite_stored_position_size in fow_explored:
			var dissolve_position:Vector2 = (fow_sprite as Sprite2D).position
			fow_dissolve(dissolve_position, fow_sprite_image)
			fow_explored.append(sprite_stored_position_size)
			
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
