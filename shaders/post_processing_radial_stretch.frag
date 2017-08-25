#ifdef GL_ES
varying mediump vec2 v_texCoord;
#else
varying vec2 v_texCoord;
#endif

uniform vec4 params;
 
void main(void) {
	vec2 uv = v_texCoord * 2 - 1;
	vec2 pix = uv * params.xy;
	float len = sqrt(pix.x * pix.x + pix.y * pix.y);
	float r = len / params.z;
	vec2 nrm = normalize(-uv);
	uv += nrm * r * r * params.w;
	uv = (uv + 1) * 0.5;
	
	gl_FragColor = texture2D(CC_Texture0, uv);
}