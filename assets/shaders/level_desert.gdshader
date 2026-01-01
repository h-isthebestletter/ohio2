shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D DISTORT_NOISE;
uniform sampler2D SAND_NOISE;

const float DISTORT_AMOUNT = 0.0015;
const float DISTORT_ZOOM = 1.2;
const float DISTORT_SPEED = 0.1;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 MAIN_COLOR = COLOR;

	float distort_noise = texture(DISTORT_NOISE, vec2(
		fract(SCREEN_UV.x * DISTORT_ZOOM - TIME * DISTORT_SPEED),
		SCREEN_UV.y * DISTORT_ZOOM
	)).x;

	distort_noise = smoothstep(0.11, 0.45, distort_noise);

	vec2 distort_uv = vec2(distort_noise, distort_noise) * DISTORT_AMOUNT;

	float sand_noise_1 = texture(SAND_NOISE, vec2(
		fract(UV.x - TIME * 0.8),
		fract(UV.y + TIME * 0.055)
	) + distort_uv).x;

	float sand_noise_2 = texture(SAND_NOISE, vec2(
		fract(UV.x * 1.2 - TIME * 0.4),
		fract(UV.y * 1.2 + TIME * 0.06)
	) + distort_uv).x;

	float sand_noise_3 = texture(SAND_NOISE, vec2(
		fract(UV.x * 0.8 - TIME * 0.6),
		fract(UV.y * 0.8 + TIME * 0.035)
	) + distort_uv).x;

	float final_sand_noise = sand_noise_1 * 0.233 * sand_noise_2 * 0.433 + sand_noise_3 * 0.333;

	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV + distort_uv);
	COLOR += MAIN_COLOR * mix(0.2, 1.0, final_sand_noise);
}
