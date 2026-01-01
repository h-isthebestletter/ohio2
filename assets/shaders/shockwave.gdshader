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

vec4 shrapnel(float speed, sampler2D noise, float time, vec2 uv) {
	vec2 polar_uv = polar_coordinates(uv, vec2(0.5), 0.4, 1.0);
	return vec4(step(0.7, texture(noise, polar_uv).r));
}

void vertex() {
	MODULATE = COLOR;
}

void fragment() {
	vec4 shrapnel_color =
		shrapnel(1.0, NOISE, ADJUSTED_TIME, UV)
		* blast_circle(1.6, ADJUSTED_TIME, UV)
	;
	vec4 blast_circle_color = blast_circle(0.7, ADJUSTED_TIME, UV) * 1.5;

	COLOR = (shrapnel_color + blast_circle_color) / 1.5;

	COLOR *= MODULATE;
}
