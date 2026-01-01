shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform float ADJUSTED_TIME = 0.0;
uniform float STRENGTH: hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec4 sample = texture(SCREEN_TEXTURE, SCREEN_UV);
	float adjusted_strength = ADJUSTED_TIME * 0.5;
	float gray = 0.21 * sample.r + 0.71 * sample.g + 0.07 * sample.b;
	COLOR = vec4(sample.rgb * (1.0 - adjusted_strength) + (0.5 * gray * adjusted_strength), sample.a);
}
