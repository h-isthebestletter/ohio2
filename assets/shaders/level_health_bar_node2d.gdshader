shader_type canvas_item;

uniform float fraction: hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec4 fill_color = vec4(0.835, 0.251, 0.345, 1.0);
	vec4 background_color = vec4(0.059, 0.043, 0.188, 1.0);

	if (UV.x < fraction) {
		COLOR = fill_color;
	} else {
		COLOR = background_color;
	}
}
