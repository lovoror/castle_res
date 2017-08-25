#ifdef GL_ES
varying mediump vec2 v_texCoord;
#else
varying vec2 v_texCoord;
#endif

uniform vec2 params;
 
void main(void) {
	vec4 c0 = texture2D(CC_Texture0, v_texCoord);
	vec4 c1 = texture2D(CC_Texture0, vec2(v_texCoord.x - params.x, v_texCoord.y));
	vec4 c2 = texture2D(CC_Texture0, vec2(v_texCoord.x + params.x, v_texCoord.y));
	vec4 c3 = texture2D(CC_Texture0, vec2(v_texCoord.x, v_texCoord.y - params.y));
	vec4 c4 = texture2D(CC_Texture0, vec2(v_texCoord.x, v_texCoord.y + params.y));
	
	gl_FragColor = (c0 + c1 + c2 + c3 + c4) / 5;
}