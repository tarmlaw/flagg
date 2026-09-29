shader_type canvas_item;

uniform vec4 flash_color: source_color;
uniform float strength = 0;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	color = mix(color, flash_color, strength * color.a);

	COLOR = color;
}
