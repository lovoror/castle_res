#ifdef GL_ES
precision lowp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform mat3 hue_mat;

void main()
{
    gl_FragColor = texture2D(CC_Texture0, v_texCoord);
    gl_FragColor.xyz = hue_mat * gl_FragColor.xyz;
    gl_FragColor = v_fragmentColor * gl_FragColor;
}