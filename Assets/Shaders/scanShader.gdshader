shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float intensity = 0.0;

void fragment()
{
	vec4 bg = texture(screen_texture, SCREEN_UV);
	float avg = (bg.r + bg.g + bg.b) / 3.0;
	COLOR = vec4(avg, avg/2.0, avg/2.0, intensity);
}