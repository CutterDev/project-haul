shader_type spatial;

// Exposes a color picker in the Inspector
uniform vec4 albedo_color : source_color = vec4(1.0, 0.0, 0.0, 0.5); // Default: Red

void fragment() {
	// Assign the RGB color to the material surface
	ALBEDO = albedo_color.rgb;
	
	// Force complete opacity
	ALPHA = albedo_color.a;
}