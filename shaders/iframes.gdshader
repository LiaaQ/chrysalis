shader_type canvas_item;

uniform bool flash_white = false;

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 tex_color = texture(TEXTURE, UV);

	if (flash_white) {
        COLOR = mix(tex_color, vec4(1.0, 1.0, 1.0, tex_color.a), 0.4);
    } else {
        COLOR = tex_color;
    }
}
