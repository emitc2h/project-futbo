shader_type spatial;

render_mode unshaded, fog_disabled;

uniform sampler2D screen_texture : hint_screen_texture;
uniform sampler2D noise_texture;
uniform sampler2D mask_texture;

uniform float noise_speed: hint_range(0.0, 1.0);
uniform float noise_intensity: hint_range(0.0, 1.0);

void vertex() {
	UV2 = UV + vec2(0.0, -noise_speed * TIME);
}

void fragment() {
	float noise = texture(noise_texture, UV2).r;
	float mask = texture(mask_texture, UV).r;
	ALBEDO = texture(screen_texture, SCREEN_UV + 0.02 * mask * noise_intensity * noise).rgb;
}
