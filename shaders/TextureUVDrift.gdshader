// NOTE: Shader automatically converted from Godot Engine 4.3.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, cull_back, diffuse_burley, specular_schlick_ggx;

group_uniforms Albedo;
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;

group_uniforms Backlight;
uniform vec4 backlight : source_color;
uniform sampler2D texture_backlight : hint_default_black, filter_linear_mipmap, repeat_enable;

group_uniforms UVDrift;
uniform float uvx_drift_speed : hint_range(-100, 100, 1);
uniform float uvy_drift_speed : hint_range(-100, 100, 1);

void vertex() {
	UV = UV + vec2(uvx_drift_speed * TIME / 3600.0, uvy_drift_speed * TIME / 3600.0);
}

void fragment() {
	vec4 albedo_tex = texture(texture_albedo, UV);
	ALBEDO = albedo.rgb * albedo_tex.rgb;

	ALPHA *= albedo.a * albedo_tex.a;

	// Backlight: Enabled
	vec3 backlight_tex = texture(texture_backlight, UV).rgb;
	BACKLIGHT = (backlight.rgb + backlight_tex);
}
