shader_type spatial;
render_mode unshaded;

uniform sampler2D fog_texture : repeat_disable;

uniform float texSize;
uniform vec2 world_offset;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;

varying mat4 CAMERA;

void vertex() {
	POSITION = vec4(VERTEX, 1.0);
	CAMERA = INV_VIEW_MATRIX;
}



void fragment() {
    vec4 original_color = textureLod(screen_texture, SCREEN_UV, 0.0);
	
	ALBEDO = original_color.rgb;
	//ALBEDO= vec3(1.0);
    float depth = textureLod(depth_texture, SCREEN_UV, 0.0).r;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 world = CAMERA * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	vec3 world_position = world.xyz / world.w;
	
	vec2 uv = (world_position.xz-world_offset)/texSize;
	vec4 texture_fow = texture(fog_texture, uv);
	ALBEDO = ALBEDO*texture_fow.rgb;
}





