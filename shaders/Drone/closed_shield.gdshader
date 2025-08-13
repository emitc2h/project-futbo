shader_type spatial;
render_mode blend_add, depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx;

group_uniforms Albedo;
uniform sampler2D texture_albedo : source_color;
uniform float albedo_uv_drift: hint_range(0.0, 1.0);

group_uniforms Alpha;
uniform sampler2D texture_alpha_mask : source_color;
uniform float alpha: hint_range(0.0, 1.0);

group_uniforms Emission;
uniform float emission_energy;

group_uniforms Dissolve;
uniform sampler2D dissolve_texture : source_color;
uniform float dissolve_value_in : hint_range(0,1);
uniform float dissolve_value_out : hint_range(0,1);
uniform float dissolve_uv_drift: hint_range(0.0, 1.0);

uniform float burn_size: hint_range(0.0, 1.0, 0.01);
uniform vec4 burn_color: source_color;
uniform float burn_boost: hint_range(1.0, 100.0);

void fragment() {

	vec2 rotating_uv = UV + vec2(albedo_uv_drift * TIME, 0.0);
	vec2 counter_rotating_uv = vec2(-UV.x, UV.y) + vec2(albedo_uv_drift * TIME, 0.0);
	vec2 dissolve_uv = UV + vec2(dissolve_uv_drift * TIME, 0.0);

	vec4 albedo_tex_1 = texture(texture_albedo, rotating_uv);
	vec4 albedo_tex_2 = texture(texture_albedo, counter_rotating_uv);
	vec4 alpha_tex = texture(texture_alpha_mask, UV);

	vec4 dissolve_in_tex = texture(dissolve_texture, dissolve_uv);
	float burn_size_step_in = burn_size * step(0.001, dissolve_value_in) * step(dissolve_value_in, 0.999);
	float threshold_in = smoothstep(dissolve_in_tex.x-burn_size_step_in, dissolve_in_tex.x, dissolve_value_in);
	float border_in = smoothstep(dissolve_in_tex.x, dissolve_in_tex.x + burn_size_step_in, dissolve_value_in);

	vec4 dissolve_out_tex = texture(dissolve_texture, vec2(-dissolve_uv.x, -dissolve_uv.y));
	float burn_size_step_out = burn_size * step(0.001, dissolve_value_out) * step(dissolve_value_out, 0.999);
	float threshold_out = smoothstep(dissolve_out_tex.x-burn_size_step_in, dissolve_out_tex.x, dissolve_value_out);
	float border_out = smoothstep(dissolve_out_tex.x, dissolve_out_tex.x + burn_size_step_out, dissolve_value_out);

	vec3 main_albedo = (albedo_tex_1.rgb + albedo_tex_2.rgb);

	ALBEDO = mix(burn_color.rgb, mix(burn_color.rgb, main_albedo, border_in), border_out);

	float burn_boost_in = (1.0 - dissolve_value_in) * burn_boost;
	//if (dissolve_value_in > 0.1) {
		//burn_boost_in = 20.0;
	//}

	float burn_boost_out = dissolve_value_out * burn_boost;
	//if (dissolve_value_in < 0.9) {
		//burn_boost_out = 20.0;
	//}

	//EMISSION = mix(burn_color.rgb * burn_boost, emission_tex, border) * emission_energy * 1000.0;
	//ALPHA *= alpha * albedo.a * albedo_tex.a * threshold;

	EMISSION = 1000.0 * emission_energy * mix(burn_color.rgb * burn_boost_out, mix(burn_color.rgb * burn_boost_in, main_albedo, border_in), border_out);

	ALPHA *= alpha * (albedo_tex_1.a + albedo_tex_2.a) * alpha_tex.r * threshold_in * threshold_out;
}
