shader_type spatial;

render_mode fog_disabled, depth_test_disabled;

uniform vec4 color: source_color;
group_uniforms Ring;
uniform sampler2D ring_texture: repeat_disable;
uniform float ring_emission_strength: hint_range(0.0, 100.0, 0.1);
uniform float ring_threshold: hint_range(0.0, 1.0, 0.01);
uniform float ring_rotation_speed: hint_range(-20.0, 20.0, 0.1);
group_uniforms Rays;
uniform sampler2D rays_texture;
uniform float rays_emission_strength: hint_range(0.0, 100.0, 0.1);
uniform float rays_threshold: hint_range(0.0, 1.0, 0.01);
group_uniforms Center;
uniform sampler2D center_texture: repeat_disable;
uniform float center_emission_strength: hint_range(0.0, 100.0, 0.1);
uniform float center_threshold: hint_range(0.0, 1.0, 0.01);
uniform float center_rotation_speed: hint_range(-20.0, 20.0, 0.1);
uniform float center_scale: hint_range(0.0, 5.0, 0.1);

varying vec2 ring_uv;
varying vec2 center_uv;

vec2 rotate(vec2 uv, vec2 pivot, float angle)
{
	mat2 rotation = mat2(vec2(sin(angle), -cos(angle)),
						vec2(cos(angle), sin(angle)));
	
	uv -= pivot;
	uv = uv * rotation;
	uv += pivot;
	return uv;
}

vec2 scale(vec2 uv, float s)
{
	mat2 scale = mat2(vec2(1.0/s, 0.0), vec2(0.0, 1.0/s));
	
	uv -= 0.5;
	uv = uv * scale;
	uv += 0.5;
	return uv;
}

void vertex() {
	// Make Billboard
	mat4 modified_model_view = VIEW_MATRIX * mat4(
        INV_VIEW_MATRIX[0],
        INV_VIEW_MATRIX[1],
        INV_VIEW_MATRIX[2],
        MODEL_MATRIX[3]
    );
    MODELVIEW_MATRIX = modified_model_view;
	
	ring_uv = rotate(UV, vec2(0.5, 0.5), ring_rotation_speed * TIME);
	center_uv = scale(rotate(UV, vec2(0.5, 0.5), center_rotation_speed * TIME), center_scale);
	
}

void fragment() {
	// RING
	vec4 ring_texture_data = texture(ring_texture, ring_uv);
	if (ring_texture_data.a < (1.0 - ring_threshold)) {
		ring_texture_data.a = 0.0;
	} else {
		ring_texture_data.a *= pow(ring_threshold, 2);
	}
	
	vec3 ring_albedo = ring_texture_data.a * color.rgb;
	float ring_alpha = ring_texture_data.a * color.a;
	vec3 ring_emission = 10000.0 * ring_emission_strength * ring_texture_data.a * color.rgb;
	
	// RAYS
	vec4 rays_texture_data = texture(rays_texture, UV);
	if (rays_texture_data.a < (1.0 - rays_threshold)) {
		rays_texture_data.a = 0.0;
	} else {
		rays_texture_data.a *= pow(rays_threshold, 2);
	}
	
	vec3 rays_albedo = rays_texture_data.a * color.rgb;
	float rays_alpha = rays_texture_data.a * color.a;
	vec3 rays_emission = 10000.0 * rays_emission_strength * rays_texture_data.a * color.rgb;
	
	// CENTER
	vec4 center_texture_data = texture(center_texture, center_uv);
	if (center_texture_data.a < (1.0 - center_threshold)) {
		center_texture_data.a = 0.0;
	} else {
		center_texture_data.a *= pow(center_threshold, 2);
	}
	
	vec3 center_albedo = center_texture_data.a * color.rgb;
	float center_alpha = center_texture_data.a * color.a;
	vec3 center_emission = 10000.0 * center_emission_strength * center_texture_data.a * color.rgb;
	
	ALBEDO = ring_albedo + rays_albedo + center_albedo;
	ALPHA = ring_alpha + rays_alpha + center_alpha;
	EMISSION = ring_emission + rays_emission + center_emission;
}
