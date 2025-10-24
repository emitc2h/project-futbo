shader_type spatial;

render_mode unshaded, fog_disabled, depth_test_disabled;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D mask_texture;

// Controls the intensity of the distortion (higher values = more distortion)
uniform float power : hint_range(-1.0, 5.0, 0.0001) = 0.0;

varying vec2 screen_node_position;

void vertex() {
	// Make Billboard
	mat4 modified_model_view = VIEW_MATRIX * mat4(
        INV_VIEW_MATRIX[0],
        INV_VIEW_MATRIX[1],
        INV_VIEW_MATRIX[2],
        MODEL_MATRIX[3]
    );
    MODELVIEW_MATRIX = modified_model_view;
	
	// Compute the position of the center of the quad
	vec4 view_node_position = (PROJECTION_MATRIX * vec4(NODE_POSITION_VIEW, 1.0));
	screen_node_position = view_node_position.xy / (2.0 * view_node_position.w);
}

void fragment() {
	float mask = texture(mask_texture, UV).r;
	
	vec2 quad_to_screen = vec2(0.5, 0.5) + screen_node_position;
	vec2 uv = SCREEN_UV - quad_to_screen;
	float dist = distance(SCREEN_UV - vec2(0.5, 0.5), screen_node_position);
	float warp = 1.0 - mask * pow(dist, power);
	vec2 warp_uv = uv * warp + quad_to_screen;
	
	vec3 albedo = texture(screen_texture, warp_uv).rgb;
	
	ALBEDO = albedo;
}
