shader_type canvas_item;

uniform float outline_width : hint_range(0.0, 1.0) = 0.02;
uniform vec4  outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Calculate distance to edges
    float dist_to_edge = min(
        min(UV.x, 1.0 - UV.x),
        min(UV.y, 1.0 - UV.y)
    );
    
    // Smooth step for anti-aliasing
    float edge_factor = smoothstep(0.0, outline_width, dist_to_edge);
    
    // Mix colors between outline and texture
    vec4 final_color = mix(outline_color, tex_color, edge_factor);

    // Apply the modulate color from the node
    COLOR = final_color * COLOR;
}
