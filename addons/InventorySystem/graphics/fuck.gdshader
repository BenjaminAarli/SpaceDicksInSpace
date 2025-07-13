shader_type canvas_item;

uniform sampler2D texture_albedo :
	source_color,
	filter_linear_mipmap,
	repeat_enable;

uniform vec2 node_size = vec2(0.0);  // Pixel Size of each grid slot.
uniform vec2 grid_size = vec2(1.0);
uniform vec2 offset = vec2(0.0);
uniform sampler2D grid_color;

vec2 get_grid_pos(vec2 pos){
	return floor(pos / (node_size / grid_size));
}

void fragment(){
	vec4 albedo_tex = texture(texture_albedo, UV * grid_size);
	vec2 pixel_pos = UV * node_size;

	vec2 pixel_size = (floor(UV * grid_size) + 0.5) / grid_size;
    vec2 grid_pos = get_grid_pos(pixel_pos);
	COLOR = albedo_tex + texture(grid_color, pixel_size);
}