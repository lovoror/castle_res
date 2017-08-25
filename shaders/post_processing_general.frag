#ifdef GL_ES
varying mediump vec2 v_texCoord;
#else
varying vec2 v_texCoord;
#endif
 
void main(void) {
	gl_FragColor = texture2D(CC_Texture0, v_texCoord);
}