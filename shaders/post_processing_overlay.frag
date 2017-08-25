#ifdef GL_ES
varying mediump vec2 v_texCoord;
#else
varying vec2 v_texCoord;
#endif
 
void main(void) {
	vec4 baseColor = texture2D(CC_Texture1, v_texCoord);
    vec4 blendColor = texture2D(CC_Texture0, v_texCoord);
    
	vec3 c;
	if (baseColor.r < 0.5) {
		c.r = 2.0 * baseColor.r * blendColor.r;
	} else {
		c.r = 1.0 - 2.0 * (1.0 - blendColor.r) * (1.0 - baseColor.r);
	}
	if (baseColor.g < 0.5) {
		c.g = 2.0 * baseColor.g * blendColor.g;
	} else {
		c.g = 1.0 - 2.0 * (1.0 - blendColor.g) * (1.0 - baseColor.g);
	}
	if (baseColor.b < 0.5) {
		c.b = 2.0 * baseColor.b * blendColor.b;
	} else {
		c.b = 1.0 - 2.0 * (1.0 - blendColor.b) * (1.0 - baseColor.b);
	}
	
	c *= blendColor.w;

	gl_FragColor.xyz = c.xyz + (1.0 - blendColor.w) * baseColor.xyz;
	gl_FragColor.w = baseColor.w;
}