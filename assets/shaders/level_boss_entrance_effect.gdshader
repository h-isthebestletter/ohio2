shader_type canvas_item;

varying vec4 MODULATE;
uniform sampler2D NOISE;
uniform float ADJUSTED_TIME;

vec2 polar_coordinates(vec2 uv, vec2 center, float zoom, float repeat) {
	vec2 dir = uv - center;
	float radius = length(dir) * 2.0;
	float angle = atan(dir.y, dir.x) * 1.0/(3.1416 * 2.0);
	return mod(vec2(radius * zoom, angle * repeat), 1.0);
}

vec4 blast_circle(float speed, float time, vec2 uv) {
	float dist = length(uv - vec2(0.5));
	float alpha = smoothstep(time * speed - 0.1, time * speed, dist)
		* smoothstep(time * speed - 0.3, time * speed, dist) * 2.0 * (0.5 - dist);
	return vec4(1.0, 1.0, 1.0, alpha);
}

vec4 growing_filled_circle(float speed, float time, vec2 uv) {
	float dist = length(uv - vec2(0.5));
	float alpha = smoothstep(time * speed, time * speed - 0.1, dist);
	return vec4(1.0, 1.0, 1.0, alpha);
}

vec4 shrapnel(float speed, sampler2D noise, float time, vec2 uv) {
	vec2 polar_uv = polar_coordinates(uv, vec2(0.5), 0.4, 1.0);
	return vec4(step(0.7, texture(noise, polar_uv).r));
}

vec4 whirlpool(float speed, float time, vec2 uv) {
	float angle = atan(-uv.y + 0.5, uv.x - 0.5) + mod(time * time * speed, PI);
	float len = length(uv - vec2(0.5));
	float amount = sin(len * 32.0 + angle * 6.0);
	return vec4(amount, amount, amount, 0.6) * 2.0 * (0.4 - len);
}

float delay_time(float time, float delay) {
	return max(0.0, time - delay);
}

void vertex() {
	MODULATE = COLOR;
}

void fragment() {
	float delayed_time = delay_time(ADJUSTED_TIME, 4.0);

	vec4 whirlpool_color =
		whirlpool(0.7, ADJUSTED_TIME, UV)
		* growing_filled_circle(1.0, ADJUSTED_TIME, UV)
		//* smoothstep(1.0, 2.0, ADJUSTED_TIME)
		* smoothstep(4.0, 3.8, ADJUSTED_TIME)
	;
	vec4 shrapnel_color =
		shrapnel(1.0, NOISE, delayed_time, UV)
		* blast_circle(1.6, delayed_time, UV)
	;
	vec4 blast_circle_color = blast_circle(0.7, delayed_time, UV) * 1.5;

	if (ADJUSTED_TIME <= 4.0) {
		COLOR = whirlpool_color;
	} else {
		COLOR = (shrapnel_color + blast_circle_color) / 1.5;
	}

	COLOR *= MODULATE;
}
