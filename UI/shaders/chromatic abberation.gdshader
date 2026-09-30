shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear;
uniform float abb_x: hint_range(-1.0, 1.0) = 0.0;
uniform float abb_y: hint_range(-1.0, 1.0) = 0.0;

void fragment() {
	vec2 pixel_size = 1.0 / vec2(textureSize(SCREEN_TEXTURE, 0));
	vec2 offset = vec2(abb_x * pixel_size.x, abb_y * pixel_size.y) * 100.0;
	
	vec3 final_color;
	final_color.r = texture(SCREEN_TEXTURE, SCREEN_UV + offset).r;
	final_color.g = texture(SCREEN_TEXTURE, SCREEN_UV).g;
	final_color.b = texture(SCREEN_TEXTURE, SCREEN_UV - offset).b;
	
	COLOR.rgb = final_color;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
