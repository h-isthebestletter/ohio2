shader_type canvas_item;

uniform int ATLAS_WIDTH = 2;
uniform int ATLAS_HEIGHT = 2;
uniform sampler2D ATLAS: filter_nearest;

varying flat int texture_id;

void vertex() {
	texture_id = int(INSTANCE_CUSTOM.a);
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 atlas_width_height = vec2(float(ATLAS_WIDTH), float(ATLAS_HEIGHT));
	vec2 uv_increment = vec2(1.0) / atlas_width_height;
	ivec2 xy = ivec2(texture_id % ATLAS_WIDTH, texture_id / ATLAS_WIDTH);

	vec2 uv = vec2(xy) * uv_increment + (UV / atlas_width_height);
	COLOR = texture(ATLAS, uv);
}
