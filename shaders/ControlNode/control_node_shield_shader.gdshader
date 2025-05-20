// NOTE: Shader automatically converted from Godot Engine 4.4.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_add, depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx;

group_uniforms Albedo;
uniform float alpha : hint_range(0.0, 1.0, 0.01);
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform ivec2 albedo_texture_size;
uniform float point_size : hint_range(0.1, 128.0, 0.1);

group_uniforms Emission;
uniform sampler2D texture_emission : source_color, hint_default_black, filter_linear_mipmap, repeat_enable;
uniform vec4 emission : source_color;
uniform float emission_energy : hint_range(0.0, 1000.0, 0.01);

group_uniforms Dissolve;
uniform sampler2D dissolve_texture : source_color;
uniform float dissolve_value : hint_range(0,1);
uniform float burn_size: hint_range(0.0, 1.0, 0.01);
uniform vec4 burn_color: source_color;

group_uniforms Ripple;
uniform sampler2D ripple_map;
uniform sampler2D ripple_mask;
uniform vec2 ripple_stretch = vec2(1.0, 1.0);
uniform float ripple_strength : hint_range(0.0, 0.1) = 0.02;
uniform float speed : hint_range(0.0, 1.0) = 0.1;

void fragment() {
	vec2 ripple_offset = texture(
		ripple_map,
		vec2(
			mod(UV.x * ripple_stretch.x + TIME * speed, 1.0),
			mod(UV.y * ripple_stretch.y + TIME * speed, 1.0))).xy;
	// Set values between -0.5 and 0.5 (instead of 0 and 1). Otherwise the reflection will move whith increased refraction_strength
	ripple_offset -= 0.5;

	float ripple_factor = texture(ripple_mask, UV).r;

	vec2 ripple_effect = -ripple_offset * ripple_strength * ripple_factor;

	vec4 albedo_tex = texture(texture_albedo, UV + ripple_effect);
	vec4 noise_tex = texture(dissolve_texture, UV);

	float burn_size_step = burn_size * step(0.001, dissolve_value) * step(dissolve_value, 0.999);
	float threshold = smoothstep(noise_tex.x-burn_size_step, noise_tex.x, dissolve_value);
	float border = smoothstep(noise_tex.x, noise_tex.x + burn_size_step, dissolve_value);

	vec3 main_albedo = albedo.rgb * albedo_tex.rgb;

	ALBEDO = mix(burn_color.rgb, main_albedo, border);

	vec3 emission_tex = texture(texture_emission, UV + ripple_effect).rgb;

	float burn_boost = dissolve_value * 200.0;
	if (dissolve_value > 0.1) {
		burn_boost = 20.0;
	}

	EMISSION = mix(burn_color.rgb * burn_boost, emission_tex, border) * emission_energy * 1000.0;
	ALPHA *= alpha * albedo.a * albedo_tex.a * threshold;
}

void light() {
	DIFFUSE_LIGHT = vec3(1.0, 1.0, 1.0);
}
