shader_type spatial;

uniform sampler2D base_texture : source_color;
uniform sampler2D decal_texture : source_color;

uniform sampler2D base_normal : hint_normal;

uniform float decal_opacity : hint_range(0.0, 1.0) = 0.5;

uniform float specular = 0.2;
uniform float roughness = 0.8;
uniform float metallicity = 0.3;

void fragment() {

	vec3 base_color_vec;
	vec3 base_normal_vec;
	vec3 decal_color_vec;
	float decal_alpha_channel;

	base_color_vec = texture(base_texture, UV).rgb;
	base_normal_vec = texture(base_normal, UV).rgb;

	decal_color_vec = texture(decal_texture, UV2).rgb;
	decal_alpha_channel = texture(decal_texture, UV2).a;

	ALBEDO = base_color_vec * (1.0 - decal_opacity * decal_alpha_channel) + decal_color_vec * decal_alpha_channel * (1.0 - decal_opacity);

	NORMAL_MAP = base_normal_vec;
}