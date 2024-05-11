shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

uniform float wave_speed = 3.0; //wave loop speed
uniform float wave_freq = 10.0; //wave vertical freq
uniform float wave_width = 1; //wave width 

void fragment(){
	vec2 scale_UV = SCREEN_UV;
	vec2 wave_uv_offset;
	wave_uv_offset.x = cos((TIME * wave_speed) + UV.x + UV.y * wave_freq * 2.0) * wave_width * 0.01;
	wave_uv_offset.y = cos((UV.x * wave_freq * 2.0 + TIME * wave_speed) + UV.y) * wave_width * 0.005;
	
	COLOR = texture(screen_texture, scale_UV+wave_uv_offset);
}