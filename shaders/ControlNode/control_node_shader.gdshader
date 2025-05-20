// NOTE: Shader automatically converted from Godot Engine 4.4.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

group_uniforms Parameters;
uniform vec4 emission_color: source_color;

group_uniforms Albedo;
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform ivec2 albedo_texture_size;
uniform float point_size : hint_range(0.1, 128.0, 0.1);

group_uniforms Roughness;
uniform sampler2D texture_roughness : hint_roughness_r, filter_linear_mipmap, repeat_enable;
uniform float roughness : hint_range(0.0, 1.0);

group_uniforms Metallic;
uniform sampler2D texture_metallic : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec4 metallic_texture_channel;
uniform float metallic : hint_range(0.0, 1.0, 0.01);

uniform float specular : hint_range(0.0, 1.0, 0.01);

group_uniforms Emission;
uniform sampler2D texture_emission : source_color, hint_default_black, filter_linear_mipmap, repeat_enable;
uniform vec4 emission : source_color;
uniform float emission_energy : hint_range(0.0, 10000.0, 1.0);

group_uniforms Normal;
uniform sampler2D texture_normal : hint_roughness_normal, filter_linear_mipmap, repeat_enable;
uniform float normal_scale : hint_range(-16.0, 16.0);

void fragment() {
	vec2 base_uv = UV;

	vec4 albedo_tex = texture(texture_albedo, base_uv);
	if (albedo_tex.g > 0.6) {
		albedo_tex = vec4(0.0, 0.0, 0.0, 0.0);
	}
	ALBEDO = albedo.rgb * albedo_tex.rgb;

	float metallic_tex = dot(texture(texture_metallic, base_uv), metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	SPECULAR = specular;

	vec4 roughness_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);
	float roughness_tex = dot(texture(texture_roughness, base_uv), roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;

	// Normal Map: Enabled
	NORMAL_MAP = texture(texture_normal, base_uv).rgb;
	NORMAL_MAP_DEPTH = normal_scale;

	// Emission: Enabled
	vec3 emission_tex = texture(texture_emission, base_uv).rgb;
	if (emission_tex.g > 0.6) {
		emission_tex = emission_color.rgb;
	}

	// Emission Operator: Add
	EMISSION = (emission.rgb + emission_tex) * emission_energy * 100.0;
}
