// NOTE: Shader automatically converted from Godot Engine 4.4.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_add, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D texture_emission : source_color, hint_default_black, filter_linear_mipmap, repeat_enable;
uniform float emission_energy : hint_range(0.0, 1000.0, 0.1);
uniform vec3 emission_color : source_color;

void fragment() {
	// Emission: Enabled
	vec3 emission_tex = texture(texture_emission, UV).rgb;
	vec3 emission_tex_colored = emission_tex;

	emission_tex_colored = emission_color * emission_tex.r;

	// Emission Operator: Add
	ALBEDO = emission_tex_colored;
	EMISSION = emission_tex_colored * emission_energy * 1000.0;
	ALPHA *= emission_tex.r;
	ALPHA_SCISSOR_THRESHOLD = 0.001;
}
