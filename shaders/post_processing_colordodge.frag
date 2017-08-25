#ifdef GL_ES
varying mediump vec2 v_texCoord;
#else
varying vec2 v_texCoord;
#endif
 
void main(void) {
	vec4 baseColor = texture2D(CC_Texture1, v_texCoord);
    vec4 blendColor = texture2D(CC_Texture0, v_texCoord);
	vec3 c = baseColor.xyz * blendColor.xyz / (1.0 - blendColor.xyz);

    gl_FragColor.xyz = c.xyz + baseColor.xyz;
    gl_FragColor.w = baseColor.w;
}