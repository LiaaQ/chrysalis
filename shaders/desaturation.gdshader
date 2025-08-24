shader_type canvas_item;

uniform float desaturation : hint_range(0.0, 1.0) = 0.7; // 1 = full grayscale, 0 = normal color

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    // Convert to grayscale using luminance
    float gray = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));

    // Mix original color with grayscale based on desaturation level
    tex_color.rgb = mix(tex_color.rgb, vec3(gray), 0.7);

    COLOR = tex_color * texture(TEXTURE, UV).a;
}