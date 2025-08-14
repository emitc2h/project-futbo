// NOTE: Shader automatically converted from Godot Engine 4.4.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_add, cull_disabled, depth_draw_opaque;

group_uniforms Texture;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;

group_uniforms Color;
uniform vec4 color : source_color;

group_uniforms Emission;
uniform float emission_factor : hint_range(0.0, 1000.0, 1.0);

group_uniforms Animation;
uniform float window_size: hint_range(0.0, 1.0, 0.05) = 0.1;
uniform float slide_value: hint_range(0.0, 1.0, 0.001) = 0.5;
uniform bool use_time = true;
uniform float speed: hint_range(0.0, 5.0, 0.01) = 1.0;
uniform bool use_instance = true;
uniform bool reverse = false;

void vertex() {
	COLOR = INSTANCE_CUSTOM;
}

void fragment() {
	vec2 base_uv = UV;

	vec4 albedo_tex = texture(texture_albedo, UV);

	vec3 visible_tex = color.rgb * albedo_tex.a;
	float visible_alpha = color.a * albedo_tex.a;

	float time;
	if (use_instance) {
		time = COLOR.y;
	} else {
		time = TIME;
	}

	float time_sign;
	if (reverse) {
		time_sign = -1.0;
	} else {
		time_sign = 1.0;
	}

	float _slide_value;
	if (use_time) {
		_slide_value = mod(speed * time_sign * time, 1.0);
	} else {
		_slide_value = slide_value;
	}

	float expanded_slide_value = _slide_value * (1.0 + 2.0 * window_size) - window_size;

	if (albedo_tex.r < expanded_slide_value - window_size) {
		visible_alpha = 0.0;
	}

	if (albedo_tex.r > expanded_slide_value + window_size) {
		visible_alpha = 0.0;
	}

	ALBEDO = visible_tex;
	EMISSION = visible_tex * emission_factor * 10000.0;

	ALPHA *= visible_alpha;
}
