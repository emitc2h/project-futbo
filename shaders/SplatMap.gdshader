shader_type spatial;

uniform sampler2D red_channel_texture:source_color;
uniform sampler2D green_channel_texture:source_color;
uniform sampler2D blue_channel_texture:source_color;

uniform sampler2D red_channel_normal:hint_normal;
uniform sampler2D green_channel_normal:hint_normal;
uniform sampler2D blue_channel_normal:hint_normal;

uniform sampler2D splatmap;

uniform float red_tiling_factor = 10.0;
uniform float green_tiling_factor = 10.0;
uniform float blue_tiling_factor = 10.0;

uniform float specular = 0.5;
uniform float roughness = 0.75;

void fragment() {
	vec3 red_color;
	vec3 green_color;
	vec3 blue_color;

	vec3 red_normal;
	vec3 green_normal;
	vec3 blue_normal;

	vec3 splatmap_color;

	splatmap_color = texture(splatmap, UV).rgb;

	red_color = texture(red_channel_texture, UV * red_tiling_factor).rgb * splatmap_color.r;
	green_color = texture(green_channel_texture, UV * green_tiling_factor).rgb * splatmap_color.g;
	blue_color = texture(blue_channel_texture, UV * blue_tiling_factor).rgb * splatmap_color.b;

	ALBEDO = red_color + green_color + blue_color;

	red_normal = texture(red_channel_normal, UV * red_tiling_factor).rgb * splatmap_color.r;
	green_normal = texture(green_channel_normal, UV * green_tiling_factor).rgb * splatmap_color.g;
	blue_normal = texture(blue_channel_normal, UV * blue_tiling_factor).rgb * splatmap_color.b;

	NORMAL_MAP = red_normal + green_normal + blue_normal;

	SPECULAR = specular;
	ROUGHNESS = roughness;
}