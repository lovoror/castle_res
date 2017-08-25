#ifdef GL_ES
precision lowp float;
#endif

uniform vec4 global_color;
varying vec2 v_texCoord;
varying vec2 v_texCoord2;

void main() {
	vec4 baseColor = texture2D(CC_Texture1, v_texCoord2);
    vec4 blendColor = global_color * texture2D(CC_Texture0, v_texCoord);
    
    //blendColor.xyz /= blendColor.w;
	if (baseColor.r < 0.5) {
		gl_FragColor.r = 2.0 * baseColor.r * blendColor.r;
	} else {
		gl_FragColor.r = 1.0 - 2.0 * (1.0 - blendColor.r) * (1.0 - baseColor.r);
	}
	if (baseColor.g < 0.5) {
		gl_FragColor.g = 2.0 * baseColor.g * blendColor.g;
	} else {
		gl_FragColor.g = 1.0 - 2.0 * (1.0 - blendColor.g) * (1.0 - baseColor.g);
	}
	if (baseColor.b < 0.5) {
		gl_FragColor.b = 2.0 * baseColor.b * blendColor.b;
	} else {
		gl_FragColor.b = 1.0 - 2.0 * (1.0 - blendColor.b) * (1.0 - baseColor.b);
	}
		
	//gl_FragColor.xyz = baseColor.xyz + (gl_FragColor.xyz - baseColor.xyz) * blendColor.w;
	gl_FragColor.w = blendColor.w;
	gl_FragColor.xyz *= blendColor.w;
}