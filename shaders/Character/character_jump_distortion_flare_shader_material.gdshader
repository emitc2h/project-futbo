shader_type spatial;

render_mode blend_add, fog_disabled, cull_disabled, shadows_disabled, ambient_light_disabled;

uniform sampler2D screen_texture : hint_screen_texture;
uniform bool enabled;
uniform sampler2D noise_texture;
uniform sampler2D mask_texture;

uniform float noise_speed: hint_range(0.0, 1.0);
uniform float noise_intensity: hint_range(0.0, 1.0);
uniform float stretch: hint_range(0.01, 2.0);

uniform vec3 flare_color: source_color;
uniform float flare_threshold: hint_range(0.0, 1.0);

void vertex() {
	UV2 = vec2(1.0, stretch) * (UV + vec2(0.0, -(noise_speed/stretch) * TIME));
}

void fragment() {
	if (enabled) {
		float noise = texture(noise_texture, UV2).r;
		float mask = texture(mask_texture, UV).r;
		
		vec3 output_color = vec3(0.0, 0.0, 0.0);

		if (noise > flare_threshold) {
			float flare_factor = 1.0 - (noise - flare_threshold)/(1.0 - flare_threshold);
			ALBEDO = flare_color * pow(flare_factor, 4);
			EMISSION = flare_color * 800000.0 * pow(flare_factor, 4) * mask;
			ALPHA = mask;
		} else {
			ALPHA = 0.0;
		}
		
	} else {
		ALPHA = 0.0;
	}
}
