shader_type canvas_item;

uniform sampler2D texture_albedo :
	source_color,
	filter_linear_mipmap,
	repeat_enable;

uniform vec2 tiling = vec2(1.0);
uniform vec2 offset = vec2(0.0);
uniform vec2 badzone = vec2(1.0);

void vertex(){
	UV = UV * tiling + offset * TIME;
}

void fragment(){
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo, base_uv);
	albedo_tex *= COLOR;
	COLOR = COLOR.rgba * vec4(albedo_tex.rgb, 1.0);
}