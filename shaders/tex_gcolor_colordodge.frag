#ifdef GL_ES
precision lowp float;
#endif

uniform vec4 global_color;
varying vec2 v_texCoord;
varying vec2 v_texCoord2;

void main() {
	vec4 baseColor = texture2D(CC_Texture1, v_texCoord2);
    vec4 blendColor = global_color * texture2D(CC_Texture0, v_texCoord);
    //gl_FragColor = baseColor / (1.0 - blendColor);
    gl_FragColor.xyz = baseColor.xyz * blendColor.xyz / (1.0 - blendColor.xyz);
    gl_FragColor.w = blendColor.w;
}