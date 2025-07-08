// NOTE: Shader automatically converted from Godot Engine 4.4.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_add, depth_draw_opaque, cull_disabled, unshaded;

uniform sampler2D texture_albedo : source_color;
uniform sampler2D noise_alpha: source_color;

uniform vec4 color_begin: source_color;
uniform vec4 color_end: source_color;
uniform float noise_speed: hint_range(0.0, 3.0);
uniform float noise_intensity: hint_range(0.0, 100.0);

void vertex() {
	UV2 = UV + vec2(0.0, noise_speed * TIME);
}

void fragment() {
	vec4 albedo_tex = texture(texture_albedo, UV);
	vec4 colored_tex = albedo_tex * (UV.y * color_begin + (1.0 - UV.y) * color_end);

	vec4 noise_tex = texture(noise_alpha, UV2);

	ALBEDO = colored_tex.rgb;
	ALPHA = noise_intensity * noise_tex.r * albedo_tex.a;
}
