shader_type canvas_item;

// Colores
uniform vec4 original_color: source_color;
uniform vec4 new_color: source_color;

// Tolerancia
//uniform float tolerancia = 0.1;
uniform float tolerancia : hint_range(0.0, 1.0);
// Reemplaza el color
vec4 reemplaza_color (vec4 color_textura)	
{
	// Calcula la distancia entre el color actual y el color original
	float distancia = distance(color_textura.rgb, original_color.rgb);
	// Calcula un factor de mezcla basado en la distancia y la tolerancia
	float factor = clamp(1.0 - (distancia / tolerancia), 0.0, 1.0);
	// Mezcla entre el color original y el nuevo color usando el factor
	vec3 color_final = mix(color_textura.rgb, new_color.rgb, factor);
	return vec4(color_final, color_textura.a);
}

void fragment()
{
	vec4 color_textura = texture(TEXTURE, UV);
	COLOR = reemplaza_color(color_textura);
}