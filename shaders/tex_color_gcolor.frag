#ifdef GL_ES
precision lowp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

uniform vec4 global_color;

void main()
{
    gl_FragColor = texture2D(CC_Texture0, v_texCoord) * global_color * v_fragmentColor;
}