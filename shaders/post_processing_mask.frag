#ifdef GL_ES
varying mediump vec2 v_texCoord;
#else
varying vec2 v_texCoord;
#endif
 
void main(void) {
	vec4 c0 = texture2D(CC_Texture0, v_texCoord);
	vec4 c1 = texture2D(CC_Texture1, v_texCoord);
	
	//if (c1.w > 0) {
		//float c = (c1.x + c1.y + c1.z) / 3;
		//c0 *= c;
	//}
	c0 *= 1 - c1.w;
	
	gl_FragColor = c0;
}