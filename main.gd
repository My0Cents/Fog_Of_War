extends Node3D

@onready var terrain = $StaticBody3D/MeshInstance3D


@onready var unit = $CharacterBody3D
@onready var fow = $fog_of_war_texture
@onready var mesh_view:MeshInstance3D = $Camera/MeshInstance3D

var dissolve_sprite:Texture2D = preload("res://fow_sprite.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	var terrain_aabb = terrain.get_aabb()
	var world_size: Vector2i = Vector2i(terrain_aabb.size[0],terrain_aabb.size[2]) 
	var texSize: float = world_size[0] # Meters in 3D, pixels in 2D Map(representation)
	var offset_3d:Vector3 = (terrain.get_parent() as StaticBody3D).global_transform*terrain_aabb.position
	var world_offset = Vector2(offset_3d.x,offset_3d.z)
	
	fow.new_fow(world_size, world_offset)
	add_unit_fow(unit)
	fow.fow_updated.connect(
		func () ->void :
			var fow_material: ShaderMaterial = mesh_view.get_active_material(0)
			fow_material.set_shader_parameter("fog_texture", fow.fow_viewport_texture)
			fow_material.set_shader_parameter("texSize", texSize)
			fow_material.set_shader_parameter("world_offset", world_offset)
	)








func add_unit_fow(fow_node3D:Node3D) -> void:
	var new_sprite:Sprite2D = Sprite2D.new()
	new_sprite.set_texture(get_new_dissolve_image_texture(64))
	fow.fow_units_treenode.add_child(new_sprite)
	fow.fow_units_data[ fow_node3D.get_instance_id() ] = [fow_node3D, new_sprite]
	

func get_new_dissolve_image_texture(size:int) -> ImageTexture:
	var dissolve_image:Image = (dissolve_sprite.get_image() as Image)
	
	dissolve_image.resize(size,size)
	return ImageTexture.create_from_image(dissolve_image)
