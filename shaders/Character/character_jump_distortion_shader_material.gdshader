shader_type spatial;

render_mode unshaded, fog_disabled;

uniform sampler2D screen_texture : hint_screen_texture;

uniform bool enabled;
uniform bool billboard;
uniform sampler2D noise_texture;
uniform sampler2D mask_texture;

uniform float noise_speed: hint_range(0.0, 1.0);
uniform float noise_intensity: hint_range(0.0, 1.0);
uniform float stretch: hint_range(0.01, 2.0);

void vertex() {
	if (enabled) {
		UV2 = vec2(1.0, stretch) * (UV + vec2(0.0, -(noise_speed/stretch) * TIME));
	}
	
	if (billboard) {
		// Make Billboard
		mat4 modified_model_view = VIEW_MATRIX * mat4(
        	INV_VIEW_MATRIX[0],
        	INV_VIEW_MATRIX[1],
        	INV_VIEW_MATRIX[2],
        	MODEL_MATRIX[3]
    	);
    	MODELVIEW_MATRIX = modified_model_view;
	}
	
}

void fragment() {
	if (enabled) {
		float noise = texture(noise_texture, UV2).r;
		float mask = texture(mask_texture, UV).r;
		ALBEDO = texture(screen_texture, SCREEN_UV + 0.2 * mask * noise_intensity * (noise - 0.5)).rgb;
	} else {
		ALPHA = 0.0;
	}
}
