shader_type spatial;
render_mode cull_disabled;

uniform sampler2D surface;
uniform float strength;
uniform sampler2D freqs;
uniform int freqs_length;

void vertex() {
	float h = sqrt(pow(VERTEX.x, 2) + pow(VERTEX.z, 2));
	
	float a2d = atan(VERTEX.z / VERTEX.x);
	float a3d = acos(VERTEX.y / h);
	
	float a = (a2d + a3d) / (4.0 * 3.1415);
	
	vec4 ft = texture(freqs, vec2(a, 0));
	
	VERTEX.xyz *= ft.x * strength;
}

void fragment() {
	vec4 txt = texture(surface, UV);
	ALBEDO.rgb = txt.rgb;
	ALPHA = txt.a;
}
