shader_type spatial;
render_mode cull_disabled;

uniform int mode = 0;
uniform float points_factor: hint_range(0.0, 10.0, 0.1) = 5.0;
uniform float lines_factor: hint_range(0.0, 10.0, 0.1) = 1.0;

uniform sampler2D freqs;
uniform sampler2D image;
uniform int freqs_length = 16;

void vertex() {
	vec4 txt = texture(image, UV);
	float w = (txt.r + txt.g + txt.b) / 3.0;
	
	if (mode == 0) {
		VERTEX.y = texture(freqs, vec2(UV.x, 0)).x * points_factor * w;
	} else {
		VERTEX.y = texture(freqs, vec2(UV.x, 0)).x * lines_factor;
	}
}

void fragment() {
	vec4 txt = texture(image, UV);
	vec4 freq = texture(freqs, vec2(UV.x, 0));
	
	ALBEDO = txt.rgb;
	ALPHA = 1.0 / (3.0 - clamp(txt.r + txt.g + txt.b, 0.0, 1.0));
	if (ALPHA < 0.36) {
		ALPHA = 0.0;
	}
    ROUGHNESS = 1.0;
    SPECULAR = 0.0;
    METALLIC = 0.0;
}