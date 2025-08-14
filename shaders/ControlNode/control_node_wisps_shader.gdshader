// NOTE: Shader automatically converted from Godot Engine 4.4.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

uniform sampler2D texture_albedo : source_color;
uniform float emission_energy;

void fragment() {
	vec4 albedo_tex = texture(texture_albedo, UV);

	// Vertex Color Use as Albedo: Enabled
	albedo_tex *= COLOR;

	ALBEDO = albedo_tex.rgb;

	// Emission Operator: Add
	EMISSION = COLOR.rgb * emission_energy * 1000.0;
	ALPHA *= albedo_tex.a;
}
