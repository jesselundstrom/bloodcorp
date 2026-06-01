shader_type canvas_item;

uniform float opacity : hint_range(0.0, 1.0) = 0.08;

void fragment() {
	float line = mod(FRAGCOORD.y, 2.0);
	float scanline = step(1.0, line);
	COLOR = vec4(0.0, 0.0, 0.0, scanline * opacity);
}
