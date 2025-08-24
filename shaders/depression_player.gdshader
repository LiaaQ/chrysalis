shader_type canvas_item;

uniform bool flash_white = false;
uniform float saturation_level : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 tex_color = texture(TEXTURE, UV);
	float gray = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
	vec3 saturated_color = mix(vec3(gray), tex_color.rgb, saturation_level);

	vec3 final_color = flash_white
        ? mix(saturated_color, vec3(1.0), 0.4) // 40% white
        : saturated_color;

	COLOR = vec4(final_color, tex_color.a);
}
